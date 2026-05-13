// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:autogumi_plaza/routes/data_form.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';

class Panel extends StatefulWidget {//------------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- <Panel>
  const Panel({super.key});

  @override
  State<Panel> createState() => PanelState();
}

class PanelState extends State<Panel> {//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <PanelState>
  // ---------- < Wariables [Static] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> data = [];
  static String? errorMessageDialog;

  // ---------- < Wariables [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  bool isCalendarPressed =  false;
  bool isRefreshingPanel =  false;
  Timer? refreshTimer;
  IconData getIcon(String iconName) => switch(iconName){
    'truck' =>          FontAwesomeIcons.truck,
    'check' =>          Icons.check,
    'printer' =>        Icons.print,
    'package' =>        FontAwesomeIcons.box,
    'x' =>              Icons.close,
    'file' =>           FontAwesomeIcons.file,
    'signature' =>      Icons.edit_document,
    'esetimunkalap' =>  Icons.content_paste_search,
    'igenyles' =>       Icons.request_page_outlined,
    'szezonalis' =>     Icons.calendar_month_outlined,
    _ =>                Icons.help_outline
  };

  Color getColor(String colorName) => switch(colorName){
    'success' =>    Colors.green,
    'secondary' =>  Colors.grey,
    'danger' =>     Colors.red,
    'warning' =>    Colors.orange,
    'primary' =>    Colors.blue,
    _ =>            Colors.blue
  };

