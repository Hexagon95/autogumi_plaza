// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'package:table_calendar/table_calendar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:restart_app/restart_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;
import '../utils.dart';
import 'package:autogumi_plaza/routes/data_form.dart';
import 'package:autogumi_plaza/routes/log_in.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';

class Calendar extends StatefulWidget {
  // ---------- < Constructor > ---------- ---------- ---------- ----------
  const Calendar({super.key});

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ----------

  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ----------
  static List<ButtonState> buttonDelete = List<ButtonState>.empty(growable: true);
  static List<String> itemsInList =       List<String>.empty(growable: true);
  static List<String> jelleg =            List<String>.empty(growable: true);
  static List<bool>   closedInList =      List<bool>.empty(growable: true);
  static String selectedDate =            DateFormat('yyyy.MM.dd').format(DateTime.now()).toString();
  static String title =                   '';
  static String errorMessage =            '';
  static String errorMessagePopUp =       '';
  static String errorMessagePopUpTitle =  '';
  static List<dynamic> incompleteDays =  [];
  static dynamic plateNumberResponse;
  static int? selectedIndexList;

  // ---------- < Variables > ------------ ---------- ---------- ---------- ---------- ---------- ----------
  CalendarFormat _calendarFormat =  CalendarFormat.month;
  DateTime _focusedDay =            DateTime.now();
  ButtonState buttonAddWork =       ButtonState.default0;
  ButtonState buttonListInquries =  ButtonState.default0;
  bool isListStockInfoOpen =        false;
  DateTime? _selectedDay;

