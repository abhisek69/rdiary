import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rdiary/screens/addSubject/scribble_canvas_widget.dart';
import 'package:scribble/scribble.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/note.dart';
import '../../models/supabase_helper.dart';
import '../../widgets/mood_selector.dart';

class AddNoteForm extends StatefulWidget {
  final DateTime? selectedDate;
  final Note? existingNote;

  const AddNoteForm({super.key, this.selectedDate, this.existingNote});

  @override
  State<AddNoteForm> createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<AddNoteForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _showDrawing = false;
  bool _isUploading = false;
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  List<String> _existingImageUrls = [];
  final List<String> _pendingDeletions = [];
  late ScribbleNotifier _scribbleNotifier;

  @override
  void initState() {
    super.initState();
    _scribbleNotifier = ScribbleNotifier();
    
    if (widget.existingNote != null) {
      debugPrint('[RDIARY][MEDIA][FETCH] Pre-filling note data for edit. noteId: ${widget.existingNote!.id}');
      _titleController.text = widget.existingNote!.title ?? "";
      _contentController.text = widget.existingNote!.content;
      _selectedDate = widget.existingNote!.date;
      _selectedMood = widget.existingNote!.mood;
      
      // Filter out the drawing preview from the photos list to avoid confusion in the UI
      _existingImageUrls = List<String>.from(widget.existingNote!.drawingPaths ?? [])
          .where((url) => !url.contains('drawing_preview.png'))
          .toList();
      
      if (widget.existingNote!.drawingData != null) {
        try {
          final sketch = Sketch.fromJson(jsonDecode(widget.existingNote!.drawingData!));
          _scribbleNotifier.setSketch(sketch: sketch);
          _showDrawing = true;
        } catch (e) {
          debugPrint("[RDIARY][DRAWING] Error loading drawing data: $e");
        }
      }
    } else {
      _selectedDate = widget.selectedDate ?? DateTime.now();
    }
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length + _existingImageUrls.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 3 images allowed")),
      );
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      debugPrint('[RDIARY][PHOTO] User selected ${images.length} photo(s)');
      final remainingSlots = 3 - (_selectedImages.length + _existingImageUrls.length);

