import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scanwords/pages/details_page.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File pickedImage;

  var result = '';
  bool isImageLoad = false;

  Future getImageFromGallery() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(tempStore.path);
      isImageLoad = true;
    });
  }

  Future getImageFromCamera() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      pickedImage = File(tempStore.path);
      isImageLoad = true;
    });
  }

  Future readTextFromAnImage() async {
    showDialog(
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ),
        context: context);
    result = '';
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizerText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizerText.processImage(myImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            result = result + ' ' + word.text;
          });

          print(word.text);
        }
      }
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          textDetails: result,
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scan Words'),
          actions: [
            IconButton(
              onPressed: () {
                clear();
              },
              icon: Icon(Icons.delete),
              iconSize: 25,
            ),
            IconButton(
              onPressed: () {
                getImageFromCamera();
              },
              icon: Icon(Icons.add_a_photo),
              iconSize: 25,
            ),
            IconButton(
              icon: Icon(Icons.camera_roll_outlined),
              iconSize: 25,
              onPressed: () {
                getImageFromGallery();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            isImageLoad != false
                ? Center(
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      child: PhotoView(
                        backgroundDecoration:
                            BoxDecoration(color: Colors.transparent),
                        imageProvider: FileImage(pickedImage),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 15,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (isImageLoad == false) {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                          'Por favor selecione uma imagem clicando no icone da camera ou da galeria !!! ',
                          textAlign: TextAlign.center),
                      content: Text(''),
                      actions: [
                        TextButton(
                          child: Text(
                            'OK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange,
                            primary: Colors.black,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            shadowColor: Colors.black,
                            elevation: 5,
                          ),
                        )
                      ],
                    );
                  });
            } else {
              readTextFromAnImage();
            }
          },
          child: Icon(
            Icons.check,
          ),
        ),
      ),
    );
  }

  void clear() {
    setState(() {
      result = '';
      isImageLoad = false;
    });
  }
}
