import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:sembast/sembast.dart';
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
  List<RecordSnapshot> spbu = [];
  final _spbu = TextEditingController();
  RecordSnapshot? selSpbu;
  Printer? printer;
  BluetoothInfo? device;

  @override
  initState() {
    super.initState();
    getSpbu();
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

  printWindows(List<int> byte) async {
    if (device == null) {
      var p = await showDialog(
          context: context,
          builder: (context) {
            return const ShowPrinterWindows();
          });
      if (p == null) return;
      setState(() => device = p);
      await printData(byte);
    } else {
      await printData(byte);
    }
  }

  selectPrinter(List<int> byte) async {
    if (Platform.isWindows) return printWindows(byte);
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
    if (Platform.isWindows) {
      await PrintBluetoothThermal.connect(macPrinterAddress: device!.macAdress);
      await PrintBluetoothThermal.writeBytes(byte);
    } else {
      await FlutterThermalPrinter.instance
          .printData(printer!, byte, longData: true);
    }
  }

// SPBU
  getSpbu() async {
    var data = await PrinterDB.getSpbu();
    setState(() {
      spbu = data;
      if (selSpbu == null) {
        selSpbu = data.first;
        _spbu.text = (data.first.value as Map<String, dynamic>)['ket'];
      } else {
        var pom = data.where((a) {
          var v = a.value as Map<String, dynamic>;
          var b = selSpbu!.value as Map<String, dynamic>;

          return (v['spbu'] as String)
              .toLowerCase()
              .contains((b['spbu'] as String).toLowerCase());
        });
        setState(() => selSpbu = pom.first);
      }
    });
  }

  addSpbu() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextFormField(
              autofocus: true,
              onFieldSubmitted: (value) async {
                await PrinterDB.addSpbu(value);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          );
        });
    getSpbu();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                          Container(
                            width: size.width - 300,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: IconButton(
                                    onPressed: () => addSpbu(),
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                                Positioned(
                                  right: 54,
                                  top: 8,
                                  child: IconButton(
                                    onPressed: () => getSpbu(),
                                    icon: const Icon(Icons.refresh),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (spbu.isNotEmpty)
                                      Container(
                                        width: 200,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: DropdownButton<RecordSnapshot>(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          isExpanded: true,
                                          padding: const EdgeInsets.all(8),
                                          value: selSpbu,
                                          underline: Container(),
                                          items: spbu
                                              .asMap()
                                              .map((k, v) {
                                                var data = v.value
                                                    as Map<String, dynamic>;
                                                return MapEntry(
                                                    k,
                                                    DropdownMenuItem<
                                                        RecordSnapshot>(
                                                      value: v,
                                                      child: Text(data['spbu']),
                                                    ));
                                              })
                                              .values
                                              .toList(),
                                          onChanged: (v) {
                                            setState(() {
                                              selSpbu = v!;
                                              _spbu.text = (v.value as Map<
                                                  String, dynamic>)['ket'];
                                            });
                                          },
                                        ),
                                      ),
                                    TextFormField(
                                        controller: _spbu, maxLines: 10),
                                  ],
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: IconButton(
                                    onPressed: () async {
                                      await PrinterDB.editSpbu(
                                          selSpbu!.key as int, _spbu.text);
                                    },
                                    icon: const Icon(Icons.save),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 16),
                          Container(
                            width: size.width - 300,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
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

class ShowPrinterWindows extends StatefulWidget {
  const ShowPrinterWindows({super.key});

  @override
  ShowPrinterWindowsState createState() => ShowPrinterWindowsState();
}

class ShowPrinterWindowsState extends State<ShowPrinterWindows> {
  List<BluetoothInfo> listPrinter = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  startScan() async {
    var paired = await PrintBluetoothThermal.pairedBluetooths;
    await Future.forEach(paired, (bl) => bl);
    setState(() => listPrinter = paired);
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
                        Navigator.pop(context, listPrinter[i]);
                      },
                      title: Text(listPrinter[i].name),
                      subtitle: Text(listPrinter[i].macAdress),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
