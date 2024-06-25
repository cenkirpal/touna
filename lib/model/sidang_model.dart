import 'package:touna/model/perkara_model.dart';

class SidangModel {
  int? id;
  String date;
  String agenda;
  String? ket;
  PerkaraModel? perkara;
  SidangModel({
    this.id,
    required this.date,
    required this.agenda,
    this.ket,
    this.perkara,
  });
  factory SidangModel.fromJson(Map<String, dynamic> json) {
    return SidangModel(
      id: json['id'],
      date: json['date'],
      agenda: json['agenda'],
      ket: json['ket'],
      perkara: json['perkara'] == null
          ? null
          : PerkaraModel.fromJson(json['perkara']),
    );
  }
  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'agenda': agenda, 'ket': ket};
  }
}
