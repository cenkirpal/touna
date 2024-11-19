import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/desktop/sidang/add_sidang.dart';
import 'package:touna/page/desktop/sidang/edit_sidang.dart';
import 'package:touna/util/date.dart';

class DetailMobile extends StatefulWidget {
  const DetailMobile({super.key, required this.perkara});
  final PerkaraModel perkara;
  @override
  DetailMobileState createState() => DetailMobileState();
}

class DetailMobileState extends State<DetailMobile> {
  late PerkaraModel perkara;
  AppState appState = AppState.done;
  List<SidangModel>? listSidang = [];
  @override
  void initState() {
    perkara = widget.perkara;
    reload();
    super.initState();
  }

  reload() async {
    setState(() {
      appState = AppState.loading;
      listSidang = [];
    });
    var data = await ApiTouna.getSidang(widget.perkara.id!);

    setState(() {
      appState = AppState.done;
      listSidang = data.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectableText(
          perkara.noPerkara,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => reload(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return AddSidang(perkara: widget.perkara);
                  });
              reload();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Terdakwa : '),
                      const Divider(),
                      Text(
                        perkara.terdakwa.replaceAll(';', '\n'),
                        style: styleBold(),
                      ),
                      Container(height: 25),
                      const Text('JPU : '),
                      const Divider(),
                      Text(
                        perkara.jpu.replaceAll(';', '\n'),
                        style: styleBold(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Majelis : '),
                      const Divider(),
                      Text(
                        perkara.majelis.replaceAll(';', '\n'),
                        style: styleBold(),
                      ),
                      Container(height: 25),
                      const Text('Panitera : '),
                      const Divider(),
                      Text(
                        perkara.panitera,
                        style: styleBold(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(height: 25),
            listSidang == null
                ? Container()
                : appState == AppState.loading
                    ? const Center(child: LinearProgressIndicator())
                    : listSidang!.isEmpty
                        ? Container()
                        : Expanded(
                            child: ListView.builder(
                              itemCount: listSidang!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                var sidang = listSidang![i];
                                return agenda(sidang, i);
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }

  agenda(SidangModel sidang, int i) {
    return Card(
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text('${i + 1}'),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateTime.parse(sidang.date).fullday),
                Text(sidang.agenda),
                if (sidang.keterangan != null)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      sidang.keterangan!,
                      style: styleN(12),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return EditSidang(
                          perkara: widget.perkara,
                          sidang: listSidang![i],
                        );
                      });
                  reload();
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  await ApiTouna.deleteSidang(listSidang![i].id!);
                  reload();
                },
                color: Colors.pink,
                icon: const Icon(Icons.delete_forever),
              ),
            ],
          ),
        ],
      ),
    );
  }

  styleBold() => const TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
  styleN(double n) => TextStyle(fontSize: n);
}
