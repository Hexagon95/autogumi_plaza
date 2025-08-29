// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/routes/data_form.dart';


class PhotoPreview extends StatefulWidget{
  // ---------- < Variables [1] > -------- ---------- ---------- ----------  

  // ---------- < Constructor > ---------- ---------- ---------- ----------
  const PhotoPreview({super.key});

  @override
  State<PhotoPreview> createState() => PhotoPreviewState();
}

class PhotoPreviewState extends State<PhotoPreview>{
  // ---------- < Variables [Static] > --- ---------- ---------- ----------  
  static int selectedIndex = 0;  
  static List<String> itemsInList =                 <String>['Még nincs fénykép'];  
  static List<int> idList =                         <int>[];
  static List<int> imageIdList =                    List<int>.empty(growable: true);
  static TextEditingController editingController =  TextEditingController();
  static bool popUpNeeded =                         false;
  static bool isSignature =                         false;
  static String imageBase64 =                       '';
  static String? imagePath;

  // ---------- < Variables [1] > -------- ---------- ---------- ----------
  List<String> itemsToShow =  itemsInList;
  ButtonState buttonComment = ButtonState.default0;  
  ButtonState buttonPhoto =   ButtonState.default0;
  ButtonState buttonSave =    ButtonState.default0;
  ButtonState buttonDelete =  ButtonState.default0;
  BoxDecoration customBoxDecoration =       BoxDecoration(            
    border:       Border.all(color: Global.getColorOfButton(ButtonState.default0), width: 1),
    color:        Colors.black,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ----------
  @override
  Widget build(BuildContext context){     
    return WillPopScope(
      onWillPop:  () => _handlePop,
      child:      Scaffold(
        appBar:           AppBar(
          title:            isSignature
            ? const Text('Munkalap csatolása')
            : Text('Fotó előnézet, pozíció: ${DataFormState.titles[DataFormState.currentProgress]}')
          ,
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
        ),
        backgroundColor:  Colors.black,
        body:             LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {switch(Global.currentRoute){
            default: return _drawPhotoPreview;
          }}
        )
      )
    );
  }

  // ---------- < WidgetBuild [2] > ------ ---------- ---------- ----------
  Widget get _drawPhotoPreview => Column(children: [
    Expanded(child: _photoPreview),
    Visibility(visible: (buttonComment == ButtonState.hidden || editingController.text.isNotEmpty), child: Padding(padding: const EdgeInsets.all(5), child: Container(
      decoration: customBoxDecoration,
      child:      TextField(
        controller:   editingController,
        keyboardType: TextInputType.multiline,
        maxLines:     null,
        decoration:   InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      'Megjegyzés',
          labelStyle:     TextStyle(color: Global.getColorOfButton(ButtonState.default0)),
          border:         InputBorder.none,
        ),
        onChanged:    (String? newValue) => setState((){}),
        style:        const TextStyle(color: Colors.white)
      )))),
    Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: switch(Global.currentRoute){
      NextRoute.photoCheck => [],
      _ =>                      [_drawButtonComment, _drawButtonTakePhoto, _drawButtonSave]
    }))
  ]);

  Widget get _photoPreview {switch(Global.currentRoute){
    case NextRoute.photoCheck:
      return Center(child: Image.network('${DataManager.rootPath}${DataManager.dataQuickCall[2][selectedIndex]['filename']}'));

    default: return Center(child: (imagePath == null)
      ? const Text('Még nincs készítve fotó ehhez', style: TextStyle(color: Color.fromARGB(255, 200, 200, 200)))
      : Image.file(File(imagePath!))
    );
  }}

  // ---------- < Widget[Buttons] > ------ ---------- ---------- ----------
  Widget get _drawButtonComment => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonComment == ButtonState.default0)? _buttonCommentPress : null,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonComment == ButtonState.loading),
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonComment)))
            )
          ), Icon(
            Icons.edit,
            color:  Global.getColorOfIcon(buttonComment),
            size:   30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonTakePhoto => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonPhoto == ButtonState.default0)? _buttonPhotoPress : null,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonPhoto == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonPhoto)))
            )
          ), Icon(
            Icons.photo_camera,
            color:  Global.getColorOfIcon(buttonPhoto),
            size:   30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonSave => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonSave == ButtonState.default0)? _buttonSavePress : null,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonSave == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonSave)))
            )
          ), Icon(
            Icons.save,
            color: Global.getColorOfIcon(buttonSave),
            size: 30,
          )
        ])
      )
    ])
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ----------
  void get _buttonCommentPress => setState(() => buttonComment = ButtonState.hidden);  

  Future get _buttonPhotoPress async{
    FocusScope.of(context).unfocus();
    Global.routeNext = NextRoute.photoTake;
    Navigator.pop(context);
    setState((){});
  }

  Future get _buttonSavePress async{
    setState(() => buttonSave = ButtonState.loading);
    await DataManager().beginProcess;
    buttonSave =              ButtonState.default0;
    editingController.text =  '';
    await DataManager(quickCall: QuickCall.askPhotos).beginQuickCall;
    if(isSignature){
      Global.currentRoute;
      Global.routeNext = NextRoute.signature;
      Navigator.popUntil(context, ModalRoute.withName('/signature'));
      await Navigator.pushReplacementNamed(context, '/signature');
    }
    else{
      Global.routeBack;
      Navigator.pop(context);
      //await Navigator.pushReplacementNamed(context, '/dataForm');
    }
  }

  Future<bool> get _handlePop async{
    switch(Global.currentRoute){

      case NextRoute.photoCheck:
        if(isSignature){
          Global.routeNext = NextRoute.signature;
          DataFormState.buttonListPictures[selectedIndex] = ButtonState.default0;
          Navigator.popUntil(context, ModalRoute.withName('/signature'));
          await Navigator.pushReplacementNamed(context, '/signature');
        }
        else{
          Global.routeBack;
          DataFormState.buttonListPictures[selectedIndex] = ButtonState.default0;
          Navigator.popUntil(context, ModalRoute.withName('/dataForm'));
          await Navigator.pushReplacementNamed(context, '/dataForm');
        }
        return false;

      case NextRoute.photoPreview:
        bool result = await Global.yesNoDialog(context, title: 'Kép elvetése?', content: 'Biztosan vissza kíván lépni?\nÍgy minden módosítás kárbavész.');
        if(result){
          Global.routeBack;          
          buttonComment =             ButtonState.default0;
          editingController.text =    '';
          if(isSignature){
            Navigator.popUntil(context, ModalRoute.withName('/signature'));
            await Navigator.pushReplacementNamed(context, '/signature');
          }
          else{
            Navigator.popUntil(context, ModalRoute.withName('/dataForm'));
            await Navigator.pushReplacementNamed(context, '/dataForm');
          }
        }    
        return result;

      default:return false;
    }    
  }
} 