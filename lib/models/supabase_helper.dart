import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static const String bucketName = 'rDiary-images';

  /// Uploads a physical file (e.g. from ImagePicker)
  static Future<String?> uploadFile(File file, String path, {String? noteId}) async {
    try {
      debugPrint('[RDIARY][SUPABASE][UPLOAD] Starting photo upload');
      debugPrint('noteId: ${noteId ?? 'N/A'}');
      debugPrint('path: $path');
      
      final supabase = Supabase.instance.client;
      
      await supabase.storage.from(bucketName).upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final url = supabase.storage.from(bucketName).getPublicUrl(path);
      debugPrint('[RDIARY][SUPABASE][UPLOAD] Photo upload SUCCESS');
      debugPrint('url: $url');
      return url;
    } catch (e) {
      debugPrint('[RDIARY][SUPABASE][UPLOAD] Photo upload FAILED');
      debugPrint('error: $e');
      return null;
    }
  }

  /// Uploads raw bytes (e.g. from Scribble canvas)
  static Future<String?> uploadBytes(List<int> bytes, String path, {String? noteId}) async {
    try {
      debugPrint('[RDIARY][SUPABASE][UPLOAD] Starting drawing upload');
      debugPrint('noteId: ${noteId ?? 'N/A'}');
      debugPrint('path: $path');
      
      final supabase = Supabase.instance.client;
      
      await supabase.storage.from(bucketName).uploadBinary(
        path,
        Uint8List.fromList(bytes),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final url = supabase.storage.from(bucketName).getPublicUrl(path);
      debugPrint('[RDIARY][SUPABASE][UPLOAD] Drawing upload SUCCESS');
      debugPrint('url: $url');
      return url;
    } catch (e) {
      debugPrint('[RDIARY][SUPABASE][UPLOAD] Drawing upload FAILED');
      debugPrint('error: $e');
      return null;
    }
  }

  /// Deletes a file from storage given its public URL or internal path
  static Future<bool> deleteFile(String pathOrUrl) async {
    try {
      debugPrint('[RDIARY][SUPABASE][DELETE] Starting media deletion');
      debugPrint('target: $pathOrUrl');
      
      final supabase = Supabase.instance.client;
      
      String path = pathOrUrl;
      if (pathOrUrl.startsWith('http')) {
        // Extract relative path from public URL
        final uri = Uri.parse(pathOrUrl);
        final segments = uri.pathSegments;
        final bucketIndex = segments.indexOf(bucketName);
        if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
          path = segments.sublist(bucketIndex + 1).join('/');
        }
      }

      await supabase.storage.from(bucketName).remove([path]);
      debugPrint('[RDIARY][SUPABASE][DELETE] Media deleted from Storage SUCCESS');
      return true;
    } catch (e) {
      debugPrint('[RDIARY][SUPABASE][DELETE] Media deletion FAILED');
      debugPrint('error: $e');
      return false;
    }
  }
}