  // ---------- < Widget Build > --------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {    
    return WillPopScope(onWillPop: () => _handlePop, child: Scaffold(
      appBar: AppBar(
        title:            Text('$title  >  ${(isListStockInfoOpen)? 'Készlet infó' : 'Feladatok'}'),
        backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      ),
      floatingActionButton:         Column(mainAxisSize: MainAxisSize.min, children: [_drawButtonInquiries, _drawButtonAddWork]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(children: [
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_calendar, Expanded(child: _listOfTasks)]),
      ])
    ));
  }

  // ---------- < Widgets [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _calendar => Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))), child: TableCalendar(
    firstDay:             kFirstDay,
    lastDay:              kLastDay,
    focusedDay:           _focusedDay,
    calendarFormat:       _calendarFormat,
    selectedDayPredicate: (day) {      
      return isSameDay(_selectedDay, day);
    },
    onDaySelected:    _dayPicked,
    onFormatChanged:  (format)      {if(_calendarFormat != format) setState(() {_calendarFormat = format;});},
    onPageChanged:    (focusedDay)  {_focusedDay = focusedDay;},
    eventLoader:      _getEventsForDay,
    calendarStyle:    CalendarStyle(
      selectedDecoration: BoxDecoration(color: Global.getColorOfButton(ButtonState.default0), shape: BoxShape.circle),
      todayDecoration:    BoxDecoration(color: Global.getColorOfButton(ButtonState.disabled), shape: BoxShape.circle)
    )
  ));  
  
  Widget get _listOfTasks => (errorMessage.isEmpty)
  ? Column(children: [          
    Expanded(
      child: Scrollbar(child: ListView.builder(
        itemCount:    itemsInList.length,
        itemBuilder:  (BuildContext context, int index) {
          return Stack(children: [
            Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))), child: ListTile(
              title: Stack(children: [
                Padding(
                  padding:  const EdgeInsets.fromLTRB(100, 0, 0, 0),
                  child:    Icon(_getIconOfCase(index), color: Global.getColorOfButton(ButtonState.disabled), size: 90),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _drawButtonDelete(index),
                  Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                    const Text("rendszam: \npartner: \njelleg: \nidőpont: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
                    Text(itemsInList[index], style: const TextStyle(fontSize: 15)),
                    Visibility(visible: (selectedIndexList != null && index == selectedIndexList), child: const Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.lightBlueAccent))
                    ))
                  ]))),
                  Visibility(visible: closedInList[index], child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Icon(Icons.done, color: Color.fromRGBO(0, 100, 0, 1), size: 40)
                  ))
                ]),
              ]),
              tileColor:  (selectedIndexList == index)? const Color.fromARGB(255, 200, 255, 200) : (closedInList[index])? const Color.fromRGBO(230, 255, 230, 1) : null,
              onTap:      () => (selectedIndexList == null)? setState(() {selectedIndexList = index; _functionPress(index);}) : null
            )),
            SizedBox(height: 90, child: Align(alignment: Alignment.bottomCenter, child: _drawButtonIgenyles(index)))
          ]);
        }
      ))
    ),
    Visibility(visible: !DataManager.isServerAvailable, child: Container(height: 20, color: Colors.red, child: Row(
      mainAxisAlignment:  MainAxisAlignment.center,
      children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
    )))
  ])
  : Center(child: Text(errorMessage, style: const TextStyle(color: Colors.grey), softWrap: true));

  // ---------- < Widgets [2] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < Buttons [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _drawButtonDelete(int index) => (!closedInList[index])
  ? Padding(padding: const EdgeInsets.fromLTRB(0, 0, 20, 0), child: TextButton(
      onPressed:  () => (buttonDelete[index] == ButtonState.default0)? _buttonDeletePressed(index) : null,
      child:      Row(children: [
        Visibility(
          visible:  buttonDelete[index] == ButtonState.loading,
          child:    _progressIndicator(Global.getColorOfButton(buttonDelete[index]))
        ),
        Icon(Icons.delete, size: 40, color: Global.getColorOfButton(buttonDelete[index]))
      ])
    ))
  : Container()
  ;

  Widget get _drawButtonInquiries => Padding(padding: const EdgeInsets.all(5), child: SizedBox(
    height: 60,
    width:  60,
    child:  badges.Badge(
      badgeContent: Text('0', style: TextStyle(color: Global.getColorOfIcon(ButtonState.disabled), fontWeight: FontWeight.bold, fontSize: 20)),
      position:     badges.BadgePosition.bottomStart(),
      badgeStyle:   badges.BadgeStyle(badgeColor: Global.getColorOfButton(ButtonState.disabled)),
      child:        FloatingActionButton(
        heroTag:          "btn1",
        onPressed:        () => (buttonListInquries == ButtonState.default0)? _buttonListInquriesPressed : null,
        backgroundColor:  Global.getColorOfButton(buttonListInquries),
        foregroundColor:  Global.getColorOfIcon(buttonListInquries),
        isExtended:       true,
        child:            Padding(padding: const EdgeInsets.all(10), child: 
          (buttonListInquries == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonListInquries)) : const Text('📄', style: TextStyle(fontSize: 26))
        )
      )
    )
  ));

  Widget get _drawButtonAddWork => Padding(padding: const EdgeInsets.all(5), child: SizedBox(
    height: 60,
    width:  60,
    child:  FloatingActionButton(
      heroTag:          "btn2",
      onPressed:        () => (buttonAddWork == ButtonState.default0)? _buttonAddWorkPressed : null,
      backgroundColor:  Global.getColorOfButton(buttonAddWork),
      foregroundColor:  Global.getColorOfIcon(buttonAddWork),
      isExtended:       true,
      child:            Padding(padding: const EdgeInsets.all(10), child: 
        (buttonAddWork == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonAddWork)) : const Icon(Icons.post_add, size: 40)
      )
    )
  ));

  Widget _drawButtonIgenyles(int index){
    return (closedInList[index])
    ? SizedBox(height: 40, width: 130, child: TextButton(
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(ButtonState.default0))),
      onPressed:  () => _buttonIgenylesPressed(index),
      child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📄 Igénylés', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(ButtonState.default0)))
      ])
    ))
    : Container();
  }

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  IconData _getIconOfCase(int index) {switch(jelleg[index]){
    case 'Eseti':     return Icons.content_paste_search;
    case 'Igénylés':  return Icons.request_page_outlined;
    default:          return Icons.calendar_month_outlined;
  }}

  Future _dayPicked(selectedDay, focusedDay) async{
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInState.updateNeeded) Restart.restartApp();

    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay =            selectedDay;
      _focusedDay =             focusedDay;
      setState((){});
      selectedDate =            DateFormat('yyyy.MM.dd').format(selectedDay).toString();
      DataManager dataManager = DataManager();
      await dataManager.beginProcess;
      setState((){});
    }
  }

  Future _functionPress(int index) async{
    errorMessage =            '';
    errorMessagePopUp =       '';
    errorMessagePopUpTitle =  '';
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInState.updateNeeded) Restart.restartApp();
    Global.routeNext =        NextRoute.tabForm;
    await DataManager(input: {'jelleg': jelleg[index]}).beginProcess;
    if(errorMessagePopUp.isNotEmpty){
      await Global.showAlertDialog(context, title: (errorMessagePopUpTitle.isNotEmpty)? errorMessagePopUpTitle : 'Hiba', content: errorMessagePopUp);
      Global.routeBack;
      setState(() => selectedIndexList = null);
      return;
    }
    else{
      await DataManager(quickCall: QuickCall.tabForm, input: {'jelleg': jelleg[index]}).beginQuickCall;
      await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
      await DataManager().formOpen;
    }
    DataFormState.workType = jelleg[index];
    DataFormState.isClosed = closedInList[index];
    await Navigator.pushNamed(context, '/dataForm');
    setState((){});
  }

  Future<bool> get _handlePop async{
    if(isListStockInfoOpen) {return false;}
    Global.routeBack;
    return true;
  }

  Future _buttonDeletePressed(int index) async{
    setState(() => buttonDelete[index] = ButtonState.loading);
    String? varString = await Global.textInputDialog(context, title: 'Munka Meghíusult', content: 'Indok:');
    if(varString != null){
      await DataManager(quickCall: QuickCall.cancelWork, input: {'index': index, 'indoklas': varString, 'jelleg': jelleg[index]}).beginQuickCall;
      if(DataManager.dataQuickCall[3].isNotEmpty) {await Global.showAlertDialog(context, title: 'Hiba!', content: DataManager.dataQuickCall[3].toString());}
      else {await DataManager().beginProcess;}
    }
    setState(() => buttonDelete[index] = ButtonState.default0);
  }

  Future get _buttonListInquriesPressed async{
    setState(() => buttonListInquries = ButtonState.loading);
    String? varString = await Global.textButtonListDialog(context,
      listItems:  const[],
      title:      'Bejövő 📄 Igénylések'
    );
    switch(varString){
      case null:
        break;

      default:
        Global.routeNext = NextRoute.abroncsIgenyles;
        await DataManager(input: {'datum': _focusedDay}).beginProcess;
        await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
        Navigator.pushNamed(context, '/dataForm');
        break;
    }
    setState(() => buttonListInquries = ButtonState.default0);
  }

  Future get _buttonAddWorkPressed async{
    setState(() => buttonAddWork = ButtonState.loading);
    String? varString = await Global.textButtonListDialog(context,
      listItems:  const['Eseti Munkalap', 'Szezonális Munkalap', '📄 Igénylés', '🔍 Rendszám keresése', '🗓 Ugrás a mai napra'],
      title:      'Új Bizonylat Felvitele'
    );
    buttonAddWork = ButtonState.default0;
    if(varString != null) {switch(varString){
      case 'Eseti Munkalap':
        Global.routeNext = NextRoute.esetiMunkalapFelvitele;
        await DataManager(input: {'datum': _focusedDay}).beginProcess;
        await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
        Navigator.pushNamed(context, '/dataForm');
        break;

      case 'Szezonális Munkalap':
        Global.routeNext = NextRoute.szezonalisMunkalapFelvitele;
        await DataManager(input: {'datum': _focusedDay}).beginProcess;
        await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
        Navigator.pushNamed(context, '/dataForm');
        break;

      case '📄 Igénylés':
        Global.routeNext = NextRoute.abroncsIgenyles;
        await DataManager(input: {'datum': _focusedDay}).beginProcess;
        await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
        Navigator.pushNamed(context, '/dataForm');
        break;

      case '🔍 Rendszám keresése':
        String? varString = await Global.textInputDialog(
          context,
          title:    '🔍 Rendszám keresése',
          content:  'Rendszám megadása:',
          special:  'Rendszám'
        );
        if(varString != null){
          await DataManager(quickCall: QuickCall.askPlateNumber, input: {'plate_number': varString}).beginQuickCall;
          try{
            if(plateNumberResponse != null && plateNumberResponse['mercarius'] != null && plateNumberResponse['mercarius'].toString() == '1'){
              if(plateNumberResponse['idopont'] != null && plateNumberResponse['idopont'].toString().isNotEmpty){
                if(plateNumberResponse['szerviz_ok'] != null && plateNumberResponse['szerviz_ok'].toString() == '1'){
                  DateTime varDateTime = DateTime.parse(Global.replaceAllInAString(plateNumberResponse['idopont'].toString(), '.', '-'));
                  await _dayPicked(varDateTime, varDateTime);
                }
                else {await Global.showAlertDialog(context, title: 'Eltérő szervíz!', content: 'Időpontfoglalás: ${plateNumberResponse['szerviz']} ${plateNumberResponse['idopont']}');}
              }
              else {await Global.showAlertDialog(context, title: 'Hiba!', content: 'Nincs időpontfoglalása.');}
            }
            else {await Global.showAlertDialog(context, title: 'Hiba!', content: 'Nem Mercarius által kezelt jármű.');}
          }
          catch(e){
            if(kDebugMode) dev.log(e.toString());
          }
        }
        break;      

      case '🗓 Ugrás a mai napra':
        await _dayPicked(DateTime.now(), DateTime.now());
        break;

      default: break;
    }}
    setState((){});
  }

  Future _buttonIgenylesPressed(int index) async{
    itemsInList;
    Global.routeNext = NextRoute.abroncsIgenyles;
    await DataManager(input: {'datum': _focusedDay}).beginProcess;
    await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
    Navigator.pushNamed(context, '/dataForm');
  }

  List<Event> _getEventsForDay(DateTime day){
    List<Event> listEvent = List<Event>.empty(growable: true);
    for(dynamic item in incompleteDays) {if(item['datum'] == day.toString().split(' ')[0]){
      for(int i = 0; i < item['munkalap_db']; i++) {listEvent.add(const Event(''));}
    }}
    return listEvent;
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  // ---------- < Methods [3] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
}