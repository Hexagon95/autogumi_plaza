// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:autogumi_plaza/routes/probe_measuring.dart';
import 'package:autogumi_plaza/routes/photo_preview.dart';
import 'package:autogumi_plaza/routes/signature.dart';
import 'package:autogumi_plaza/routes/calendar.dart';
import 'package:autogumi_plaza/data_manager.dart';
import '../global.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:masked_text/masked_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DataForm extends StatefulWidget {//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataForm>
  const DataForm({super.key});

  @override
  State<DataForm> createState() => DataFormState();
}

class DataFormState extends State<DataForm> {//-- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataFormState>
  // ---------- < Wariables [Static] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> rawData =                      List<dynamic>.empty();
  static List<dynamic> rawDataExtra =                 List<dynamic>.empty();
  static List<dynamic> rawDataExtraCopy =             List<dynamic>.empty();
  static List<dynamic> rawDataCopy =                  List<dynamic>.empty();
  static List<dynamic> dataQuickCall1Copy =           List<dynamic>.empty();
  static Map<String, dynamic> listOfLookupDatasCopy = {};
  static List<ButtonState> buttonListPictures =       List<ButtonState>.empty(growable: true);
  static List<int> numberOfPictures =                 List<int>.empty(growable: true);
  static List<String> titles =                        List<String>.empty();
  static List<bool> progress =                        List<bool>.empty();
  static Map<String, dynamic> listOfLookupDatas =     <String, dynamic>{};
  static ButtonState buttonCamera =                   ButtonState.disabled;
  static String workType =                            '';
  static int indexOfShot =                            0;
  static int indexOfExtraForm =                       0;
  static bool isFoglalas =                            true;
  static bool quickSaveLock =                         false;
  static bool isClosed =                              false;
  static bool isExtraForm =                           false;
  static bool isScreenLocked =                        false;
  static int? amount;
  static int? selectedIndexInCalendar;
  static int get currentProgress{
    if(progress.isNotEmpty) for(int i = 0; i < progress.length; i++) {if(!progress[i]) return i;}
    return 0;
  }
  static set currentProgress(int value){
    if(progress.isNotEmpty) for(int i = 0; i < progress.length; i++) {if(i < value){progress[i] = true;} else{progress[i] = false;}}
  }
  static ButtonState _buttonContinue = ButtonState.disabled; static ButtonState get buttonContinue => _buttonContinue; static set buttonContinue(ButtonState input){
    _buttonContinue = (isClosed && currentProgress == progress.length - 1)? ButtonState.disabled : input;
  }

