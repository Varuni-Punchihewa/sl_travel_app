import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:sl_travel_app/services/networking.dart';

//https://images.google.com/searchbyimage?image_url=https://i.ibb.co/XxjfF59/donkeypng-donkey-png-273-491.png
//https://images.google.com/searchbyimage?image_url=https://live.staticflickr.com/65535/48843248352_377d10aa73_s.jpg
const imgbbAPIKey = '3459fcd562cee3e42fc0089be694906d';

class UploadPhoto extends StatefulWidget {
  @override
  _UploadPhotoState createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  File _imageFile;
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

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
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
//                    List<int> imageBytes = _imageFile.readAsBytesSync();
//                    String base64Image = base64Encode(imageBytes);
//                    print(base64Image);
                    String URL =
                        'https://api.imgbb.com/1/upload?key=$imgbbAPIKey?image=iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
                    NetworkHelper networkHelper = NetworkHelper(URL);

                    var decodedData = await networkHelper.postData();
                    print(decodedData);
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

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
