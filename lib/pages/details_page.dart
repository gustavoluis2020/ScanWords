import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:clipboard/clipboard.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:scanwords/api/api_pdf.dart';

import 'package:scanwords/models/utils_flusbar.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class DetailsPage extends StatefulWidget {
  String textDetails;

  DetailsPage({this.textDetails});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  GlobalKey<ScaffoldState> copykey = new GlobalKey<ScaffoldState>();

  GlobalKey containerKey = GlobalKey();

  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  //
  TextEditingController editingController = TextEditingController();
  //
  var result = '';
  //

  @override
  void initState() {
    super.initState();
    editingController.text = widget.textDetails;
  }

  @override
  void dispose() {
    editingController.dispose();

    super.dispose();
  }

  void resultText() {
    result = '';
    setState(() {
      result = editingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: copykey,
      floatingActionButton: AnimatedFloatingActionButton(
        colorEndAnimation: Colors.orangeAccent,
        colorStartAnimation: Colors.orange,
        animatedIconData: AnimatedIcons.menu_home,
        fabButtons: <Widget>[
          saveText(),
          copyText(),
          shareText(),
          pdfText(),
        ],
      ),
      appBar: AppBar(
        title: Text('Clique no Texto para Editar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: containerKey,
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12),
                  child: _editTitleTextField(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // print and save jpg on galery
  Future<void> save() async {
    RenderRepaintBoundary boundary =
        containerKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    //Request permissions
    if (!(await Permission.storage.status.isGranted))
      await Permission.storage.request();
    final time = DateTime.now().toIso8601String().replaceAll('.', ':');
    final name = 'text$time.png';
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 80,
        name: name);
    print(result);

    final isSuccess = result['isSuccess'];

    if (isSuccess) {
      //  Navigator.pop(context);

      Utils.showSnackBar(
        context,
        text: 'Salvo na Galeria',
        color: Colors.orange,
      );
    } else {
      Utils.showSnackBar(
        context,
        text: 'Erro ao Salvar',
        color: Colors.red,
      );
    }
  }

  // edit text
  Widget _editTitleTextField() {
    return Container(
      child: TextField(
        controller: editingController,
        maxLines: null,
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: new InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  // ref  floatingActionButton: AnimatedFloatingActionButton
  Widget copyText() {
    return Container(
        child: FloatingActionButton(
      onPressed: () {
        FlutterClipboard.copy(editingController.text).then((value) => copykey
            .currentState
            .showSnackBar(new SnackBar(content: Text('Texto Copiado'))));
      },
      focusColor: Colors.yellow,
      focusElevation: 16.0,
      elevation: 2.0,
      heroTag: 'copy',
      child: Icon(
        Icons.copy,
        color: Colors.white,
      ),
    ));
  }

  Widget saveText() {
    return Container(
        child: FloatingActionButton(
      onPressed: () {
        save();
      },
      focusColor: Colors.yellow,
      focusElevation: 16.0,
      elevation: 2.0,
      heroTag: 'save',
      child: Icon(
        Icons.save,
        color: Colors.white,
      ),
    ));
  }

  Widget shareText() {
    return Container(
        child: FloatingActionButton(
      onPressed: () {
        Share.share(editingController.text);
      },
      focusColor: Colors.yellow,
      focusElevation: 16.0,
      elevation: 2.0,
      heroTag: 'share',
      child: Icon(
        Icons.share,
        color: Colors.white,
      ),
    ));
  }

  Widget pdfText() {
    return Container(
        child: FloatingActionButton(
      onPressed: _creatPDF,
      focusColor: Colors.yellow,
      focusElevation: 16.0,
      elevation: 2.0,
      heroTag: 'pdf',
      child: Icon(
        Icons.picture_as_pdf,
        color: Colors.white,
      ),
    ));
  }

  // save pdf
  Future<void> _creatPDF() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    dynamic textpdf = editingController.text;
    Size size = font.measureString(textpdf);

    // view pdf format text
    PdfTextElement(
            text: textpdf, font: PdfStandardFont(PdfFontFamily.helvetica, 18))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(0, 0, page.getClientSize().width / 1,
                page.getClientSize().height / 0));

    List<int> bytes = document.save();
    document.dispose();
    saveAndLaunchFile(bytes, 'ScanWords.pdf');
  }
}
