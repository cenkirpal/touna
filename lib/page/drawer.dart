import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touna/provider_widget.dart';

class DrawerWidget extends ConsumerStatefulWidget {
  const DrawerWidget({super.key});

  @override
  DrawerState createState() => DrawerState();
}

class DrawerState extends ConsumerState<DrawerWidget> {
  bool show = false;

  goRoute(String name, bool draw) {
    if (draw) {
      Scaffold.of(context).closeDrawer();
    }
    ref.read(route.notifier).state = name;
  }

  @override
  Widget build(BuildContext context) {
    var draw = Scaffold.of(context).hasDrawer;
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
                    color: activeColor('Printer'),
                    child: ListTile(
                      onTap: () => goRoute('Printer', draw),
                      title: const Text('Printer'),
                    ),
                  ),
                Card(
                  color: activeColor('Data Perkara'),
                  child: ListTile(
                    onTap: () => goRoute('Data Perkara', draw),
                    title: const Text('Data Perkara'),
                  ),
                ),
                Card(
                  color: activeColor('Jadwal Sidang'),
                  child: ListTile(
                    onTap: () => goRoute('Jadwal Sidang', draw),
                    title: const Text('Jadwal Sidang'),
                  ),
                ),
                Card(
                  color: activeColor('Rekap Sidang'),
                  child: ListTile(
                    onTap: () => goRoute('Rekap Sidang', draw),
                    title: const Text('Rekap Sidang'),
                  ),
                ),
                if (show)
                  Card(
                    color: activeColor('Open Web'),
                    child: ListTile(
                      onTap: () => goRoute('Open Web', draw),
                      title: const Text('Open Web'),
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