      setState(() {
        _selectedImages.addAll(
          images.take(remainingSlots).map((e) => File(e.path)),
        );
      });
    }
  }

  Future<List<String>> _uploadPhotos(String noteId, String uid) async {
    List<String> imageUrls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photo_${timestamp}_$i.jpg';
      
      // users/{uid}/notes/{noteId}/photos/{fileName}
      final path = 'users/$uid/notes/$noteId/photos/$fileName';

      final url = await SupabaseHelper.uploadFile(file, path, noteId: noteId);
      if (url != null) {
        imageUrls.add(url);
      }
    }

    return imageUrls;
  }

  Future<void> _saveNote() async {
    final hasDrawing = _scribbleNotifier.currentSketch.lines.isNotEmpty;

    if (_contentController.text.trim().isEmpty &&
        !hasDrawing &&
        _selectedImages.isEmpty &&
        _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note can't be empty!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final noteId = widget.existingNote?.id ?? const Uuid().v4();

    try {
      debugPrint('[RDIARY][MEDIA] Saving note with media...');
      setState(() => _isUploading = true);

      // 1. Perform pending deletions from Supabase
      if (_pendingDeletions.isNotEmpty) {
        debugPrint('[RDIARY][SUPABASE][DELETE] Clearing ${_pendingDeletions.length} pending deletions');
        for (final url in _pendingDeletions) {
          await SupabaseHelper.deleteFile(url);
        }
      }

      List<String> finalImageUrls = List.from(_existingImageUrls);

      // 2. Upload new gallery photos
      if (_selectedImages.isNotEmpty) {
        debugPrint('[RDIARY][MEDIA] Adding new photos: ${_selectedImages.length}');
        final newUrls = await _uploadPhotos(noteId, user.uid);
        finalImageUrls.addAll(newUrls);
      }

      String? drawingDataJson;
      String? drawingPreviewUrl = widget.existingNote?.drawingPreviewUrl;

      // 3. Handle digital drawing
      if (hasDrawing) {
        debugPrint('[RDIARY][DRAWING] Preparing drawing for upload...');
        // Save raw vector data for editing
        drawingDataJson = jsonEncode(_scribbleNotifier.currentSketch.toJson());

        // Render PNG preview for the feed
        final imageBytes = await _scribbleNotifier.renderImage();
        if (imageBytes != null) {
          final fileName = 'drawing_preview.png';
          // users/{uid}/notes/{noteId}/drawings/{fileName}
          final path = 'users/${user.uid}/notes/$noteId/drawings/$fileName';

          final url = await SupabaseHelper.uploadBytes(
            imageBytes.buffer.asUint8List(),
            path,
            noteId: noteId,
          );
          if (url != null) {
            drawingPreviewUrl = url;
          }
        }
      } else if (widget.existingNote?.drawingPreviewUrl != null) {
        debugPrint('[RDIARY][SUPABASE][DELETE] Drawing cleared, removing from storage');
        await SupabaseHelper.deleteFile(widget.existingNote!.drawingPreviewUrl!);
        drawingPreviewUrl = null;
      }

      // 4. Update Firestore with new Supabase references
      debugPrint('[RDIARY][FIRESTORE] Saving media reference...');
      final noteData = {
        'title': _titleController.text.isEmpty ? null : _titleController.text,
        'content': _contentController.text,
        'date': Timestamp.fromDate(
          DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          ),
        ),
        'mood': _selectedMood ?? "neutral",
        'drawingPaths': finalImageUrls,
        'drawingData': drawingDataJson,
        'drawingPreviewUrl': drawingPreviewUrl,
        'updatedAt': Timestamp.now(),
      };

      if (widget.existingNote == null) {
        noteData['createdAt'] = Timestamp.now();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .set(noteData, SetOptions(merge: true));

      debugPrint('[RDIARY][FIRESTORE] Media reference saved SUCCESS');
      debugPrint('[RDIARY][MEDIA] Note save SUCCESS');

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note saved successfully! 🎉"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      if (mounted) {
        Get.back();
      }
    } catch (e) {
      debugPrint('[RDIARY][MEDIA] Note save FAILED');
      debugPrint('error: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving note: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _scribbleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📅 Date Display
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 😊 Mood Selector
          const Text(
            "How are you feeling today?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          MoodSelector(
            selectedMoodId: _selectedMood,
            onSelected: (moodId) {
              setState(() {
                _selectedMood = moodId;
              });
            },
          ),

          const SizedBox(height: 24),
          
          /// 🖼 Attachment Section
          const Text(
            "Memory Photos",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Existing Images (Cloud)
              ..._existingImageUrls.map(
                (url) => Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('[RDIARY][FIRESTORE] Marking photo for removal: $url');
                          setState(() {
                            _existingImageUrls.remove(url);
                            _pendingDeletions.add(url);
                          });
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // New Local Images
              ..._selectedImages.map(
                (image) => Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.remove(image);
                          });
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_selectedImages.length + _existingImageUrls.length < 3)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600),
                        const SizedBox(height: 4),
                        Text("Add", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          TextField(
            controller: _titleController,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: 'Note Title',
              hintText: 'Enter a title (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),

          const SizedBox(height: 16),

          // ✍️ Content
          const Text(
            "Daily Story",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _contentController,
            maxLines: null,
            minLines: 8,
            decoration: const InputDecoration(
              hintText: 'Write your heart out... ✍️',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),

          const SizedBox(height: 30),
          
          /// 🎨 Drawing Toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _showDrawing = !_showDrawing;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primary.withOpacity(0.08),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.brush_rounded, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        "Digital Sketchpad",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Icon(
                    _showDrawing ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showDrawing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ScribbleCanvasWidget(
                notifier: _scribbleNotifier,
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _saveNote,
              icon: _isUploading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  widget.existingNote == null ? "Save Entry" : "Update Entry",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
