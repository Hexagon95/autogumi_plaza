// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter/material.dart';

class Panel extends StatefulWidget {//------------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- <Panel>
  const Panel({super.key});

  @override
  State<Panel> createState() => PanelState();
}

class PanelState extends State<Panel> {//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <PanelState>
  // ---------- < Wariables [Static] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> data = [];
  static String? errorMessageDialog;
  bool isCalendarPressed = false;

  // ---------- < Wariables [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  IconData getIcon(String iconName) => switch(iconName){
    'truck' =>      FontAwesomeIcons.truck,
    'check' =>      Icons.check,
    'printer' =>    Icons.print,
    'package' =>    FontAwesomeIcons.box,
    'x' =>          Icons.close,
    'file' =>       FontAwesomeIcons.file,
    'signature' =>  Icons.edit_document,
    _ =>            Icons.help_outline
  };

  Color getColor(String colorName) => switch(colorName){
    'success' =>    Colors.green,
    'secondary' =>  Colors.grey,
    'danger' =>     Colors.red,
    _ =>            Colors.blue
  };

  // ---------- < Widget [1] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: _handlePop, child: Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body:   _drawPanel,
      floatingActionButton: FloatingActionButton(
        onPressed:        (!isCalendarPressed)? _calendarButtonPressed : null,
        child:            const Icon(Icons.calendar_month),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ));
  }

  // ---------- < Widget [2] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawPanel{
    final size = MediaQuery.of(context).size;
    const padding = 12.0;
    const spacing = 12.0;
    const crossAxisCount = 2;
    // ignore: prefer_const_declarations
    final totalHorizontalPadding = padding * 2 + spacing * (crossAxisCount - 1);
    final cardWidth = (size.width - totalHorizontalPadding) / crossAxisCount; // heuristic: allow card height to scale with screen height
    final cardHeight = size.height * 0.28;
    final aspectRatio = cardWidth / cardHeight;
    return Padding( padding: const EdgeInsets.all(12.0), child: GridView.count(
      crossAxisCount:   crossAxisCount,
      mainAxisSpacing:  spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: aspectRatio.clamp(0.9, 2.4),
      children:         data.map((item) {item['buttons'] = normalizeButtons(item['buttons']); return Card(
        elevation:  3,
        shape:      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child:      Padding(padding: const EdgeInsets.all(12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(alignment: Alignment.topRight, child: Icon(getIcon(item['icon']), color: Colors.blue)),
            const SizedBox(height: 8),
            Text(item['value'], style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item['title'], style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            Wrap(spacing: 6, runSpacing: 4, children: List.generate(item['buttons'].length, (i) {
              final btn = (item['buttons'] is String)? jsonDecode(item['buttons'])[i] : item['buttons'][i];
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:  getColor(btn['color']),
                  padding:          const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  visualDensity:    VisualDensity.compact,
                ),
                onPressed:  () => buttonPressed(btn),
                icon:       Icon(getIcon(btn['icon']), size: 14),
                label:      Text(btn['name'], style: const TextStyle(fontSize: 12)),
              );
            }))
          ],
        ))
      );}).toList()
    ));
  }

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future _calendarButtonPressed() async {
    setState(() => isCalendarPressed);
    Global.routeNext = NextRoute.calendar;
    await DataManager(quickCall: QuickCall.askIncompleteDays).beginQuickCall;
    isCalendarPressed = false;
    await Navigator.pushNamed(context, '/calendar');
    await DataManager(quickCall: QuickCall.panel).beginQuickCall;
    setState((){});
  }

  Future<void> buttonPressed(dynamic item) async{
    if((item['question']?.isNotEmpty ?? false) && !await Global.yesNoDialog(context, title: item['name'], content: item['question'])) return;
    switch(item['type'].toString()){
      case 'link':  await DataManager(quickCall: QuickCall.callButtonWebLink, input: {'callback': item['callback'], 'name': item['name']}).beginQuickCall;  break;
      case 'php':   await DataManager(quickCall: QuickCall.callButtonPhp, input: {'callback': item['callback']}).beginQuickCall;                            break;

      case 'esetimunkalap':
        Global.routeNext = NextRoute.esetiMunkalapFelvitele;
        await DataManager(input: {
          'datum':      DateTime.now(),
          'parent_id':  (item['parameters'] is String)? jsonDecode(item['parameters'])['parent_id'] : item['parameters']['parent_id']
        }).beginProcess;
        await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
        await Navigator.pushNamed(context, '/dataForm');
        await _calendarButtonPressed();
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
    if(await Global.yesNoDialog(context, title: 'Kijelentkezés', content: 'Biztosan ki szeretne jelentkezni az alkalmazásból?')) {await Restart.restartApp();}
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
}