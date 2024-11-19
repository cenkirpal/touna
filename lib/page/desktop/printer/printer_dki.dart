import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:touna/page/desktop/printer/database.dart';
import 'package:touna/page/desktop/printer/nota_model.dart';
import 'package:image/image.dart' as img;

class PrinterDKI extends StatefulWidget {
  const PrinterDKI({super.key, this.onPrint});
  final Function(List<int>)? onPrint;
  @override
  PrinterDKIState createState() => PrinterDKIState();
}

class PrinterDKIState extends State<PrinterDKI> {
  final _form = GlobalKey<FormState>();
  final _kode = TextEditingController();
  final _alamat = TextEditingController();
  //
  final _shift = TextEditingController();
  final _trans = TextEditingController();
  final _waktu = TextEditingController();
  //
  final _pompa = TextEditingController();
  final _produk = TextEditingController();
  final _harga = TextEditingController();
  final _volume = TextEditingController();
  final _total = TextEditingController();
  final _operator = TextEditingController();
  //
  final _cash = TextEditingController();
  final _plat = TextEditingController();
  final _ket = TextEditingController();

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    var data = await PrinterDB.getNota('nota2');
    var nota = data ?? nota2;

    setState(() {
      _kode.text = nota.kode;
      _alamat.text = nota.alamat;
      _shift.text = nota.shift;
      _trans.text = nota.trans;
      _waktu.text = nota.waktu;
      _pompa.text = nota.pompa;
      _produk.text = nota.produk;
      _harga.text = nota.harga;
      _volume.text = nota.volume;
      _total.text = nota.total;
      _operator.text = nota.operator;
      _cash.text = nota.cash;
      _plat.text = nota.plat;
      _ket.text = nota.ket;
    });
  }

  printReceipt() async {
    _form.currentState?.save();
    var nota = NotaModel(
      kode: _kode.text,
      alamat: _alamat.text,
      shift: _shift.text,
      trans: _trans.text,
      waktu: _waktu.text,
      jam: '',
      pompa: _pompa.text,
      produk: _produk.text,
      harga: _harga.text,
      volume: _volume.text,
      total: _total.text,
      operator: _operator.text,
      cash: _cash.text,
      plat: _plat.text,
      ket: _ket.text,
    );
    var pompa = 'Pulau/Pompa: ${_pompa.text}';
    var produk = 'Nama Produk: ${_produk.text}';
    var harga = 'Harga / Liter  : ${_harga.text}';
    var volume = 'Volume    : ${_volume.text}';
    var total = 'Total Harga: ${_total.text}';
    var operator = 'Operator  : ${_operator.text}';

    var cont = '$pompa\n$produk\n$harga\n$volume\n$total\n$operator';

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    final ByteData data = await rootBundle.load('assets/logo2.png');

    if (data.lengthInBytes > 0) {
      final Uint8List imageBytes = data.buffer.asUint8List();
      final decodedImage = img.decodeImage(imageBytes)!;
      img.Image thumbnail = img.copyResize(decodedImage, height: 65);

      bytes += generator.image(thumbnail, align: PosAlign.center);
      bytes += generator.feed(1);
    }
    bytes += generator.text(
      _kode.text,
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      _alamat.text,
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      'Shift : ${_shift.text}  No Trans : ${_trans.text}',
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      'Waktu : ${_waktu.text}',
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      '${List.generate(22, (t) => '-').join()}    ',
      styles:
          const PosStyles(fontType: PosFontType.fontB, align: PosAlign.right),
    );
    bytes += generator.text(
      cont,
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      '${List.generate(22, (t) => '-').join()}    ',
      styles:
          const PosStyles(fontType: PosFontType.fontB, align: PosAlign.right),
    );
    bytes += generator.text(
      'CASH',
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      _total.text,
      styles:
          const PosStyles(align: PosAlign.right, fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      'CHANGE',
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      _plat.text,
      styles:
          const PosStyles(align: PosAlign.right, fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      '${List.generate(22, (t) => '-').join()}    ',
      styles:
          const PosStyles(fontType: PosFontType.fontB, align: PosAlign.right),
    );
    bytes += generator.text(
      _ket.text,
      styles: const PosStyles(
        align: PosAlign.center,
        fontType: PosFontType.fontB,
      ),
    );

    bytes += generator.emptyLines(2);
    //
    await PrinterDB.addNota('nota2', nota.toMap());

    widget.onPrint?.call(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          receipWidget(),
          Positioned(
            right: 16,
            child: IconButton(
              onPressed: () => printReceipt(),
              color: Colors.pink,
              icon: const Icon(Icons.print),
            ),
          ),
        ],
      ),
    );
  }

  Widget receipWidget() {
    return Form(
      key: _form,
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(8),
        width: 350,
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
            SizedBox(
              child: TextFormField(
                controller: _kode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            TextFormField(
              controller: _alamat,
              minLines: 2,
              maxLines: 5,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
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
                    "  No Trans : ",
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
                      controller: _waktu,
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
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
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
            const Text('-----------------------------------------------'),
            const Align(alignment: Alignment.centerLeft, child: Text('CASH')),
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
            const Align(alignment: Alignment.centerLeft, child: Text('CHANGE')),
            Align(
              alignment: Alignment.centerRight,
              child: TextFormField(
                controller: _plat,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const Text('-----------------------------------------------'),
            TextFormField(
              controller: _ket,
              maxLines: 8,
              textAlign: TextAlign.center,
            ),
            Container(height: 8),
          ],
        ),
      ),
    );
  }
}

NotaModel nota2 = NotaModel(
  kode: '3412902',
  alamat: 'SPBU Kuningan\nJl. Gatot Subroto, Kuningan',
  shift: '1',
  trans: '1435893',
  waktu: '07/11/2024 07:11:28',
  jam: '',
  pompa: '4',
  produk: 'PERTAMAX',
  harga: 'Rp. 12,100',
  volume: '10',
  total: '300,000',
  operator: 'DENI MALIK',
  cash: '300,000',
  plat: '-',
  ket:
      'Anda menggunakan subsidi BBM dari negara: Bio Solar Rp. 3.584/liter dan Pertalite Rp. 353/liter untuk tidak disalahgunakan. Mari Gunakan Pertamax Series dan Dex Series subsidi hanya untuk yang berhak menerimanya.',
);
