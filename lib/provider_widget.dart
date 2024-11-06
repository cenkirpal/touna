import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touna/page/desktop/perkara/data_perkara.dart';
import 'package:touna/page/desktop/rekap/rekap_sidang.dart';
import 'package:touna/page/desktop/sidang/jadwal_sidang.dart';

final route = StateProvider<String>((ref) => 'Jadwal Sidang');

final routeProvider = Provider<WidgetBuilder>((ref) {
  var des = ref.watch(route);
  return routeBuilder[des] ?? routeBuilder.values.first;
});

Map<String, WidgetBuilder> routeBuilder = {
  'Data Perkara': (context) => const DataPerkara(),
  'Jadwal Sidang': (context) => const JadwalSidang(),
  'Rekap Sidang': (context) => const RekapSidang(),
};
