// ignore_for_file: depend_on_referenced_packages

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:math';
import 'package:autogumi_plaza/tools/sqflite_plugin.dart' if (dart.library.html) 'package:autogumi_plaza/tools/web/sqflite_plugin.dart';
import 'package:autogumi_plaza/routes/photo_preview.dart';
import 'package:autogumi_plaza/routes/panel.dart';
import 'package:autogumi_plaza/routes/data_form.dart';
import 'package:autogumi_plaza/routes/signature.dart';
import 'package:autogumi_plaza/routes/calendar.dart';
import 'package:autogumi_plaza/routes/log_in.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:autogumi_plaza/utils.dart';

class DataManager{
  // ---------- < Variables [Static] > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static String thisVersion =                       '1.40a';
  static int verzioTest =                           0;      // anything other than 0 will draw "[Teszt #]" at the LogIn screen.
  
  static String openAiPassword =                    'qifqik-sedpuf-rejKu6';
 
  static bool isIgenylesDisabled =                  false;  // true will disable all buttons of "📄 Igénylés".

  static bool test =                                false;  // <--- Set the root of the Php files here: true = test, false = live Php file directory. This is the same with the directory of the photos!
  static String urlPath =                           test? 'https://developer.mosaic.hu/android/szerviz_mezandmol/' : 'https://app.mosaic.hu/android/szerviz_mezandmol/';
  static String rootPath =                          test? 'https://developer.mosaic.hu/' : 'https://appdoc.mosaic.hu/';
  static String get sqlUrlLink =>                   'https://app.mosaic.hu/sql/ExternalInputChangeSQL.php?ceg=mezandmol&SQL=';

  static List<dynamic> data =                       List<dynamic>.empty(growable: true);
  static List<dynamic> dataQuickCall =              List<dynamic>.empty(growable: true);
  static List<dynamic> materials =                  List<dynamic>.empty(growable: true);
  static List<dynamic> quickData =                  List<dynamic>.empty(growable: true);
  static List<dynamic> comboboxQueriesDefault =     List<dynamic>.empty();
  static List<dynamic> comboboxQueriesAdditional =  List<dynamic>.empty();
  static bool isServerAvailable =                   true;
  static String actualVersion =                     thisVersion;
  static String customer =                          'mosaic';
  static const String nameOfApp =                   'MezandMol Szervíz';
  static String get serverErrorText =>              (isServerAvailable)? '' : errorMessage;
  static String errorMessage =                      '';
  static int userId =                               0;
  static String? foglalasId;
  static Identity? identity;

  static Future<void> get identitySQLite async {await SqflitePlugin.identitySQLite();}
  static Future<String?> get lastUserNameSQLite async {return await SqflitePlugin.lastUserNameSQLite();}
  static Future<void> saveLastUserNameSQLite(String userName) async {await SqflitePlugin.saveLastUserNameSQLite(userName);}
 
  // ---------- < Variables [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  final Map<String,String> headers = {'Content-Type': 'application/json'};
  dynamic input;
  QuickCall? quickCall;  

  // ---------- < Constructors > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  DataManager({this.quickCall, this.input});

  // ---------- < Methods [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static final RegExp _reHasFrom = RegExp(r'\bFROM\b', caseSensitive: false);

  static bool _isSelectNoFrom(String sql) {
    final s = sql.trim();
    if (!s.toUpperCase().startsWith('SELECT')) return false;
    return !_reHasFrom.hasMatch(s);
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

        case QuickCall.logIn:
          var queryParameters = {
            'customer':   customer,
            'eszkoz_id':  identity.toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}login.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(34)] =         await jsonDecode(response.body);
          if(kDebugMode){
            dev.log(dataQuickCall[34].toString());
          }
          break;

        case QuickCall.logInNamePassword:
          var queryParameters = {
            'customer':       'mosaic', //customer,
            'eszkoz_id':      identity.toString(),
            'user_name':      input['user_name'],
            'user_password':  input['user_password'],
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                Uri.parse('${urlPath}login_name_password.php');
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(31)] =  (response.body != 'null')? await jsonDecode(response.body) : [];
          if(kDebugMode){
            String varString = dataQuickCall[31].toString();
            print(varString);
          }
          break;

