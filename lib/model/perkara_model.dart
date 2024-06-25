import 'package:touna/model/sidang_model.dart';

class PerkaraModel {
  int? id;
  String noPerkara;
  String terdakwa;
  String pasal;
  String jpu;
  String majelis;
  String panitera;
  bool? putusan;
  List<SidangModel>? sidang;
  PerkaraModel({
    this.id,
    required this.noPerkara,
    required this.terdakwa,
    required this.pasal,
    required this.jpu,
    required this.majelis,
    required this.panitera,
    this.putusan,
    this.sidang,
  });
  factory PerkaraModel.fromJson(Map<String, dynamic> json) {
    // print(json['sidang']);
    List<SidangModel> sdg = [];
    if (json['sidang'] != null) {
      for (var item in json['sidang']) {
        // sdg.add(item);
        sdg.add(SidangModel.fromJson(item));
      }
    }
    return PerkaraModel(
      id: json['id'],
      noPerkara: json['no_perkara'],
      terdakwa: json['terdakwa'],
      pasal: json['pasal'],
      jpu: json['jpu'],
      majelis: json['majelis'],
      panitera: json['panitera'],
      putusan: int.parse(json['putusan']) == 0 ? false : true,
      sidang: sdg,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no_perkara': noPerkara,
      'terdakwa': terdakwa,
      'pasal': pasal,
      'jpu': jpu,
      'majelis': majelis,
      'panitera': panitera,
      'putusan': putusan,
      'sidang': sidang,
    };
  }
}
