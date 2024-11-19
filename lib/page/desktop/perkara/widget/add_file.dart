import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';

class AddFile extends StatefulWidget {
  const AddFile({super.key, required this.id});
  final int id;
  @override
  AddFileState createState() => AddFileState();
}

class AddFileState extends State<AddFile> {
  PlatformFile? file;
  String error = '';

  pickFile() async {
    var p = await FilePicker.platform
        .pickFiles(allowedExtensions: ['pdf'], type: FileType.custom);
    if (p == null) return;

    if ((p.files.first.size / 1000) > 1000) {
      setState(() => error = 'Ukuran File Lebih dari 500 kb');
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          error = '';
          file = null;
        });
      });
    } else {
      setState(() => file = p.files.first);
    }
  }

  // await ApiTouna.addFiles(widget.perkara.id!);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text(
                  error,
                  style: const TextStyle(
                      color: Colors.pink, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(file?.name ?? 'Pilih File'),
                    IconButton(
                      onPressed: () => pickFile(),
                      icon: const Icon(Icons.picture_as_pdf),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            setState(() => error = '');
            if (file == null) {
              setState(() => error = 'File belum ada');
              return;
            }
            await ApiTouna.addFiles(widget.id, file!.path!);
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
