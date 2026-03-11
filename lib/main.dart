import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autogumi_plaza/tools/probe_measuring.dart'  if(dart.library.html) 'package:autogumi_plaza/tools/web/probe_measuring.dart' as probe_measuring;
import 'package:autogumi_plaza/tools/photo_take.dart'       if(dart.library.html) 'package:autogumi_plaza/tools/web/photo_take.dart' as photo_take;
import 'package:autogumi_plaza/routes/pdf_signature.dart'   if(dart.library.html) 'package:autogumi_plaza/routes/web/pdf_signature.dart';
import 'package:autogumi_plaza/routes/photo_preview.dart';
import 'package:autogumi_plaza/routes/data_form.dart';
import 'package:autogumi_plaza/routes/signature.dart';
import 'package:autogumi_plaza/routes/calendar.dart';
import 'package:autogumi_plaza/routes/log_in.dart';
import 'package:autogumi_plaza/routes/panel.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('hu_HU', null);
  await DataManager.identitySQLite;
  Global.routeNext = NextRoute.logIn;
  final routes = <String, WidgetBuilder>{
    '/':                (context) => const LogIn(),
    '/calendar':        (context) => const Calendar(),
    '/dataForm':        (context) => const DataForm(),
    '/photo/preview':   (context) => const PhotoPreview(),
    '/signature':       (context) => const SignatureForm(),
    '/pdfSignature':    (context) => const PdfSignaturePage(),
    '/panel':           (context) => const Panel()
  };
  if(!kIsWeb){
    routes['/probeMeasuring'] = (content) => const probe_measuring.ProbeMeasuring();
    routes['/photo/take'] =     (context) => const photo_take.TakePictureScreen();
  }
  runApp(
    MaterialApp(      
      initialRoute: '/',
      routes:       routes
    )
  );
}