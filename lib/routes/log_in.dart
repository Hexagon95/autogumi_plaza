import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:autogumi_plaza/tools/ota_plugin.dart' if (dart.library.html) 'package:autogumi_plaza/tools/web/ota_plugin.dart' as ota_plugin;
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => LogInState();
}

class LogInState extends State<LogIn>{
  // ---------- < Variables [Static] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static dynamic logInNamePassword; 
  static String errorMessage =              '';
  static String forgottenPasswordMessage =  '';
  static bool updateNeeded =                false;
  static const channel =                    MethodChannel('wallpaper_channel');

  // ---------- < Methods [Static] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static Future<bool> setWallpaper() async {
    if (kIsWeb) return false;
    try {
      final ByteData data = await rootBundle.load('images/wallpaper.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final result = await channel.invokeMethod<bool>(
        'setWallpaper',
        {'bytes': bytes},
      );
      return result ?? false;
    } catch (e) {
      if (kDebugMode) print('Error setting wallpaper: $e');
      return false;
    }
  }

  // ---------- < Variables > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonLogIn =   ButtonState.default0;
  bool isPasswordHidden =     true;
  bool isMenuItemNotPressed = true;
  final ota_plugin.OtaPlugin otaPlugin = ota_plugin.OtaPlugin();
  int otaProgress = 0;
  late double _width;
  

  // ---------- < Widget Build [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width - 50;
    if(_width > 400) _width = 400;

    return WillPopScope( 
      onWillPop:  () async => false,
      child:      Scaffold(
        body: Container(
          decoration: const BoxDecoration(image: DecorationImage(
            image:      AssetImage('images/wallpaper.png'),
            fit:        BoxFit.cover,
            alignment:  Alignment.topCenter
          )),
          child: Center(child: Column(
            mainAxisAlignment:  MainAxisAlignment.end,
            mainAxisSize:       MainAxisSize.max,
            children:           [
              _drawVerzio,
              _drawButtonLogIn,
              _drawErrorMessage
            ]
          ))
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {}, // required but unused
          backgroundColor: Global.getColorOfButton(ButtonState.default0),
          foregroundColor: Global.getColorOfIcon(ButtonState.default0),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 'wallpaper':
                  final ok = await LogInState.setWallpaper();
                  if (!ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hiba: nem sikerült a háttérkép beállítása')),
                    );
                  }
                  break;
                case 'deviceId':
                  await Global.showAlertDialog(
                    context,
                    content: DataManager.identity.toString(),
                    title: 'Eszköz id',
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'wallpaper',
                child: Row(
                  children: [
                    Icon(Icons.wallpaper, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Háttérkép beállítása'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'deviceId',
                child: Row(
                  children: [
                    Icon(Icons.perm_device_information, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Eszköz ID'),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      )
    );
  }

  // ---------- < Widget Build [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawVerzio => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('v${DataManager.thisVersion}${(DataManager.verzioTest == 0)? '' : '   [Teszt: ${DataManager.verzioTest.toString()}]'}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
      Text((DataManager.appIs == AppIs.web)? '  🌐 web     ' : '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal))
    ])
  ]);

  Widget get _drawButtonLogIn =>  Padding(
    padding:  const EdgeInsets.fromLTRB(20, 40, 20, 40),
    child:    SizedBox(height: 40, width: _width, child: TextButton(
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonLogIn))),
      onPressed:  (buttonLogIn == ButtonState.default0)? _onLogInPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonLogIn == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfButton(buttonLogIn))))
        ),
        Text(
          (){return switch(buttonLogIn){
            ButtonState.disabled => otaProgress > 0 ? 'Új verzió érhető el.     Letöltés: $otaProgress%' : 'Új verzió érhető el.',
            ButtonState.loading =>  'Betöltés...',
            _ =>                    'Bejelentkezés'
          };}(),
          style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonLogIn))
        )
      ])
    ))
  );

  Widget get _drawErrorMessage => errorMessage.isNotEmpty
    ? Row(mainAxisSize: MainAxisSize.max, children:[Expanded(child: Container(
        color:      Colors.red,
        height:     22,
        alignment:  Alignment.center,
        child:      Text(errorMessage,
          style:      const TextStyle(color: Colors.yellow, fontSize: 16),
          softWrap:   true,
        )
      ))])
    : Container()
  ;
  
  // ---------- < Methods [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> _onLogInPressed() async {
    DataManager.customer = 'mosaic';
    //errorMessage = '';
    forgottenPasswordMessage = '';
    setState(() => buttonLogIn = ButtonState.loading);

    // 1) Check version first
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if (updateNeeded) {
      setState(() => buttonLogIn = ButtonState.disabled);
      await tryOtaUpdate();
      return;
    }

    await DataManager(input: {'number': 0, 'login': 'customer'}).beginProcess;
    if (errorMessage.isNotEmpty) {
      await Global.showAlertDialog(context, title: 'Hiba!', content: errorMessage);
      if (mounted) setState(() => buttonLogIn = ButtonState.default0);
      return;
    }    

    // 2) Ask username + password
    final savedUserName = await DataManager.lastUserNameSQLite;
    final result = await Global.logInDialog(
      context,
      userNameInput: savedUserName ?? ((logInNamePassword != null && logInNamePassword.isNotEmpty)? logInNamePassword[0]['nev'].toString() : null),
    );

    if (result == null) {
      if (mounted) setState(() => buttonLogIn = ButtonState.default0);
      return;
    }

    // 👉 Show spinner while authenticating (this is the key change)
    if (mounted) setState(() => buttonLogIn = ButtonState.loading);

    // 3) Forgotten password?
    if (result['buttonState'] == ButtonState.loading) {
      await DataManager(
        quickCall: QuickCall.forgottenPassword,
        input: {'user_name': result['userName']},
      ).beginQuickCall;

      await Global.showAlertDialog(
        context,
        title: 'Elfelejtett jelszó',
        content: forgottenPasswordMessage,
      );

      if (mounted) setState(() => buttonLogIn = ButtonState.default0);
      return;
    }

    // 4) Normal login
    await DataManager(
      quickCall: QuickCall.logInNamePassword,
      input: {
        'user_name': result['userName'],
        'user_password': result['userPassword'],
      },
    ).beginQuickCall;

    if (logInNamePassword == null || logInNamePassword.isEmpty) {
      await Global.showAlertDialog(
        context,
        title: 'Ismeretlen felhasználónév!',
        content: 'A megadott felhasználónév: ${result['userName']} ismeretlen!',
      );
      if (mounted) setState(() => buttonLogIn = ButtonState.default0);
      return;
    }

    if (logInNamePassword[0]['jelszo_ok'].toString() == '0') {
      await Global.showAlertDialog(
        context,
        title: 'Helytelen jelszó!',
        content: 'A megadott jelszó helytelen!',
      );
      if (mounted) setState(() => buttonLogIn = ButtonState.default0);
      return;
    }
    await DataManager.saveLastUserNameSQLite(result['userName']);

    // 5) Continue flow
    await DataManager(input: {'number': 1, 'login': 'service'}).beginProcess;
    if (errorMessage.isNotEmpty) {
      await Global.showAlertDialog(context, title: 'Hiba!', content: errorMessage);
      if (mounted) setState(() => buttonLogIn = ButtonState.default0);
      return;
    }
    await DataManager(quickCall: QuickCall.tabletBelep).beginQuickCall;
    Global.routeNext = NextRoute.panel;
    await DataManager(quickCall: QuickCall.panel).beginQuickCall;

    //if (mounted) setState(() => buttonLogIn = ButtonState.default0);
    if (!mounted) return;
    await Navigator.pushNamed(context, '/panel');
  }  

  // ---------- < Methods [2] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> tryOtaUpdate() async {
    await otaPlugin.tryOtaUpdate(
      onProgress: (progress) {
        if (!mounted) return;
        setState(() => otaProgress = progress);
      },
    );
  }
}