        case QuickCall.forgottenPassword:
          Uri uriUrl =                Uri.parse(Uri.encodeFull('https://app.mosaic.hu/sql/ForgottenPasswordSQL.php?name=${input['user_name']}'));
          http.Response response =    await http.post(uriUrl);
          dataQuickCall[check(32)] =  (response.body != 'null')? [await jsonDecode(response.body)] : [];
          if(kDebugMode){
            String varString = dataQuickCall[32].toString();
            print(varString);
          }
          break;

        case QuickCall.tabForm:
          switch(input['jelleg']){

            case 'Igénylés':
              var queryParameters = {
                'customer':     customer,
                'eszkoz_id':    identity.toString(),
                'datum':        CalendarState.selectedDate,
                'foglalas_id':  data[2][DataFormState.selectedIndexInCalendar!]['id'].toString()
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
                'foglalas_id':  data[2][DataFormState.selectedIndexInCalendar!]['id'].toString()
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
                'foglalas_id':  data[2][DataFormState.selectedIndexInCalendar!]['id'].toString()
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
              if(!['select','search', 'text-lookup'].contains(item['input_field'])) continue;
              listOfLookupDatas[item['id']] = await _getCachedLookupData(
                thisData:     input['rawDataInput'],
                input:        item['lookup_data'],
                isPhp:        (item['php'].toString() == '1'),
                cacheEnabled: (item['cache'] != null && item['cache'].toString() == '1')
              );
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
          // ───── helpers ─────────────────────────────────────────────
          bool isEmptyId(dynamic v) {
            if (v == null) return true;
            if (v is String) {
              final s = v.trim().toLowerCase();
              // treat '', 'null' and '0' as empty
              return s.isEmpty || s == 'null' || s == '0';
            }
            if (v is num) {
              // also catch 0 as number
              return v == 0;
            }
            return false;
          }

          List<dynamic> deepCopyList(List<dynamic> src) =>
              List<dynamic>.from(src.map((e) => Map<String, dynamic>.from(e)));

          int getIndexFromId({required String id}) {
            for (int i = 0; i < input['rawDataInput'].length; i++) {
              if (input['rawDataInput'][i]['id'] == id) return i;
            }
            throw Exception('No such id in rawData: $id');
          }

          bool isLookupDataOnTheSide(String inputId) {
            for (dynamic item in input['rawDataInput']) {
              if (item['id'] == inputId) return true;
            }
            return false;
          }

          dynamic getItemFromId({required String id}) {
            if (input['isExtraForm'] != null && input['isExtraForm']) {
              for (dynamic item in DataFormState.rawDataExtra) {
                if (item['id'] == id) return item;
              }
            } else {
              for (dynamic item in dataQuickCall[0]['foglalas']) {
                if (item['id'] == id) return item;
              }
              for (dynamic itemList in dataQuickCall[0]['poziciok']) {
                for (dynamic item in itemList['adatok']) {
                  if (item['id'] == id) return item;
                }
              }
              if (dataQuickCall[0]['osszesites'] != null) {
                for (dynamic item in dataQuickCall[0]['osszesites']) {
                  if (item['id'] == id) return item;
                }
              }
            }
            throw Exception('No such Item with id: $id');
          }

          int getPlaceIndexOfId(String entry) {
            for (dynamic item in dataQuickCall[0]['foglalas']) {
              if (item['id'] == entry) return 0;
            }
            for (int i = 0; i < dataQuickCall[0]['poziciok'].length; i++) {
              for (dynamic item in dataQuickCall[0]['poziciok'][i]['adatok']) {
                if (item['id'] == entry) return i + 1;
              }
            }
            if (dataQuickCall[0]['osszesites'] != null) {
              for (dynamic item in dataQuickCall[0]['osszesites']) {
                if (item['id'] == entry) return 0;
              }
            }
            throw Exception('No such Item with id: $entry');
          }

          Future<dynamic> getItemUpdateItems() async {
            try {
              return await json.decode(
                  input['rawDataInput'][input['index']]['update_items'].toString());
            } catch (_) {
              return input['rawDataInput'][input['index']]['update_items'];
            }
          }

          // ───── 0️⃣ bulk mode ───────────────────────────────────────
          if (input['index'] == null) {
            for (int i = 0; i < input['rawDataInput'].length; i++) {
              await DataManager(
                quickCall: QuickCall.chainGiveDatas,
                input: {
                  ...input,
                  'index': i,
                  'newValue': input['rawDataInput'][i]['value'],
                },
              ).beginQuickCall;
            }
            break;
          }

          // ───── 1️⃣ single-item logic ───────────────────────────────
          try {
            input['rawDataInput'][input['index']]['kod'] =
                Global.where(
                  DataFormState.listOfLookupDatas[input['rawDataInput'][input['index']]['id']],
                  'megnevezes',
                  input['newValue'],
                )['id'];
          } catch (_) {
            /* ignore */
          }

          final updateItemsItem = await getItemUpdateItems();
          if (updateItemsItem == null) break;
          for (dynamic item in updateItemsItem) {
            try {
              final bool varIsLookupDataOnTheSide = isLookupDataOnTheSide(item['id']);
              final dynamic varGetItemFromId = getItemFromId(id: item['id']);
              final List<String> sqlCommandLookupData =
                  item['lookup_data'].toString().split(' ');

              // ── handle SET commands ────────────────────────────────
              if (sqlCommandLookupData[0] == 'SET') {
                try {
                  final String fieldName = sqlCommandLookupData[1].toString().substring(1);
                  final List<String> listOfStringInput = [
                    'value',
                    'name',
                    'input_field',
                    'input_mask',
                    'keyboard_type',
                    'kod'
                  ];

                  bool assign(dynamic target, dynamic value) {
                    final v = (listOfStringInput.contains(fieldName))
                        ? Global.getStringOrNullFromString(value)
                        : Global.getIntBoolFromString(value);
                    target[fieldName] = v;
                    return true;
                  }

                  if (input['isCheckBox']) {
                    final bool fire =
                        (input['newValue'] == '1' && item['event'] == 'on') ||
                        (input['newValue'] == '0' && item['event'] == 'off');
                    if (!fire) continue;
                  }

                  if (sqlCommandLookupData.length == 4) {
                    if (item['id'] != null) {
                      if (varIsLookupDataOnTheSide) {
                        assign(input['rawDataInput'][getIndexFromId(id: item['id'])],
                            sqlCommandLookupData[3]);
                      } else {
                        assign(varGetItemFromId, sqlCommandLookupData[3]);
                      }
                    } else {
                      switch (fieldName) {
                        case 'numberOfPictures':
                          DataFormState.numberOfPictures[DataFormState.currentProgress] =
                              int.parse(sqlCommandLookupData[3].toString());
                          break;
                        default:
                          break;
                      }
                    }
                  } else if (sqlCommandLookupData.length > 4) {
                    final varDynamic = await _getCachedLookupData(
                      thisData: input['rawDataInput'],
                      input: sqlCommandLookupData.sublist(3).join(' '),
                      isPhp: (item['php'].toString() == '1'),
                      cacheEnabled:
                          (item['cache'] != null && item['cache'].toString() == '1'),
                    );
                    final dynamic calc = varDynamic[0][''].toString();
                    if (varIsLookupDataOnTheSide) {
                      assign(input['rawDataInput'][getIndexFromId(id: item['id'])], calc);
                    } else {
                      assign(varGetItemFromId, calc);
                    }
                  }
                  continue; // handled SET
                } catch (e) {
                  if (kDebugMode) dev.log(e.toString());
                }
              }

              // ── normal lookup refresh ──────────────────────────────
              if (input['isCheckBox']) {
                switch (item['event']) {
                  case 'on':
                    if (input['newValue'] == '0') continue;
                    break;
                  case 'off':
                    if (input['newValue'] == '1') continue;
                    break;
                  default:
                    continue;
                }
              }

              final list = await _getCachedLookupData(
                thisData: input['rawDataInput'],
                input: item['lookup_data'],
                isPhp: (item['php'].toString() == '1'),
                cacheEnabled: (item['cache'] != null && item['cache'].toString() == '1'),
              );

              // sanitize before storing
              final cleaned = clean(list);

              // deep copy to avoid aliasing across fields
              DataFormState.listOfLookupDatas[item['id']] = deepCopyList(cleaned);              

              if (varGetItemFromId['input_field'] == 'checkbox') {
                final src = DataFormState.listOfLookupDatas[item['id']];
                final firstId = (src.isNotEmpty) ? src[0]['id'] : null;
                final val = (firstId == null) ? '0' : firstId.toString();
                if (varIsLookupDataOnTheSide) {
                  input['rawDataInput'][getIndexFromId(id: item['id'])]['value'] = val;
                } else {
                  varGetItemFromId['value'] = val;
                }
              }
              if (varGetItemFromId['input_field'] == 'select' &&
                  item['lookup_data'] != null) {
                varGetItemFromId['lookup_data'] = item['lookup_data'];
              }
            } catch (e) {
              if (kDebugMode) print(e);
            }
          }

          // ── post-processing: set values WITHOUT clearing lists ────
          final keysSnapshot =
              List<String>.from(DataFormState.listOfLookupDatas.keys); // snapshot keys
          for (final entry in keysSnapshot) {
            try {
              if (isLookupDataOnTheSide(entry)) {
                for (int i = 0; i < input['rawDataInput'].length; i++) {
                  if (input['rawDataInput'][i]['id'] != entry) continue;

                  final list = (DataFormState.listOfLookupDatas[entry] ?? []) as List;
                  if (['text', 'number'].contains(input['rawDataInput'][i]['input_field'])) {
                    if (list.isNotEmpty && !isEmptyId(list[0]['id'])) {
                      input['rawDataInput'][i]['value'] = list[0]['id'].toString();
                    } else {
                      // keep list as-is, just clear value
                      input['rawDataInput'][i]['value'] = '';
                    }
                    break;
                  }
                  if (['select', 'search', 'text-lookup'].contains(input['rawDataInput'][i]['input_field'])) {
                    // do NOT replace options with []
                    if (list.isNotEmpty && !isEmptyId(list[0]['id'])) {
                      for (var item in list) {
                        if (item['selected'] != null && item['selected'].toString() == '1') {
                          input['rawDataInput'][i]['value'] = item['id'];
                          break;
                        }
                      }
                    } else {
                      // leave options intact; just ensure no selection forced
                      // input['rawDataInput'][i]['value'] = ''; // optional
                    }
                    break;
                  }
                }
              } else {
                final varGetItemFromId = getItemFromId(id: entry);
                final list = (DataFormState.listOfLookupDatas[entry] ?? []) as List;

                if (['text', 'number'].contains(varGetItemFromId['input_field'])) {
                  if (list.isNotEmpty && !isEmptyId(list[0]['id'])) {
                    varGetItemFromId['value'] = list[0]['id'].toString();
                  } else {
                    varGetItemFromId['value'] = '';
                  }
                }

                if (['select', 'search', 'text-lookup'].contains(varGetItemFromId['input_field'])) {
                  // never nuke list; only pick selection if present
                  if (list.isNotEmpty && !isEmptyId(list[0]['id'])) {
                    for (var item in list) {
                      if (item['selected'] != null && item['selected'].toString() == '1') {
                        varGetItemFromId['value'] = item['id'];
                        break;
                      }
                    }
                  }
                  if (!input['isExtraForm']) {
                    dataQuickCall[1][getPlaceIndexOfId(entry)][entry] =
                        DataFormState.listOfLookupDatas[entry];
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) print(e);
            }
          }
          break;        

        case QuickCall.chainGiveDatasFormOpen:
          // ------------------ Fast indexes (built once) ------------------
          final List<dynamic> foglalas = (dataQuickCall[0]['foglalas'] as List?) ?? const [];
          final List<dynamic> poziciok = (dataQuickCall[0]['poziciok'] as List?) ?? const [];

          // id -> direct reference to the field map in foglalas/poziciok
          final Map<String, Map<String, dynamic>> byId = <String, Map<String, dynamic>>{};          

          // IMPORTANT:
          // If you want changes to immediately affect dataQuickCall structures, you must store references.
          // So use the "DON'T clone" line above.
          // I'll do it correctly here (reference, no clone):

          byId.clear();
          for (final f in foglalas) {
            if (f is Map<String, dynamic>) {
              final id = f['id']?.toString();
              if (id != null && id.isNotEmpty) byId[id] = f;
            } else if (f is Map) {
              final id = f['id']?.toString();
              if (id != null && id.isNotEmpty) byId[id] = f.cast<String, dynamic>();
            }
          }
          for (final p in poziciok) {
            final adatok = (p as Map?)?['adatok'] as List?;
            if (adatok == null) continue;
            for (final f in adatok) {
              if (f is Map<String, dynamic>) {
                final id = f['id']?.toString();
                if (id != null && id.isNotEmpty) byId[id] = f;
              } else if (f is Map) {
                final id = f['id']?.toString();
                if (id != null && id.isNotEmpty) byId[id] = f.cast<String, dynamic>();
              }
            }
          }

          // ------------------ Helpers ------------------
          bool isEmptyValue(dynamic v) => _isItEmpty(v);

          void applyValueToField({
            required Map<String, dynamic> field,
            required List<dynamic> lookupList,
          }) {
            final inputField = field['input_field']?.toString() ?? '';

            if (inputField == 'text') {
              field['value'] = (lookupList.isEmpty || isEmptyValue(lookupList[0]['id']))
                  ? ''
                  : lookupList[0]['id'].toString();
              return;
            }

            if (['select', 'search', 'text-lookup'].contains(inputField)) {
              // Preserve your current behavior: if list empty / id empty => nuke options list
              if (lookupList.isEmpty || isEmptyValue(lookupList[0]['id'])) {
                lookupList = <dynamic>[];
              } else {
                for (final opt in lookupList) {
                  if (opt is Map && opt['selected']?.toString() == '1') {
                    field['value'] = opt['id'];
                    break;
                  }
                }
              }
              return;
            }
          }

          // ------------------ Preserve your existing 'kod' set attempt ------------------
          try {
            foglalas[input['i']]['kod'] = foglalas[input['i']]['value'];
          } catch (_) {
            foglalas[input['i']]['kod'] = null;
          }

          // ------------------ Main optimized logic ------------------
          try {
            final Map<String, dynamic> lookupDatas =
                (input['lookupDatas'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

            final dynamic updateItems = foglalas[input['i']]['update_items'];
            if (updateItems == null) break;

            // 1) Collect only the tasks we actually need (event=form_open)
            final List<dynamic> tasks = <dynamic>[];
            if (updateItems is List) {
              for (final t in updateItems) {
                if (t is Map && t['event']?.toString() == 'form_open') tasks.add(t);
              }
            }

            if (tasks.isEmpty) break;

            // 2) Fetch all lookups (one per task) + update lookup_data on the target field
            for (final t in tasks) {
              final id = t['id']?.toString();
              if (id == null || id.isEmpty) continue;

              final lookupSql = t['lookup_data']?.toString();
              if (lookupSql == null || lookupSql.isEmpty) continue;

              final isPhp = (t['php']?.toString() == '1');

              lookupDatas[id] = await _getLookupDataFromRawData(
                input: lookupSql,
                isPhp: isPhp,
              );

              // set lookup_data onto the real field (O(1) via index)
              final target = byId[id];
              if (target != null) {
                target['lookup_data'] = lookupSql;
              }
            }

            // 3) Apply results to the fields (O(k), no scanning per id)
            for (final entry in lookupDatas.keys) {
              final target = byId[entry];
              if (target == null) continue;

              final list = lookupDatas[entry];
              if (list is List) {
                applyValueToField(field: target, lookupList: list);
              }
            }

            // Keep your original debug-ish tail expressions if you want:
            // dataQuickCall; input['lookupDatas'];
          } catch (e) {
            if (kDebugMode) print(e);
          }
          break;

        case QuickCall.askPhotos:
          foglalasId = data[2][DataFormState.selectedIndexInCalendar!]['id'].toString();
          var queryParameters = {
            'customer':     (foglalasId != null && int.parse(foglalasId!) < 0)? 'mercarius' : customer,
            'foglalas_id':  foglalasId?.replaceFirst(RegExp(r'^-+'), ''),
            'jelleg':       (DataFormState.workType == 'Igénylés')? 'Eseti' : DataFormState.workType,
            'pozicio':      PhotoPreviewState.isSignature
              ? 'Signature'
              : DataFormState.titles[DataFormState.currentProgress]
            ,
          };
          Uri uriUrl =              Uri.parse('${urlPath}ask_pictures.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dynamic varDynamic =      await jsonDecode(response.body)[0][''];
          dataQuickCall[check(2)] = await jsonDecode(varDynamic.toString());
          if(kDebugMode){
            String varString = dataQuickCall[2].toString();
            print(varString);
          }
          break;

        case QuickCall.cancelWork: switch(input['jelleg']){

          case 'Igénylés':
            var queryParameters = {
              'customer':     customer,
              'bizonylat_id': data[2][input['index']]['id'].toString(),
              'indoklas':     input['indoklas'],
              'user_id':      userId,
            };
            Uri uriUrl =              Uri.parse('${urlPath}cancel_igenyles.php');          
            http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
            dataQuickCall[check(3)] = await jsonDecode(await jsonDecode(response.body));
            if(kDebugMode)print(dataQuickCall[3].toString());
            break;

          default:
            var queryParameters = {
              'customer':     customer,
              'foglalas_id':  data[2][input['index']]['id'].toString(),
              'indoklas':     input['indoklas'],
              'user_id':      userId,
              'jelleg':       input['jelleg']
            };
            Uri uriUrl =              Uri.parse('${urlPath}cancel_work.php');          
            http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
            dataQuickCall[check(3)] = await jsonDecode(await jsonDecode(response.body));
            if(kDebugMode)print(dataQuickCall[3].toString());
            break;
        } break;

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
            'customer':   (foglalasId != null && int.parse(foglalasId!) < 0)? 'mercarius' : customer,
            'parameter':  (input['lezart'] != 1 && input['quickSave'] == null)? jsonEncode(DataFormState.rawData) : jsonEncode(dataQuickCall[0]),
            'user_id':    userId, //data[0][1]['dolgozo_kod'],
            'lezart':     input['lezart']
          };
          Uri uriUrl = Uri.parse('${urlPath}save_eseti_munkalap.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(5)] =     (['[]', '"[]"', '""[]""'].contains(response.body))? [] : json.decode(json.decode(response.body));
          if(kDebugMode) dev.log(dataQuickCall[5].toString());
          SignatureFormState.message =  (dataQuickCall[5].isNotEmpty)? dataQuickCall[5][0] : null;
          break;

        case QuickCall.uploadSignature:
          var queryParameters = {
            'customer':       (foglalasId != null && int.parse(foglalasId!) < 0)? 'mercarius' : customer,
            'bizonylat_id':   input['bizonylat_id']?.replaceFirst(RegExp(r'^-+'), ''),
            'alairo':         input['alairo'],
            'alairas':        input['alairas'],
          };
          Uri uriUrl = Uri.parse('${urlPath}upload_signature.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) dev.log(response.body);
          dataQuickCall[check(10)] =     (['[]', '"[]"', '""[]""'].contains(response.body))? [] : json.decode(json.decode(response.body));
          if(kDebugMode) dev.log(dataQuickCall[10].toString());
          break;
  
        case QuickCall.saveSzezonalisMunkalapFelvitele:
          if(input['lezart'] == null) input['lezart'] = 0;
          var queryParameters = {
            'customer':   customer,
            'parameter':  jsonEncode(dataQuickCall[0]),
            'user_id':    userId, //data[0][1]['dolgozo_kod'],
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
            'user_id':    userId, //data[0][1]['dolgozo_kod'],
            'lezart':     input['lezart']
          };
          Uri uriUrl = Uri.parse('${urlPath}save_abroncs_igenyles.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(5)] =     (['[]', '"[]"', '""[]""'].contains(response.body))? [] : json.decode(json.decode(response.body));
          if(kDebugMode) dev.log(dataQuickCall[5].toString());
          if(kDebugMode) dev.log(queryParameters['parameter'].toString());
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

        case QuickCall.askEsetiMunkalapMeghiusulasOkai:
          var queryParameters = {
            'customer':     customer,
          };
          Uri uriUrl = Uri.parse('${urlPath}ask_eseti_munkalap_meghiusulas_okai.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) dev.log(response.body.toString());
          dataQuickCall[check(7)] =    json.decode(json.decode(response.body));
          break;

        case QuickCall.panel:
          var queryParameters = {
            'customer': customer,
            'user_id':  userId    
          };
          Uri uriUrl = Uri.parse('${urlPath}ask_panel.php');
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode) dev.log(response.body.toString());
          dataQuickCall[check(8)] =   json.decode(json.decode(response.body));
          break;

        case QuickCall.callButtonPhp:
          Uri uriUrl = Uri.parse(Uri.encodeFull(input['callback']).replaceAll('+', '%2b'));
          http.Response response =  await http.get(uriUrl);
          dataQuickCall[check(9)] = await jsonDecode(response.body);
          break;

        case QuickCall.callButtonWebLink:
          try {await openInBrowser(input['callback']);}
          catch(e) {PanelState.errorMessageDialog = 'Nem sikerült végrehajtani az alábbi linket: ${input['name']}\n${input['callback']}'; debugPrint('WebLink hiba: ${input['callback']}');}
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
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                    Uri.parse('${urlPath}login.php');
          http.Response response =        await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(input['number'])] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = data[input['number']].toString();
            dev.log(varString);
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
          data[check(2)] =          await jsonDecode(response.body);
          if(kDebugMode){
            String varString = data[2].toString();
            print(varString);
          }
          break;

        case NextRoute.tabForm:
          foglalasId =          data[2][DataFormState.selectedIndexInCalendar!]['id'].toString();
          data[check(3)] =      [];
          if(['Eseti', 'Igénylés'].contains(input['jelleg'])) break;
          var queryParameters = {
            'customer':     customer,
            'foglalas_id':  foglalasId,
            'user_id':      userId
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
            'customer': (foglalasId != null && int.parse(foglalasId!) < 0)? 'mercarius' : customer,
            'parameter': jsonEncode({
              'id':       foglalasId?.replaceFirst(RegExp(r'^-+'), ''),
              'pozicio':  PhotoPreviewState.isSignature
                ? 'Signature'
                : DataFormState.titles[DataFormState.currentProgress]
              ,
              'kep':      PhotoPreviewState.imageBase64,
              'comment':  PhotoPreviewState.editingController.text
            }),
            'user_id': userId
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
            'parameter':  jsonEncode(dataQuickCall[0]),
            'user_id':    userId //data[0][1]['dolgozo_kod'],
          };
          if(kDebugMode)dev.log(queryParameters.toString());
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
            'datum':        input['datum'].toString().split(' ')[0],
            'parent_id':    input['parent_id']
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
            'munkalap_id':  input['munkalap_id']?.toString() ?? '0',
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
      if(kDebugMode)dev.log(e.toString());
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
      if(['select', 'search', 'text-lookup'].contains(dataQuickCall[0]['foglalas'][i]['input_field'].toString())){
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

        case QuickCall.logInNamePassword:
          LogInState.errorMessage = '';
          LogInState.logInNamePassword = dataQuickCall[31];
          userId =          (dataQuickCall[31].isNotEmpty)? int.parse(dataQuickCall[31][0]['id'].toString()) : -1;
          break;

        case QuickCall.forgottenPassword:
          LogInState.forgottenPasswordMessage = '';
          if(dataQuickCall[32][0]['errors'].isEmpty) {for(dynamic item in dataQuickCall[32][0]['message']) {LogInState.forgottenPasswordMessage += '${item['text']}\n';}}
          else {for(dynamic item in dataQuickCall[32][0]['errors']) {LogInState.forgottenPasswordMessage += '${item['text']}\n';}}
          break;

        case QuickCall.tabForm:
          DataFormState.rawData =   dataQuickCall[0]['foglalas'];
          DataFormState.options =   dataQuickCall[0]['beallitasok'] ?? [];
          // ----- Title progressBar Reset ----- //
          DataFormState.progress =          List<bool>.empty(growable: true);
          DataFormState.numberOfPictures =  List<int>.empty(growable: true);
          DataFormState.titles =            List<String>.empty(growable: true);
          for(int i = 0; i < dataQuickCall[0]['poziciok'].length + 1; i++){
            DataFormState.progress.add(false);
            DataFormState.numberOfPictures.add(0);
            DataFormState.titles.add((i == 0)? 'Foglalás' : '${Global.parse(dataQuickCall[0]['poziciok'][i - 1]['emoji']?.toString() ?? '')}${dataQuickCall[0]['poziciok'][i - 1]['pozicio'].toString()}');
          }
          break;

        case QuickCall.giveDatas:
          if(dataQuickCall[1].isNotEmpty) DataFormState.listOfLookupDatas = dataQuickCall[1][(DataFormState.isExtraForm)? 0 : DataFormState.currentProgress];
          break;

        case QuickCall.askPhotos:
          DataFormState.numberOfPictures[DataFormState.currentProgress] = dataQuickCall[2].length;
          break;

        case QuickCall.askIncompleteDays:
          CalendarState.incompleteDays = dataQuickCall[6];
          break;

        case QuickCall.askPlateNumber:
          CalendarState.plateNumberResponse = dataQuickCall[6][0];
          break;

        case QuickCall.askEsetiMunkalapMeghiusulasOkai:
          CalendarState.reasonOfDelete = (dataQuickCall[7] as List).cast<String>();
          break;

        case QuickCall.panel:
          PanelState.data = dataQuickCall[8];
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
        CalendarState.errorMessage =    data[2][0]['error'];
        CalendarState.buttonDelete =    List<ButtonState>.empty(growable: true);
        CalendarState.buttonIgenyles =  List<ButtonState>.empty(growable: true);
        CalendarState.itemsInList =     List<String>.empty(growable: true);
        CalendarState.jelleg =          List<String>.empty(growable: true);
        CalendarState.closedInList =    List<bool>.empty(growable: true);
        if(data[2][0]['error'].isEmpty){
          List<dynamic> varData = jsonDecode(data[2][0]['json']);
          data[2] = varData;
          for (var item in varData) {
            CalendarState.buttonDelete.add(ButtonState.default0);
            CalendarState.buttonIgenyles.add(ButtonState.default0);
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
  Future openInBrowser(String url) async{
    final Uri uri = Uri.parse(url.replaceAll(r'\/', '/'));
    try {await launchUrl(uri, mode: LaunchMode.externalApplication);}
    catch(e) {if(kDebugMode){dev.log(e.toString());} throw Exception();}
  }  

  Future<List<dynamic>> _getCachedLookupData({required List<dynamic> thisData, required String input, required bool isPhp, required bool cacheEnabled}) async{
    final key = '${isPhp ? 'php:' : ''}$input';    
    if (cacheEnabled && Global.lookupCache.containsKey(key)) {
      return Global.lookupCache[key];
    }
    final result = await _getLookupData(thisData: thisData, input: input, isPhp: isPhp);
    if(cacheEnabled) Global.lookupCache[key] = result;
    return result;
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

  // ---------- < Methods [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
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
    else {
      if (sqlCommand.isEmpty) return [];
      // Fast path: SELECT without FROM → evaluate locally via SQLite
      if (_isSelectNoFrom(sqlCommand)) {
        try {
          if (kDebugMode) dev.log('(Local call)     SQL:  $sqlCommand');
          final rows = await SqflitePlugin.runLocalSelect(
            _normalizeForSqlite(sqlCommand),
          );
          if (kDebugMode) dev.log('(Local call)  RESULT:  ${rows.toString()}');
          return rows;
        } catch (e) {
          if (kDebugMode) dev.log('(Local call)  FAILED:  $e');
        }
      }
      // Fallback / normal path: go to server
      if (kDebugMode)     dev.log('(Php call)       SQL:  $sqlCommand');
      final queryParameters = {
        'customer': customer,
        'sql':      sqlCommand,
      };
      final uriUrl = Uri.parse('${urlPath}select_sql.php');
      final response = await http.post(
        uriUrl,
        body: json.encode(queryParameters),
        headers: headers,
      );
      final result = jsonDecode(response.body)[0]['result'];
      if (kDebugMode)     dev.log('(Php call)    RESULT:  ${result.toString()}');
      return result;
    }}
    catch(e) {
      if(kDebugMode) dev.log(e.toString());
      return [];
    }
  }

  // ---------- < Methods [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<dynamic> clean(List<dynamic> l) => l.where((e) {
    final m = e as Map?;
    if (m == null) return false;
    final id = m['id'];
    if (id == null) return false;
    final s = id.toString().trim();
    // remove only if id is empty or literally "null" (any case)
    if (s.isEmpty || s.toLowerCase() == 'null') return false;
    return true; // keep everything else, including 0, '0', 1, '1'
  }).toList();

  String _normalizeForSqlite(String sql) {
    return sql.replaceAllMapped(
      RegExp(r"'(\d+(?:\.\d+)?)'"),
      (m) => m.group(1)!,
    );
  }

  // ---------- < Methods [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  bool _isItEmpty(dynamic input) {
    if (input == null) return true;
    if (input is num) return input == 0; // handle numeric 0
    final s = input.toString().trim().toLowerCase();
    return s.isEmpty || s == 'null' || s == '0';
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
  String toString() => identity; //'00000000000000000000000000000000';
}