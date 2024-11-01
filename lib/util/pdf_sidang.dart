import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:printing/printing.dart';
import 'package:touna/util/date.dart';
import 'package:url_launcher/url_launcher.dart';

class SidangPdf {
  generate(BuildContext context, List<SidangModel> lists, int nama) async {
    final pdf = pw.Document();
    Size size = MediaQuery.of(context).size;
    double row = 18;

    final font = await PdfGoogleFonts.poppinsLight();
    final fontB = await PdfGoogleFonts.poppinsBold();
    final fontI = await PdfGoogleFonts.poppinsItalic();

    final logo = await rootBundle.load('assets/logo_kejaksaan.png');
    final esign = await rootBundle.load('assets/esign.png');

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 0,
            marginTop: 30,
            marginLeft: 20,
            marginRight: 20,
          ),
          theme: pw.ThemeData.withFont(base: font, bold: fontB, italic: fontI),
        ),
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Stack(
                  children: [
                    pw.Container(
                      // margin: const pw.EdgeInsets.only(left: 16),
                      width: 80,
                      height: 80,
                      child: pw.Image(pw.MemoryImage(logo.buffer.asUint8List()),
                          height: 100),
                    ),
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text('KEJAKSAAN REPUBLIK INDONESIA',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('KEJAKSAAN TINGGI SULAWESI TENGAH',
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('KEJAKSAAN NEGERI TOJO UNA-UNA',
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              'JL.Merdeka Komp.Perkantoran Bumi Mas Uemalingku Kec.Ratolindo Kab.Tojo Una Una 94683',
                              style: pw.TextStyle(
                                  fontSize: 8, fontStyle: pw.FontStyle.italic)),
                          pw.Text('Tlp. (0464) 2251515 Fax (0464) 2251515',
                              style: pw.TextStyle(
                                  fontSize: 8, fontStyle: pw.FontStyle.italic)),
                          pw.Container(height: 8),
                          pw.Container(
                            width: size.width - 200,
                            height: 4,
                            color: PdfColor.fromHex('#010'),
                          ),
                          pw.Container(height: 2),
                          pw.Container(
                            width: size.width - 200,
                            height: 2,
                            color: PdfColor.fromHex('#010'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text(
                    'P-38',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.SizedBox(width: 100, child: pw.Text('Nomor')),
                        pw.Text(': B- 1587/P.2.18/Es.2/10/2024')
                      ],
                    ),
                    pw.Text('Ampana, 31 Oktober 2024'),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.SizedBox(width: 100, child: pw.Text('Lampiran')),
                    pw.Text(': -')
                  ],
                ),
                pw.Row(
                  children: [
                    pw.SizedBox(width: 100, child: pw.Text('Hal')),
                    pw.Text(': Bantuan Pemanggilan Terdakwa'),
                  ],
                ),
                pw.Container(height: 12),
                pw.Text('Yth. '),
                pw.Text(
                  'Kepala Lembaga Pemasyaakatan\nKlas II B Ampana \nDI –',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Container(height: 12),
                pw.RichText(
                  textAlign: pw.TextAlign.justify,
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(text: 'Guna melaksanakan persidangan '),
                      pw.TextSpan(
                        text:
                            'Tatap Muka (Offline) Di Kantor Pengadilan Negeri Klas IB Poso ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      const pw.TextSpan(
                          text: 'yang menetapkan hari sidang, pada hari '),
                      pw.TextSpan(
                        text: 'Rabu, tanggal 31 Oktober 2024,',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      const pw.TextSpan(
                          text:
                              ' sehubungan dengan perkara atas nama terdakwa sebagaimana yang terdapat pada kolom di bawah, dengan ini diminta bantuan Saudara, agar kepada orang yang namanya tersebut dibawah ini diperintahkan untuk menghadiri persidangan tersebut.'),
                    ],
                  ),
                ),
                if (lists.isNotEmpty)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                alignment: pw.Alignment.center,
                                height: row,
                                width: 40,
                                decoration: tableBorder,
                                child: pw.Text('No'),
                              ),
                              pw.Container(
                                width: 300,
                                height: row,
                                decoration: rbtBorder,
                                alignment: pw.Alignment.center,
                                child: pw.Text('Terdakwa'),
                              ),
                            ],
                          ),
                          ...lists.asMap().map((i, v) {
                            var p = v.perkara!.terdakwa.split(';').length;
                            return MapEntry(
                              i,
                              pw.Row(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    height: p * row,
                                    width: 40,
                                    decoration: rlbBorder,
                                    child: pw.Text('${i + 1}',
                                        textAlign: pw.TextAlign.center),
                                  ),
                                  pw.Container(
                                    width: 300,
                                    height: p * row,
                                    decoration: rbBorder,
                                    padding: const pw.EdgeInsets.only(left: 4),
                                    child: pw.Text(
                                      v.perkara!.terdakwa.replaceAll(';', '\n'),
                                      overflow: pw.TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).values
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Container(
                            height: row,
                            width: 100,
                            decoration: rbtBorder,
                            alignment: pw.Alignment.center,
                            child: pw.Text('Alamat'),
                          ),
                          pw.Container(
                            height: nama * row,
                            width: 100,
                            decoration: rbBorder,
                            alignment: pw.Alignment.center,
                            child: pw.Text('Lapas Ampana'),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Container(
                            height: row,
                            width: 100,
                            decoration: rbtBorder,
                            alignment: pw.Alignment.center,
                            child: pw.Text('Keterangan'),
                          ),
                          pw.Container(
                            height: nama * row,
                            width: 100,
                            alignment: pw.Alignment.center,
                            decoration: rbBorder,
                            child: pw.Text('Dipanggil Sebagai Terdakwa',
                                textAlign: pw.TextAlign.center),
                          ),
                        ],
                      ),
                    ],
                  ),
                pw.Text('Atas bantuannya diucapkan terima kasih. '),
                pw.Container(height: 8),
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColor.fromHex('#010'))),
                    width: 400,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'A.n Kepala Kejaksaan Negeri Tojo Una Una\nPlt. Kepala Seksi Tindak Pidana Umum',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Container(
                          // margin: const pw.EdgeInsets.only(left: 16),
                          width: 120,
                          height: 100,
                          child: pw.Image(
                            pw.MemoryImage(esign.buffer.asUint8List()),
                          ),
                        ),
                        pw.Text(
                          'JUSRIN HUSEN, S.H.,M.H.\nJaksa Muda / Nip. 19841106 200912 1 001',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Text(
                  'Tembusan :',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                    '1.	Yth. Kepala Kejaksaan Negeri Tojo Una Una (sebagai laporan).'),
                pw.Text('2.	Yth. Ketua Pengadilan Negeri Poso Kelas IB.'),
                pw.Text('3.	A r s i p.  '),
              ],
            ),
          );
        },
      ),
    );

    var doc = await getApplicationDocumentsDirectory();
    var dir = Directory(join(doc.path, 'sidang'));
    dir.create(recursive: true);
    var file = File(join(dir.path, 'P38.pdf'));
    file.writeAsBytes(await pdf.save());
  }

  fromPDF(Uint8List bytes, DateTime date) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 0,
            marginTop: 20,
            marginLeft: 20,
            marginRight: 20,
          ),
        ),
        build: (context) {
          return pw.Image(
            pw.MemoryImage(bytes),
            alignment: pw.Alignment.topCenter,
          );
        },
      ),
    );

    var doc = await getApplicationDocumentsDirectory();
    var dir = Directory(join(doc.path, 'sidang'));
    dir.create(recursive: true);

    var file =
        await File(join(dir.path, 'P38 - ${date.formatDB}.pdf')).create();
    file.writeAsBytesSync(await pdf.save());

    // final uri = Uri.file(des.path);
    final uri = Uri.file(dir.path);

    await launchUrl(uri);
  }

  pw.BoxDecoration tableBorder =
      pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('#010')));

  pw.BoxDecoration rlbBorder = pw.BoxDecoration(
      border: pw.Border(
          right: pw.BorderSide(color: PdfColor.fromHex('#010')),
          left: pw.BorderSide(color: PdfColor.fromHex('#010')),
          bottom: pw.BorderSide(color: PdfColor.fromHex('#010'))));

  pw.BoxDecoration rbtBorder = pw.BoxDecoration(
      border: pw.Border(
          right: pw.BorderSide(color: PdfColor.fromHex('#010')),
          bottom: pw.BorderSide(color: PdfColor.fromHex('#010')),
          top: pw.BorderSide(color: PdfColor.fromHex('#010'))));
  pw.BoxDecoration rbBorder = pw.BoxDecoration(
      border: pw.Border(
          right: pw.BorderSide(color: PdfColor.fromHex('#010')),
          bottom: pw.BorderSide(color: PdfColor.fromHex('#010'))));
  pw.BoxDecoration ltBorder = pw.BoxDecoration(
      border: pw.Border(
          left: pw.BorderSide(color: PdfColor.fromHex('#010')),
          top: pw.BorderSide(color: PdfColor.fromHex('#010'))));

  titleText(String data) {
    return Text(data, textAlign: TextAlign.center, style: const TextStyle());
  }
}
