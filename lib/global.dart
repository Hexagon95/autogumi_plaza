// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------- - < Enums > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
enum NextRoute    {logIn,   calendar,       tabForm,        photoPreview, photoTake,  photoCheck, signature,  esetiMunkalapFelvitele, default0, abroncsIgenyles, szezonalisMunkalapFelvitele, probeMeasuring}
enum ButtonState  {hidden,  loading,        disabled,       error,        default0}
enum QuickCall    {tabForm, giveDatas,      chainGiveDatas, verzio,       askPhotos,  default0, cancelWork, tabletBelep, saveEsetiMunkalapFelvitele, saveAbroncsIgenyles, chainGiveDatasFormOpen, saveSzezonalisMunkalapFelvitele, askIncompleteDays, askPlateNumber}
enum Probe        {bluetoothCheck, deviceSearch, measureCommand, default0}

class Global{
  // ---------- < Variables [Static] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static const List<Map<String, Object?>> defaultIdentity = [{'id': 0, 'userName': '', 'password': ''}];
  static List<NextRoute> routes =                           List<NextRoute>.empty(growable: true);
  static NextRoute get currentRoute =>                      routes.last;
  static void get routeBack                                 {routes.removeLast(); _printRoutes;}
  static set routeNext (NextRoute value){
    int check(int i) {while(routes.length > i){routes.removeLast();} while(routes.length <= i){routes.add(NextRoute.default0);} return i;}
    switch(value){
      case NextRoute.logIn:                       routes[check(0)] = value; break;
      case NextRoute.calendar:                    routes[check(1)] = value; break;
      case NextRoute.tabForm:                     routes[check(2)] = value; break;
      case NextRoute.esetiMunkalapFelvitele:      routes[check(2)] = value; break;
      case NextRoute.szezonalisMunkalapFelvitele: routes[check(2)] = value; break;
      case NextRoute.abroncsIgenyles:             routes[check(2)] = value; break;
      case NextRoute.photoTake:                   routes[check(3)] = value; break;
      case NextRoute.photoPreview:                routes[check(3)] = value; break;
      case NextRoute.photoCheck:                  routes[check(3)] = value; break;
      case NextRoute.signature:                   routes[check(3)] = value; break;
      case NextRoute.probeMeasuring:              routes[check(3)] = value; break;
      default: throw Exception('Default route has been thrown!!!');
    }
    _printRoutes;
  }

