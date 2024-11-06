import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touna/page/new_print.dart';
import 'package:touna/provider_widget.dart';

class DrawerWidget extends ConsumerStatefulWidget {
  const DrawerWidget({super.key});

  @override
  DrawerState createState() => DrawerState();
}

class DrawerState extends ConsumerState<DrawerWidget> {
  bool show = false;

  goRoute(String name) {
    ref.read(route.notifier).state = name;
  }

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
                if (show)
                  Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const NewPrinterPage();
                        }));
                      },
                      title: const Text('Print POS'),
                    ),
                  ),
                Card(
                  color: activeColor('Data Perkara'),
                  child: ListTile(
                    onTap: () => goRoute('Data Perkara'),
                    title: const Text('Data Perkara'),
                  ),
                ),
                Card(
                  color: activeColor('Jadwal Sidang'),
                  child: ListTile(
                    onTap: () => goRoute('Jadwal Sidang'),
                    title: const Text('Jadwal Sidang'),
                  ),
                ),
                Card(
                  color: activeColor('Rekap Sidang'),
                  child: ListTile(
                    onTap: () => goRoute('Rekap Sidang'),
                    title: const Text('Rekap Sidang'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  activeColor(String name) {
    if (ref.watch(route) == name) return Colors.blue[300];
    return null;
  }
}
