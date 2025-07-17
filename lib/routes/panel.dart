// ignore_for_file: use_build_context_synchronously

import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Panel extends StatefulWidget {
  const Panel({super.key});

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  final List<Map<String, dynamic>> jsonData = [
    {
      "type": "1",
      "icon": "truck",
      "title": "Lakihegy Komisszió–Ipsum-Tech Service",
      "value": "SZL2025/2591 2025.06.30",
      "buttons": [
        {
          "name": "Átvettem",
          "callback": "DashboardSzallitoLevelAtvettemButtonClick('47754')",
          "color": "success",
          "icon": "check"
        },
        {
          "name": "Nyomtatás",
          "callback": "printPage",
          "color": "secondary",
          "icon": "printer"
        },
        {
          "name": "MPL",
          "callback": "openMPL",
          "color": "success",
          "icon": "package"
        }
      ],
      "link": "https://app.mosaic.hu/pdfgenerator/mercarius/szallitolevel.php?kategoria_id=3&id=47754&saveandopen=1"
    },
    // You can add more items here.
  ];

  IconData getIcon(String iconName) {
    switch (iconName) {
      case 'truck':
        return FontAwesomeIcons.truck;
      case 'check':
        return Icons.check;
      case 'printer':
        return Icons.print;
      case 'package':
        return FontAwesomeIcons.box;
      default:
        return Icons.help_outline;
    }
  }

  Color getColor(String colorName) {
    switch (colorName) {
      case 'success':
        return Colors.green;
      case 'secondary':
        return Colors.grey;
      case 'danger':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Overview")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: jsonData.map((item) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(getIcon(item['icon']), color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(item['value'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item['title'], style: const TextStyle(color: Colors.black54)),
                    const Spacer(),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: List.generate(item['buttons'].length, (i) {
                        final btn = item['buttons'][i];
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getColor(btn['color']),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            debugPrint("Pressed: ${btn['callback']}");
                          },
                          icon: Icon(getIcon(btn['icon']), size: 14),
                          label: Text(btn['name'], style: const TextStyle(fontSize: 12)),
                        );
                      }),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Global.routeNext = NextRoute.calendar;
          await DataManager(quickCall: QuickCall.askIncompleteDays).beginQuickCall;
          await Navigator.pushNamed(context, '/calendar');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.calendar_month),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}