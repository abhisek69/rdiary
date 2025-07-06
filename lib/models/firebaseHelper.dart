import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadFileToFirebase(File file, String path) async {
  try {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    print("Upload error: $e");
    return null;
  }
}