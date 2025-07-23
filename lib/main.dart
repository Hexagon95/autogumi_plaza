import 'routes/probe_measuring.dart';
import 'routes/photo_preview.dart';
import 'routes/photo_take.dart';
import 'routes/data_form.dart';
import 'routes/signature.dart';
import 'routes/calendar.dart';
import 'routes/log_in.dart';
import 'routes/panel.dart';
import 'data_manager.dart';
import 'global.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  await DataManager.identitySQLite;
  Global.routeNext = NextRoute.logIn;
  runApp(
    MaterialApp(      
      initialRoute:   '/',
      routes: {
        '/':                (context) => const LogIn(),
        '/calendar':        (context) => const Calendar(),
        '/dataForm':        (context) => const DataForm(),
        '/probeMeasuring':  (content) => const ProbeMeasuring(),
        '/photo/take':      (context) => TakePictureScreen(camera: cameras.first,),
        '/photo/preview':   (context) => const PhotoPreview(),
        '/signature':       (context) => const SignatureForm(),
        '/panel':           (context) => const Panel()
      },
    )
  );
}