import 'dart:async';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal_windows.dart';
import 'package:sembast/sembast.dart';
import 'package:touna/db/database.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  PrinterPageState createState() => PrinterPageState();
}

class PrinterPageState extends State<PrinterPage> {
  late List<RecordSnapshot> listJenis;
  late RecordSnapshot jenis;
  late List<RecordSnapshot> listSpbu;
  late RecordSnapshot spbu;
  final regNum = RegExp(r'[^0-9]');
  int harga = 0;
  BluetoothInfo? printer;
  List<BluetoothInfo> listPrinter = [];
  final _form = GlobalKey<FormState>();
  final _kodePom = TextEditingController();
  final _alamat = TextEditingController();
  //
  final _shift = TextEditingController();
  final _trans = TextEditingController();
  final _tgl = TextEditingController();
  final _jam = TextEditingController();
  //
  final _pompa = TextEditingController();
  final _produk = TextEditingController();
  final _harga = TextEditingController();
  final _volume = TextEditingController();
  final _total = TextEditingController();
  final _operator = TextEditingController();
  //
  final _plat = TextEditingController();

  @override
  initState() {
    super.initState();
    init();
    _kodePom.text = '7494622';
    _alamat.text =
        'SPBU TRANSSULAWESI, PUSUNGI\nJL. SULTAN HASANUDIN AMPANA KOTA\nTelp. 02182651332';
    _shift.text = '1';
    _trans.text = '363751';
    _tgl.text = '06/07/2024';
    _jam.text = '10:10:10';
    _pompa.text = '2';
    _operator.text = 'Hasanudin';
    _plat.text = '-';
    scanPrinter();
  }

  init() async {
    setState(() {
      listSpbu = [];
      listJenis = [];
    });
    final pom = await TounaDB.get('spbu');
    final bensin = await TounaDB.get('jenis');
    setState(() {
      listSpbu = pom;
      listJenis = bensin;
      spbu = pom.first;
      jenis = bensin.first;
      _produk.text = (jenis.value as Map)['nama'];
      _harga.text = rupiah((jenis.value as Map)['harga']);
      _volume.text = '10';
      harga = int.parse(_harga.text.replaceAll(regNum, ''));
    });
    hitungTotal();
  }

  hitungTotal() {
    var vol = double.parse(_volume.text.replaceAll(',', '.'));
    setState(() => _total.text =
        _total.text = rupiah((double.parse('$harga') * vol).toInt()));
  }

  Future<void> scanPrinter() async {
    setState(() => listPrinter = []);
    final pair = await PrintBluetoothThermal.pairedBluetooths;
    if (mounted) setState(() => listPrinter = pair);
  }

  setPrint() async {
    if (printer == null) return;
    await PrintBluetoothThermal.connect(macPrinterAddress: printer!.macAdress);
  }

