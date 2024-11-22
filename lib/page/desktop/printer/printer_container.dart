import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:touna/main.dart';
import 'package:touna/page/desktop/printer/database.dart';
import 'package:touna/page/desktop/printer/printer_ampana.dart';
import 'package:touna/page/desktop/printer/printer_dki.dart';
import 'package:url_launcher/url_launcher.dart';

class PrinterContainer extends StatefulWidget {
  const PrinterContainer({super.key});
  @override
  PrinterContainerState createState() => PrinterContainerState();
}

class PrinterContainerState extends State<PrinterContainer> {
  String nota = 'nota1';
  late Widget printerWidget;
  final _note = TextEditingController();
  Printer? printer;

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    printerWidget = PrinterAmpana(
      onPrint: (data) {
        selectPrinter(data);
      },
    );
    var q = await PrinterDB.note('get', 'data');
    setState(() => _note.text = q);
  }

  updateWidget(String mode) {
    setState(() {
      mode == 'nota1'
          ? printerWidget = PrinterAmpana(onPrint: (data) {
              selectPrinter(data);
            })
          : printerWidget = PrinterDKI(onPrint: (data) {
              selectPrinter(data);
            });
      nota = mode;
    });
  }

  Future<bool> cekPrinter() async {
    if (printer == null) return false;
    var c = await FlutterThermalPrinter.instance.connect(printer!);
    if (!c) setState(() => printer = null);
    return c;
  }

  selectPrinter(List<int> byte) async {
    if (printer != null) {
      if (await cekPrinter()) {
        await printData(byte);
      } else {
        await FlutterThermalPrinter.instance.connect(printer!);
        await printData(byte);
      }
    } else {
      // if (!mounted) return;

      var p = await showDialog(
          context: context,
          builder: (context) {
            return const ShowPrinter();
          });

      if (p == null) return;
      setState(() => printer = p);
      await FlutterThermalPrinter.instance.connect(p);
      await printData(byte);
    }
  }

  printData(List<int> byte) async {
    showSnack('Printing ...');
    await FlutterThermalPrinter.instance
        .printData(printer!, byte, longData: true);
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Printer',
      actions: [
        IconButton(
          onPressed: () async {
            final doc = await getApplicationSupportDirectory();
            final dir = Directory(path.join(doc.path, 'touna'));

            launchUrl(Uri.file(dir.path));
          },
          icon: const Icon(Icons.folder),
        ),
      ],
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => updateWidget('nota1'),
                    style: buttonStyle('nota1'),
                    child: const Text('Nota 1'),
                  ),
                  Container(width: 16),
                  TextButton(
                    onPressed: () => updateWidget('nota2'),
                    style: buttonStyle('nota2'),
                    child: const Text('Nota 2'),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  printerWidget,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              TextFormField(controller: _note, maxLines: 20),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: IconButton(
                                  onPressed: () async {
                                    await PrinterDB.note('add', _note.text);
                                  },
                                  icon: const Icon(Icons.save),
                                ),
                              ),
                            ],
                          ),
                          const Column(
                            children: [
                              Text('data'),
                              Text('data'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 18)),
          behavior: SnackBarBehavior.floating,
          width: 300,
        ),
      );
  }

  buttonStyle(String mode) {
    return nota == mode
        ? ElevatedButton.styleFrom(
            backgroundColor: Colors.green[300],
            foregroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))
        : ElevatedButton.styleFrom(foregroundColor: Colors.black87);
  }
}

class ShowPrinter extends StatefulWidget {
  const ShowPrinter({super.key});

  @override
  ShowPrinterState createState() => ShowPrinterState();
}

class ShowPrinterState extends State<ShowPrinter> {
  List<Printer> listPrinter = [];
  StreamSubscription<List<Printer>>? stream;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  @override
  dispose() {
    super.dispose();
    stream?.cancel();
  }

  startScan() async {
    try {
      Future.delayed(const Duration(seconds: 3), () => stopScan());
      await FlutterThermalPrinter.instance.startScan();
      stream = FlutterThermalPrinter.instance.devicesStream.listen((event) {
        // if (!mounted) return;

        setState(() {
          listPrinter = event.map((e) => Printer.fromJson(e.toJson())).toList();
          listPrinter.removeWhere(
            (element) => element.name == null || element.name!.isEmpty,
          );
        });
      });
    } catch (e) {
      showSnack('Failed to start scanning for devices $e');
    }
  }

  stopScan() async {
    try {
      stream?.cancel();
      await FlutterThermalPrinter.instance.stopScan();
    } catch (e) {
      showSnack('Failed to stop scanning for devices $e');
    }
  }

  showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 18)),
          behavior: SnackBarBehavior.floating,
          width: 300,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      content: SizedBox(
        height: size.height * .7,
        width: size.width * .7,
        child: listPrinter.isEmpty
            ? const Center(
                child: SizedBox(width: 100, child: LinearProgressIndicator()),
              )
            : ListView.builder(
                itemCount: listPrinter.length,
                itemBuilder: (context, i) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        // await FlutterThermalPrinter.instance
                        //     .connect(listPrinter[i]);
                        Navigator.pop(context, listPrinter[i]);
                      },
                      title: Text(listPrinter[i].name ?? ''),
                      subtitle: Text(listPrinter[i].address ?? ''),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
