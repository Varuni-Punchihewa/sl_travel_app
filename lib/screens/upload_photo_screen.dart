import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

//https://images.google.com/searchbyimage?image_url=https://i.ibb.co/XxjfF59/donkeypng-donkey-png-273-491.png

//const imgbbAPIKey = '3459fcd562cee3e42fc0089be694906d';
const baseURL = 'https://images.google.com/searchbyimage?image_url=';

class UploadPhoto extends StatefulWidget {
  @override
  _UploadPhotoState createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  File _imageFile;
  String publicImgUrl;
  dynamic _pickImageError;
  String _retrieveDataError;

  void _onImageButtonPressed(ImageSource source) async {
    try {
      _imageFile = await ImagePicker.pickImage(source: source);
      setState(() {});
    } catch (e) {
      _pickImageError = e;
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.image) {
        setState(() {
          _imageFile = response.file;
        });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  Widget uploadImagePreview() {
    return Column(
      children: <Widget>[
        Image.file(_imageFile),
        FlatButton(
          child: Text('Upload'),
          onPressed: () {},
        )
      ],
    );
  }

  _launchURL() async {
    String url = '$baseURL$publicImgUrl';
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future uploadPic() async {
    ///Get only the image name
    String fileName = basename(_imageFile.path);

    ///Get the firebase storage reference for the image file
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);

    ///Upload the image file to the firebase
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);

    ///Wait till the image file is uploaded to the firebase completely
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    var downloadUrl = await taskSnapshot.ref.getDownloadURL();
    String url = downloadUrl.toString();
    setState(() {
      publicImgUrl = url;
      print("Profile Picture uploaded");
      print(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: _imageFile == null
                    ? Text('No image selected.')
                    : Image.file(_imageFile),
              ),
              Expanded(
                flex: 1,
                child: FlatButton(
                  child: Text('Upload'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(0.0),
                  splashColor: Colors.blue[100],
                  onPressed: () async {
                    print(_imageFile);

                    /// Convert the image into base64 encode
//                    List<int> imageBytes = _imageFile.readAsBytesSync();
//                    String base64Image = base64Encode(imageBytes);
//                    print(base64Image);
                    ///Upload the image into firebase
                    await uploadPic();

                    /// Open the web view on the browser
                    await _launchURL();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery);
            },
            heroTag: 'image0',
            tooltip: 'Pick Image from gallery',
            child: Icon(Icons.photo_library),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}
