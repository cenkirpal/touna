import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:touna/model/perkara_model.dart';

class EditPerkara extends StatefulWidget {
  const EditPerkara({super.key, required this.perkara});
  final QueryDocumentSnapshot perkara;
  @override
  EditPerkaraState createState() => EditPerkaraState();
}

class EditPerkaraState extends State<EditPerkara> {
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
    var pkr =
        PerkaraModel.fromJson(widget.perkara.data() as Map<String, dynamic>);

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
            );
            await FirebaseAuth.instance.signInAnonymously();

            await FirebaseFirestore.instance
                .collection('perkara')
                .doc(widget.perkara.id)
                .update(pkr.toMap());
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