  // ---------- < Widget [1] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: _handlePop, child: Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Stack(
        children: [
          _drawPanel,
          if (isRefreshingPanel) Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:        (!isCalendarPressed)? _calendarButtonPressed : null,
        child:            const Icon(Icons.calendar_month),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ));
  }

  // ---------- < Widget [2] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawPanel {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, sectionIndex) {
        final section = Map<String, dynamic>.from(data[sectionIndex] as Map);
        final items = normalizeItems(section['items']);
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Padding(padding: const EdgeInsets.all(5), child: Text(
                    section['title']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  _getButtonFor(section['title'])
                ]),
                const SizedBox(height: 8),
                ...items.map(_drawListItem),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- < Widget [3] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  
  Widget _drawListItem(Map<String, dynamic> item) {
    final buttons = normalizeButtons(item['buttons']);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            getIcon(item['icon']?.toString() ?? ''),
            color:  (buttons.isNotEmpty)? Colors.blue : Colors.grey,
            size:   22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['value']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  item['title']?.toString() ?? '',
                  style: const TextStyle(color: Colors.black54),
                ),
                if(item['message']?.toString().isNotEmpty ?? false) Text(
                  item['message'].toString(),
                  style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: buttons.map((btn) {
              return IconButton(
                tooltip: btn['name']?.toString(),
                style: IconButton.styleFrom(
                  backgroundColor: getColor(btn['color']?.toString() ?? ''),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                  minimumSize: const Size(42, 42),
                ),
                onPressed: () => buttonPressed(btn),
                icon: Icon(
                  _getIconForButton(btn),
                  size: (['esetimunkalap', 'igenyles', 'szezonalis'].contains(btn['type']))? 24 : 18,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _getButtonFor(String input){
    if(input != 'Igénylések') return Container();
    return ElevatedButton(
      onPressed:  _addIgenyles,
      child:      const Row(children: [Padding(padding: EdgeInsets.all(5), child: Icon(Icons.add)), Text('Hozzáadás')])
    );
  }

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  IconData _getIconForButton(Map<String, dynamic> btn) => getIcon((['esetimunkalap', 'igenyles', 'szezonalis'].contains(btn['type']))? btn['type'] : btn['icon']?.toString() ?? '');

  @override
  void initState() {
    super.initState();
    refreshPanel();
    refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshPanel();
    });
  }

  List<Map<String, dynamic>> normalizeItems(dynamic v) {
    if (v == null) return const [];
    try {
      if (v is String) {
        final decoded = jsonDecode(v);
        return normalizeItems(decoded);
      }
      if (v is List) {
        return v
            .where((e) => e != null)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      if (v is Map) {
        return [Map<String, dynamic>.from(v)];
      }
    } catch (_) {}
    return const [];
  }

  Future _calendarButtonPressed() async {
    setState(() => isCalendarPressed = true);
    Global.routeNext = NextRoute.calendar;
    await DataManager(quickCall: QuickCall.askIncompleteDays).beginQuickCall;
    isCalendarPressed = false;
    await Navigator.pushNamed(context, '/calendar');
    await DataManager(quickCall: QuickCall.panel).beginQuickCall;
    setState((){});
  }

  Future<void> buttonPressed(dynamic item) async{
    String workTypeString(String input) {return switch(input){
      'szezonalis' =>     'Szezonális',
      'esetimunkalap' =>  'Eseti',
      'igenyles' =>       'Igénylés',
      _ =>                ''
    };}
    NextRoute getNextRoute(String input) {return switch(input){
      'szezonalis' =>     NextRoute.szezonalisMunkalapFelvitele,
      'esetimunkalap' =>  NextRoute.esetiMunkalapFelvitele,
      'igenyles' =>       NextRoute.abroncsIgenyles,
      _ =>                NextRoute.tabForm
    };}
    if((item['question']?.isNotEmpty ?? false) && !await Global.yesNoDialog(context, title: item['name'], content: item['question'])) return;
    switch(item['type'].toString()){
      case 'link':  await DataManager(quickCall: QuickCall.callButtonWebLink, input: {'callback': item['callback'], 'name': item['name']}).beginQuickCall;  break;
      case 'php':   await DataManager(quickCall: QuickCall.callButtonPhp, input: {'callback': item['callback']}).beginQuickCall;                            break;

      case 'igenyles':
      case 'szezonalis':
      case 'esetimunkalap':
        int foglalasId =          int.parse(((item['parameters'] is String)? jsonDecode(item['parameters'])['id'] : item['parameters']['id']).toString());
        DataManager.foglalasId =  foglalasId.toString();
        Global.routeNext =        (foglalasId == 0)? getNextRoute(item['type'].toString()) : NextRoute.tabForm;
        if(foglalasId == 0){
          await DataManager(input: {
            'datum':        DateTime.now(),
            'foglalas_id':  foglalasId,
            'parent_id':    (item['parameters'] is String)? jsonDecode(item['parameters'])['parent_id'] : item['parameters']['parent_id']
          }).beginProcess;
        }
        else{
          await DataManager(quickCall: QuickCall.tabForm, input: {
            'jelleg':       workTypeString(item['type'].toString()),
            'datum':        DateTime.now(),
            'foglalas_id':  foglalasId,
            'parent_id':    (item['parameters'] is String)? jsonDecode(item['parameters'])['parent_id'] : item['parameters']['parent_id']
          }).beginQuickCall;
        }
        DataFormState.workType = workTypeString(item['type'].toString());
        await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
        DataFormState.bizonylatId = ((item['parameters'] is String)? jsonDecode(item['parameters'])['id'] : item['parameters']['id']).toString();
        await Navigator.pushNamed(context, '/dataForm');
        break;

      case 'alairas':
         await Navigator.pushNamed(
          context,
          '/pdfSignature',
          arguments: {
            'pdfUrl': item['source'],
            'bizonylatId': item['bizonylat_id'],
            'submitUrl': item['link'], // or callback, depending on backend
            'title': item['name'],
            // pass anything else you need
          },
        );
        break;

      default:break;
    }
    //if(Global.trueString.contains(item['php'].toString())) {await DataManager(quickCall: QuickCall.callButtonPhp, input: {'callback': item['callback']}).beginQuickCall;}
    //else {await DataManager(quickCall: QuickCall.callButtonWebLink, input: {'callback': item['callback'], 'name': item['name']}).beginQuickCall;}
    if(errorMessageDialog?.isNotEmpty ?? false) {await Global.showAlertDialog(context, content: errorMessageDialog!, title: '⚠️ Hiba!');}
    await DataManager(quickCall: QuickCall.panel).beginQuickCall;
    setState((){});
  }

  Future<bool> _handlePop() async{
    if(!kIsWeb && await Global.yesNoDialog(context, title: 'Kijelentkezés', content: 'Biztosan ki szeretne jelentkezni az alkalmazásból?')) {await Restart.restartApp();}
    return false;
  }

  List<Map<String, dynamic>> normalizeButtons(dynamic v) {
    if (v == null) return const [];
    try {
      if (v is String) {
        // If it's a JSON string, decode and recurse
        final decoded = jsonDecode(v);
        return normalizeButtons(decoded);
      }
      if (v is List) {
        // List of maps (or map-like)
        return v
            .where((e) => e != null)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      if (v is Map) {
        // Single button object
        return [Map<String, dynamic>.from(v)];
      }
    } catch (_) {
      // Bad JSON or unexpected shape → just return empty for safety
    }
    return const [];
  }

  Future<void> _addIgenyles() async{
    Global.routeNext = NextRoute.abroncsIgenyles;
    await DataManager(input: {'datum': DateTime.now()}).beginProcess;
    await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
    await Navigator.pushNamed(context, '/dataForm');
    await DataManager().beginProcess;
    await DataManager(quickCall: QuickCall.askIncompleteDays).beginQuickCall;
    setState((){});
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> refreshPanel() async {
    if (isRefreshingPanel || !mounted) return;
    setState(() => isRefreshingPanel = true);
    try {
      await DataManager(quickCall: QuickCall.panel).beginQuickCall;
      if (!mounted) return;
      setState(() {}); // data updated
    } catch (e) {
      if (kDebugMode) print('Panel refresh error: $e');
    } finally {
      if (mounted) setState(() => isRefreshingPanel = false);
    }
  }
}