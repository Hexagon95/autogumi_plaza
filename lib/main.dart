import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:autogumi_plaza/tools/probe_measuring.dart'  if(dart.library.html) 'package:autogumi_plaza/tools/web/probe_measuring.dart' as probe_measuring;
import 'package:autogumi_plaza/tools/photo_take.dart'       if(dart.library.html) 'package:autogumi_plaza/tools/web/photo_take.dart' as photo_take;
import 'package:autogumi_plaza/routes/pdf_signature.dart'   if(dart.library.html) 'package:autogumi_plaza/routes/web/pdf_signature.dart';
import 'package:autogumi_plaza/routes/photo_preview.dart';
import 'package:autogumi_plaza/tools/image_picker.dart';
import 'package:autogumi_plaza/routes/data_form.dart';
import 'package:autogumi_plaza/routes/signature.dart';
import 'package:autogumi_plaza/routes/calendar.dart';
import 'package:autogumi_plaza/routes/log_in.dart';
import 'package:autogumi_plaza/routes/panel.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MidnightLogoutGuard extends StatefulWidget {
  final Widget child;
  const MidnightLogoutGuard({super.key, required this.child});

  @override
  State<MidnightLogoutGuard> createState() => _MidnightLogoutGuardState();
}

class _MidnightLogoutGuardState extends State<MidnightLogoutGuard>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _loginDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightLogout();
  }

  void _scheduleMidnightLogout() {
    _timer?.cancel();

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);

    _timer = Timer(nextMidnight.difference(now), _logout);
  }

  void _logout() {
    Global.routeNext = NextRoute.logIn;

    navigatorKey.currentState?.popUntil((route) => route.isFirst);

    _loginDay = DateTime.now();
    _scheduleMidnightLogout();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();

      if (now.day != _loginDay.day ||
          now.month != _loginDay.month ||
          now.year != _loginDay.year) {
        _logout();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

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
    '/panel':           (context) => const Panel(),
    '/imagePicker':     (context) => const ImagePicker(),
  };
  if(!kIsWeb){
    routes['/probeMeasuring'] = (content) => const probe_measuring.ProbeMeasuring();
    routes['/photo/take'] =     (context) => const photo_take.TakePictureScreen();
  }
  runApp(
    MidnightLogoutGuard(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: routes,
        scaffoldMessengerKey: Global.scaffoldMessengerKey,
      ),
    ),
  );
}