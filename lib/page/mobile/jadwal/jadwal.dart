import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/mobile/perkara/detail.dart';
import 'package:touna/util/date.dart';

class JadwalMobile extends StatefulWidget {
  const JadwalMobile({super.key});
  @override
  JadwalMobileState createState() => JadwalMobileState();
}

class JadwalMobileState extends State<JadwalMobile> {
  DateTime date = DateTime.now();
  final controller = ScreenshotController();
  AppState appState = AppState.done;
  List<SidangModel> lists = [];
  Uint8List? bytes;
  bool detail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    cek();
  }

  @override
  dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> cek() async {
    if (date.dayname == 'Minggu') {
      date = date.add(const Duration(days: 1));
    }
    if (date.dayname == 'Sabtu') {
      date = date.add(const Duration(days: 2));
    }
    setState(() {
      appState = AppState.loading;
      lists = [];
    });
    var fetch = await ApiTouna.jadwal(date.formatDB);
    if (!mounted) return;
    setState(() {
      appState = AppState.done;
      lists = fetch;
    });
  }

  capture(BuildContext context) async {
    var disk = await Permission.manageExternalStorage.isGranted;
    if (!disk) await Permission.manageExternalStorage.request();
    // var dir = await getDownloadsDirectory();
    var dir = Directory('/storage/emulated/0/Download/sidang/');
    await dir.create(recursive: true);

    // var des = Directory(join(dir.path, 'sidang'));
    // des.create(recursive: true);

    // if (context.mounted) {
    //   var byte = await controller.captureFromLongWidget(
    //     pixelRatio: 2,
    //     InheritedTheme.captureAll(context, sidangWidget(context, true)),
    //   );

    //   var file =
    //       await File(join(des.path, 'P38 - ${date.fullday}.png')).create();
    //   file.writeAsBytesSync(byte);

    //   final uri = Uri.file(des.path);
    //   await launchUrl(uri);
    // }
  }

  datePick(BuildContext context) async {
    var pick = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: date,
    );
    if (pick != null) {
      setState(() => date = pick);
      cek();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      actions: [
        Text(
          '${lists.length} Perkara',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => datePick(context),
          child: Text(
            date.fullday,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => capture(context),
          icon: const Icon(Icons.photo),
        ),
        PopupMenuButton(itemBuilder: (context) {
          return [
            PopupMenuItem(
              onTap: () => cek(),
              child: const Text('Refresh'),
            ),
            PopupMenuItem(
              onTap: () => setState(() => detail = !detail),
              child: const Text('Detail'),
            ),
          ];
        }),
      ],
      body: appState == AppState.loading
          ? const Center(
              child: SizedBox(width: 200, child: LinearProgressIndicator()),
            )
          : lists.isEmpty
              ? const Center(child: Text('Tidak ada sidang hari ini'))
              : SingleChildScrollView(
                  child: Screenshot(
                    controller: controller,
                    child: sidangWidget(context, false),
                  ),
                ),
    );
  }

  Widget sidangWidget(BuildContext context, bool shot) {
    var data = lists.asMap();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data
          .map((i, v) {
            return MapEntry(
                i,
                Card(
                  color: colorTile(v),
                  child: sidangContainer(context, shot, i, v),
                ));
          })
          .values
          .toList(),
    );
  }

  sidangContainer(BuildContext context, bool shot, int i, SidangModel data) {
    if (shot) return sidangTile(context, i, data, shot);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: sidangTile(context, i, data, shot),
    );
  }

  sidangTile(BuildContext context, int i, SidangModel data, bool shot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text('${i + 1}'),
          ),
          SizedBox(
            width: 250,
            child: Text(
              data.perkara!.terdakwa.replaceAll(';', '\n'),
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(
            width: 250,
            child: Text(
              data.agenda,
            ),
          ),
          SizedBox(
            width: 250,
            child: Text(
              detail
                  ? data.perkara!.jpu.replaceAll(';', '\n')
                  : data.perkara!.jpu.split(';').first,
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(
            width: 250,
            child: Text(
              detail
                  ? data.perkara!.majelis.replaceAll(';', '\n')
                  : data.perkara!.majelis.split(';').first,
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(
            width: 250,
            child: Text(
              data.perkara!.panitera,
              overflow: TextOverflow.clip,
            ),
          ),
          if (!shot)
            SizedBox(
              width: 50,
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DetailMobile(perkara: data.perkara!);
                  }));
                },
                icon: const Icon(Icons.remove_red_eye),
              ),
            ),
          if (!shot)
            SizedBox(
              width: 50,
              child: IconButton(
                onPressed: () async {
                  await ApiTouna.ketSidang(data.id!, !(data.ket ?? false));
                  await cek();
                },
                icon: const Icon(Icons.done),
              ),
            ),
        ],
      ),
    );
  }

  colorTile(SidangModel data) {
    if (data.perkara!.putusan != null) return Colors.pink[200];
    if (data.ket == true) return Colors.green[200];
    return null;
  }
}
