import 'package:autogumi_plaza/routes/probe_measuring.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'global.dart';
import 'data_manager.dart';
import 'routes/log_in.dart';
import 'routes/calendar.dart';
import 'routes/data_form.dart';
import 'routes/photo_take.dart';
import 'routes/photo_preview.dart';
import 'routes/signature.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
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
      },
    )
  );
  await DataManager.identitySQLite;
}