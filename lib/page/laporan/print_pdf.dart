import 'package:flutter/material.dart';
import 'package:touna/model/p38_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';

class PrintPDF {
  printPdf(BuildContext context, List<SidangModel> lists, int nama,
      P38Model dataSurat) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: LayoutBuilder(
        builder: (context, box) {
          return Container(
            color: Colors.white,
            width: 920,
            padding: const EdgeInsets.fromLTRB(50, 24, 50, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      height: 100,
                      child: Image.asset('assets/logo_kejaksaan.png'),
                    ),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'KEJAKSAAN REPUBLIK INDONESIA',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'KEJAKSAAN TINGGI SULAWESI TENGAH',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'KEJAKSAAN NEGERI TOJO UNA-UNA',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'JL.Merdeka Komp.Perkantoran Bumi Mas Uemalingku Kec.Ratolindo Kab.Tojo Una Una 94683',
                            style: TextStyle(
                                fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                          const Text(
                            'Tlp. (0464) 2251515 Fax (0464) 2251515',
                            style: TextStyle(
                                fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                          Container(height: 8),
                          Container(
                            width: size.width - 100,
                            height: 4,
                            color: Colors.black,
                          ),
                          Container(height: 2),
                          Container(
                            width: size.width - 100,
                            height: 2,
                            color: Colors.black,
                          ),
                        ],
                      ), // Header
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'P-38',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 100, child: Text('Nomor')),
                        Text(': ${dataSurat.nomor}'),
                      ],
                    ),
                    Text(
                        'Ampana, ${DateTime.parse(dataSurat.tanggal).fullday}'),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(width: 100, child: Text('Lampiran')),
                    Text(': -')
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(width: 100, child: Text('Hal')),
                    Text(': Bantuan Pemanggilan Terdakwa'),
                  ],
                ),
                Container(height: 12),
                const Text('Yth. '),
                const Text(
                  'Kepala Lembaga Pemasyaakatan\nKlas II B Ampana \nDI –',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text.rich(TextSpan(children: [
                  WidgetSpan(child: SizedBox(width: 40)),
                  TextSpan(
                      text: 'A m p a n a',
                      style: TextStyle(fontWeight: FontWeight.bold))
                ])),
                Container(height: 12),
                Text.rich(
                  textAlign: TextAlign.justify,
                  TextSpan(
                    children: [
                      const WidgetSpan(child: SizedBox(width: 40)),
                      const TextSpan(text: 'Guna melaksanakan persidangan '),
                      const TextSpan(
                        text:
                            'Tatap Muka (Offline) Di Kantor Pengadilan Negeri Klas IB Poso ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                          text: 'yang menetapkan hari sidang, pada hari '),
                      TextSpan(
                        text:
                            '${DateTime.parse(dataSurat.tanggal).dayname}, tanggal ${DateTime.parse(dataSurat.tanggal).fullday},',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                          text:
                              ' sehubungan dengan perkara atas nama terdakwa sebagaimana yang terdapat pada kolom di bawah, dengan ini diminta bantuan Saudara, agar kepada orang yang namanya tersebut dibawah ini diperintahkan untuk menghadiri persidangan tersebut.'),
                    ],
                  ),
                ),
                Container(height: 12),
                if (lists.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                decoration: tableBorder,
                                height: 25,
                                width: 40,
                                child: const Text(
                                  'No',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                width: 400,
                                height: 25,
                                alignment: Alignment.center,
                                decoration: rbtBorder,
                                child: const Text(
                                  'Terdakwa',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          ...lists.asMap().map((i, v) {
                            var p = v.perkara!.terdakwa.split(';').length;
                            return MapEntry(
                              i,
                              Row(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: rlbBorder,
                                    height: p * 25,
                                    width: 40,
                                    child: Text('${i + 1}'),
                                  ),
                                  Container(
                                    width: 400,
                                    padding: const EdgeInsets.only(left: 8),
                                    height: p * 25,
                                    decoration: rbBorder,
                                    child: Text(
                                      v.perkara!.terdakwa.replaceAll(';', '\n'),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).values
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 25,
                            width: 150,
                            decoration: rbtBorder,
                            alignment: Alignment.center,
                            child: const Text(
                              'Alamat',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: nama * 25,
                            width: 150,
                            decoration: rbBorder,
                            alignment: Alignment.center,
                            child: const Text('Lapas Ampana'),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 25,
                            width: 150,
                            decoration: rbtBorder,
                            alignment: Alignment.center,
                            child: const Text(
                              'Keterangan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: nama * 25,
                            width: 150,
                            decoration: rbBorder,
                            alignment: Alignment.center,
                            child: const Text(
                              'Dipanggil Sebagai Terdakwa',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                Container(height: 12),
                const Text('Atas bantuannya diucapkan terima kasih. '),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: size.width / 2,
                    child: Column(
                      children: [
                        Text(
                          'A.n Kepala Kejaksaan Negeri Tojo Una Una\n${dataSurat.kasi}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image.asset(
                          'assets/esign.png',
                          width: 200,
                          height: 75,
                        ),
                        Text(
                          '${dataSurat.nama}\n${dataSurat.jabatan}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Tembusan :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                    '1.	Yth. Kepala Kejaksaan Negeri Tojo Una Una (sebagai laporan).'),
                const Text('2.	Yth. Ketua Pengadilan Negeri Poso Kelas IB.'),
                const Text('3.	A r s i p.  '),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration tableBorder = BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 14, 7, 7)));

  BoxDecoration rlbBorder = const BoxDecoration(
      border: Border(
          left: BorderSide(color: Colors.black),
          right: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black)));
  BoxDecoration rbtBorder = const BoxDecoration(
      border: Border(
          right: BorderSide(color: Colors.black),
          top: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black)));
  BoxDecoration rbBorder = const BoxDecoration(
      border: Border(
          right: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black)));
  BoxDecoration ltBorder = const BoxDecoration(
      border: Border(
          left: BorderSide(color: Colors.black),
          top: BorderSide(color: Colors.black)));

  titleText(String data) {
    return Text(data, textAlign: TextAlign.center, style: const TextStyle());
  }
}
