import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/detail_perkara.dart';
import 'package:touna/page/edit_perkara.dart';
import 'package:touna/page/jadwal_sidang.dart';
import 'package:touna/util/date.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  AppState appState = AppState.done;
  final _keyword = TextEditingController();
  List<PerkaraModel> lists = [];
  bool detail = false;

  @override
  initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    setState(() {
      appState = AppState.loading;
      lists = [];
    });
    var d = await ApiTouna.getPerkara(keyword: _keyword.text);
    if (!mounted) return;
    setState(() {
      lists = d;
      appState = AppState.done;
    });
  }

  insert() async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const AddPerkara();
        });
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: TextFormField(
              controller: _keyword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    _keyword.clear();
                    fetch();
                  },
                  iconSize: 20,
                  color: Colors.pink,
                  icon: const Icon(Icons.close),
                ),
              ),
              onFieldSubmitted: (value) {
                if (_keyword.text.isNotEmpty) fetch();
              },
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const JadwalSidang();
              }));
            },
            icon: const Icon(Icons.schedule),
          ),
          IconButton(
            onPressed: () => setState(() => detail = !detail),
            color: detail ? Colors.blue : Colors.red,
            icon: const Icon(Icons.remove_red_eye),
          ),
          IconButton(onPressed: () => insert(), icon: const Icon(Icons.add)),
          IconButton(onPressed: () => fetch(), icon: const Icon(Icons.refresh))
        ],
      ),
      body: appState == AppState.loading
          ? const Center(
              child: SizedBox(
              width: 200,
              child: LinearProgressIndicator(),
            ))
          : lists.isEmpty
              ? const Center(child: Text('No Data'))
              : ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, i) {
                    var data = lists[i];
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.green[400]!, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      shadowColor: Colors.pink,
                      surfaceTintColor: Colors.pink,
                      color: data.putusan == true ? Colors.pink[200] : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return DetailPerkara(
                                                  perkara: lists[i]);
                                            }));
                                          },
                                          child: Text(
                                            data.noPerkara,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          data.terdakwa.replaceAll(';', '\n'),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: PopupMenuButton(
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero,
                                              () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return EditPerkara(
                                                      perkara: lists[i]);
                                                }).then((v) => fetch());
                                          });
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero,
                                              () async {
                                            bool putus = data.putusan ?? false;

                                            await ApiTouna.putus(
                                                lists[i].id!, !putus);

                                            fetch();
                                          });
                                        },
                                        child: const Text('Putusan'),
                                      ),
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero,
                                              () async {
                                            await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    content: const Text(
                                                        'Delete Data ?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await ApiTouna
                                                              .deletePerkara(
                                                                  lists[i].id!);
                                                          fetch();
                                                          if (context.mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  );
                                                });
                                            fetch();
                                          });
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (detail) const Divider(),
                          if (detail)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data.jpu.replaceAll(';', '\n'),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(width: 32),
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data.majelis
                                                  .replaceAll(';', '\n'),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(width: 32),
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data.panitera
                                                  .replaceAll(';', '\n'),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (data.sidang != null)
                            sidang(data.sidang!.reversed.toList()),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget sidang(List<SidangModel> data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: data
              .toList()
              .asMap()
              .map((key, value) => MapEntry(
                  key,
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 4, 18, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${key + 1}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateTime.parse(value.date).fullday),
                            Text(
                              value.agenda,
                              style: key != 0
                                  ? null
                                  : TextStyle(
                                      color: colorSidang(value),
                                      fontWeight: FontWeight.bold,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )))
              .values
              .toList(),
        ),
      ),
    );
  }

  Color? colorSidang(SidangModel sidang) {
    if (DateTime.parse(sidang.date).difference(DateTime.now()).inDays >= 0) {
      return null;
    }
    return Colors.pink[700];
  }

  Widget formatText(String txt, {TextAlign? align, TextStyle? style}) {
    return SelectableText(txt.replaceAll(';', '\n'),
        textAlign: align, style: style);
  }
}

class AddPerkara extends StatefulWidget {
  const AddPerkara({super.key});
  @override
  AddPerkaraState createState() => AddPerkaraState();
}

class AddPerkaraState extends State<AddPerkara> {
  final _form = GlobalKey<FormState>();
  final _noPerkara = TextEditingController();
  final _terdakwa = TextEditingController();
  final _pasal = TextEditingController();
  final _jpu = TextEditingController();
  final _majelis = TextEditingController();
  final _panitera = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('Tambah Perkara'),
      content: SizedBox(
        width: size.width - 200,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _noPerkara,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'No Perkara', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _terdakwa,
                    maxLines: 3,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Terdakwa', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _pasal,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Pasal', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _jpu,
                    maxLines: 3,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'JPU', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _majelis,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Majelis', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _panitera,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Panitera', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            var pkr = PerkaraModel(
              terdakwa: _terdakwa.text,
              pasal: _pasal.text,
              jpu: _jpu.text,
              majelis: _majelis.text,
              panitera: _panitera.text,
              noPerkara: _noPerkara.text,
              putusan: false,
            ).toMap();
            pkr.removeWhere((key, value) => key == 'sidang');

            await ApiTouna.addPerkara(pkr);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
