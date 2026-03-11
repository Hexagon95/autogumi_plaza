// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:async';

import 'package:flutter/services.dart';

import '../global.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ProbeMeasuring extends StatefulWidget {//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataForm>
  const ProbeMeasuring({super.key});

  @override
  State<ProbeMeasuring> createState() => ProbeMeasuringState();
}

class ProbeMeasuringState extends State<ProbeMeasuring> {//-- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataFormState>
  // ---------- < Wariables [Static] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static int index =    0;

  // ---------- < Wariables [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  final _bluetoothClassicPlugin =             BluetoothClassic();
  List<Device> _devices =                     [];
  Uint8List _data =                           Uint8List(0);
  ButtonState buttonCancel =                  ButtonState.default0;
  ButtonState buttonRefresh =                 ButtonState.default0;
  BoxDecoration customBoxDecoration =         const BoxDecoration(
    color:        Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(30)),
    boxShadow: [BoxShadow(
      color:        Color.fromRGBO(38, 57, 77, 1),
      blurRadius:   30,
      spreadRadius: -10,
      offset:       Offset(0,20)
    )]
  );
  Probe _probe =  Probe.default0; Probe get probe => _probe; set probe(Probe input) {_probe = input; switch(input){
    case Probe.bluetoothCheck:  _runBluetoothCheck; break;
    case Probe.deviceSearch:    _runDeviceSearch;   break;
    default: break;
  }}
  StreamSubscription<dynamic>? subscriptionDeviceStatusChanged;
  StreamSubscription<dynamic>? subscriptionDeviceDataReceived;

  // ---------- < Constructor > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

  // ---------- < WidgetBuild [1] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){
    if(probe == Probe.default0) probe = Probe.bluetoothCheck;
    return WillPopScope(
      onWillPop:  _handlePop,
      child:      Scaffold(
        backgroundColor:  const Color.fromARGB(130, 0, 0, 0),
        body:               Center(child: Container(
          height:     300,
          width:      500,
          decoration: customBoxDecoration,
          child:      Stack(children: [
            (probe == Probe.deviceSearch)? Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: _drawButtonRefresh)) : Container(),
            Align(alignment: Alignment.bottomRight, child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 8), child: _drawButtonCancel)),
            _getContent
          ])
        )),
      )
    );
  }

  // ---------- < WidgetBuild [2] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _getContent {return switch(probe){

    Probe.bluetoothCheck => Align(alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Bluetooth bekapcsolása...', style: TextStyle(fontSize: 20)),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _drawCustomProgressIndicator(color: Colors.blue),
        const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.bluetooth, size: 50, color: Colors.blue))
      ])
    ])),

    Probe.deviceSearch => Align(alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, children: (_devices.isEmpty)
    ?[
      const Text('Nincs párosítva Bluetooth eszköz', style: TextStyle(fontSize: 20)),
      Padding(padding: const EdgeInsets.all(8), child: _drawCustomProgressIndicator(color: Global.getColorOfButton(ButtonState.loading)))
    ]
    : _getListOfDevicesAsWidgets)),

    Probe.measureCommand => Align(alignment: Alignment.center, child: Column(children: [
      const  Padding(padding: EdgeInsets.fromLTRB(0, 12, 0, 6), child: Text('Beérkezett adatok:', style: TextStyle(fontSize: 20))),
      Text(String.fromCharCodes(_data), style: const TextStyle(fontSize: 16))
    ])),

    _ => Align(alignment: Alignment.center, child: _drawCustomProgressIndicator(color: Global.getColorOfButton(ButtonState.default0)))
  };}

  // ---------- < WidgetBuild [3] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _drawCustomProgressIndicator({required Color color}) => Padding(
    padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
    child:    SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: color))
  );

  List<Widget> get _getListOfDevicesAsWidgets{
    List<Widget> listWidget = List<Widget>.empty(growable: true);
    for(Device item in _devices) {listWidget.add(
      Padding(
        padding:  const EdgeInsets.all(5),
        child:    TextButton(
          onPressed:  () async => await _runMeasureCommand(item),
          style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(ButtonState.default0))),
          child:      Text(item.name ?? '- - Névtelen eszköz! - -', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(ButtonState.default0)))
        )
      )
    );}
    return listWidget;
  }

  // ---------- < WidgetBuild [Buttons] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonCancel => TextButton(
      style:      ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonCancel))
      ),
      onPressed:  (buttonCancel == ButtonState.default0)? () => _buttonCancelPressed : null,          
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonCancel == ButtonState.loading)? true : false,
          child:    _drawCustomProgressIndicator(color: Global.getColorOfIcon(buttonCancel))
        ),
        Text('Mégse', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonCancel)))
      ])
    );

  Widget get _drawButtonRefresh => TextButton(
      style:      ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonRefresh))
      ),
      onPressed:  (buttonRefresh == ButtonState.default0)? () => _buttonRefreshPressed : null,          
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonRefresh == ButtonState.loading)? true : false,
          child:    _drawCustomProgressIndicator(color: Global.getColorOfIcon(buttonRefresh))
        ),
        Text('Frissítés', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonRefresh)))
      ])
    );

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _buttonCancelPressed async => (await _handlePop())? Navigator.pop(context) : null;

  Future get _buttonRefreshPressed async{
    setState(() => buttonRefresh = ButtonState.loading);
    await _runDeviceSearch;
    setState(() => buttonRefresh = ButtonState.default0);
  }  

  Future<bool> _handlePop() async{
    setState(() => buttonCancel = ButtonState.loading);
    bool isLeave = await Global.yesNoDialog(context,
      title:    'Mérés Evletése',
      content:  'Kívánja elvetni a mérést?'
    );
    buttonCancel = ButtonState.default0;
    if(isLeave){
      await _bluetoothClassicPlugin.disconnect();
      _probe =        Probe.default0;
      Global.routeBack;
    }
    else {setState((){});}
    return isLeave;
  }

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _runBluetoothCheck async{
    try{
      probe = Probe.deviceSearch;
    }
    catch(e){
      if(kDebugMode) dev.log(e.toString());
      buttonCancel = ButtonState.default0;
      Navigator.pop(context);
    }
  }

  Future<void> get _runDeviceSearch async {
    _devices = await _bluetoothClassicPlugin.getPairedDevices();
    setState((){});
  }

  Future _runMeasureCommand(Device item) async{
    setState(() => probe = Probe.measureCommand);
    await _bluetoothClassicPlugin.connect(item.address,"00001101-0000-1000-8000-00805f9b34fb");
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      setState(() {
        _data = Uint8List.fromList([..._data, ...event]);
      });
    });
  }

  // ---------- < Methods [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
}