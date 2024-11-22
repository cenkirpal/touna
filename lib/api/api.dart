import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:touna/api/response.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';

class ApiTouna {
  static Future<ResponseApi> getPerkara({String? keyword}) async {
    List<PerkaraModel> list = [];
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/get-perkara',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'keyword': keyword},
    );

    try {
      final response = await request;
      List<dynamic> data = response.data;
      for (var item in data) {
        list.add(PerkaraModel.fromJson(item));
      }
      return ResponseApi<PerkaraModel>(error: false, result: list);
    } on DioException catch (e) {
      error(e.response?.data.toString());
      return ResponseApi(error: false, msg: e.message ?? 'Unknown Error');
    }
  }

  static Future<PerkaraModel> findPerkara(String no) async {
    final request = Dio().post('https://cenkirpal.com/api/touna/find-perkara',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        data: {'no': no});

    try {
      final response = await request;
      return PerkaraModel.fromJson(response.data);
    } on DioException catch (e) {
      error(e.response?.data);
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future addPerkara(Map<String, dynamic> pkr) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/add-perkara',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'perkara': pkr},
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future editPerkara(int id, PerkaraModel pkr) async {
    var update = pkr.toMap();
    update.removeWhere((k, v) => k == 'sidang');

    final request = Dio().post(
      'https://cenkirpal.com/api/touna/edit-perkara',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'id': id, 'perkara': update},
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future addFiles(int id, String putusan) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/add-files',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: FormData.fromMap({
        'id': id,
        'putusan': await MultipartFile.fromFile(putusan),
        // 'saksi': 'path to saksi file 3',
      }),
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future putus(int id, String? putusan) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/putus',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'id': id, 'putusan': putusan},
    );
    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
    }
  }

  static Future deletePerkara(int id) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/delete-perkara',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'id': id},
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future<List<SidangModel>> getSidang(int id) async {
    List<SidangModel> list = [];
    final request = Dio().post('https://cenkirpal.com/api/touna/get-sidang',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        data: {'id': id});

    try {
      final response = await request;
      List<dynamic> data = response.data;
      for (var item in data) {
        list.add(SidangModel.fromJson(item));
      }
      return list;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      return list;
    }
  }

  static Future addSidang(String no, String date, String agenda) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/add-sidang',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {
        'no': no,
        'date': date,
        'agenda': agenda,
      },
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future editSidang(int id, String date, String agenda,
      {bool? ket, String? keterangan}) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/edit-sidang',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {
        'id': id,
        'date': date,
        'agenda': agenda,
        'ket': ket,
        'keterangan': keterangan,
      },
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future ketSidang(int id, bool ket) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/ket-sidang',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'id': id, 'ket': ket},
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      error(e.response?.statusMessage);
      error(e.response?.statusCode.toString());
      error(e.response?.data);
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future deleteSidang(int id) async {
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/delete-sidang',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'id': id},
    );

    try {
      await request;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static Future<List<SidangModel>> jadwal(String date) async {
    List<SidangModel> list = [];
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/jadwal',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }, persistentConnection: false),
      data: {'date': date},
    );
    try {
      final response = await request;
      List<dynamic> data = response.data;
      for (var item in data) {
        list.add(SidangModel.fromJson(item));
      }
      return list;
    } on DioException catch (e) {
      print(e.error);
      print(e.message);
      print(e.response?.statusMessage);
      print(e.response?.statusCode.toString());
      print(e.response?.data);
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }

  static error(String? e) {
    if (kDebugMode) print(e ?? 'Error');
  }

  static Future<List<SidangModel>> rekapJadwal(
      String dateStart, String dateEnd) async {
    List<SidangModel> list = [];
    final request = Dio().post(
      'https://cenkirpal.com/api/touna/rekap-jadwal',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
      data: {'dateStart': dateStart, 'dateEnd': dateEnd},
    );
    try {
      final response = await request;
      List<dynamic> data = response.data;
      for (var item in data) {
        list.add(SidangModel.fromJson(item));
      }
      return list;
    } on DioException catch (e) {
      error(e.response?.data.toString());
      throw Exception(e.response?.data ?? 'Unknown Error');
    }
  }
}
