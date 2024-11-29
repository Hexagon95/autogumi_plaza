// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:math';
import 'package:autogumi_plaza/routes/photo_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'global.dart';
import 'utils.dart';
import 'routes/signature.dart';
import 'routes/data_form.dart';
import 'routes/calendar.dart';
import 'routes/log_in.dart';

class DataManager{
  // ---------- < Variables [Static] > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static bool test =                                false; // <--- Set test/live here!!!!!!!
  static List<dynamic> data =                       List<dynamic>.empty(growable: true);
  static List<dynamic> dataQuickCall =              List<dynamic>.empty(growable: true);
  static List<dynamic> materials =                  List<dynamic>.empty(growable: true);
  static List<dynamic> quickData =                  List<dynamic>.empty(growable: true);
  static List<dynamic> comboboxQueriesDefault =     List<dynamic>.empty();
  static List<dynamic> comboboxQueriesAdditional =  List<dynamic>.empty();
  static bool isServerAvailable =                   true;
  static String customer =                          'mosaic';
  static String thisVersion =                       '1.21';
  static String actualVersion =                     thisVersion;
  static String get sqlUrlLink =>                   'https://app.mosaic.hu/sql/ExternalInputChangeSQL.php?ceg=mezandmol&SQL=';
  static const String nameOfApp =                   'MezandMol Szervíz';
  //static const String urlPath =                     'https://app.mosaic.hu/android/szerviz_mezandmol/';    // Live
  //static const String urlPath =                     'https://developer.mosaic.hu/android/szerviz_mezandmol/';  // Test
  static String urlPath =                           test? 'https://developer.mosaic.hu/android/szerviz_mezandmol/' : 'https://app.mosaic.hu/android/szerviz_mezandmol/';
  static String rootPath =                          test? 'https://developer.mosaic.hu/' : 'https://app.mosaic.hu/';
  static String get serverErrorText =>              (isServerAvailable)? '' : errorMessage;
  static String errorMessage =                      '';
  static String? foglalasId;
  static Identity? identity;
 
  // ---------- < Variables [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  final Map<String,String> headers = {'Content-Type': 'application/json'};
  dynamic input;
  QuickCall? quickCall;

  // ---------- < Constructors > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  DataManager({this.quickCall, this.input});

