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
  // ---------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    static List<dynamic> data = [];
    static String? errorMessageDialog;

    // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    ButtonState buttonAddIgenyles = ButtonState.default0;
    bool isCalendarPressed =        false;
    bool isRefreshingPanel =        false;
    bool isDashboardLocked =        false;
    String? loadingDashboardButtonId;
    Timer? refreshTimer;

    // ---------- [💎 complex variables] -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
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
      appBar: AppBar(title: Text("Dashboard - ${DataManager.szervizMegnevezes}")),
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
        onPressed:        (!isCalendarPressed && !isDashboardLocked)? _calendarButtonPressed : null,
        child:            const Icon(Icons.calendar_month),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ));
  }

  // ---------- < Widget [2] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawPanel {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.sizeOf(context);
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final isHorizontal = screenSize.width > screenSize.height;
        final cardCount = data.length.clamp(1, 999);
        if (isHorizontal && keyboardHeight == 0) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(data.length, (index) {
              final maxCardWidth = constraints.maxWidth / cardCount;
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCardWidth),
                child: _drawSectionCard(data[index]),
              );
            }),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: keyboardHeight + 24),
          child: Column(
            children: List.generate(data.length, (index) {
              final maxCardHeight = constraints.maxHeight / cardCount;
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxCardHeight),
                child: _drawSectionCard(data[index]),
              );
            }),
          ),
        );
      },
    );
  }

  // ---------- < Widget [3] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  
  Widget _drawListItem(Map<String, dynamic> item, int index) {
    final buttons = normalizeButtons(item['buttons']);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color:  index.isEven ? Colors.white : Colors.grey.shade100,
          border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
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
              final buttonId = _getDashboardButtonId(item, btn);
              final isLoading = loadingDashboardButtonId == buttonId;
              return SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: btn['name']?.toString(),
                      style: IconButton.styleFrom(
                        backgroundColor: getColor(btn['color']?.toString() ?? ''),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: getColor(btn['color']?.toString() ?? ''),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                        minimumSize: const Size(42, 42),
                      ),
                      onPressed: isDashboardLocked ? null : () => buttonPressed(btn, buttonId),
                      icon: Icon(
                        _getIconForButton(btn),
                        size: (['esetimunkalap', 'igenyles', 'szezonalis'].contains(btn['type']))? 24 : 18,
                      ),
                    ),
                    if(isLoading) ...[
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _drawSectionCard(dynamic rawSection) {
    return PanelSectionCard(
      rawSection: rawSection,
      normalizeItems: normalizeItems,
      drawListItem: _drawListItem,
      getButtonFor: _drawButtonIgenyles,
    );
  }

  Widget _drawButtonIgenyles(String input) {
    if (input != 'Igénylések') return Container();
    return ElevatedButton(
      onPressed: buttonAddIgenyles == ButtonState.default0 && !isDashboardLocked
          ? _addIgenyles
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Global.getColorOfButton(buttonAddIgenyles),
        foregroundColor: Global.getColorOfIcon(buttonAddIgenyles),
        disabledBackgroundColor: Global.getColorOfButton(buttonAddIgenyles),
        disabledForegroundColor: Global.getColorOfIcon(buttonAddIgenyles),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (buttonAddIgenyles == ButtonState.loading) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Global.getColorOfIcon(buttonAddIgenyles),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            const Icon(Icons.add),
            const SizedBox(width: 6),
          ],
          Text(
            buttonAddIgenyles == ButtonState.loading
                ? 'Betöltés...'
                : 'Hozzáadás',
          ),
        ],
      ),
    );
  }

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  IconData _getIconForButton(Map<String, dynamic> btn) => getIcon((['esetimunkalap', 'igenyles', 'szezonalis'].contains(btn['type']))? btn['type'] : btn['icon']?.toString() ?? '');

  String _getDashboardButtonId(Map<String, dynamic> item, Map<String, dynamic> btn) => '${item['value']}_${item['title']}_${btn['type']}_${btn['callback']}_${btn['name']}';

  @override
  void initState() {
    super.initState();
    refreshPanel();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
       if ( mounted && Global.currentRoute == NextRoute.panel && !isRefreshingPanel && !isDashboardLocked && buttonAddIgenyles != ButtonState.loading) {await refreshPanel();}
      },
    );
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
    if(isDashboardLocked) return;
    setState(() => isCalendarPressed = true);
    Global.routeNext = NextRoute.calendar;
    await DataManager(quickCall: QuickCall.askIncompleteDays).beginQuickCall;
    isCalendarPressed = false;
    await Navigator.pushNamed(context, '/calendar');
    await DataManager(quickCall: QuickCall.panel).beginQuickCall;
    setState((){});
  }

  Future<void> buttonPressed(dynamic item, String buttonId) async{
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
    if(isDashboardLocked) return;
    setState(() {isDashboardLocked = true; loadingDashboardButtonId = buttonId;});
    try {
    switch(item['type'].toString()){
      case 'link':  await DataManager(quickCall: QuickCall.callButtonWebLink, input: {'callback': item['callback'], 'name': item['name']}).beginQuickCall;  break;
      case 'php':   await DataManager(quickCall: QuickCall.callButtonPhp, input: {'callback': item['callback']}).beginQuickCall;                            break;

      case 'igenyles':
      case 'szezonalis':
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

      case 'esetimunkalap':
        final params = (item['parameters'] is String)? jsonDecode(item['parameters']) : item['parameters'];
        int foglalasId = int.parse(params['id'].toString());
        DataManager.foglalasId = foglalasId.toString();
        final type = item['type'].toString();
        final workType = workTypeString(type);
        Global.routeNext = (foglalasId == 0)? getNextRoute(type) : NextRoute.tabForm;
        if (foglalasId == 0) {
          await DataManager(input: {
            'datum': DateTime.now(),
            'foglalas_id': foglalasId,
            'parent_id': params['parent_id'],
          }).beginProcess;
          await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
          DataFormState.workType = workType;
          await Navigator.pushNamed(context, '/dataForm');
          // ✅ after creation, immediately open the created Eseti munkalap
          if (type == 'esetimunkalap' && DataManager.dataQuickCall.length > 5 && DataManager.dataQuickCall[5] != null && DataManager.dataQuickCall[5].length > 2){
            final newFoglalasId = DataManager.dataQuickCall[5][1];
            final newParentId = DataManager.dataQuickCall[5][2];
            if (!mounted) return;
            setState(() => isRefreshingPanel = true);
            Global.routeNext = NextRoute.tabForm;
            DataManager.foglalasId = newFoglalasId.toString();
            await DataManager(input: {'jelleg': 'Eseti', 'foglalasId': newFoglalasId}).beginProcess;
            await DataManager(quickCall: QuickCall.tabForm, input: {
              'jelleg': 'Eseti',
              'datum': DateTime.now(),
              'foglalas_id': newFoglalasId,
              'parent_id': newParentId,
            }).beginQuickCall;
            await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
            await DataManager().formOpen;
            DataFormState.workType = 'Eseti';
            DataFormState.isClosed = false;
            DataFormState.bizonylatId = newFoglalasId.toString();
            if (!mounted) return;
            setState(() => isRefreshingPanel = false);
            await Navigator.pushNamed(context, '/dataForm');
          }
        }
        else{
          await DataManager(quickCall: QuickCall.tabForm, input: {
            'jelleg':       workType,
            'datum':        DateTime.now(),
            'foglalas_id':  foglalasId,
            'parent_id':    params['parent_id'],
          }).beginQuickCall;
          DataFormState.workType = workType;
          await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
          DataFormState.bizonylatId = foglalasId.toString();
          await Navigator.pushNamed(context, '/dataForm');
        }
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
    if(mounted) setState((){});
    } finally {
      if(mounted) setState(() {isDashboardLocked = false; loadingDashboardButtonId = null;});
    }
  }

  Future<bool> _handlePop() async{
    if(isDashboardLocked) return false;
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

  Future<void> _addIgenyles() async {
    if(isDashboardLocked || buttonAddIgenyles == ButtonState.loading) return;
    setState(() {buttonAddIgenyles = ButtonState.loading; isRefreshingPanel = false;});
    try {
      Global.routeNext = NextRoute.abroncsIgenyles;
      await DataManager(
        input: {'datum': DateTime.now()},
      ).beginProcess;
      await DataManager(
        quickCall: QuickCall.giveDatas,
      ).beginQuickCall;
      await Navigator.pushNamed(context, '/dataForm');
      await DataManager().beginProcess;
      await DataManager(
        quickCall: QuickCall.askIncompleteDays,
      ).beginQuickCall;
    } finally {if (mounted) {setState(() {buttonAddIgenyles = ButtonState.default0;});}}
  }

  /*Future<void> _addIgenyles() async{
    setState(() {isRefreshingPanel = false; buttonAddIgenyles = ButtonState.loading;});
    Global.routeNext = NextRoute.abroncsIgenyles;
    await DataManager(input: {'datum': DateTime.now()}).beginProcess;
    await DataManager(quickCall: QuickCall.giveDatas).beginQuickCall;
    await Navigator.pushNamed(context, '/dataForm');
    await DataManager().beginProcess;
    await DataManager(quickCall: QuickCall.askIncompleteDays).beginQuickCall;
    isRefreshingPanel = false; buttonAddIgenyles = ButtonState.loading;
    setState((){});
  }*/

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> refreshPanel() async {
    if(isRefreshingPanel || isDashboardLocked || buttonAddIgenyles == ButtonState.loading || !mounted) return;
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

class PanelSectionCard extends StatefulWidget {
  final dynamic rawSection;
  final List<Map<String, dynamic>> Function(dynamic) normalizeItems;
  final Widget Function(Map<String, dynamic>, int) drawListItem;
  final Widget Function(String) getButtonFor;

  const PanelSectionCard({
    super.key,
    required this.rawSection,
    required this.normalizeItems,
    required this.drawListItem,
    required this.getButtonFor,
  });

  @override
  State<PanelSectionCard> createState() => _PanelSectionCardState();
}

class _PanelSectionCardState extends State<PanelSectionCard> {
  String searchText = '';

  bool _matchesSearch(Map<String, dynamic> item) {
    final query = searchText.toLowerCase().trim();
    if (query.isEmpty) return true;

    return [
      item['value'],
      item['title'],
      item['message'],
    ].any((v) => v?.toString().toLowerCase().contains(query) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final section = Map<String, dynamic>.from(widget.rawSection as Map);
    final items = widget.normalizeItems(section['items']);
    final filteredItems = items.where(_matchesSearch).toList();
    final scrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final estimatedListHeight = items.length * 72;
        final needsSearch =         estimatedListHeight > constraints.maxHeight - 80;
        final border =              OutlineInputBorder(borderRadius: BorderRadius.circular(30));

        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          section['title']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),                        
                      ),
                    ),
                    if (needsSearch)
                      SizedBox(
                        width: constraints.maxWidth * 0.45,
                        child: TextField(
                          decoration: InputDecoration(
                            isDense:        true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            prefixIcon:     const Icon(Icons.search),
                            labelText:      'Keresés',
                            border:         border,
                            enabledBorder:  border,
                            focusedBorder:  border,
                          ),
                          onChanged: (value) => setState(() => searchText = value),
                        ),
                      ),
                    const SizedBox(width: 8),
                    widget.getButtonFor(section['title']?.toString() ?? ''),
                  ],
                ),

                const SizedBox(height: 8),

                Flexible(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView(
                      controller: scrollController,
                      shrinkWrap: true,
                      children: filteredItems.asMap().entries.map(
                        (entry) => widget.drawListItem(entry.value, entry.key),
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}