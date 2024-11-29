// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io' as io;
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:autogumi_plaza/routes/data_form.dart';
import 'package:autogumi_plaza/routes/photo_preview.dart';

class TakePictureScreen extends StatefulWidget {
  // ---------- < Variables [1] > -------- ---------- ---------- ----------
  final CameraDescription camera;

  // ---------- < Constructor > ---------- ---------- ---------- ----------
  const TakePictureScreen({Key? key,required this.camera}) : super(key: key);  

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  // ---------- < Variables [Static] > --- ---------- ---------- ----------
  static int indexOfShot = 0;

  // ---------- < Variables [1] > -------- ---------- ---------- ----------
  ButtonState buttonTakePicture = ButtonState.default0;
  late CameraController     _controller;
  late AnimationController  _flashModeControlRowAnimationController;
  late AnimationController  _exposureModeControlRowAnimationController;
  late Future<void>         _initializeControllerFuture;  

  // ---------- < WidgetBuild > ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _handlePop,
      child: Scaffold(
        appBar: AppBar(
          title:  PhotoPreviewState.isSignature
            ? const Text('Munkalap csatolása')
            : Text('Fénykép készítése, pozíció: ${DataFormState.titles[DataFormState.currentProgress]}')
          ,
          backgroundColor:  Global.getColorOfButton(ButtonState.default0)
        ),
        backgroundColor:  Colors.black,
        body:             FutureBuilder<void>(
          future:   _initializeControllerFuture,
          builder:  (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {return Center(child: CameraPreview(_controller));}
            else{return const Center(child: CircularProgressIndicator());}
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:  () => (buttonTakePicture == ButtonState.default0)? _pictureTake : null,
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
          child:            Icon(
            Icons.camera_alt,
            color: Global.getColorOfIcon(buttonTakePicture)
          )
        )
      )
    );
  }

  // ---------- < Methods [1] > ---------- ---------- ---------- ----------
  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    _flashModeControlRowAnimationController = AnimationController(
      duration:                               const Duration(milliseconds: 300),
      vsync:                                  this,
    );
    _exposureModeControlRowAnimationController =  AnimationController(duration: const Duration(milliseconds: 300),vsync: this);
    _controller =                                 CameraController(widget.camera, ResolutionPreset.ultraHigh);    
    _initializeControllerFuture =                 _controller.initialize();
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();   
    super.dispose(); 
  }

  Future<bool> get _handlePop async{
    if(
      PhotoPreviewState.editingController.text.isEmpty ||
      await Global.yesNoDialog(context, title: 'Kép elvetése?', content: 'Biztosan vissza kíván lépni?\nÍgy minden módosítás kárbavész.')
    ){
      Global.routeBack;
      PhotoPreviewState.editingController.text = '';
      return true;
    }
    else {return false;}
  }

  void get _pictureTake async{    
    try {
      setState(() =>  buttonTakePicture = ButtonState.disabled);
      await _initializeControllerFuture;
      indexOfShot++;
      final image =                   await _controller.takePicture();
      PhotoPreviewState.imageIdList.add(indexOfShot);
      PhotoPreviewState.imagePath =   image.path;
      PhotoPreviewState.imageBase64 = base64Encode(io.File(image.path).readAsBytesSync());      
      buttonTakePicture =             ButtonState.default0;      
      switch(Global.currentRoute){
        case NextRoute.photoTake:   Global.routeNext = NextRoute.photoPreview;  await Navigator.pushNamed(context, '/photo/preview'); break;
        default:throw Exception('Not Implemented');
      }
      setState((){});
    }
    catch (e) {      
      if(kDebugMode) print(e);
    }
  }
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;