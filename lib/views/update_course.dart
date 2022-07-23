// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateCourseScreen extends StatefulWidget {
  String documentId;
  String courseTitle;
  String courseDescription;
  String courseImage;

  UpdateCourseScreen({
    Key? key,
    required this.documentId,
    required this.courseTitle,
    required this.courseDescription,
    required this.courseImage,
  }) : super(key: key);

  @override
  State<UpdateCourseScreen> createState() => _UpdateCourseScreenState();
}

class _UpdateCourseScreenState extends State<UpdateCourseScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _courseImage;
  String? imageUrl;

  _chooseImage() async {
    final ImagePicker _picker = ImagePicker();
    _courseImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  //for update data in the firebase storage:
  updateData(selectedDocument) async {
    FirebaseStorage _storage = FirebaseStorage.instance;


    if (_courseImage == null) {
      CollectionReference _course =
          FirebaseFirestore.instance.collection("Courses");

      _course.doc(selectedDocument).update({
        'course_title': _titleController.text,
        'course_description': _descriptionController.text,
        'image': widget.courseImage
      });
      print("Successfully added");
      Navigator.pop(context);
    } else {
      File _imageFile = File(_courseImage!.path);
      UploadTask _uploadTask =
          _storage.ref("images").child(_courseImage!.name).putFile(_imageFile);
      TaskSnapshot _taskSnapshot = await _uploadTask;
      imageUrl = await _taskSnapshot.ref.getDownloadURL();
      print("image url: ${imageUrl}");
      CollectionReference _courseRef =
          FirebaseFirestore.instance.collection("Courses");

      _courseRef.doc(selectedDocument).update({
        'course_title': _titleController.text,
        'course_description': _descriptionController.text,
        'image': imageUrl
      });
      print("Successfully added");
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.courseTitle;
    _descriptionController.text = widget.courseDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, top: 20),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  hintText: "Enter course title",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: "Enter course description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 14),
            Expanded(
              child: SizedBox(
                child: Center(
                  child: SizedBox(
                    child: _courseImage == null
                        ? Image.network(
                            widget.courseImage,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(
                              _courseImage!.path,
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _chooseImage,
              icon: Icon(Icons.photo_camera),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => updateData(widget.documentId),
                  child: Text("Update course"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                    onPressed: _chooseImage, child: Text("Select image"))
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
