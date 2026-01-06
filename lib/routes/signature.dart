// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:autogumi_plaza/routes/calendar.dart';
import 'package:autogumi_plaza/routes/data_form.dart';
import 'package:autogumi_plaza/routes/photo_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../data_manager.dart';
import '../global.dart';

class SignatureForm extends StatefulWidget {
  const SignatureForm({super.key});

  @override  
  SignatureFormState createState() => SignatureFormState();
}

class SignatureFormState extends State<SignatureForm> {
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> rawData =                    List<dynamic>.empty();
  static TextEditingController editingController =  TextEditingController();
  static String signatureBase64 =                   '';
  static dynamic message;

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonClear =   ButtonState.disabled;
  ButtonState buttonCamera =  ButtonState.default0;
  ButtonState buttonCheck =   ButtonState.disabled;
  final SignatureController _controller = SignatureController(
    penStrokeWidth:         1,
    disabled:               DataFormState.buttonListPictures.isNotEmpty || (DataFormState.option('Lezárt')?['value']?.toString() == '1'),
    penColor:               Colors.black,
    exportBackgroundColor:  Colors.white,
    onDrawStart:            (){},
    onDrawEnd:              (){}
  );
  BoxDecoration customBoxDecoration = BoxDecoration(            
    border:       Border.all(color: Global.getColorOfButton(ButtonState.default0), width: 1),
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );
  BoxDecoration customBoxDecoration2 = BoxDecoration(            
    border:       Border.all(color: Global.getColorOfButton(ButtonState.disabled), width: 1),
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );
  bool get isClosed => (DataFormState.option('Lezárt')?['value']?.toString() == '1');

