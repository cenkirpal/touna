import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';

class RekapMobile extends StatefulWidget {
  const RekapMobile({super.key});
  @override
  RekapMobileState createState() => RekapMobileState();
}

class RekapMobileState extends State<RekapMobile> {
  AppState appState = AppState.done;
  List<SidangModel> lists = [];
  DateTimeRange? date;
  int perkara = 0;

  rekap(DateTimeRange date) async {
    setState(() {
      appState = AppState.loading;
      lists = [];
    });
    final data =
        await ApiTouna.rekapJadwal(date.start.formatDB, date.end.formatDB);
    data.sort((a, b) {
      if (DateTime.parse(a.date).isAfter(DateTime.parse(b.date))) return 1;
      return -1;
    });
    setState(() => lists = data);
    var perk = [];
    for (var item in data) {
      perk.add(item.perkara!.noPerkara);
    }
    var jml = perk.toSet().toList();

    setState(() {
      perkara = jml.length;
      appState = AppState.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: lists.isEmpty
          ? ''
          : 'Total Sidang : ${lists.length} dari $perkara Perkara',
      actions: [
        TextButton(
          onPressed: () async {
            var picker = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            setState(() => date = picker);
            if (picker != null) rekap(picker);
          },
          child: Text(
            date == null
                ? 'Pilih Tanggal'
                : '${date!.start.fullday} - ${date!.end.fullday}',
          ),
        ),
      ],
      body: appState == AppState.loading
          ? const Center(
              child: SizedBox(
              width: 200,
              child: LinearProgressIndicator(),
            ))
          : lists.isEmpty
              ? const Center(child: Text('Tidak Ada Data'))
              : ListView.builder(
                  itemCount: lists.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) => sidangTile(i, lists[i]),
                ),
    );
  }

  sidangTile(int i, SidangModel data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text('${i + 1}'),
              ),
              SizedBox(
                width: 250,
                child: Text(lists[i].perkara!.terdakwa.replaceAll(';', '\n')),
              ),
              SizedBox(
                width: 200,
                child: Text(lists[i].agenda),
              ),
              Container(width: 16),
              SizedBox(
                width: 150,
                child: Text(DateTime.parse(lists[i].date).fullday),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