  // ---------- < Methods [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static Future get identitySQLite async {
    final database = openDatabase(
      p.join(await getDatabasesPath(), 'unique_identity.db'),
      onCreate:(db, version) => db.execute(Global.sqlCreateTableIdentity),
      version: 1
    );
    final db =                          await database;
    List<Map<String, dynamic>> result = await db.query('identityTable');
    if(result.isEmpty){
      identity = Identity.generate();
      await db.insert('identityTable', identity!.toMap, conflictAlgorithm: ConflictAlgorithm.replace);
      result = await db.query('identityTable');
    }
    identity = Identity(id: 0, identity: result[0]['identity'].toString());
  }

  static ButtonState get setButtonSave {
    for(var item in DataFormState.rawData){
      if(item['value'] == null || item['value'].toString().isEmpty){
        return ButtonState.disabled;
      }
    }
    return ButtonState.default0;
  }
   
  // ---------- < Methods [Public] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get beginQuickCall async{
    int check (int index) {while(dataQuickCall.length < index + 1) {dataQuickCall.add(List<dynamic>.empty());} return index;}
    try {
      isServerAvailable = true;
      switch(quickCall){

        case QuickCall.verzio: //Ha a verzió nem egyezik, akkor tegyen vissza a kezdő képernyőre!
          var queryParameters = {
            'customer':   'mosaic',
          };
          Uri uriUrl =              Uri.parse('${urlPath}verzio.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          actualVersion =           jsonDecode(response.body)[0]['verzio_autogumi_plaza'].toString();
          LogInState.updateNeeded = (thisVersion != actualVersion);
          break;

        case QuickCall.tabForm:
          switch(input['jelleg']){

            case 'Igénylés':
              var queryParameters = {
                'customer':     customer,
                'eszkoz_id':    identity.toString(),
                'datum':        CalendarState.selectedDate,
                'foglalas_id':  data[2][CalendarState.selectedIndexList!]['id'].toString()
              };
              Uri uriUrl =              Uri.parse('${urlPath}abroncs_igenyles.php');          
              http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
              dataQuickCall[check(0)] = await jsonDecode(await jsonDecode(response.body));
              break;

            case 'Eseti':
              var queryParameters = {
                'customer':     customer,
                'eszkoz_id':    identity.toString(),
                'datum':        CalendarState.selectedDate,
                'foglalas_id':  data[2][CalendarState.selectedIndexList!]['id'].toString()
              };
              Uri uriUrl =              Uri.parse('${urlPath}worksheetFormEseti.php');          
              http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
              dataQuickCall[check(0)] = await jsonDecode(await jsonDecode(response.body));
              break;

            default:
              var queryParameters = {
                'customer':     customer,
                'eszkoz_id':    identity.toString(),
                'datum':        CalendarState.selectedDate,
                'foglalas_id':  data[2][CalendarState.selectedIndexList!]['id'].toString()
              };
              Uri uriUrl =              Uri.parse('${urlPath}worksheetForm.php');          
              http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
              dataQuickCall[check(0)] = await jsonDecode(await jsonDecode(response.body));
            break;
          }
          break;

        case QuickCall.giveDatas:
          Future<Map<String, dynamic>> generateListOfLookupDatas(List<dynamic> rawData) async{
            Map<String, dynamic> listOfLookupDatas = <String, dynamic>{};
            for(dynamic item in rawData){
              if(!['select','search'].contains(item['input_field'])) continue;
              listOfLookupDatas[item['id']] = await _getLookupData(thisData: input['rawDataInput'], input: item['lookup_data'], isPhp: (item['php'].toString() == '1'));
            }
            return listOfLookupDatas;
          }
          input ??= {'rawDataInput': DataFormState.rawData};
          dataQuickCall[check(1)] = List<dynamic>.empty(growable: true);
          if(!DataFormState.isExtraForm){
            dataQuickCall[1].add(await generateListOfLookupDatas(dataQuickCall[0]['foglalas']));
            for(dynamic item in dataQuickCall[0]['poziciok']) {dataQuickCall[1].add(await generateListOfLookupDatas(item['adatok']));}
          }
          else if(DataFormState.rawDataExtra.isNotEmpty) {dataQuickCall[1].add(await generateListOfLookupDatas(DataFormState.rawDataExtra));}
          break;

        case QuickCall.chainGiveDatas:
          int getIndexFromId({required String id}) {for(int i = 0; i < input['rawDataInput'].length; i++) {if(input['rawDataInput'][i]['id'] == id) return i;} throw Exception('No such id in rawData: $id');}
          bool isLookupDataOnTheSide(String inputId) {for(dynamic item in input['rawDataInput']) {if(item['id'] == inputId) return true;} return false;}
          dynamic getItemFromId({required String id}){
            if(input['isExtraForm']) {for(dynamic item in DataFormState.rawDataExtra) {if(item['id'] == id) return item;}}
            else{
              for(dynamic item in dataQuickCall[0]['foglalas']) {if(item['id'] == id) return item;}
              for(dynamic itemList in dataQuickCall[0]['poziciok']) {for(dynamic item in itemList['adatok']) {{if(item['id'] == id) return item;}}}
              if(dataQuickCall[0]['osszesites'] != null) for(dynamic item in dataQuickCall[0]['osszesites']) {if(item['id'] == id) return item;}
            }
            throw Exception('No such Item with id: $id');
          }
          int getPlaceIndexOfId(String entry){
            for(dynamic item in dataQuickCall[0]['foglalas']) {if(item['id'] == entry) return 0;}
            for(int i = 0; i < dataQuickCall[0]['poziciok'].length; i++) {for(dynamic item in dataQuickCall[0]['poziciok'][i]['adatok']) {{if(item['id'] == entry) return i + 1;}}}
            if(dataQuickCall[0]['osszesites'] != null) for(dynamic item in dataQuickCall[0]['osszesites']) {if(item['id'] == entry) return 0;}
            throw Exception('No such Item with id: $entry');
          }

          try {input['rawDataInput'][input['index']]['kod'] = Global.where(DataFormState.listOfLookupDatas[input['rawDataInput'][input['index']]['id']],'megnevezes',input['newValue'])['id'];}
          catch(e) {/*input['rawDataInput'][input['index']]['kod'] = null;*/}

          if(input['rawDataInput'][input['index']]['update_items'] == null) return;
          for(dynamic item in input['rawDataInput'][input['index']]['update_items']) {
            try{
              bool varIsLookupDataOnTheSide =     isLookupDataOnTheSide(item['id']);
              dynamic varGetItemFromId =          getItemFromId(id: item['id']);
              List<String> sqlCommandLookupData = item['lookup_data'].toString().split(' ');
              if(sqlCommandLookupData[0] == 'SET'){
                try{
                  String fieldName = sqlCommandLookupData[1].toString().substring(1);
                  List<String> listOfStringInput = ['value', 'name', 'input_field', 'input_mask', 'keyboard_type', 'kod'];
                  if(input['isCheckBox']){
                    if(input['newValue'] == '1' && item['event'] == 'on' || input['newValue'] == '0' && item['event'] == 'off'){
                      if(sqlCommandLookupData.length == 4){
                        if(item['id'] != null){
                          if(varIsLookupDataOnTheSide)  {input['rawDataInput'][getIndexFromId(id: item['id'])][fieldName] = (listOfStringInput.contains(fieldName))? Global.getStringOrNullFromString(sqlCommandLookupData[3]) : Global.getIntBoolFromString(sqlCommandLookupData[3]);}
                          else                          {varGetItemFromId[fieldName] =                                      (listOfStringInput.contains(fieldName))? Global.getStringOrNullFromString(sqlCommandLookupData[3]) : Global.getIntBoolFromString(sqlCommandLookupData[3]);}
                        }
                        else {switch(fieldName){
                          case 'numberOfPictures': DataFormState.numberOfPictures[DataFormState.currentProgress] = int.parse(sqlCommandLookupData[3].toString());
                          default:break;
                        }}
                      }
                      if(sqlCommandLookupData.length > 4){
                        dynamic varDynamic = await _getLookupData(thisData: input['rawDataInput'], input: sqlCommandLookupData.sublist(3).join(' '), isPhp: (item['php'].toString() == '1'));
                        if(varIsLookupDataOnTheSide)  {input['rawDataInput'][getIndexFromId(id: item['id'])][fieldName] = Global.getIntBoolFromString(varDynamic[0][''].toString());}
                        else                          {varGetItemFromId[fieldName] =                                      Global.getIntBoolFromString(varDynamic[0][''].toString());}
                      }
                    }
                  }
                  else if(item['id'] != null){
                    if(sqlCommandLookupData.length == 4){
                      if(varIsLookupDataOnTheSide)  {input['rawDataInput'][getIndexFromId(id: item['id'])][fieldName] = (listOfStringInput.contains(fieldName))? Global.getStringOrNullFromString(sqlCommandLookupData[3]) : Global.getIntBoolFromString(sqlCommandLookupData[3]);}
                      else                          {varGetItemFromId[fieldName] =                                      (listOfStringInput.contains(fieldName))? Global.getStringOrNullFromString(sqlCommandLookupData[3]) : Global.getIntBoolFromString(sqlCommandLookupData[3]);}
                    }
                    if(sqlCommandLookupData.length > 4){
                      dynamic varDynamic = await _getLookupData(thisData: input['rawDataInput'], input: sqlCommandLookupData.sublist(3).join(' '), isPhp: (item['php'].toString() == '1'));
                      if(varIsLookupDataOnTheSide)  {input['rawDataInput'][getIndexFromId(id: item['id'])][fieldName] = (listOfStringInput.contains(fieldName))? Global.getStringOrNullFromString(varDynamic[0][''].toString()) : Global.getIntBoolFromString(varDynamic[0][''].toString());}
                      else                          {varGetItemFromId[fieldName] =                                      (listOfStringInput.contains(fieldName))? Global.getStringOrNullFromString(varDynamic[0][''].toString()) : Global.getIntBoolFromString(varDynamic[0][''].toString());}
                    }
                  }
                  continue;
                }
                catch(e){
                  if(kDebugMode)dev.log(e.toString());
                }
              }
              if(input['isCheckBox']) {switch(item['event']){
                case 'on':  if(input['newValue'] == '0') continue; break;
                case 'off': if(input['newValue'] == '1') continue; break;
                default:                                 continue;
              }}
              DataFormState.listOfLookupDatas[item['id']] = await _getLookupData(thisData: input['rawDataInput'], input: item['lookup_data'], isPhp: (item['php'].toString() == '1'));
              //if(varIsLookupDataOnTheSide) {input['rawDataInput'][getIndexFromId(id: item['id'])]['value'] = null;}
              //else {varGetItemFromId['value'] = null;}

              if(varGetItemFromId['input_field'] == 'checkbox'){
                if(varIsLookupDataOnTheSide){
                  input['rawDataInput'][getIndexFromId(id: item['id'])]['value'] = DataFormState.listOfLookupDatas[item['id']][0]['id'].toString();
                }
                else{
                  varGetItemFromId['value'] = DataFormState.listOfLookupDatas[item['id']][0]['id'].toString();
                }
              }
              if(varGetItemFromId['input_field'] == 'select' && item['lookup_data'] != null) {varGetItemFromId['lookup_data'] = item['lookup_data'];}
            }
            catch(e){
              if(kDebugMode)print(e);
            }
          }
          for(String entry in DataFormState.listOfLookupDatas.keys){
            try{
              if(isLookupDataOnTheSide(entry)){
                for(int i = 0; i < input['rawDataInput'].length; i++){
                  if(input['rawDataInput'][i]['id'] == entry){
                    if(['text', 'number'].contains(input['rawDataInput'][i]['input_field'])){
                      input['rawDataInput'][i]['value'] = (DataFormState.listOfLookupDatas[entry][0]['id'] == null)
                        ? ''
                        : DataFormState.listOfLookupDatas[entry][0]['id'].toString()
                      ;
                      break;
                    }
                    if(['select','search'].contains(input['rawDataInput'][i]['input_field'])){
                      if(DataFormState.listOfLookupDatas[entry].length == 0 || DataFormState.listOfLookupDatas[entry][0]['id'] == null) {DataFormState.listOfLookupDatas[entry] = List<dynamic>.empty();}
                      else {for(var item in DataFormState.listOfLookupDatas[entry]){
                        if(item['selected'] != null && item['selected'].toString() == '1') {input['rawDataInput'][i]['value'] = item['id']; break;}
                      }}
                      break;
                    }
                  }
                }
              }
              else{
                dynamic varGetItemFromId = getItemFromId(id: entry);
                if(['text', 'number'].contains(varGetItemFromId['input_field'])){
                  varGetItemFromId['value'] = (DataFormState.listOfLookupDatas[entry][0]['id'] == null)
                    ? ''
                    : DataFormState.listOfLookupDatas[entry][0]['id'].toString()
                  ;
                }
                if(['select','search'].contains(varGetItemFromId['input_field'])){
                  if(DataFormState.listOfLookupDatas[entry].length == 0 || DataFormState.listOfLookupDatas[entry][0]['id'] == null) {DataFormState.listOfLookupDatas[entry] = List<dynamic>.empty();}
                  else {for(var item in DataFormState.listOfLookupDatas[entry]){
                    if(item['selected'] != null && item['selected'].toString() == '1') {varGetItemFromId['value'] = item['id']; break;}
                  }}
                  if(!input['isExtraForm']) {dataQuickCall[1][getPlaceIndexOfId(entry)][entry] = DataFormState.listOfLookupDatas[entry];}
                }
              }
            }
            catch(e){
              if(kDebugMode)print(e);
            }
          }
          break;

        case QuickCall.chainGiveDatasFormOpen:
          dynamic getItemFromId({required String id}){
            for(dynamic item in dataQuickCall[0]['foglalas']) {if(item['id'] == id) return item;}
            for(dynamic itemList in dataQuickCall[0]['poziciok']) {for(dynamic item in itemList['adatok']) {{if(item['id'] == id) return item;}}}
            throw Exception('No such Item with id: $id');
          }
          void fillLookupDatas(dynamic rawDataInput, String entry){for(int i = 0; i < rawDataInput.length; i++){
            dataQuickCall[1];
            if(rawDataInput[i]['id'].toString() == entry){
              if(['text'].contains(rawDataInput[i]['input_field'])){
                rawDataInput[i]['value'] = (input['lookupDatas'][entry][0]['id'] == null)
                  ? ''
                  : input['lookupDatas'][entry][0]['id'].toString()
                ;
                break;
              }
              if(['select','search'].contains(rawDataInput[i]['input_field'])){
                if(input['lookupDatas'][entry].length == 0 || input['lookupDatas'][entry][0]['id'] == null) {input['lookupDatas'][entry] = List<dynamic>.empty();}
                else {for(var item in input['lookupDatas'][entry]){
                  if(item['selected'] != null && item['selected'].toString() == '1') {rawDataInput[i]['value'] = item['id']; break;}
                }}
                break;
              }
            }
          }}

          try {dataQuickCall[0]['foglalas'][input['i']]['kod'] = dataQuickCall[0]['foglalas'][input['i']]['value'];}
          catch(e) {dataQuickCall[0]['foglalas'][input['i']]['kod'] = null;}
 
          try{
            if(dataQuickCall[0]['foglalas'][input['i']]['update_items'] == null) return;
            for(dynamic item in dataQuickCall[0]['foglalas'][input['i']]['update_items']) {
              input['lookupDatas'][item['id']] = await _getLookupDataFromRawData(input: item['lookup_data'], isPhp: (item['php'].toString() == '1'));
              getItemFromId(id: item['id'])['lookup_data'] = item['lookup_data'];
            }
            for(String entry in input['lookupDatas'].keys){
              fillLookupDatas(dataQuickCall[0]['foglalas'], entry);
              for(dynamic field in dataQuickCall[0]['poziciok']) {fillLookupDatas(field['adatok'], entry);}
            }
            dataQuickCall; input['lookupDatas'];
          }
          catch(e){
            if(kDebugMode)print(e);
          }
          break;

        case QuickCall.askPhotos:
          var queryParameters = {
            'customer':     customer,
            'foglalas_id':  data[2][CalendarState.selectedIndexList!]['id'].toString(),
            'jelleg':       (DataFormState.workType == 'Igénylés')? 'Eseti' : DataFormState.workType,
            'pozicio':      PhotoPreviewState.isSignature
              ? 'Signature'
              : DataFormState.titles[DataFormState.currentProgress]
            ,
          };
          Uri uriUrl =              Uri.parse('${urlPath}ask_pictures.php');          
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(2)] = await jsonDecode(await jsonDecode(response.body)[0]['']);
          if(kDebugMode){
            String varString = dataQuickCall[2].toString();
            print(varString);
          }
          break;

        case QuickCall.cancelWork:
          var queryParameters = {
            'customer':     customer,
            'foglalas_id':  data[2][input['index']]['id'].toString(),
            'indoklas':     input['indoklas'],
            'jelleg':       input['jelleg']
          };
          Uri uriUrl =              Uri.parse('${urlPath}cancel_work.php');          
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(3)] = await jsonDecode(await jsonDecode(response.body));
          break;

        case QuickCall.tabletBelep:
          var queryParameters = {
            'customer':   customer,
            'eszkoz_id':  identity.toString(),
            'verzio':     thisVersion
          };
          Uri uriUrl = Uri.parse('${urlPath}tablet_belep.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(4)] = [response.reasonPhrase];
          break;

        case QuickCall.saveEsetiMunkalapFelvitele:
          var queryParameters = {
            'customer':   customer,
            'parameter':  (input['lezart'] != 1 && input['quickSave'] == null)? jsonEncode(DataFormState.rawData) : jsonEncode(dataQuickCall[0]),
            'lezart':     input['lezart']
          };
          Uri uriUrl = Uri.parse('${urlPath}save_eseti_munkalap.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(5)] =     (['[]', '"[]"', '""[]""'].contains(response.body))? [] : json.decode(json.decode(response.body));
          if(kDebugMode) dev.log(dataQuickCall[5].toString());
          SignatureFormState.message =  (dataQuickCall[5].isNotEmpty)? dataQuickCall[5][0] : null;
          break;

        case QuickCall.saveSzezonalisMunkalapFelvitele:
          dataQuickCall[0]['foglalas'] = DataFormState.rawData;
          if(input['lezart'] == null) input['lezart'] = 0;
          var queryParameters = {
            'customer':   customer,
            'parameter':  jsonEncode(dataQuickCall[0]),
            'lezart':     input['lezart']
          };
          Uri uriUrl =              Uri.parse('${urlPath}finish_worksheet.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(5)] = (['[]', '"[]"', '""[]""'].contains(response.body))? [] : json.decode(json.decode(response.body));
          if(kDebugMode) dev.log(dataQuickCall[5].toString());
          SignatureFormState.message =  (dataQuickCall[5].isNotEmpty)? dataQuickCall[5][0] : null;
          break;

        case QuickCall.saveAbroncsIgenyles:
          var queryParameters = {
            'customer':   customer,
            'parameter':  (input['lezart'] != 1 && input['quickSave'] == null)? jsonEncode(DataFormState.rawData) : jsonEncode(dataQuickCall[0]),
            'lezart':     input['lezart']
          };
          Uri uriUrl = Uri.parse('${urlPath}save_abroncs_igenyles.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(5)] =     (['[]', '"[]"', '""[]""'].contains(response.body))? [] : json.decode(json.decode(response.body));
          SignatureFormState.message =  (dataQuickCall[5].isNotEmpty)? dataQuickCall[5][0] : null;
          break;

        case QuickCall.askIncompleteDays:
          var queryParameters = {
            'customer':   customer,
            'eszkoz_id':  identity.toString(),
            'datum_tol':  DateFormat('yyyy.MM.dd').format(kFirstDay).toString(),
            'datum_ig':   DateFormat('yyyy.MM.dd').format(kLastDay).toString()
          };
          Uri uriUrl = Uri.parse('${urlPath}ask_incomplete_days.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) dev.log(response.body.toString());
          dataQuickCall[check(6)] =     json.decode(json.decode(response.body));
          break;

        case QuickCall.askPlateNumber:
          CalendarState.plateNumberResponse = null;
          var queryParameters = {
            'customer':     customer,
            'eszkoz_id':    identity.toString(),
            'plate_number': input['plate_number']
          };
          Uri uriUrl = Uri.parse('${urlPath}ask_plate_number.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) dev.log(response.body.toString());
          dataQuickCall[check(6)] =     json.decode(json.decode(response.body));
          break;

        default:break;
      }
    }
    catch(e) {if(![QuickCall.askPhotos].contains(quickCall)){
      if(kDebugMode)print('$e');
      errorMessage = e.toString();
    }}
    finally{
      await _decisionQuickCall;
    }
  }

  Future get beginProcess async{
    int check (int index) {while(data.length < index + 1) {data.add(List<dynamic>.empty());} return index;}
    
    try {
      isServerAvailable = true;
      switch(Global.currentRoute){

        case NextRoute.logIn:
          var queryParameters = {
            'customer':   customer,
            'login_type': input['login'],
            'eszkoz_id':  identity.toString(),
          };
          Uri uriUrl =                    Uri.parse('${urlPath}login.php');          
          http.Response response =        await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(input['number'])] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = data[input['number']].toString();
            print(varString);
          }
          break;

        case NextRoute.calendar:
          var queryParameters = {
            'customer':   customer,
            'eszkoz_id':  identity.toString(),
            'datum':      CalendarState.selectedDate,
          };
          Uri uriUrl =              Uri.parse('${urlPath}tasks.php');          
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(2)] =         await jsonDecode(response.body);
          if(kDebugMode){
            String varString = data[2].toString();
            print(varString);
          }
          break;

        case NextRoute.tabForm:
          foglalasId =          data[2][CalendarState.selectedIndexList!]['id'].toString();
          if(['Eseti', 'Igénylés'].contains(input['jelleg'])) break;
          var queryParameters = {
            'customer':     customer,
            'foglalas_id':  foglalasId
          };
          Uri uriUrl =              Uri.parse('${urlPath}worksheet.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) print(response.body);
          String varString = (response.body.substring(0,1) == '"')? response.body.substring(1, response.body.length - 1) : response.body;
          dynamic varJson = await jsonDecode(varString);
          try       {data[check(3)] = varJson[0];}
          catch(e)  {data[check(3)] = varJson;}
          if(kDebugMode){
            String varString = data[3].toString();
            print(varString);
          }
          break;

        case NextRoute.photoPreview:
          var queryParameters = {
            'customer': customer,
            'parameter': jsonEncode({
              'id':       foglalasId,
              'pozicio':  PhotoPreviewState.isSignature
                ? 'Signature'
                : DataFormState.titles[DataFormState.currentProgress]
              ,
              'kep':      PhotoPreviewState.imageBase64,
              'comment':  PhotoPreviewState.editingController.text
            })
          };
          String phpFileName = switch(DataFormState.workType){
            'Igénylés' => 'photo_save_eseti.php',
            'Eseti' =>    'photo_save_eseti.php',
            _=>           'photo_save.php'
          };
          Uri uriUrl =              Uri.parse('$urlPath$phpFileName');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) print(response.body);
          data[check(4)] =          [response.reasonPhrase];
          if(kDebugMode){
            String varString = data[4].toString();
            print(varString);
          }
          break;

        case NextRoute.signature:
          var queryParameters = {
            'customer':   customer,
            'parameter':  jsonEncode(dataQuickCall[0])
          };
          Uri uriUrl =              Uri.parse('${urlPath}finish_worksheet.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) dev.log(response.body);
          data[check(5)] =     (['[]', '"[]"', '""[]""'].contains(response.body))? [] : json.decode(json.decode(response.body));
          SignatureFormState.message =  (data[5].isNotEmpty)? data[5][0] : null;
          if(kDebugMode){
            String varString = data[5].toString();
            print(varString);
          }
          break;
 
        case NextRoute.esetiMunkalapFelvitele:
          var queryParameters = {
            'customer':     customer,
            'eszkoz_id':    identity.toString(),
            'datum':        input['datum'].toString().split(' ')[0]
          };
          Uri uriUrl =              Uri.parse('${urlPath}eseti_munkalap.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(0)] = await jsonDecode(await jsonDecode(response.body));
          break;

        case NextRoute.szezonalisMunkalapFelvitele:
          var queryParameters = {
              'customer':     customer,
              'eszkoz_id':    identity.toString(),
              'datum':        CalendarState.selectedDate,
              'foglalas_id':  0
            };
            Uri uriUrl =              Uri.parse('${urlPath}worksheetForm.php');          
            http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
            dataQuickCall[check(0)] = await jsonDecode(await jsonDecode(response.body));
          break;

        case NextRoute.abroncsIgenyles:
          var queryParameters = {
            'customer':     customer,
            'eszkoz_id':    identity.toString(),
            'datum':        input['datum'].toString().split(' ')[0],
            'foglalas_id':  0
          };
          Uri uriUrl =              Uri.parse('${urlPath}abroncs_igenyles.php');          
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(0)] = await jsonDecode(await jsonDecode(response.body));
          break;

        default:break;
      }
    }
    catch(e) {
      if(kDebugMode)print('$e');
      isServerAvailable = false;
      errorMessage =      e.toString();
    }
    finally{
      await _decision;
    }
  }

  Future<dynamic> getJsonFromSql({required String input}) async{
    try {
      var queryParameters = {
        'customer': customer,
        'sql':      input
      };
      Uri uriUrl =              Uri.parse('${urlPath}select_sql.php');          
      http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
      dynamic result =          await jsonDecode(await jsonDecode(response.body)[0]['result'][0]['b'])['adatok'];
      return result;
    }
    catch(e) {
      if(kDebugMode) dev.log(e.toString());
      return [];
    }
  }

  Future executeSql({required String input, required dynamic parameter}) async{
    var queryParameters = {
      'customer':     customer,
      'input':        input,
      'parameter':    jsonEncode(parameter)
    };
    Uri uriUrl =              Uri.parse('${urlPath}execute_sql_from_input.php');          
    http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
    if(kDebugMode){
      dev.log(response.body);
    }
  }

  Future get formOpen async{
    for(int i = 0; i < dataQuickCall[0]['foglalas'].length; i++){
      if(['select', 'search'].contains(dataQuickCall[0]['foglalas'][i]['input_field'].toString())){
        dynamic item = dataQuickCall[0]['foglalas'][i];
        if(item['update_items'] != null){
          for(int j = 0; j < item['update_items'].length; j++){
           if(item['update_items'][j]['event'] != null && item['update_items'][j]['event'].toString() == 'form_open'){
            await DataManager(
              quickCall:  QuickCall.chainGiveDatasFormOpen,
              input:      {'i': i, 'j': j, 'lookupDatas': dataQuickCall[1][0]}
            ).beginQuickCall;
           }
          }
        }
      }
    }
    for(String entry1 in dataQuickCall[1][0].keys) {for(int i = 1; i < dataQuickCall[1].length; i++) {for(String entry2 in dataQuickCall[1][i].keys){
      if(entry2 == entry1) {dataQuickCall[1][i][entry2] = dataQuickCall[1][0][entry1]; break;}
    }}}
    DataFormState.listOfLookupDatas = dataQuickCall[1][0];
  }

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
   Future get _decisionQuickCall async{ 
    try { 
      switch(quickCall){

        case QuickCall.verzio:
          LogInState.errorMessage = isServerAvailable ? '' : 'Nincs internet kapcsolat!';
          break;

        case QuickCall.tabForm:
          DataFormState.rawData =   dataQuickCall[0]['foglalas'];
          // ----- Title progressBar Reset ----- //
          DataFormState.progress =          List<bool>.empty(growable: true);
          DataFormState.numberOfPictures =  List<int>.empty(growable: true);
          DataFormState.titles =            List<String>.empty(growable: true);
          for(int i = 0; i < dataQuickCall[0]['poziciok'].length + 1; i++){
            DataFormState.progress.add(false);
            DataFormState.numberOfPictures.add(0);
            DataFormState.titles.add((i == 0)? 'Foglalás' : dataQuickCall[0]['poziciok'][i - 1]['pozicio'].toString());
          }
          break;

        case QuickCall.giveDatas:
          if(dataQuickCall[1].isNotEmpty) DataFormState.listOfLookupDatas = dataQuickCall[1][(DataFormState.isExtraForm)? 0 : DataFormState.currentProgress];
          break;

        case QuickCall.askPhotos:
          DataFormState.buttonListPictures =  List<ButtonState>.empty(growable: true);
          for(int i = 0; i < dataQuickCall[2].length; i++) {DataFormState.buttonListPictures.add(ButtonState.default0);}
          break;

        case QuickCall.askIncompleteDays:
          CalendarState.incompleteDays = dataQuickCall[6];
          break;

        case QuickCall.askPlateNumber:
          CalendarState.plateNumberResponse = dataQuickCall[6][0];
          break;

        default:break;
      }
    }
    catch(e){
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
  }

  Future get _decision async{
    try {switch(Global.currentRoute){

      case NextRoute.logIn:
        LogInState.errorMessage = data[input['number']][0]['error'].toString();
        if(LogInState.errorMessage.isEmpty){
          if(input['number'] == 0) customer = data[0][0]['Ugyfel_id'];
          if(input['number'] == 1) CalendarState.title = data[1][0]['szerviz_megnevezes'].toString();
        }
        break;

      case NextRoute.calendar:
        CalendarState.errorMessage =  data[2][0]['error'];
        CalendarState.buttonDelete =  List<ButtonState>.empty(growable: true);
        CalendarState.itemsInList =   List<String>.empty(growable: true);
        CalendarState.jelleg =        List<String>.empty(growable: true);
        CalendarState.closedInList =  List<bool>.empty(growable: true);
        if(data[2][0]['error'].isEmpty){
          List<dynamic> varData = jsonDecode(data[2][0]['json']);
          data[2] = varData;
          for (var item in varData) {
            CalendarState.buttonDelete.add(ButtonState.default0);
            CalendarState.itemsInList.add("${item['rendszam']}\n${item['partner']}\n${item['jelleg']}\n${item['idopont']}");
            CalendarState.jelleg.add(item['jelleg']);
            CalendarState.closedInList.add((item['lezart'].toString() == '1'));
          }
        }
        break;

      case NextRoute.tabForm:
        CalendarState.errorMessagePopUpTitle = (data[3].isNotEmpty && data[3]['name'] != null) ? data[3]['name'] : '';
        CalendarState.errorMessagePopUp = (data.length < 4 || data[3].isEmpty)? '' : (data[3]['row'] != null)
          ? data[3]['row'].toString()
          : data[3].toString();
        break;

      case NextRoute.esetiMunkalapFelvitele:
      case NextRoute.szezonalisMunkalapFelvitele:
      case NextRoute.abroncsIgenyles:
        DataFormState.rawData =   dataQuickCall[0]['foglalas'];
        // ----- Title progressBar Reset ----- //
        DataFormState.progress =  List<bool>.empty(growable: true);
        DataFormState.titles =    List<String>.empty(growable: true);
        for(int i = 0; i < dataQuickCall[0]['poziciok'].length + 1; i++){
          DataFormState.progress.add(false);
          DataFormState.titles.add((i == 0)? 'Foglalás' : dataQuickCall[0]['poziciok'][i - 1]['pozicio'].toString());
        }
        break;

      default:break;
    }}
    catch (e){
      if(kDebugMode)print('$e');
    }
  }  

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<dynamic> _getLookupData({required List<dynamic> thisData, required String input, required bool isPhp}) async{
    String sequence1(dynamic item, String sqlCommand){
      String pattern = '[${item['id'].toString()}]';
      sqlCommand =      sqlCommand.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
      pattern =         '[jellemzo_${item['jellemzo_id'].toString()}]';
      sqlCommand =      sqlCommand.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
      return sqlCommand;
    }
    String sqlCommand = (foglalasId != null)? input.replaceAll("[id]", foglalasId!) : input;
    for(dynamic item in thisData) {sqlCommand = sequence1(item, sqlCommand);}
    if(dataQuickCall[0]['foglalas'] != null)    for(dynamic item in dataQuickCall[0]['foglalas'])   {sqlCommand = sequence1(item, sqlCommand);}
    if(dataQuickCall[0]['poziciok'] != null)    for(dynamic array in dataQuickCall[0]['poziciok'])  {for(dynamic item in array['adatok']) {sqlCommand = sequence1(item, sqlCommand);}}
    if(dataQuickCall[0]['osszesites'] != null)  for(dynamic item in dataQuickCall[0]['osszesites']) {sqlCommand = sequence1(item, sqlCommand);}
    sqlCommand = sqlCommand.replaceAll("'null'", "null");
        
    try {if(isPhp){
      Uri uriUrl =              Uri.parse(Uri.encodeFull('$sqlUrlLink$sqlCommand').replaceAll('+', '%2b'));
      //uriUrl =                  Uri.parse(Uri.encodeFull('$sqlUrlLink$sqlCommand').replaceAll('&', '%26'));
      http.Response response =  await http.post(uriUrl);
      dynamic result =          await jsonDecode(response.body);
      return result;
    } 
    else{
      if(sqlCommand.isEmpty) return [];
      var queryParameters = {
        'customer': customer,
        'sql':      sqlCommand
      };
      if(kDebugMode) dev.log(sqlCommand);
      Uri uriUrl =              Uri.parse('${urlPath}select_sql.php');          
      http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
      dynamic result =          await jsonDecode(response.body)[0]['result'];
      return result;
    }}
    catch(e) {
      if(kDebugMode) print(e);
      return [];
    }
  }
  Future<dynamic> _getLookupDataFromRawData({required String input, required bool isPhp}) async{
    String sequence1(dynamic item, String sqlCommand){
      String pattern = '[${item['id'].toString()}]';
      sqlCommand =      sqlCommand.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
      pattern =         '[jellemzo_${item['jellemzo_id'].toString()}]';
      sqlCommand =      sqlCommand.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
      return sqlCommand;
    }
    String sqlCommand = (foglalasId != null)? input.replaceAll("[id]", foglalasId!) : input;
    for(dynamic item in dataQuickCall[0]['foglalas']) {sqlCommand = sequence1(item, sqlCommand);}
    for(dynamic array in dataQuickCall[0]['poziciok']) {for(dynamic item in array['adatok']) {sqlCommand = sequence1(item, sqlCommand);}}
        
    try {if(isPhp){
      Uri uriUrl =              Uri.parse(Uri.encodeFull('$sqlUrlLink$sqlCommand').replaceAll('+', '%2b'));
      //uriUrl =                  Uri.parse(Uri.encodeFull('$sqlUrlLink$sqlCommand').replaceAll('&', '%26'));
      http.Response response =  await http.post(uriUrl);
      dynamic result =          await jsonDecode(response.body);
      return result;
    }
    else{
      if(sqlCommand.isEmpty) return [];
      var queryParameters = { 
        'customer': customer,
        'sql':      sqlCommand
      };
      Uri uriUrl =              Uri.parse('${urlPath}select_sql.php');          
      http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
      dynamic result =          await jsonDecode(response.body)[0]['result'];
      return result;
    }}
    catch(e) {
      if(kDebugMode) print(e);
      return [];
    }
  }
}


class Identity{
  // ---------- < Variables > ---------- ---------- ---------- ----------
  int id =            0;
  String identity =   '';

  // ---------- < Constructors > ------- ---------- ---------- ----------
  Identity({required this.id, required this.identity});
  Identity.generate(){
    identity = generateRandomString();
  }

  // ---------- < Methods [1] > -------- ---------- ---------- ----------
  Map<String, dynamic> get toMap => {
    'id':         id,
    'identity':   identity
  };
  String generateRandomString({int length = 32}){
    final random =    Random();
    const charList =  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';    

    if(kDebugMode) {return 'zUAcgDoRLBK35MJ6RLm46RPcsZhxFb97';}
    else{
      return List.generate(length,
        (index) => charList[random.nextInt(charList.length)]
      ).join();
    }
  }
  @override
  String toString() => identity;
}