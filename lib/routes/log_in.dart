// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:ota_update/ota_update.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => LogInState();
}

class LogInState extends State<LogIn>{
  // ---------- < Variables [Static] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static String errorMessage =  '';
  static bool updateNeeded = false;

  // ---------- < Variables > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonLogIn =   ButtonState.default0;
  bool isPasswordHidden =     true;
  bool isMenuItemNotPressed = true;
  OtaEvent? currentEvent;
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
            image:  AssetImage('images/Mercarius_Autogumiplaza_függőleges_háttér_Rajztábla 1.png'),
            fit:    BoxFit.cover
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
          onPressed:            () async => await Global.showAlertDialog(context, content: DataManager.identity.toString(), title: 'Eszköz id'),
          backgroundColor:      Global.getColorOfButton(ButtonState.default0),
          foregroundColor:      Global.getColorOfIcon(ButtonState.default0),
          mini:                 true,
          child:                const Icon(Icons.construction, size: 36),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      )
    );
  }

  // ---------- < Widget Build [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawVerzio => Column(children: [
    //Text('v1.20a (TEST 2)', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)), //${DataManager.thisVersion}
    Text('v${DataManager.thisVersion}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
  ]);

  Widget get _drawButtonLogIn =>  Padding(
    padding:  const EdgeInsets.fromLTRB(20, 40, 20, 40),
    child:    SizedBox(height: 40, width: _width, child: TextButton(
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonLogIn))),
      onPressed:  (buttonLogIn == ButtonState.default0)? () => _buttonLogInPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonLogIn == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfButton(buttonLogIn))))
        ),
        Text(
          (){return switch(buttonLogIn){
            ButtonState.disabled => (currentEvent?.value != null && currentEvent!.value!.isNotEmpty)? 'Új verzió érhető el.     Letöltés: ${currentEvent?.value}%' : 'Új verzió érhető el.',
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
  Future get _buttonLogInPressed async {
    DataManager.customer =  'mosaic';
    DataManager.data =      List<dynamic>.empty(growable: true);
    DataManager.quickData = List<dynamic>.empty(growable: true);
    errorMessage =           '';
    setState(() => buttonLogIn = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(DataManager.isServerAvailable){
      if(!updateNeeded){
        await DataManager(quickCall: QuickCall.tabletBelep).beginQuickCall;
        await DataManager(input: {'number': 0, 'login': 'customer'}).beginProcess;
        if(errorMessage.isNotEmpty){
          await Global.showAlertDialog(context, title: 'Hiba!', content: errorMessage);
          setState(() => buttonLogIn = ButtonState.default0);
          return;
        }
        await DataManager(input: {'number': 1, 'login': 'service'}).beginProcess;
        if(errorMessage.isNotEmpty){
          await Global.showAlertDialog(context, title: 'Hiba!', content: errorMessage);
          setState(() => buttonLogIn = ButtonState.default0);
          return;
        }
        Global.routeNext = NextRoute.calendar;
        await DataManager().beginProcess;
        buttonLogIn =             ButtonState.default0;
        if(errorMessage.isEmpty){
          await DataManager(quickCall: QuickCall.askIncompleteDays).beginQuickCall;
          await Navigator.pushNamed(context, '/calendar');
        }
        else{
          await Global.showAlertDialog(context, title: 'Hiba', content: errorMessage);
          Global.routeBack;
        }
        setState((){});
      }
      else{
        setState(() => buttonLogIn = ButtonState.disabled);
        tryOtaUpdate();
      }
    }
    else{
      setState(() => buttonLogIn = ButtonState.default0);
    }
  }

  // ---------- < Methods [2] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> tryOtaUpdate() async {
    try {
      if(kDebugMode)print('ABI Platform: ${await OtaUpdate().getAbi()}');
      OtaUpdate().execute(
        'https://app.mosaic.hu/ota/szerviz_mezandmol/${DataManager.actualVersion}/app-release.apk',
        destinationFilename: 'app-release.apk',
      ).listen(
        (OtaEvent event) {setState(() => currentEvent = event);}
      );
    } catch (e) {
      if(kDebugMode)print('Failed to make OTA update. Details: $e');
    }
  }
}