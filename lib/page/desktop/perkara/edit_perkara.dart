import 'dart:io';

import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';

class EditPerkara extends StatefulWidget {
  const EditPerkara({super.key, required this.perkara});
  final PerkaraModel perkara;
  @override
  EditPerkaraState createState() => EditPerkaraState();
}

class EditPerkaraState extends State<EditPerkara> {
  AppState appState = AppState.done;
  final _form = GlobalKey<FormState>();
  final _noPerkara = TextEditingController();
  final _terdakwa = TextEditingController();
  final _pasal = TextEditingController();
  final _jpu = TextEditingController();
  final _majelis = TextEditingController();
  final _panitera = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    var pkr = widget.perkara;

    _noPerkara.text = pkr.noPerkara;
    _terdakwa.text = pkr.terdakwa;
    _pasal.text = pkr.pasal;
    _jpu.text = pkr.jpu;
    _majelis.text = pkr.majelis;
    _panitera.text = pkr.panitera;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('Tambah Perkara'),
      content: SizedBox(
        width: size.width - (Platform.isAndroid ? 12 : 200),
        child: appState == AppState.loading
            ? const Center(
                child: SizedBox(
                width: 250,
                child: LinearProgressIndicator(),
              ))
            : SingleChildScrollView(
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
                              labelText: 'No Perkara',
                              border: OutlineInputBorder()),
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
                              labelText: 'Terdakwa',
                              border: OutlineInputBorder()),
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
                              labelText: 'Majelis',
                              border: OutlineInputBorder()),
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
                              labelText: 'Panitera',
                              border: OutlineInputBorder()),
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
            setState(() => appState = AppState.loading);
            var pkr = PerkaraModel(
              id: widget.perkara.id,
              terdakwa: _terdakwa.text,
              pasal: _pasal.text,
              jpu: _jpu.text,
              majelis: _majelis.text,
              panitera: _panitera.text,
              noPerkara: _noPerkara.text,
              putusan: widget.perkara.putusan,
            );

            ApiTouna.editPerkara(widget.perkara.id!, pkr).then((v) {
              if (context.mounted) Navigator.pop(context, true);
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
