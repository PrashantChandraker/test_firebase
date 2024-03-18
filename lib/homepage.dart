import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_firebase/retrivepage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  final picker = ImagePicker();
  bool _uploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() {
      _uploading = true;
    });

    try {
      // Upload image to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().toString()}.png');
      final uploadTask = ref.putFile(_imageFile!);

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });
      await uploadTask;

      // Fetch the download URL of the uploaded image
      String imageUrl = await ref.getDownloadURL();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image uploaded successfully'),
      ));

      // Navigate to the Retrievepage and pass the image URL as a parameter
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Retrivepage(imageUrl: imageUrl)),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to upload image'),
      ));
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text('Image Upload'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              /*
              Container(
                  height: 500,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: Image.file(
                          _imageFile!,
                        ),
                        fit: BoxFit.fill),
                  ),
                ),
               */

              children: <Widget>[
                _imageFile == null
                    ? const Text('No image selected.')
                    : Container(
                        height: 500,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(4),
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        minimumSize: MaterialStateProperty.all(
                            Size.square(50)), // Adjust the size as needed
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                      ),
                      onPressed: _pickImage,
                      child: const Text(
                        'Pick Image',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(4),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                        minimumSize: MaterialStateProperty.all(
                            Size.square(50)), // Adjust the size as needed
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                      ),
                      onPressed: _uploading ? null : _uploadImage,
                      child: _uploading
                          ? CircularProgressIndicator() // Show circular progress indicator while uploading
                          : const Text(
                              'Upload Image',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(4),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    minimumSize: MaterialStateProperty.all(
                        Size.square(50)), // Adjust the size as needed
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Retrivepage(
                            imageUrl: '',
                          ),
                        ));
                  },
                  child: const Text(
                    'Retrive Image',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),

                // ElevatedButton(
                //   onPressed: _uploadImage,
                //   child: const Text('Upload Image'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
