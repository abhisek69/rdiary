import 'dart:io';
import 'dart:typed_data'; // ✅ correct

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rdiary/screens/addSubject/scribble_canvas_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../widgets/mood_selector.dart';

class AddNoteForm extends StatefulWidget {
  final DateTime? selectedDate;

  const AddNoteForm({super.key, this.selectedDate});

  @override
  State<AddNoteForm> createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<AddNoteForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _showDrawing = false;
  bool _isUploading = false;
  Uint8List? _drawingImage;
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  Map<String, dynamic>? _drawingData;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maximum 3 images allowed")));
      return;
    }

    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      final remainingSlots = 3 - _selectedImages.length;

      setState(() {
        _selectedImages.addAll(
          images.take(remainingSlots).map((e) => File(e.path)),
        );
      });
    }
  }

  Future<List<String>> _uploadImages(String noteId) async {
    List<String> imageUrls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];

      final ref = FirebaseStorage.instance
          .ref()
          .child('notes')
          .child(noteId)
          .child('image_$i.jpg');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }

    return imageUrls;
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty &&
        _drawingImage == null &&
        _selectedImages.isEmpty) {
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

    final id = const Uuid().v4();

    try {
      setState(() => _isUploading = true);

      List<String> imageUrls = [];

      /// Upload selected gallery images
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages(id);
      }

      /// Upload drawing as PNG if exists
      if (_drawingImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('notes')
            .child(id)
            .child('drawing.png');

        await ref.putData(_drawingImage!);
        final drawingUrl = await ref.getDownloadURL();

        imageUrls.add(drawingUrl);
      }

      /// Save note in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(id)
          .set({
            'title':
                _titleController.text.isEmpty ? null : _titleController.text,
            'content': _contentController.text,
            'date': Timestamp.fromDate(
              DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
              ),
            ),
            'mood': _selectedMood ?? "neutral",
            'images': imageUrls,
            'createdAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note saved successfully! 🎉"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving note: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

          const SizedBox(height: 20),
          //TODO add photos
          // const Text(
          //   "Add Photos (Max 3)",
          //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          // ),
          //
          // const SizedBox(height: 10),
          //
          // Wrap(
          //   spacing: 10,
          //   children: [
          //     ..._selectedImages.map((image) => Stack(
          //       children: [
          //         ClipRRect(
          //           borderRadius: BorderRadius.circular(10),
          //           child: Image.file(
          //             image,
          //             width: 90,
          //             height: 90,
          //             fit: BoxFit.cover,
          //           ),
          //         ),
          //         Positioned(
          //           right: 0,
          //           top: 0,
          //           child: GestureDetector(
          //             onTap: () {
          //               setState(() {
          //                 _selectedImages.remove(image);
          //               });
          //             },
          //             child: const CircleAvatar(
          //               radius: 12,
          //               backgroundColor: Colors.red,
          //               child: Icon(Icons.close,
          //                   size: 14, color: Colors.white),
          //             ),
          //           ),
          //         ),
          //       ],
          //     )),
          //
          //     if (_selectedImages.length < 3)
          //       GestureDetector(
          //         onTap: _pickImages,
          //         child: Container(
          //           width: 90,
          //           height: 90,
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(10),
          //             border: Border.all(color: Colors.grey),
          //           ),
          //           child: const Icon(Icons.add_a_photo, size: 30),
          //         ),
          //       ),
          //   ],
          // ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title (Optional)',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // ✍️ Content
          const Text(
            "Your Thoughts",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _contentController,
            maxLines: null,
            minLines: 8,
            decoration: const InputDecoration(
              hintText: 'Write your thoughts... ✍️',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),
          //TODO add scribble support
          // GestureDetector(
          //   onTap: () {
          //     setState(() {
          //       _showDrawing = !_showDrawing;
          //     });
          //   },
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(12),
          //       color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         const Text(
          //           "Add Drawing",
          //           style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //         Icon(
          //           _showDrawing
          //               ? Icons.keyboard_arrow_up
          //               : Icons.keyboard_arrow_down,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          //
          // AnimatedCrossFade(
          //   duration: const Duration(milliseconds: 300),
          //   crossFadeState: _showDrawing
          //       ? CrossFadeState.showFirst
          //       : CrossFadeState.showSecond,
          //   firstChild: Padding(
          //     padding: const EdgeInsets.only(top: 16),
          //     child: ScribbleCanvasWidget(
          //       onImageExported: (imageBytes) {
          //         setState(() {
          //           _drawingImage = imageBytes;
          //         });
          //       },
          //     ),
          //   ),
          //   secondChild: const SizedBox.shrink(),
          // ),
          // // 💾 Save Button
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "Save Note",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