  // ---------- < Widget [Build] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {
    if(DataFormState.buttonListPictures.isNotEmpty && buttonCheck != ButtonState.loading){
      buttonCheck = ButtonState.default0;
      _controller.clear();
      editingController.text = '';
    }
    return WillPopScope(onWillPop: _handlePop, child: Scaffold(
      appBar:           AppBar(
        backgroundColor:  Global.getColorOfButton(ButtonState.default0),
        foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
        title:            Center(child: Text(isClosed ? 'Összesítés' : 'Összesítés és Lezárás', style: const TextStyle(fontSize: 26))),
      ),
      backgroundColor:  Colors.white,
      body: OrientationBuilder(builder: (context, orientation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _drawFormList,
            if (!isClosed) ...[
              _drawSignatureBlock,
              _drawEnterName,
              _drawBottomBar,
            ],
          ],
        );
      }),
    ));
  }

  // ---------- < Widget [1] > ----------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawFormList{
    int maxSor() {int maxSor = 1; for(var item in rawData) {if(item['sor'] > maxSor) maxSor = item['sor'];} return maxSor;}
    List<Widget> varListWidget = List<Widget>.empty(growable: true);

    if(rawData.isNotEmpty) {for(int sor = 1; sor <= maxSor(); sor++) {
      List<Widget> row = List<Widget>.empty(growable: true);
      for(int i = 0; i < rawData.length; i++) {if(rawData[i]['sor'] == sor){
        if(rawData[i]['visible'] != null && ['0', 'false'].contains(rawData[i]['visible'].toString())) continue;
        row.add(Padding(
          padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child:    Container(decoration: customBoxDecoration2, child: Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawData, rawData[i], i)))
        ));
      }}
      varListWidget.add(SizedBox(width: MediaQuery.of(context).size.width, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: row)));
    }}
    return Expanded(child: Padding(padding: const EdgeInsets.all(5), child: Container(
      decoration: customBoxDecoration,
      child: Padding(padding: const EdgeInsets.all(5), child: SingleChildScrollView(child: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:           varListWidget
      ))),
    )));
  }

  Widget get _drawSignatureBlock => Stack(children: [
    Padding(padding: const EdgeInsets.all(5), child: Container(
      decoration: customBoxDecoration,
      height:     200,
      child:      Padding(padding: const EdgeInsets.all(5), child: Signature( //SIGNATURE CANVAS0
        controller:       _controller,
        backgroundColor:  Colors.white,
      ))
    )),
    const Padding(padding: EdgeInsets.all(15), child: Text('Aláírás', style: TextStyle(color: Colors.grey)))
  ]);

  Widget get _drawEnterName => Padding(padding: const EdgeInsets.all(5), child: Container(
    decoration: customBoxDecoration,
    child:      TextFormField(
      enabled:      (buttonCheck != ButtonState.loading || DataFormState.buttonListPictures.isEmpty),
      controller:   editingController,
      decoration:   InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        labelText:      'Aláíró neve',
        labelStyle:     TextStyle(color: Global.getColorOfButton(ButtonState.default0)),
        border:         InputBorder.none,
      ),
      onChanged:    (String? newValue) => setState(() => buttonCheck = (editingController.text.isEmpty || _controller.isEmpty)? ButtonState.disabled : ButtonState.default0),
    )
  ));

  Widget get _drawBottomBar => Container( //OK AND CLEAR BUTTONS
    decoration: BoxDecoration(color: Global.getColorOfButton(ButtonState.default0)),
    child:      Row(
      mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
      mainAxisSize:       MainAxisSize.max,
      children:           <Widget>[ //CLEAR CANVAS                
        _drawButtonClear,
        _drawButtonCamera,
        _drawButtonListPictures,
        _drawButtonCheck
      ],
    ),
  );

  // ---------- < Widget [1] > ----------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _getWidget(List<dynamic> thisData, dynamic input, int index){
    double getWidth() => MediaQuery.of(context).size.width - 45;

    switch(input['input_field']){

      case 'checkbox': return SizedBox(height: 32, width: getWidth(), child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(width: getWidth() / 2.1, child: Text(thisData[index]['name'].toString(), style: const TextStyle(color: Color.fromARGB(255, 153, 153, 153), fontSize: 16))),
        Row(children: [
          CupertinoSwitch(
            value:        (thisData[index]['value'] != null && thisData[index]['value'].toString() == '1'),
            onChanged:    (value){},
            activeColor:  Global.getColorOfButton(ButtonState.disabled),
          )
        ])
      ]));

      default: return SizedBox(height: 22, width: getWidth(), child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(width: getWidth() / 2.1, child: Text('${input['name']}:',   style: const TextStyle(color: Color.fromARGB(255, 153, 153, 153), fontSize: 16))),
        Text(input['value'],  style: const TextStyle(color: Color.fromARGB(255, 120, 120, 120), fontSize: 16))
      ]));
    }
  }

  // ---------- < Widget [Buttons] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonClear => IconButton(
    icon:       const Icon(Icons.backspace),
    color:      Global.getColorOfIcon(buttonClear),
    iconSize:   30,
    onPressed:  () => (buttonClear == ButtonState.default0 && buttonCheck != ButtonState.loading)? setState(() => _controller.clear()) : null
  );

  Widget get _drawButtonCheck => Row(children: [
      Visibility(
        visible:  (buttonCheck == ButtonState.loading),
        child:    _progressIndicator(Global.getColorOfIcon(ButtonState.loading))
      ),
      IconButton(
        icon:       const Icon(Icons.save),
        color:      Global.getColorOfIcon(buttonCheck),
        iconSize:   30,
        onPressed:  () => (buttonCheck == ButtonState.default0)? _checkPressed : null
      )
    ]);

  Widget get _drawButtonCamera => TextButton(
    onPressed:  () async => (buttonCamera == ButtonState.default0)? _buttonCameraPressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children:[
      (buttonCamera == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonCamera)) : Container(),
      Icon(Icons.camera_alt, color: Global.getColorOfIcon(buttonCamera), size: 30)
    ]))
  );

  Widget get _drawButtonListPictures{
    List<Widget> listButtons = List<Widget>.empty(growable: true);

    for(int i = 0; i < DataFormState.buttonListPictures.length; i++) {listButtons.add(TextButton(
      onPressed:  () async => (DataFormState.buttonListPictures[i] == ButtonState.default0)? _buttonListPicturesPressed(i) : null,
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child:      Padding(padding: const EdgeInsets.all(5), child: Row(children:[
        (DataFormState.buttonListPictures[i] == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(DataFormState.buttonListPictures[i])) : Container(), 
        Icon(Icons.image_outlined, color: Global.getColorOfIcon(DataFormState.buttonListPictures[i]), size: 30)
      ]))
    ));}
    return Row(children: listButtons);
  }

  // ---------- < Widget [3] > ----------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  void initState() {
    super.initState();
    _controller.addListener((){
      buttonClear = (_controller.isNotEmpty) ? ButtonState.default0 : ButtonState.disabled;
      if(DataFormState.buttonListPictures.isEmpty){
        if(_controller.isEmpty || editingController.text.isEmpty) {buttonCheck = ButtonState.disabled;}
        else                                                      {buttonCheck = ButtonState.default0;}
      }
      setState((){});
    });
  }

  Future get _checkPressed async{
    String title =    'Adatlap elmentése';
    String content =  'Menteni kívánja a változtatásokat és lezárja az adatlapot?';
    if ((_controller.isNotEmpty || DataFormState.buttonListPictures.isNotEmpty) && await Global.yesNoDialog(context, title: title, content: content)) {
      _controller.disabled = true;
      setState(() => buttonCheck = ButtonState.loading);
      final Uint8List? data = await _controller.toPngBytes();
      if(data != null) signatureBase64 = base64.encode(data);
      DataManager.dataQuickCall[0]['beallitasok'][getIndexFromOptions('Átvevő aláírása')]['value'] =  signatureBase64;
      DataManager.dataQuickCall[0]['beallitasok'][getIndexFromOptions('Átvevő neve')]['value'] =      editingController.text;
      switch(DataFormState.workType){        
        case 'Igénylés':  await DataManager(quickCall: QuickCall.saveAbroncsIgenyles, input: {'lezart': 1}).beginQuickCall;         break;  
        case 'Eseti':     await DataManager(quickCall: QuickCall.saveEsetiMunkalapFelvitele, input: {'lezart': 1}).beginQuickCall;  break;
        default:
          Global.routeNext = NextRoute.signature; 
          await DataManager().beginProcess;
          Global.routeBack;
          break;
      }
      if(
          message == null ||
          ['NULL', 'Null','null', '', ' ', '[]', '[ ]', '{}', '{ }'].contains(message.toString()) ||
          (message is Map && [null, '', ' ', 'null'].contains(message['message']))
        ){
        resetVariables;
        Global.routeBack; Global.routes;
        if(kDebugMode)print(Global.currentRoute);
        CalendarState.selectedIndexList = null;
        await DataManager().beginProcess;
        Navigator.popUntil(context, ModalRoute.withName('/calendar'));
        await Navigator.pushReplacementNamed(context, '/calendar');
      }
      else{
        await Global.showAlertDialog(context, content: message['message'], title: message['name']);
        setState(() => buttonCheck = ButtonState.default0);
      }
    }
  }
  
  Future get _buttonCameraPressed async{
    setState(() => buttonCamera = ButtonState.loading);
    Global.routeNext =              NextRoute.photoTake;
    buttonCamera =                  ButtonState.default0;
    PhotoPreviewState.isSignature = true;
    await Navigator.pushNamed(context, '/photo/take');
    refreshImages;
    setState((){});
  }

  Future _buttonListPicturesPressed(int i) async{
    setState(() => DataFormState.buttonListPictures[i] = ButtonState.loading);
    Global.routeNext =                NextRoute.photoCheck;
    PhotoPreviewState.selectedIndex = i;
    await Navigator.pushNamed(context, '/photo/preview');
    setState(() => DataFormState.buttonListPictures[i] = ButtonState.default0);
  }

  Future<bool> _handlePop() async{ if(buttonCheck != ButtonState.loading){
    DataFormState.buttonContinue =  ButtonState.default0;
    PhotoPreviewState.isSignature = false;
    await DataManager(quickCall: QuickCall.askPhotos).beginQuickCall;
    refreshImages;
    setState((){});
    Global.routeBack;
    return true;
    //Navigator.popUntil(context, ModalRoute.withName('/dataForm'));
   //await Navigator.pushReplacementNamed(context, '/dataForm');
  } return false;}

  void get resetVariables{
    rawData =                           List<dynamic>.empty();
    editingController =                 TextEditingController();
    signatureBase64 =                   '';
    DataFormState.buttonListPictures =  List<ButtonState>.empty(growable: true);
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  void get refreshImages async{
    DataFormState.buttonListPictures = List<ButtonState>.empty(growable: true);
    for(int i = 0; i < DataFormState.numberOfPictures[DataFormState.currentProgress]; i++) {DataFormState.buttonListPictures.add(ButtonState.default0);}
  }
  int getIndexFromOptions(String input) {for(int i = 0; i < DataManager.dataQuickCall[0]['beallitasok'].length; i++){
    if(DataManager.dataQuickCall[0]['beallitasok'][i]['name'] == input) return i;
  } throw Exception('Nincs ilyen Beállítás!');}
}