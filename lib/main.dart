import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scanwords/pages/scan_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scan Words',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: ScanPage());
  }
}