  // ---------- < Wariables [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<TextEditingController> controllerCopy =  List<TextEditingController>.empty(growable: true);
  List<TextEditingController> controller =      List<TextEditingController>.empty(growable: true);
  List<FocusNode> focusNode =                   List<FocusNode>.empty(growable: true);
  ButtonState buttonCopy =                      ButtonState.disabled;
  ButtonState buttonBack =                      ButtonState.default0;
  ButtonState buttonSave =                      ButtonState.disabled;
  ButtonState buttonSaveProgress =              ButtonState.default0;
  bool enableInteraction =                      true;
  int numberOfRequiredPictures =                0;
  BoxDecoration customBoxDecoration =           BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );
  BoxDecoration customMandatoryBoxDecoration = BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(255, 255, 0, 0), width: 1),
    color:        const Color.fromARGB(255, 255, 230, 230),
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  bool get changeDetected{
    if(currentProgress < 2) return false;
    for(int i = 0; i < DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'].length; i++){
      if(DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'][i]['name'] == 'DOT-szám')break;
      if(
        DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'][i]['value'] !=
        DataManager.dataQuickCall[0]['poziciok'][currentProgress - 2]['adatok'][i]['value']
      ) {return true;}
    }
    return false;
  }

  // ---------- < Constructor > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  DataFormState() {_resetController(rawData);}

  // ---------- < WidgetBuild [1] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
   Widget build(BuildContext context) => AbsorbPointer(absorbing: isScreenLocked, child: GestureDetector(
      onTap:  () => setState((){}),
      child:  WillPopScope(
        onWillPop:  _handlePop,
        child:      (!isExtraForm)
        ? Scaffold(
          appBar: AppBar(
            title:                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_drawButtonCancel, _drawTitleProgressBar, _drawOptionsMenu]),
            backgroundColor:            Global.getColorOfButton(ButtonState.default0),
            automaticallyImplyLeading:  false,
          ),
          backgroundColor:  Colors.white,
          body:             LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _drawFormList,
                _drawBottomBar
              ]);
            }
          ),
        )
        : Scaffold(
          appBar: AppBar(
            title:                      Center(child: Text('Új hozzáadása', style: TextStyle(color: Global.getColorOfIcon(ButtonState.default0), fontWeight: FontWeight.bold))),
            backgroundColor:            Global.getColorOfButton(ButtonState.default0),
            automaticallyImplyLeading:  false,
          ),
          backgroundColor:  Colors.white,
          body:             LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _drawFormListExtra,
                _drawBottomBarExtra
              ]);
            }
          )
        )
      )
    ));

  // ---------- < WidgetBuild [2] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawFormList{
    int maxSor() {int maxSor = 1; for(var item in rawData) {if(item['sor'] > maxSor) maxSor = item['sor'];} return maxSor;}
    bool isMandatory(int index) => (
      rawData[index]['mandatory'] != null
      && Global.trueString.contains(rawData[index]['mandatory'].toString())
      && (rawData[index]['value'] == null || rawData[index]['value'].isEmpty)
    );
    
    List<Widget> varListWidget = List<Widget>.empty(growable: true);
    for(int sor = 1; sor <= maxSor(); sor++) {
      List<Widget> row = List<Widget>.empty(growable: true);
      for(int i = 0; i < rawData.length; i++) {if(rawData[i]['sor'] == sor){
        if(rawData[i]['visible'] != null && Global.falseString.contains(rawData[i]['visible'].toString())) continue;
        row.add(Padding(
          padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child:    Container(decoration: (isMandatory(i))? customMandatoryBoxDecoration : customBoxDecoration, child: Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawData, rawData[i], i)))
        ));
      }}
      varListWidget.add(SizedBox(width: MediaQuery.of(context).size.width, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: row)));
    }
    _setButtonContinue;
    return Expanded(child: SingleChildScrollView(child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:           varListWidget
    )));
  }

  Widget get _drawFormListExtra{
    int maxSor() {int maxSor = 1; for(var item in rawDataExtra) {if(item['sor'] > maxSor) maxSor = item['sor'];} return maxSor;}
    bool isMandatory(int index) => (
      rawDataExtra[index]['mandatory'] != null
      && Global.trueString.contains(rawDataExtra[index]['mandatory'].toString())
      && (rawDataExtra[index]['value'] == null || rawDataExtra[index]['value'].isEmpty)
    );

    List<Widget> varListWidget = List<Widget>.empty(growable: true);
    for(int sor = 1; sor <= maxSor(); sor++) {
      List<Widget> row = List<Widget>.empty(growable: true);
      for(int i = 0; i < rawDataExtra.length; i++) {if(rawDataExtra[i]['sor'] == sor){
        if(i == 15){
          if(kDebugMode)print('Stop');
        }
        row.add(Padding(
          padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child:    Container(decoration: (isMandatory(i))? customMandatoryBoxDecoration : customBoxDecoration, child: Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawDataExtra, rawDataExtra[i], i)))
        ));
      }}
      varListWidget.add(SizedBox(width: MediaQuery.of(context).size.width, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: row)));
    }
    return Expanded(child: SingleChildScrollView(child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:           varListWidget
    )));
  }

  Widget get _drawTitleProgressBar{
    Color getColorOfText(int i) => Global.getColorOfIcon((i == currentProgress)? ButtonState.default0 : ButtonState.disabled);

    List<Widget> titleBarList = List<Widget>.empty(growable: true);
    for(int i = 0; i < progress.length; i++){
      if(i == 0) {titleBarList.add(Text(_getTitleString, style: TextStyle(color: getColorOfText(i))));}
      else{
        if(i == 1) titleBarList.add(Text(' > Pozíciók: ', style: TextStyle(color: Global.getColorOfIcon(ButtonState.disabled))));
        if(i > 1) titleBarList.add(Text(' > ', style: TextStyle(color: Global.getColorOfIcon(ButtonState.disabled))));
        titleBarList.add(Text(titles[i], style: TextStyle(color: getColorOfText(i))));
      }
    }
    return Center(child: Padding(padding: const EdgeInsets.all(15), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: titleBarList)));
  }

  Widget get  _drawOptionsMenu => (!isClosed || (['Eseti', 'Szezonális'].contains(workType) && Global.currentRoute == NextRoute.tabForm && !isClosed))
  ? PopupMenuButton(
    icon:             Icon(Icons.menu, color: Global.getColorOfIcon(ButtonState.default0), size: 34),
    color:            Colors.transparent,
    shadowColor:      Colors.transparent,
    surfaceTintColor: Colors.transparent,
    itemBuilder:      (BuildContext buildContext) => [
      PopupMenuItem(child: _drawButtonSaveProgress)
    ]
  )
  : Icon(Icons.menu, color: Global.getColorOfIcon(ButtonState.disabled), size: 34);

  Widget get _drawBottomBar{
    buttonCopy = changeDetected? ButtonState.default0 : ButtonState.disabled;
    return Container(
      height: 50,
      color:  Global.getColorOfButton(ButtonState.default0),
      child:  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: switch (currentProgress) {
        0 => [_drawButtonBack, _drawButtonNext],
        1 => [_drawButtonBack, _drawButtonCamera, _drawButtonListPictures, _drawButtonNext]
        ,
        _ => [Row(children: [_drawButtonBack, _drawButtonCopy]), _drawButtonCamera, _drawButtonListPictures, _drawButtonNext]
        ,
      })
    );
  }

  Widget get _drawBottomBarExtra{
    return Container(
      height: 50,
      color:  Global.getColorOfButton(ButtonState.default0),
      child:  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [_drawButtonCancelExtra, Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: _drawButtonExtraCopy)]),
        _drawButtonContinue
      ])
    );
  }

  // ---------- < WidgetBuild [3] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonSaveProgress => TextButton(
    onPressed:        (buttonSaveProgress == ButtonState.default0)? _quickSave : null,
    style:            ButtonStyle(
      backgroundColor:  MaterialStateProperty.all(Global.getColorOfButton(buttonSaveProgress)),
      side:             MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonSaveProgress)))
    ),
    child:            Row(children: [
      _drawProgressIndicator(buttonSaveProgress),
      Icon(Icons.save_as, color: Global.getColorOfIcon(buttonSaveProgress)),
      Text(' Mentés zárás nélkül', style: TextStyle(color: Global.getColorOfIcon(buttonSaveProgress), fontSize: 16))
    ]),
  );

  Widget get _drawButtonBack => TextButton(
    onPressed:  () async => await _buttonBackPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      Icon(Icons.arrow_back, color: Global.getColorOfIcon(buttonBack), size: 30)
    ]))
  );

  Widget get _drawButtonCancel => TextButton(
    onPressed:  () async => await _buttonCancelPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      Icon(Icons.close, color: Global.getColorOfIcon(buttonBack), size: 30)
    ]))
  );

  Widget get _drawButtonCancelExtra => TextButton(
    onPressed:() async => await _buttonCancelExtraPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      Icon(Icons.close, color: Global.getColorOfIcon(buttonBack), size: 30)
    ]))
  );

  Widget get _drawButtonNext {switch(Global.currentRoute){
    case NextRoute.abroncsIgenyles:
    case NextRoute.szezonalisMunkalapFelvitele:
    case NextRoute.esetiMunkalapFelvitele:      return _drawButtonSave;
    default:                                    return (currentProgress == progress.length - 1)? _drawButtonSignature : _drawButtonContinue;
  }}

  Widget get _drawButtonContinue => Padding(padding: const EdgeInsets.fromLTRB(0, 0, 80, 0), child: TextButton(
    onPressed:  () async => (buttonContinue == ButtonState.default0)? _buttonContinuePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonContinue == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonContinue)) : Container(),
      Icon((isExtraForm)? Icons.save : Icons.arrow_forward, color: Global.getColorOfIcon(buttonContinue), size: 30)
    ]))
  ));

  Widget get _drawButtonSignature => Padding(padding: const EdgeInsets.fromLTRB(0, 0, 80, 0), child: TextButton(
    onPressed:  () async => (buttonContinue == ButtonState.default0)? _buttonSignaturePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonContinue == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonContinue)) : Container(),
      Icon(Icons.edit_document, color: Global.getColorOfIcon(buttonContinue), size: 30)
    ]))
  ));

  Widget get _drawButtonSave => TextButton(
    onPressed:  () async => (buttonContinue == ButtonState.default0)? _buttonSavePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonContinue == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonContinue)) : Container(),
      Icon(Icons.save, color: Global.getColorOfIcon(buttonContinue), size: 30)
    ]))
  );

  Widget get _drawButtonCopy => (!['Szezonális', 'Eseti'].contains(workType))? TextButton(
    onPressed:  () async => (buttonCopy == ButtonState.default0)? _buttonCopyPressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children:[
      (buttonCopy == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonCopy)) : Container(),
      Icon(Icons.copy, color: Global.getColorOfIcon(buttonCopy), size: 30)
    ]))
  )
  : Container();

  Widget get _drawButtonExtraCopy {
    buttonCopy = (buttonCopy == ButtonState.disabled)? ButtonState.default0 : buttonCopy;
    return (rawDataExtraCopy.isNotEmpty)? TextButton(
      onPressed:  () async => (buttonCopy == ButtonState.default0)? _buttonExtraCopyPressed : null,
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child:      Padding(padding: const EdgeInsets.all(5), child: Row(children:[
        (buttonCopy == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonCopy)) : Container(),
        Icon(Icons.copy, color: Global.getColorOfIcon(buttonCopy), size: 30)
      ]))
    )
    : Container();
  }

  Widget get _drawButtonCamera => TextButton(
    onPressed:  () async => (buttonCamera == ButtonState.default0)? _buttonCameraPressed() : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children:[
      (buttonCamera == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonCamera)) : Container(),
      Icon(Icons.camera_alt, color: Global.getColorOfIcon(buttonCamera), size: 30)
    ]))
  );

  Widget get _drawButtonListPictures{
    List<Widget> listButtons = List<Widget>.empty(growable: true);
    
    for(int i = 0; i < buttonListPictures.length; i++) {listButtons.add(TextButton(
      onPressed:  () async => (buttonListPictures[i] == ButtonState.default0)? _buttonListPicturesPressed(i) : null,
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child:      Padding(padding: const EdgeInsets.all(5), child: Row(children:[ 
        (buttonListPictures[i] == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonListPictures[i])) : Container(),
        Icon(Icons.image_outlined, color: Global.getColorOfIcon(buttonListPictures[i]), size: 30)
      ]))
    ));}
    return Row(children: listButtons);
  }

  Widget _drawProgressIndicator(ButtonState inputButton) => (inputButton == ButtonState.loading)
  ? Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfButton(inputButton))))
  : Container();

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  void initState(){
    super.initState();
    _initOpenForm();
  }

  @override
  void dispose(){
    Global.lookupCache.clear();
    super.dispose();
  }

  Future _quickSave() async{
    if(!enableInteraction) return;
    if(quickSaveLock) return;
    quickSaveLock = true;
    setState(() => buttonSaveProgress = ButtonState.loading);
    switch(currentProgress){
      case 0:
        DataManager.dataQuickCall[0]['foglalas'] =  rawData;
        DataManager.dataQuickCall[1][0] =           listOfLookupDatas;
        break;

      default:
        DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'] = rawData;
        DataManager.dataQuickCall[1][currentProgress] =                           listOfLookupDatas;
      break;
    }
    switch(workType){
      case 'Eseti':       await DataManager(quickCall: QuickCall.saveEsetiMunkalapFelvitele,      input: {'lezart': 0, 'quickSave': true}).beginQuickCall; break;
      case 'Szezonális':  await DataManager(quickCall: QuickCall.saveSzezonalisMunkalapFelvitele, input: {'lezart': 0, 'quickSave': true}).beginQuickCall; break;
      default: break;
    }
    CalendarState.selectedIndexList = null;
    Global.routeBack;
    await DataManager().beginProcess;
    quickSaveLock = false;
    buttonSaveProgress = ButtonState.default0;
    Navigator.popUntil(context, ModalRoute.withName('/calendar'));
    await Navigator.pushReplacementNamed(context, '/calendar');
  }

  Widget _getWidget(List<dynamic> thisData, dynamic input, int index){
    bool editable =           (Global.trueString.contains(input['editable'].toString()));
    controller[index].text =  (thisData[index]['value'] == null)? '' : thisData[index]['value'].toString();
    double getWidth(int index) {int sorDB = 0; for(var item in thisData) {if(item['sor'] == thisData[index]['sor']) sorDB++;} return MediaQuery.of(context).size.width / sorDB - 22;}
    TextInputType? getKeyboard(String? keyboardType) {if(keyboardType == null) return null; switch(keyboardType){
      case 'number':  return TextInputType.number;
      default:        return TextInputType.text;
    }}

    switch(input['input_field']){

      case 'search':
        List<String> items =    List<String>.empty(growable: true);
        for(var item in listOfLookupDatas[input['id']]) {items.add(item['megnevezes'].toString());}
        return (items.isNotEmpty && !isClosed)
        ? Stack(alignment: AlignmentDirectional.centerStart, children: [
            Visibility(visible: (thisData[index]['value'] == null), child: Padding(padding: const EdgeInsets.all(5), child: Text(
              thisData[index]['name'],
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ))),
            SizedBox(height: 55, width: getWidth(index), child: DropdownSearch<String>(
              items:                  items,
              selectedItem:           controller[index].text,
              popupProps:             const PopupProps.menu(showSearchBox: true, searchFieldProps: TextFieldProps(autofocus: true)),
              onChanged:              (String? newValue) => _handleSelectChange(thisData, newValue, index),
              dropdownButtonProps:    const DropdownButtonProps(
                icon:                     Row(mainAxisSize: MainAxisSize.min, children:[Icon(Icons.search), Icon(Icons.arrow_downward)]),
                padding:                  EdgeInsets.symmetric(vertical: 16),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                baseStyle:                const TextStyle(color: Colors.black),
                textAlign:                TextAlign.start,
                textAlignVertical:        TextAlignVertical.center,
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  labelText:      thisData[index]['name'],
                  border:         InputBorder.none,
                )
              ),
            ))
          ])
        : SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:      false,          
          controller:   controller[index],
          decoration:   InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      thisData[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      case 'select':
        bool isInLookupData(String input, List<dynamic>? list) {if(list != null)for(var item in list) {if(item['id'].toString() == input) return true;} return false;}
        String getItem(dynamic varList, String id) {for(dynamic item in varList) {if(item['id'] == id) return item['megnevezes'];} return '';}

        List<DropdownMenuItem<String>> items =  List<DropdownMenuItem<String>>.empty(growable: true);
        List<dynamic>? lookupData =             listOfLookupDatas[input['id']];
        if(lookupData != null) for(var item in lookupData) {items.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['megnevezes'], textAlign: TextAlign.start)));}
        String? selectedItem =    (isInLookupData(thisData[index]['value'].toString(), lookupData))? thisData[index]['value'].toString() : null;
        return (lookupData != null && (lookupData.isNotEmpty || input['buttons'] != null) && editable && !isClosed)
        ? Stack(children: [
          SizedBox(height: 55, width: getWidth(index), child: Padding(padding: const EdgeInsets.all(15), child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value:            selectedItem,
            hint:             Text(thisData[index]['name'].toString(), textAlign: TextAlign.start),
            icon:             const Icon(Icons.arrow_downward),
            iconSize:         24,
            elevation:        16,
            isExpanded:       false,
            alignment:        AlignmentDirectional.centerStart,
            dropdownColor:    const Color.fromRGBO(230, 230, 230, 1),
            menuMaxHeight:    MediaQuery.of(context).size.height / 3,
            onChanged:        (String? newValue) async => await _handleSelectChange(thisData, newValue, index),
            items:            items
          )))),
          (selectedItem != null)
          ? Text(thisData[index]['name'].toString(), style: const TextStyle(color: Colors.grey))
          : Container(),
          (input['buttons'] != null)? SizedBox(height: 55, width: getWidth(index) - 60, child: Row(
            mainAxisAlignment:  MainAxisAlignment.end,
            children:           [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 30, 0), child: IconButton(onPressed: () => _selectAddPressed(index: index), icon: const Icon(Icons.add, size: 30)))]
          )) : Container(),
        ])
        : SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:      false,
          initialValue: (selectedItem != null)? getItem(lookupData, selectedItem) : null,
          controller:   (selectedItem != null)? null : controller[index],
          decoration:   InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      thisData[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      case 'number':
      case 'integer': switch(input['name']){

        case 'Profilmélység': return Stack(children: [
          SizedBox(height: 55, width: getWidth(index), child: TextFormField(
            enabled:            (editable && !isClosed),          
            controller:         controller[index],
            onEditingComplete:  () => setState(() {_checkDouble(thisData, controller[index].text, input, index); _handleSelectChange(thisData, controller[index].text, index); focusNode[index].unfocus();}),
            onTapOutside:       (PointerDownEvent varPointerDownEvent) => setState(() {_checkDouble(thisData, controller[index].text, input, index); _handleSelectChange(thisData, controller[index].text, index); focusNode[index].unfocus();}),
            focusNode:          focusNode[index],
            decoration:         InputDecoration(
              contentPadding:     const EdgeInsets.all(10),
              labelText:          input['name'],
              border:             InputBorder.none, 
            ),
            style:        TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          )),
          SizedBox(height: 55, width: getWidth(index), child: const Row(
            mainAxisAlignment:  MainAxisAlignment.end,
            children:           [IconButton(onPressed: null /*() => _measureProfilmelyseg(index: index)*/, icon: Icon(Icons.line_weight_sharp, size: 30))]
          ))
        ]);

        default: return SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:            (editable && !isClosed),          
          controller:         controller[index],
          onEditingComplete:  () => setState((){
            _formatInput(controller[index], int.parse(thisData[index]['decimal_places']?.toString() ?? '0'));
            _checkDouble(thisData, controller[index].text, input, index);
            _handleSelectChange(thisData, controller[index].text, index);
            focusNode[index].unfocus();
          }),
          onTapOutside:       (PointerDownEvent varPointerDownEvent) => setState((){
            _formatInput(controller[index], int.parse(thisData[index]['decimal_places']?.toString() ?? '0'));
            _checkDouble(thisData, controller[index].text, input, index);
            _handleSelectChange(thisData, controller[index].text, index);
            focusNode[index].unfocus();
          }),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // Allow numbers and decimals
          ],
          focusNode:          focusNode[index],
          decoration:         InputDecoration(
            contentPadding:     const EdgeInsets.all(10),
            labelText:          input['name'],
            border:             InputBorder.none,
          ),
          style:        TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ));
      }

      case 'checkbox': return SizedBox(height: 55, width: getWidth(index), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          '   ${thisData[index]['name'].toString()}',
          style: TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153))
        ),
        Row(children: [
          Visibility(visible: (!editable || isClosed), child: const Icon(Icons.lock, color: Color.fromRGBO(200, 200, 200, 1))),
          CupertinoSwitch(
            value:        (thisData[index]['value'] != null && thisData[index]['value'].toString() == '1'),
            onChanged:    (value) async => (editable && !isClosed)? await _handleSelectChange(thisData, value? '1' : '0', index, isCheckBox: true) : null,
            activeColor:  Global.getColorOfButton((editable && !isClosed)? ButtonState.default0 : ButtonState.disabled),
          )
        ])
      ]));

      case 'date': return Stack(children:[
        SizedBox(height: 55, width: getWidth(index), child: TextField(
          enabled:          false,
          controller:       controller[index],
          decoration:       InputDecoration(
            contentPadding:   const EdgeInsets.all(10),
            labelText:        input['name'],
            border:           InputBorder.none,
          ),
          style: TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        )),
        (editable && !isClosed)
        ? SizedBox(height: 55, width: getWidth(index), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(
            onPressed: (){
              picker.DatePicker.showDateTimePicker(context,
                showTitleActions: true,
                onChanged:        (date) {},
                onConfirm:        (date) => setState((){
                  thisData[index]['value'] =    '${date.year}.${(date.month < 10)? '0' : ''}${date.month}.${(date.day < 10)? '0' : ''}${date.day} ${(date.hour < 10)? '0' : ''}${date.hour}:${(date.minute < 10)? '0' : ''}${date.minute}';
                  thisData[index]['variable'] = date.toString();
                }),
                currentTime:      (thisData[index]['variable'] != null)? DateTime.parse(thisData[index]['variable']) : DateTime.now(),
                locale:           picker.LocaleType.hu
              );
            },
            icon: const Icon(Icons.calendar_month, size: 30)
          )
        ]))
        : Container()
      ]);

      /*case 'photo_tray':
        final listButtons = <Widget>[];
        for (int i = 0; i < buttonListPictures.length; i++) {
          listButtons.add(
            TextButton(
              onPressed: (buttonListPictures[i] == ButtonState.default0)
                  ? () => _buttonListPicturesPressed(i)
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
                minimumSize: MaterialStateProperty.all(const Size(0, 0)),  // ✅ don't expand
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,           // ✅ compact
                visualDensity: VisualDensity.compact,                      // ✅ compact
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // ✅ <— important
                children: [
                  if (buttonListPictures[i] == ButtonState.loading)
                    _progressIndicator(Global.getColorOfIcon(buttonListPictures[i])),
                  Icon(
                    Icons.image_outlined,
                    color: Global.getColorOfButton(buttonListPictures[i]),
                    size: 30,
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox(
          width: getWidth(index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(input['name']),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: listButtons,
              ),
            ],
          ),
        );*/

      case 'photo_tray': {
        // how many slots this field should show
        final int maxImgs = int.tryParse(input['max_number_of_images']?.toString() ?? '0') ?? 0;
        // how many pictures are already attached to this field
        int taken = 0;
        try {
          final pics = jsonDecode((input['pictures'] ?? '[]').toString());
          if (pics is List) taken = pics.length;
        } catch (_) { /* ignore bad json */ }
        // small helper to make compact buttons that don't expand
        ButtonStyle compactBtnStyle(Color? bg) => ButtonStyle(
              backgroundColor: MaterialStateProperty.all(bg ?? Colors.transparent),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
              minimumSize: MaterialStateProperty.all(const Size(0, 0)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
        final List<Widget> rowButtons = [];
        // 📸 camera button on the left
        rowButtons.add(
          TextButton(
            onPressed: (editable && !isClosed) ? () async => _buttonCameraPressed() : null,
            style: compactBtnStyle(Colors.transparent),
            child: Icon(
              Icons.camera_alt,
              size: 26,
              color: Global.getColorOfIcon(
                (editable && !isClosed) ? ButtonState.default0 : ButtonState.disabled,
              ),
            ),
          ),
        );
        // 🖼️ image slot buttons
        for (int j = 0; j < maxImgs; j++) {
          final bool enabled = j < taken; // enable only the already-filled slots
          final state = enabled ? ButtonState.default0 : ButtonState.disabled;
          rowButtons.add(
            TextButton(
              onPressed: enabled ? () => _buttonListPicturesPressed(j) : null,
              style: compactBtnStyle(Colors.transparent),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state == ButtonState.loading)
                    _progressIndicator(Global.getColorOfIcon(state)),
                  Icon(
                    Icons.image_outlined,
                    size: 30,
                    color: Global.getColorOfButton(state),
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox(
          width: getWidth(index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(input['name']),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rowButtons,
              ),
            ],
          ),
        );
      }

      default: return (input['input_mask'] != null && input['input_mask'].toString().isNotEmpty)
        ? SizedBox(height: 55, width: getWidth(index), child: MaskedTextField(
          enabled:          (editable && !isClosed),
          controller:       controller[index],
          mask:             input['input_mask'],
          keyboardType:     getKeyboard(input['keyboard_type']),

          decoration:       InputDecoration(
            contentPadding:   const EdgeInsets.all(10),
            labelText:        input['name'],
            hintText:         input['input_mask'],
            border:           InputBorder.none,
          ),
          onEditingComplete: () async{
            maskEditingComplete(thisData, input, index);
            if(thisData[index]['update_items'].isNotEmpty){
              await DataManager(
                quickCall:  QuickCall.chainGiveDatas,
                input:      {'rawDataInput': thisData, 'index': index, 'isCheckBox': false, 'newValue': thisData[index]['value'], 'isExtraForm': isExtraForm}
              ).beginQuickCall;
              thisData[index]['value'] = controller[index].text;
              buttonSave = DataManager.setButtonSave;
              FocusManager.instance.primaryFocus?.unfocus();
              setState((){});
            }
          },
          style: TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        ))
        : (input['name'].toString().contains('e-mail'))
        ? SizedBox(height: 55, width: getWidth(index), child: TextField(
          enabled:          (editable && !isClosed),
          controller:       controller[index],
          keyboardType:     TextInputType.emailAddress,
          decoration:       InputDecoration(
            contentPadding:   const EdgeInsets.all(10),
            labelText:        input['name'],
            border:           InputBorder.none,
          ),
          onEditingComplete: () async{
            if((RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(controller[index].text))){
              thisData[index]['value'] = controller[index].text;
              buttonSave = DataManager.setButtonSave;
              FocusManager.instance.primaryFocus?.unfocus();
              setState((){});
            }
            else {setState(() {controller[index].text = ''; thisData[index]['value'] = ''; buttonSave = DataManager.setButtonSave;});}
            if(thisData[index]['update_items'].isNotEmpty){
              await DataManager(
                quickCall:  QuickCall.chainGiveDatas,
                input:      {'rawDataInput': thisData, 'index': index, 'isCheckBox': false, 'newValue': thisData[index]['value'], 'isExtraForm': isExtraForm}
              ).beginQuickCall;
              thisData[index]['value'] = controller[index].text;
              buttonSave = DataManager.setButtonSave;
              FocusManager.instance.primaryFocus?.unfocus();
              setState((){});
            }
          },
          style: TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        ))
        : (input['name'].toString().contains('telefon'))
        ? SizedBox(height: 55, width: getWidth(index), child: TextField(
          enabled:          (editable && !isClosed),
          controller:       controller[index],
          keyboardType:     TextInputType.phone,
          decoration:       InputDecoration(
            contentPadding:   const EdgeInsets.all(10),
            labelText:        input['name'],
            border:           InputBorder.none,
          ),
          onChanged: (String input) => setState((){
            thisData[index]['value'] =  controller[index].text;
            buttonSave =                DataManager.setButtonSave;
          }),
          onEditingComplete: () async {if(thisData[index]['update_items'].isNotEmpty){
            await DataManager(
              quickCall:  QuickCall.chainGiveDatas,
              input:      {'rawDataInput': thisData, 'index': index, 'isCheckBox': false, 'newValue': thisData[index]['value'], 'isExtraForm': isExtraForm}
            ).beginQuickCall;
            thisData[index]['value'] =  controller[index].text;
            buttonSave =                DataManager.setButtonSave;
            FocusManager.instance.primaryFocus?.unfocus();
            setState((){});
          }},
          style: TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        ))
        : SizedBox(height: 55, width: getWidth(index), child: TextField(
          enabled:          (editable && !isClosed),
          controller:       controller[index],
          keyboardType:     getKeyboard(input['keyboard_type']),
          decoration:       InputDecoration(
            contentPadding:   const EdgeInsets.all(10),
            labelText:        input['name'],
            border:           InputBorder.none,
          ),
          onChanged: (String input) => setState((){
            thisData[index]['value'] =  controller[index].text;
            buttonSave =                DataManager.setButtonSave;
          }),
          onEditingComplete:() async {if(thisData[index]['update_items'].
          isNotEmpty){
            await DataManager(
              quickCall:  QuickCall.chainGiveDatas,
              input:      {'rawDataInput': thisData, 'index': index, 'isCheckBox': false, 'newValue': thisData[index]['value'], 'isExtraForm': isExtraForm}
            ).beginQuickCall;
            thisData[index]['value'] =  controller[index].text;
            buttonSave =                DataManager.setButtonSave;
            FocusManager.instance.primaryFocus?.unfocus();
            setState((){});
          }},
          style: TextStyle(color: (editable && !isClosed)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        ))
      ;
    }
  }

  Future get _buttonContinuePressed async{
    if(!enableInteraction) return;
    numberOfRequiredPictures = 0;
    if(isExtraForm){
      setState(() => buttonContinue = ButtonState.loading);
      rawDataExtraCopy = List.from(rawDataExtra);
      await DataManager().executeSql(input: await jsonDecode(rawData[indexOfExtraForm]['buttons'].toString())[0]['sql_output'], parameter: rawDataExtra);
      buttonContinue = ButtonState.disabled;
      await _extraFormFinish;
    }
    else{
      buttonCamera = ButtonState.default0;
      if(numberOfPictures[currentProgress] > buttonListPictures.length){
        await Global.showAlertDialog(context,
          title:    'Hiányzó fényképek!',
          content:  'Szükséges fényképek száma a folytatáshoz: ${numberOfPictures[currentProgress]}.'
        );
        FocusScope.of(context).unfocus();
        setState((){});
        return;
      }
      switch(currentProgress){
        case 0:
          DataManager.dataQuickCall[0]['foglalas'] =  rawData;
          DataManager.dataQuickCall[1][0] =           listOfLookupDatas;
          rawData =                                   DataManager.dataQuickCall[0]['poziciok'][0]['adatok'];
          listOfLookupDatas =                         DataManager.dataQuickCall[1][1];
          progress[currentProgress] =                 true;
          await DataManager(quickCall: QuickCall.askPhotos).beginQuickCall;
          _resetController(rawData);
          break;

        default:
          if(currentProgress == progress.length - 1) break;
          DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'] = rawData;
          DataManager.dataQuickCall[1][currentProgress] =                         listOfLookupDatas;
          progress[currentProgress] = true;
          await DataManager(quickCall: QuickCall.askPhotos).beginQuickCall;
          rawData =                   DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'];
          for(String entry in DataManager.dataQuickCall[1][currentProgress - 1].keys){
            if(DataManager.dataQuickCall[1][currentProgress][entry] != null){
              DataManager.dataQuickCall[1][currentProgress][entry] = DataManager.dataQuickCall[1][currentProgress - 1][entry];
            }}
          listOfLookupDatas =         DataManager.dataQuickCall[1][currentProgress];
          _resetController(rawData);
          break;
      }
      FocusScope.of(context).unfocus();
      setState((){});
    }
    await refreshImages();
    setState((){});
  }

  Future get _buttonSavePressed async {if(!enableInteraction) {return;} switch(Global.currentRoute){
    case NextRoute.abroncsIgenyles:
    case NextRoute.esetiMunkalapFelvitele:
    case NextRoute.szezonalisMunkalapFelvitele:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(
        quickCall:  (){switch(Global.currentRoute){
          case NextRoute.abroncsIgenyles:             return QuickCall.saveAbroncsIgenyles;
          case NextRoute.szezonalisMunkalapFelvitele: return QuickCall.saveSzezonalisMunkalapFelvitele;
          default:                                    return QuickCall.saveEsetiMunkalapFelvitele;
        }}(),
        input: {'lezart': 0}
      ).beginQuickCall;
      /*if(
        DataManager.dataQuickCall[5] != null    &&
        (DataManager.dataQuickCall[5].isNotEmpty || DataManager.dataQuickCall[5].toString() != "[]") &&
        DataManager.dataQuickCall[5][0]['name'] != null &&
        DataManager.dataQuickCall[5][0]['message'] != null
      ){
        await Global.showAlertDialog(context,
          title:    DataManager.dataQuickCall[5][0]['name'],
          content:  DataManager.dataQuickCall[5][0]['message']
        );
        setState((){buttonContinue = ButtonState.default0;});
      }
      else {
        buttonContinue = ButtonState.disabled;
        Global.routeBack;
        await DataManager().beginProcess;
        Navigator.popUntil(context, ModalRoute.withName('/calendar'));
        await Navigator.pushReplacementNamed(context, '/calendar');
      }*/
      final raw = DataManager.dataQuickCall[5];
      Map<String, dynamic>? contentMap;

      if (raw is List && raw.isNotEmpty && raw[0] is Map) {
        contentMap = Map<String, dynamic>.from(raw[0]);
      } else if (raw is Map) {
        contentMap = Map<String, dynamic>.from(raw);
      }

      if (contentMap != null && contentMap['name'] != null && contentMap['message'] != null) {
        await Global.showAlertDialog(
          context,
          title: contentMap['name'],
          content: contentMap['message'],
        );
        setState(() {
          buttonContinue = ButtonState.default0;
        });
      } else {
        buttonContinue = ButtonState.disabled;
        Global.routeBack;
        Navigator.pop(context);
        /*await DataManager().beginProcess;
        Navigator.popUntil(context, ModalRoute.withName('/calendar'));
        await Navigator.pushReplacementNamed(context, '/calendar');*/
      }
      break;

    default: return;
  }}

  Future get _buttonSignaturePressed async{
    if(!enableInteraction) return;
    setState(() => buttonContinue = ButtonState.loading);
    DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'] = rawData;
    DataManager.dataQuickCall[1][currentProgress] =                           listOfLookupDatas;
    _resetController(rawData);
    PhotoPreviewState.isSignature = true;
    await DataManager(quickCall: QuickCall.askPhotos).beginQuickCall;
    Global.routeNext =  NextRoute.signature;
    buttonContinue =    ButtonState.default0;
    await refreshImages();
    setState((){});
    if(DataManager.dataQuickCall[0]['osszesites'] != null) SignatureFormState.rawData = DataManager.dataQuickCall[0]['osszesites'];
    await Navigator.pushNamed(context, '/signature');
  }

  Future get _buttonCopyPressed async{
    if(!enableInteraction) return;
    setState(() => buttonCopy = ButtonState.loading);
    if(await Global.yesNoDialog(
      context,
      title:    'Adatok lemásolása',
      content:  'Le kívánja másolni ide, a(z) ${titles[currentProgress - 1]} pozíció adatait?'
    )){
      for(int i = 0; i < DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'].length; i++){
        if(DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'][i]['name'] == 'DOT-szám')break;
        DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'][i]['value'] =
          DataManager.dataQuickCall[0]['poziciok'][currentProgress - 2]['adatok'][i]['value']
        ;
      }
    }
    setState(() => buttonCopy = ButtonState.disabled);
  }

  Future get _buttonExtraCopyPressed async{
    if(!enableInteraction) return;
    setState(() => buttonCopy = ButtonState.loading);
    rawDataExtra =  List.from(rawDataExtraCopy);
    buttonCopy =    ButtonState.default0;
    _setButtonContinue;
    setState((){});
  }

  Future _buttonCameraPressed({bool forced = false}) async{
    if(!forced && !enableInteraction) return;
    setState(() => buttonCamera = ButtonState.loading);
    Global.routeNext =              NextRoute.photoTake;    
    PhotoPreviewState.isSignature = false;
    await Navigator.pushNamed(context, '/photo/take');
    await refreshImages();
    setState(() => buttonCamera = ButtonState.default0);
  }

  Future get _buttonBackPressed async{
    if(!enableInteraction) return;
    if(await _handlePop()) {Navigator.pop(context);}
  }

  Future get _buttonCancelPressed async {if(!enableInteraction) {return;} if(isClosed || await Global.yesNoDialog(context,
    title:    'Adatlap elhagyása',
    content:  'Elveti módosításait és visszatér a Naptárhoz?'
  )) {Global.routeBack; CalendarState.selectedIndexList = null; currentProgress = 0; isClosed = false; Navigator.pop(context);}}

  Future get _buttonCancelExtraPressed async{
    if(!enableInteraction) return;
    controller =                    List.from(controllerCopy);
    rawData =                       List.from(rawDataCopy);
    DataManager.dataQuickCall[1] =  List.from(dataQuickCall1Copy);
    listOfLookupDatas =             Map.from(listOfLookupDatasCopy);
    isExtraForm =                   false;
    isClosed =                      false;
    _setButtonContinue;
    setState((){});
  }

  Future _buttonListPicturesPressed(int i) async{
    if(!enableInteraction) return;
    setState(() => buttonListPictures[i] = ButtonState.loading);
    Global.routeNext =                NextRoute.photoCheck;
    PhotoPreviewState.selectedIndex = i; 
    await Navigator.pushNamed(context, '/photo/preview');
  }

  String get _getTitleString {switch(Global.currentRoute){
    case NextRoute.abroncsIgenyles:             return 'Igénylés';
    case NextRoute.esetiMunkalapFelvitele:      return 'Eseti Munkalap Foglalás';
    case NextRoute.szezonalisMunkalapFelvitele: return 'Szezonális Munkalap Foglalás';
    default:                                    return 'Foglalás';
  }}

  Future _selectAddPressed({required int index}) async{
    if(!enableInteraction) return;
    controllerCopy =          List.from(controller);
    rawDataCopy =             List.from(rawData);
    dataQuickCall1Copy =      List.from(DataManager.dataQuickCall[1]);
    listOfLookupDatasCopy =   Map.from(listOfLookupDatas);
    isExtraForm =             true;
    rawDataExtra =            await DataManager().getJsonFromSql(input: await json.decode(rawData[index]['buttons'].toString())[0]['sql_input']);
    _resetController(rawDataExtra);
    await DataManager(quickCall: QuickCall.giveDatas, input: {'rawDataInput': rawDataExtra}).beginQuickCall;
    indexOfExtraForm = index;
    _setButtonContinue;
    setState((){});
  }

  // ignore: unused_element
  Future _measureProfilmelyseg({required int index}) async{
    if(!enableInteraction) return;
    if(await Global.yesNoDialog(context,
      title: 'Profilmélység Mérése Szondával',
      content: 'Kívánja az abroncs profilmélységét szondával mérni?'
    )){
      Global.routeNext =          NextRoute.probeMeasuring;
      ProbeMeasuringState.index = index;
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque:       false,
          pageBuilder:  (_, __, ___) => const ProbeMeasuring()
        )
      );
    }
  }

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  void get _setButtonContinue => buttonContinue = (_isAllMandatoryFilled)? ButtonState.default0 : ButtonState.disabled;

  Future<void> _initOpenForm() async{
    if(DataManager.dataQuickCall[0]['formopen']?.isNotEmpty ?? false){
      await DataManager(
        quickCall:  QuickCall.chainGiveDatas,
        input:      {'rawDataInput': [{'id': 'formopener', 'update_items': DataManager.dataQuickCall[0]['formopen']}], 'isCheckBox': false, 'isExtraForm': false}
      ).beginQuickCall;
      setState((){});
    }
  }

  Future maskEditingComplete(List<dynamic> thisData, dynamic input, int index) async{
    switch(thisData[index]['name']){

      case 'DOT-szám':
        bool isDotNumberWrong() => (
          int.parse(controller[index].text.substring(0,2)) < 1  ||
          int.parse(controller[index].text.substring(0,2)) > 53 ||
          int.parse(controller[index].text.substring(2)) > int.parse(DateTime.now().year.toString().substring(2))
        );
        if(controller[index].text.length != input['input_mask'].length || isDotNumberWrong()){
          await Global.showAlertDialog(
            context,
            title:    'Hiba!',
            content:  'A megadott DOT-szám helytelen!'
          );
          thisData[index]['value'] = '';
        }
        else{
          thisData[index]['value'] = controller[index].text;
          _handleSelectChange(thisData, thisData[index]['value'], index);
        }
        break;

      default:
        if(controller[index].text.length == input['input_mask'].length){
          thisData[index]['value'] = controller[index].text;
          _handleSelectChange(thisData, thisData[index]['value'], index);
        }
        else {thisData[index]['value'] = '';}
        break;
    }
    buttonSave = DataManager.setButtonSave;
    FocusManager.instance.primaryFocus?.unfocus();
    setState((){});
  }

  void _formatInput(TextEditingController controller, int decimalPlaces){
    String text = controller.text.replaceAll(',', ''); // Remove thousands separators
    if (text.isNotEmpty) {
      double? value = double.tryParse(text);
      if (value != null) {
        // Create a dynamic formatter based on decimal places
        String decimalPattern = '0' * decimalPlaces;
        NumberFormat formatter = NumberFormat("0.$decimalPattern");

        // Update the controller text
        controller.value = TextEditingValue(
          text: formatter.format(value), // Format without thousand separators
          selection: TextSelection.collapsed(offset: formatter.format(value).length),
        );
      }
    }
  }

  Future _checkDouble(dynamic thisData, String? value, dynamic input, int index) async{
    double? valueDouble = double.tryParse((value == null)? '0.00' : value);
    double minValue =    (input['min_value'] != null)? double.tryParse(input['min_value'].toString())! :  0.00;
    double? maxValue =   (input['max_value'] != null)? double.tryParse(input['max_value'].toString()) :   null;
    
    if(valueDouble == null || valueDouble < minValue){
      await Global.showAlertDialog(context,
        title:    'Nem megfelelő érték!',
        content:  'A megadott érték túl kevés!'
      );
      controller[index].text =    '';
      thisData[index]['value'] =  '';
    }
    else{
      valueDouble = (maxValue != null && valueDouble > maxValue)?     maxValue :  valueDouble;
      String numberFieldString = switch (thisData[index]['name']) {
        'Km óra állás' => valueDouble.toStringAsFixed(0),
        _ =>              valueDouble.toString()
      };
      controller[index].text =  numberFieldString;
      thisData[index]['value'] = numberFieldString;
    }
    setState((){});
  }

  Future<bool> _handlePop() async{
    if(isScreenLocked) return false;
    switch(currentProgress){
      case 0:
        if(isClosed || await Global.yesNoDialog(context,
          title:    'Adatlap elhagyása',
          content:  'Elveti módosításait és visszatér a Naptárhoz?'
        )){
          Global.routeBack;
          CalendarState.selectedIndexList = null;
          isClosed =                        false;
          numberOfRequiredPictures = 0;
          Navigator.popUntil(context, ModalRoute.withName('/calendar'));
          await Navigator.pushReplacementNamed(context, '/calendar');
          return false;
        }
        else {return false;}

      default:
        buttonCamera = (currentProgress == 1)? ButtonState.disabled : ButtonState.default0;
        DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok'] = rawData;
        DataManager.dataQuickCall[1][currentProgress] =                           listOfLookupDatas;
        progress[currentProgress - 1] =                                           false;
        rawData = (currentProgress > 0)
          ? DataManager.dataQuickCall[0]['poziciok'][currentProgress - 1]['adatok']
          : DataManager.dataQuickCall[0]['foglalas']
        ;
        await DataManager(quickCall: QuickCall.askPhotos).beginQuickCall;
        listOfLookupDatas = DataManager.dataQuickCall[1][currentProgress];
        _resetController(rawData);
        numberOfRequiredPictures = 0;
        await refreshImages();
        setState((){});
        return false;
    }
  }

  Future _handleSelectChange(List<dynamic> thisData, String? newValue, int index, {bool isCheckBox = false}) async{ if(enableInteraction){
    try{
      enableInteraction =         false;
      thisData[index]['value'] =  newValue;
      if(listOfLookupDatas[thisData[index]['id']] != null) {for(dynamic item in listOfLookupDatas[thisData[index]['id']]) {item['selected'] = '0';}}
      setState((){});
      await DataManager(
        quickCall:  QuickCall.chainGiveDatas,
        input:      {'rawDataInput': thisData, 'index': index, 'isCheckBox': isCheckBox, 'newValue': newValue, 'isExtraForm': isExtraForm}
      ).beginQuickCall;
      buttonSave = DataManager.setButtonSave;
      _setButtonContinue;
      await refreshImages();
      setState((){});
    }
    catch(e) {if(kDebugMode) print(e);}
    finally {enableInteraction = true;}
  }}

  void _resetController(List<dynamic> thisData) {
    controller =  List<TextEditingController>.empty(growable: true);
    focusNode =   List<FocusNode>.empty(growable: true);
    for(int i = 0; i < thisData.length; i++){
    controller.add(TextEditingController(text: ''));
    focusNode.add(FocusNode());
    }
  }

  Future get _extraFormFinish async{
    controller =                    List.from(controllerCopy);
    rawData =                       List.from(rawDataCopy);
    isExtraForm =                     false;
    await DataManager(quickCall: QuickCall.giveDatas, input: {'rawDataInput': rawData}).beginQuickCall;
    await DataManager(
      quickCall:  QuickCall.chainGiveDatas,
      input:      {
        'rawDataInput': rawData,
        'index':        indexOfExtraForm,
        'isCheckBox':   false,
        'newValue':     (rawData[indexOfExtraForm]['kod'] != null)? rawData[indexOfExtraForm]['kod'].toString() : rawData[indexOfExtraForm]['value'].toString()
      }
    ).beginQuickCall;
    dynamic newItem = Global.getNewItem(listOfLookupDatasCopy[rawData[indexOfExtraForm]['id']], listOfLookupDatas[rawData[indexOfExtraForm]['id']]);
    if(newItem != null) await _handleSelectChange(rawData, newItem['id'], indexOfExtraForm);
    listOfLookupDatasCopy;
    listOfLookupDatas; rawData;
    _setButtonContinue;
    setState((){});
  }

  Future refreshImages() async{
    dynamic getNumberOfPicturesItem() {for(dynamic item in rawData) {if(['id_number_of_pictures_1', 'id_number_of_pictures_2', 'id_number_of_pictures_3', 'id_number_of_pictures_4', 'id_number_of_pictures_5', 'id_number_of_pictures_6'].contains(item['id'])) return item;} return null;}
    void resetButtonListPictures()    {for(int i = 0; i < numberOfPictures[currentProgress]; i++) {buttonListPictures.add(ButtonState.default0);}}

    buttonListPictures =            List<ButtonState>.empty(growable: true);
    dynamic numberOfPicturesItem =  getNumberOfPicturesItem();
    if(numberOfPicturesItem != null){
      if(numberOfPictures[currentProgress] < int.parse(numberOfPicturesItem['value'].toString())){
        for(int i = 0; i < int.parse(numberOfPicturesItem['value'].toString()); i++) {buttonListPictures.add(ButtonState.disabled);}
        for(int i = 0; i < numberOfPictures[currentProgress]; i++) {buttonListPictures[i] = ButtonState.default0;}
        int varInt = 0; for(ButtonState item in buttonListPictures) {if(item == ButtonState.disabled) varInt++;}
        if(varInt != numberOfRequiredPictures){
          numberOfRequiredPictures = varInt;
          String? varStringQ = await Global.showPhotoDialog(context,
            title:    '📸 Kötelező Fényképek',
            content:  'A továbblépéshez $varInt képet kell készítened.'
          );
          switch(varStringQ){
            case 'photo': await _buttonCameraPressed(forced: true); break;
            default:                                                break;
          }          
        }
      }
      else {numberOfPicturesItem = 0; resetButtonListPictures();}
    }
    else {numberOfPicturesItem = 0; resetButtonListPictures();}
    buttonListPictures;
  }

  // ---------- < Methods [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  bool get _isAllMandatoryFilled{
    try{
      if(currentProgress > 0 && buttonListPictures.contains(ButtonState.disabled)) return false;
      for(dynamic item in (isExtraForm)? rawDataExtra : rawData) {if(
        (item['value'] == null || item['value'].isEmpty) && Global.trueString.contains(item['mandatory'].toString())
      ) return false;}
      return true;
    }
    catch(e){
      if(kDebugMode)print(e);
      return true;
    }
  }
}