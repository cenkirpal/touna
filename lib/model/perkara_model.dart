import 'package:touna/model/sidang_model.dart';

class PerkaraModel {
  String noPerkara;
  String terdakwa;
  String pasal;
  String jpu;
  String majelis;
  String panitera;
  bool? inkrah;
  List<SidangModel>? sidang;
  PerkaraModel({
    required this.noPerkara,
    required this.terdakwa,
    required this.pasal,
    required this.jpu,
    required this.majelis,
    required this.panitera,
    this.inkrah,
    this.sidang,
  });
  factory PerkaraModel.fromJson(Map<String, dynamic> json) {
    List<SidangModel> sdg = [];
    if (json['sidang'] != null) {
      for (var item in json['sidang']) {
        // sdg.add(item);
        sdg.add(SidangModel.fromJson(item));
      }
    }
    return PerkaraModel(
      noPerkara: json['noPerkara'],
      terdakwa: json['terdakwa'],
      pasal: json['pasal'],
      jpu: json['jpu'],
      majelis: json['majelis'],
      panitera: json['panitera'],
      inkrah: json['inkrah'],
      sidang: sdg,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'noPerkara': noPerkara,
      'terdakwa': terdakwa,
      'pasal': pasal,
      'jpu': jpu,
      'majelis': majelis,
      'panitera': panitera,
      'inkrah': inkrah,
      'sidang': sidang,
    };
  }
}