  showDevicesList() async {
    await scanPrinter();
    if (!mounted) return;
    Size size = MediaQuery.of(context).size;
    var bt = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              height: size.height * .7,
              width: size.width * .7,
              child: ListView.builder(
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
        });
    setState(() => printer = bt);
    if (bt == null) return;
    await setPrint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Text(printer?.name ?? ''),
          IconButton(
            onPressed: () => showDevicesList(),
            icon: const Icon(Icons.print_sharp),
          ),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const AddDataPrinter();
                    }).then((v) => init());
              },
              icon: const Icon(Icons.add_rounded)),
          Container(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              receipWidget(),
              Container(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: listSpbu.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          onTap: () {
                            var pom =
                                (listSpbu[i].value as Map<String, dynamic>);
                            setState(() {
                              _kodePom.text = pom['kode'].toString();
                              _alamat.text = '${pom['nama']}\n${pom['alamat']}';
                            });
                          },
                          title: Text((listSpbu[i].value
                              as Map<String, dynamic>)['title']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditSPBU(spbu: listSpbu[i]);
                                      });
                                  init();
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await TounaDB.delete(
                                      'spbu', listSpbu[i].key as int);
                                  init();
                                },
                                color: Colors.pink,
                                icon: const Icon(Icons.delete_forever),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: listJenis.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          onTap: () {
                            var bensin =
                                (listJenis[i].value as Map<String, dynamic>);
                            setState(() {
                              _harga.text = rupiah(bensin['harga']);
                              harga = bensin['harga'];
                              _produk.text = bensin['nama'];
                            });
                            hitungTotal();
                          },
                          title: Text((listJenis[i].value
                              as Map<String, dynamic>)['nama']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditJenis(jenis: listJenis[i]);
                                      });
                                  init();
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await TounaDB.delete(
                                      'jenis', listJenis[i].key as int);
                                  init();
                                },
                                color: Colors.pink,
                                icon: const Icon(Icons.delete_forever),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget receipWidget() {
    return Form(
      key: _form,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            margin: const EdgeInsets.only(left: 32),
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo2.png',
                    height: 76,
                    width: 200,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: _kodePom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextFormField(
                    controller: _alamat,
                    minLines: 3,
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text(
                        "Shift : ",
                        textAlign: TextAlign.start,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _shift,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      const Text(
                        "     No Trans : ",
                        textAlign: TextAlign.start,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _trans,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text('Waktu : '),
                      Expanded(
                        child: TextFormField(
                          controller: _tgl,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      const Text('           '),
                      Expanded(
                        child: TextFormField(
                          controller: _jam,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('-----------------------------------------------'),
                Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Pulau / Pompa'),
                        ),
                        const Text(': '),
                        Expanded(
                          child: TextFormField(
                            controller: _pompa,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Nama Produk'),
                        ),
                        const Text(': '),
                        Expanded(
                          child: TextFormField(
                            controller: _produk,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Harga / Liter'),
                        ),
                        const Text(': '),
                        Expanded(
                          child: TextFormField(
                            controller: _harga,
                            onEditingComplete: () {
                              var a = _harga.text.replaceAll(regNum, '');
                              setState(() => harga = int.parse(a));
                              hitungTotal();
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Volume'),
                        ),
                        const Text(': '),
                        Expanded(
                          child: TextFormField(
                            controller: _volume,
                            onChanged: (value) {
                              hitungTotal();
                            },
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                return TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                );
                              }),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Total Harga'),
                        ),
                        const Text(': '),
                        Expanded(
                          child: TextFormField(
                            controller: _total,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Operator'),
                        ),
                        const Text(': '),
                        Expanded(
                          child: TextFormField(
                            controller: _operator,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Align(
                    alignment: Alignment.centerLeft, child: Text('CASH')),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextFormField(
                    controller: _total,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Text('-----------------------------------------------'),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Text('Plat No.                 : ',
                            textAlign: TextAlign.left),
                        Expanded(
                          child: TextFormField(
                            controller: _plat,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    )),
                const Text('-----------------------------------------------'),
                const Text(
                  'SUBSIDI BULAN JANUARI 2024 : BIOSOLAR RP. 5.200 / LITER DAN PERTALITE RP. 1.350/LITER\nMARI GUNAKAN PERTAMAX SERIES DAN DEX SERIES SUBSIDI HANYA UNTUK YANG BERHAK MENERIMA\nSELAMAT JALAN DAN TERIMAKASIH',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                Container(height: 8),
              ],
            ),
          ),
          Positioned(
            right: 8,
            child: IconButton(
              onPressed: () => printReceipt(),
              icon: const Icon(Icons.print),
              color: Colors.pink,
              iconSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  String rupiah(int number) {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    return 'Rp. ${currencyFormatter.format(number)}';
  }

  printReceipt() async {
    _form.currentState?.save();
    var pompa = 'Pulau/Pompa    : ${_pompa.text}';
    var produk = 'Nama Produk    : ${_produk.text}';
    var harga = 'Harga / Liter  : ${_harga.text}';
    var volume = 'Volume         : ${_volume.text}';
    var total = 'Total Harga    : ${_total.text}';
    var operator = 'Operator       : ${_operator.text}';
    var cont = '$pompa\n$produk\n$harga\n$volume\n$total\n$operator';

    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Image
    final ByteData data = await rootBundle.load('assets/logo2.png');
    if (data.lengthInBytes > 0) {
      final Uint8List imageBytes = data.buffer.asUint8List();
      final decodedImage = img.decodeImage(imageBytes)!;
      img.Image thumbnail = img.copyResize(decodedImage, height: 100);

      bytes += generator.imageRaster(thumbnail, align: PosAlign.center);
      bytes += generator.feed(1);
    }
    bytes += generator.text(
      _kodePom.text,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      _alamat.text,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Shift : ${_shift.text}     No Trans : ${_trans.text}',
    );
    bytes += generator.text('Waktu : ${_tgl.text}     ${_jam.text}');
    bytes += generator.hr();
    bytes += generator.text(cont);
    bytes += generator.text('CASH');
    bytes += generator.text(
      _total.text,
      styles: const PosStyles(align: PosAlign.right),
    );
    bytes += generator.hr();
    bytes += generator.text('Plat No. 	   : ${_plat.text}');
    bytes += generator.hr();
    bytes += generator.text(
      'SUBSIDI BULAN JANUARI 2024 : BIOSOLAR RP. 5.200 / LITER DAN PERTALITE RP. 1.350/LITER\nMARI GUNAKAN PERTAMAX SERIES DAN DEX SERIES SUBSIDI HANYA UNTUK YANG BERHAK MENERIMA\nSELAMAT JALAN DAN TERIMAKASIH',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.emptyLines(2);
    await PrintBluetoothThermalWindows.writeBytes(bytes: bytes);
  }

  /// Draw the image [src] onto the image [dst].
  ///
  /// In other words, drawImage will take an rectangular area from src of
  /// width [src_w] and height [src_h] at position ([src_x],[src_y]) and place it
  /// in a rectangular area of [dst] of width [dst_w] and height [dst_h] at
  /// position ([dst_x],[dst_y]).
  ///
  /// If the source and destination coordinates and width and heights differ,
  /// appropriate stretching or shrinking of the image fragment will be performed.
  /// The coordinates refer to the upper left corner. This function can be used to
  /// copy regions within the same image (if [dst] is the same as [src])
  /// but if the regions overlap the results will be unpredictable.
  img.Image drawImage(img.Image dst, img.Image src,
      {int? dstX,
      int? dstY,
      int? dstW,
      int? dstH,
      int? srcX,
      int? srcY,
      int? srcW,
      int? srcH,
      bool blend = true}) {
    dstX ??= 0;
    dstY ??= 0;
    srcX ??= 0;
    srcY ??= 0;
    srcW ??= src.width;
    srcH ??= src.height;
    dstW ??= (dst.width < src.width) ? dstW = dst.width : src.width;
    dstH ??= (dst.height < src.height) ? dst.height : src.height;

    if (blend) {
      for (var y = 0; y < dstH; ++y) {
        for (var x = 0; x < dstW; ++x) {
          final stepX = (x * (srcW / dstW)).toInt();
          final stepY = (y * (srcH / dstH)).toInt();
          final srcPixel = src.getPixel(srcX + stepX, srcY + stepY);
          img.drawPixel(dst, dstX + x, dstY + y, srcPixel);
        }
      }
    } else {
      for (var y = 0; y < dstH; ++y) {
        for (var x = 0; x < dstW; ++x) {
          final stepX = (x * (srcW / dstW)).toInt();
          final stepY = (y * (srcH / dstH)).toInt();
          final srcPixel = src.getPixel(srcX + stepX, srcY + stepY);
          dst.setPixel(dstX + x, dstY + y, srcPixel);
        }
      }
    }
    return dst;
  }
}

class AddDataPrinter extends StatefulWidget {
  const AddDataPrinter({super.key});

  @override
  AddDataPrinterState createState() => AddDataPrinterState();
}

class AddDataPrinterState extends State<AddDataPrinter> {
  final _title = TextEditingController();
  final _type = TextEditingController();
  final _kode = TextEditingController();
  final _nama = TextEditingController();
  final _alamat = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _type,
            onChanged: (value) {
              setState(() {});
            },
            decoration: const InputDecoration(
                labelText: 'Jenis', border: OutlineInputBorder()),
          ),
          if (_type.text.toLowerCase() == 'spbu') Container(height: 8),
          if (_type.text.toLowerCase() == 'spbu')
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
          Container(height: 8),
          TextFormField(
            controller: _kode,
            decoration: InputDecoration(
                labelText:
                    _type.text.toLowerCase() == 'bensin' ? 'Harga' : 'Kode',
                border: const OutlineInputBorder()),
          ),
          Container(height: 8),
          TextFormField(
            controller: _nama,
            decoration: const InputDecoration(
                labelText: 'Nama', border: OutlineInputBorder()),
          ),
          Container(height: 8),
          if (_type.text.toLowerCase() == 'spbu')
            TextFormField(
              controller: _alamat,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Alamat', border: OutlineInputBorder()),
            ),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Jenis : spbu / bensin',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => save(), child: const Text('Save')),
      ],
    );
  }

  save() async {
    if (_type.text.toLowerCase() == 'spbu') {
      await TounaDB.add(_type.text, {
        'title': _title.text,
        'kode': _kode.text,
        'nama': _nama.text,
        'alamat': _alamat.text,
      });
      if (mounted) Navigator.pop(context);
    }
    if (_type.text.toLowerCase() == 'bensin') {
      await TounaDB.add('jenis', {
        'nama': _nama.text,
        'harga': int.parse(_kode.text),
      });
      if (mounted) Navigator.pop(context);
    }
  }
}

class EditJenis extends StatefulWidget {
  const EditJenis({super.key, required this.jenis});
  final RecordSnapshot jenis;

  @override
  EditJenisState createState() => EditJenisState();
}

class EditJenisState extends State<EditJenis> {
  final _harga = TextEditingController();
  @override
  void initState() {
    super.initState();
    _harga.text =
        (widget.jenis.value as Map<String, dynamic>)['harga'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextFormField(controller: _harga),
      actions: [
        TextButton(
          onPressed: () async {
            await TounaDB.editJenis(
                int.parse(_harga.text), widget.jenis.key as int);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class EditSPBU extends StatefulWidget {
  const EditSPBU({super.key, required this.spbu});
  final RecordSnapshot spbu;

  @override
  EditSPBUState createState() => EditSPBUState();
}

class EditSPBUState extends State<EditSPBU> {
  final _title = TextEditingController();
  final _kode = TextEditingController();
  final _nama = TextEditingController();
  final _alamat = TextEditingController();
  @override
  void initState() {
    super.initState();
    _title.text =
        (widget.spbu.value as Map<String, dynamic>)['title'].toString();
    _kode.text = (widget.spbu.value as Map<String, dynamic>)['kode'].toString();
    _nama.text = (widget.spbu.value as Map<String, dynamic>)['nama'].toString();
    _alamat.text =
        (widget.spbu.value as Map<String, dynamic>)['alamat'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(controller: _title),
          TextFormField(controller: _kode),
          TextFormField(controller: _nama),
          TextFormField(
            controller: _alamat,
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            var data = {
              'title': _title.text,
              'kode': _kode.text,
              'nama': _nama.text,
              'alamat': _alamat.text,
            };
            await TounaDB.editSPBU(data, widget.spbu.key as int);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
