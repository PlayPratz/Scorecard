import 'dart:io';

import 'package:image_picker/image_picker.dart';

class _ImagePickerHandler {
  Future<void> initialize() async {}

  Future<File?> pickPhotoFromGallery() async {
    final pickedPhoto =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedPhoto == null) {
      return null;
    }
    return File(pickedPhoto.path);
  }
}

// ignore: non_constant_identifier_names
final ImagePickerHandler = _ImagePickerHandler();