  static BoxDecoration customBoxDecoration = BoxDecoration(
    border:       Border.all(color: Colors.green, width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  static BoxDecoration customButtonDesign(ButtonState input) => BoxDecoration(
    //border:       Border.all(color: getColorOfText(input), width: 1),
    color:        getColorOfButton(input),
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  // ---------- < SQL Commands > ----- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static const String sqlCreateTableIdentity = "CREATE TABLE identityTable(id INTEGER PRIMARY KEY, identity TEXT)";

  // ---------- < Methods [Static] > - -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static Color invertColor(Color input) => Color.fromRGBO((input.red - 255).abs(), (input.green - 255).abs(), (input.blue - 255).abs(), 1.0);

  static Map<ButtonState, Color> customColor = {
    ButtonState.default0: const Color.fromRGBO(0, 180, 125, 1.0),
    ButtonState.disabled: const Color.fromRGBO(75, 255, 200, 1.0),
    ButtonState.loading:  const Color.fromRGBO(0, 225, 0, 1.0),
    ButtonState.hidden:   Colors.transparent,
    ButtonState.error:    Colors.red
  };
  static Color getColorOfButton(ButtonState buttonState) => customColor[buttonState]!;

  static Color getColorOfIcon(ButtonState buttonState){    
    switch(buttonState){
      case ButtonState.default0:  return Colors.white;
      case ButtonState.disabled:  return const Color.fromRGBO(0, 0, 0, 0.3);
      case ButtonState.loading:   return const Color.fromRGBO(255, 255, 0, 1.0);
      case ButtonState.hidden:    return Colors.transparent;
      default:                    return Colors.red;
    }
  }

  static int getIntBoolFromString(String value) {switch(value){
    case '':
    case ' ':
    case 'FALSE':
    case 'False':
    case 'false':
    case '0':     return 0;
    default:      return 1;
  }}

  static String? getStringOrNullFromString(String value){
    if(['NULL', 'Null', 'null'].contains(value)) return null;
    return value;
  }

  static String replaceAllInAString(String input, String replaceFrom, String replaceTo){
    List<String> listString = input.split('');
    for(int i = 0; i < listString.length; i++) {if(listString[i] == replaceFrom) listString[i] = replaceTo;}
    return listString.join('');
  }

  // ---------- < Methods [1] > ------ -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static void get _printRoutes{
    String varString = 'IIIII: ';
    for(var item in routes) {varString += '$item, ';}
    if(kDebugMode)print(varString);
  }

  // ---------- < Global Dialogs > --- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static Future showAlertDialog(BuildContext context, {String title = 'Üzenet', required String content}) async{
    
    Widget okButton = TextButton(
      child: const Text('Ok'),
      onPressed: () => Navigator.pop(context, true)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title,   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 16)),
      actions:  [okButton]
    ); 

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<bool> yesNoDialog(BuildContext context, {String title = '', String content = ''}) async{
    Widget leftButton = TextButton(
      child: const Text('Igen'),
      onPressed: () => Navigator.pop(context, true)
    );
    Widget rightButton = TextButton(
      child: const Text('Nem'),
      onPressed: () => Navigator.pop(context, false)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 16)),
      actions:  [leftButton, rightButton]
    );

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<String?> showPhotoDialog(BuildContext context, {String title = 'Üzenet', required String content}) async{
    
    Widget cameraButton = TextButton(
      child: const Icon(Icons.camera_alt),
      onPressed: () => Navigator.pop(context, 'photo')
    );

    Widget okButton = TextButton(
      child: const Text('Ok'),
      onPressed: () => Navigator.pop(context, null)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title,   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 16)),
      actions:  [cameraButton, okButton]
    ); 

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<String?> textInputDialog(BuildContext context, {String title = '', String content = '', String? special}) async{
    // --------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    String? varString;
    BoxDecoration customBoxDecoration =       BoxDecoration(            
      border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color:        Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8))
    );

    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget okButton = TextButton(child: const Text('Ok'),     onPressed: () => Navigator.pop(context, varString));
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));
    Widget inputField() {switch(special){

      case 'Rendszám': return TextField(
        inputFormatters:    <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]"))],
        textCapitalization: TextCapitalization.characters,
        onChanged:          (value) => varString = value,
        decoration:         InputDecoration(
          contentPadding:     const EdgeInsets.all(10),
          labelText:          content,
          border:             InputBorder.none,
        ),
        style:              const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      );

      default: return TextFormField(
        onChanged:    (value) => varString = value,
        decoration:   InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      content,
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      );
    }}

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //

    // --------- < Display > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Container(height: 55, decoration: customBoxDecoration, child: inputField()),
      actions:  [okButton, cancel]
    );

    // --------- < Return > ---- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<String?> textButtonListDialog(BuildContext context, {String title = '', required List<String> listItems}) async{
    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));
    Widget drawButton(String input) => Padding(
      padding:  const EdgeInsets.symmetric(vertical: 10),
      child:    SizedBox(height: 40, width: 220, child: TextButton(          
        style:      ButtonStyle(
          side:            WidgetStateProperty.all(BorderSide(color: Global.getColorOfIcon(ButtonState.default0))),
          backgroundColor: WidgetStateProperty.all(Global.getColorOfButton(ButtonState.default0))
        ),
        onPressed:  () => Navigator.pop(context, input),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(input, style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(ButtonState.default0)))
        ])
      ))
    );

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    List<Widget> drawButtonList(){
      List<Widget> varList = List<Widget>.empty(growable: true);
      for(String item in listItems) {varList.add(drawButton(item));}
      return varList;
    }

    // --------- < Display > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      title:      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      scrollable: true,
      content:    Center(child: Column(mainAxisSize: MainAxisSize.min, children: drawButtonList())),
      actions:    [cancel]
    );

    // --------- < Return > ---- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static dynamic where(List<dynamic> input, String entry, String value) {for(dynamic item in input){
    if(item[entry] == value) return item;
  }}

  static dynamic getNewItem(List<dynamic> oldList, List<dynamic> newList){
    for(dynamic newItem in newList){
      bool varBool = true;
      for(dynamic oldItem in oldList) {if(newItem['id'] == oldItem['id']) varBool = false;}
      if(varBool) return newItem;
    }
    return null;
  }
}


class FormData { //------------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <FormData>
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
  List<dynamic> rawData = List<Map<String, dynamic>>.empty(growable: true);
  int? numberOfColumns;
  int? selectedIndex;
}


class ListAdd { //------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <ListAdd>
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
  String item;
  double stock;
  bool isMaterial;
  String unit;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ListAdd({required this.item, this.stock = 0, required this.isMaterial, this.unit = 'db'});
}