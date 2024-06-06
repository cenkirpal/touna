class SidangModel {
  String date;
  String agenda;
  SidangModel({required this.date, required this.agenda});
  factory SidangModel.fromJson(Map<String, dynamic> json) {
    return SidangModel(date: json['date'], agenda: json['agenda']);
  }
  Map<String, dynamic> toMap() {
    return {'date': date, 'agenda': agenda};
  }
}
