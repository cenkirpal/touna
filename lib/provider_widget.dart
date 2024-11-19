import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touna/page/desktop/browser/open_web.dart';
import 'package:touna/page/desktop/perkara/data_perkara.dart';
import 'package:touna/page/desktop/printer/printer_container.dart';
import 'package:touna/page/desktop/rekap/rekap_sidang.dart';
import 'package:touna/page/desktop/sidang/jadwal_sidang.dart';
import 'package:touna/page/mobile/jadwal/jadwal.dart';
import 'package:touna/page/mobile/perkara/perkara.dart';
import 'package:touna/page/mobile/rekap/rekap.dart';

final route = StateProvider<String>((ref) => 'Jadwal Sidang');

final routeProvider = Provider<WidgetBuilder>((ref) {
  var des = ref.watch(route);
  // if (Platform.isAndroid) {
  // return mobileRoute[des] ?? mobileRoute.values.first;
  // } else {
  return routeBuilder[des] ?? routeBuilder.values.first;
  // }
});

Map<String, WidgetBuilder> routeBuilder = {
  'Data Perkara': (context) => const DataPerkara(),
  'Jadwal Sidang': (context) => const JadwalSidang(),
  'Rekap Sidang': (context) => const RekapSidang(),
  'Printer': (context) => const PrinterContainer(),
  'Open Web': (context) => const OpenWeb(),
};
Map<String, WidgetBuilder> mobileRoute = {
  'Data Perkara': (context) => const PerkaraMobile(),
  'Jadwal Sidang': (context) => const JadwalMobile(),
  'Rekap Sidang': (context) => const RekapMobile(),
  // 'Printer': (context) => const PrinterContainer(),
  // 'Open Web': (context) => const OpenWeb(),
};
