import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/desktop/perkara/edit_perkara.dart';
import 'package:touna/page/desktop/perkara/widget/add_file.dart';
import 'package:touna/page/desktop/sidang/add_sidang.dart';
import 'package:touna/page/desktop/sidang/edit_sidang.dart';
import 'package:touna/util/date.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPerkara extends StatefulWidget {
  const DetailPerkara({super.key, required this.perkara});
  final PerkaraModel perkara;
  @override
  DetailPerkaraState createState() => DetailPerkaraState();
}

class DetailPerkaraState extends State<DetailPerkara> {
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
    var data = await ApiTouna.findPerkara(perkara.noPerkara);
    if (!mounted) return;
    setState(() {
      perkara = data;
      listSidang = data.sidang == null ? [] : data.sidang!.reversed.toList();
      appState = AppState.done;
    });
  }

  addFiles() async {
    var p = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AddFile(id: perkara.id!);
        });
    if (p == true) reload();
  }

  editPerkara() async {
    var p = await showDialog(
        context: context,
        builder: (context) {
          return EditPerkara(perkara: perkara);
        });
    if (p == true) reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectableText(perkara.noPerkara),
        actions: [
          IconButton(
            onPressed: () => reload(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              var p = await showDialog(
                  context: context,
                  builder: (context) {
                    return AddSidang(perkara: perkara);
                  });
              if (p == true) reload();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => editPerkara(),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              height: double.infinity,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Terdakwa : '),
                        Text(
                          perkara.terdakwa.replaceAll(';', '\n'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(endIndent: 100),
                        const Text('JPU : '),
                        Text(
                          perkara.jpu.replaceAll(';', '\n'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(endIndent: 100),
                        const Text('Majelis : '),
                        Text(
                          perkara.majelis.replaceAll(';', '\n'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(endIndent: 100),
                        const Text('Panitera : '),
                        Text(
                          perkara.panitera.replaceAll(';', '\n'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(),
                        ...listFile()
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: () => addFiles(),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              color: Colors.black12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                      return Card(
                                        child: ListTile(
                                          leading: Text('${i + 1}'),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(DateTime.parse(sidang.date)
                                                  .fullday),
                                              if (sidang.keterangan != null)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          16, 8, 16, 8),
                                                  child:
                                                      Text(sidang.keterangan!),
                                                )
                                            ],
                                          ),
                                          subtitle: Text(sidang.agenda),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  var p = await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return EditSidang(
                                                          perkara: perkara,
                                                          sidang:
                                                              listSidang![i],
                                                        );
                                                      });
                                                  if (p == true) reload();
                                                },
                                                icon: const Icon(Icons.edit),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await ApiTouna.deleteSidang(
                                                      listSidang![i].id!);
                                                  reload();
                                                },
                                                color: Colors.pink,
                                                icon: const Icon(
                                                    Icons.delete_forever),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> listFile() {
    return [
      // if (perkara.files != null)
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.green[300], borderRadius: BorderRadius.circular(8)),
        child: TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return LoadPDF(path: perkara.files!.putusan!);
                });
          },
          child: const Text(
            'File Putusan',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
      // else
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.green[300], borderRadius: BorderRadius.circular(8)),
        child: TextButton(
          onPressed: () {
            var uri =
                'https://drive.google.com/drive/folders/1-raXAxYYar77MeTkM9ZNdNiVubyTqyhe?usp=drive_link';
            launchUrl(Uri.parse(uri));
          },
          child: const Text(
            'File Uri Putusan',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    ];
  }
}

class LoadPDF extends StatefulWidget {
  const LoadPDF({super.key, required this.path});
  final String path;
  @override
  LoadPDFState createState() => LoadPDFState();
}

class LoadPDFState extends State<LoadPDF> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      content: SizedBox(
        width: size.width - 50,
        height: size.height - 50,
        child: PdfDocumentViewBuilder.uri(
          Uri.parse('https://cenkirpal.com/backend/public/${widget.path}'),

          builder: (context, document) {
            return ListView.builder(
              itemCount: document?.pages.length ?? 0,
              itemBuilder: (context, i) {
                return PdfPageView(document: document, pageNumber: i + 1);
              },
            );
            // return PdfPageView(document: document, pageNumber: pageNumber);
          },
          // params: PdfViewerParams(
          //   errorBannerBuilder: (context, error, stackTrace, documentRef) {
          //     print('object');
          //     return Column(
          //       children: [
          //         Text(documentRef.sourceName),
          //         Text(error.toString()),
          //       ],
          //     );
          //   },
          // ),
        ),
      ),
    );
  }
}
