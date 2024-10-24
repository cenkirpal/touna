import 'package:flutter/material.dart';
import 'package:touna/page/index.dart';
import 'package:touna/page/printer.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  DrawerState createState() => DrawerState();
}

class DrawerState extends State<DrawerWidget> {
  bool show = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey.shade200,
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset(
                  'assets/logo_kejaksaan.png',
                  height: 100,
                  colorBlendMode: BlendMode.overlay,
                  filterQuality: FilterQuality.high,
                ),
                GestureDetector(
                  onDoubleTap: () => setState(() => show = !show),
                  child: const Text(
                    'KN TOJO UNA UNA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const HomePage(title: 'Jadwal Sidang KN Touna');
                      }));
                    },
                    title: const Text('Data Perkara'),
                  ),
                ),
                if (show)
                  Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const PrinterPage();
                        }));
                      },
                      title: const Text('Print POS'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
