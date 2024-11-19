class NotaModel {
  String kode;
  String alamat;
  String shift;
  String trans;
  String waktu;
  String jam;
  String pompa;
  String produk;
  String harga;
  String volume;
  String total;
  String operator;
  String cash;
  String plat;
  String ket;
  NotaModel({
    required this.kode,
    required this.alamat,
    required this.shift,
    required this.trans,
    required this.waktu,
    required this.jam,
    required this.pompa,
    required this.produk,
    required this.harga,
    required this.volume,
    required this.total,
    required this.operator,
    required this.cash,
    required this.plat,
    required this.ket,
  });
  factory NotaModel.fromJson(Map<String, dynamic> data) {
    return NotaModel(
      kode: data['kode'],
      alamat: data['alamat'],
      shift: data['shift'],
      trans: data['trans'],
      waktu: data['waktu'],
      jam: data['jam'],
      pompa: data['pompa'],
      produk: data['produk'],
      harga: data['harga'],
      volume: data['volume'],
      total: data['total'],
      operator: data['operator'],
      cash: data['cash'],
      plat: data['plat'],
      ket: data['ket'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'kode': kode,
      'alamat': alamat,
      'shift': shift,
      'trans': trans,
      'waktu': waktu,
      'jam': jam,
      'pompa': pompa,
      'produk': produk,
      'harga': harga,
      'volume': volume,
      'total': total,
      'operator': operator,
      'cash': cash,
      'plat': plat,
      'ket': ket,
    };
  }
}
