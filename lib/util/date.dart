import 'package:intl/intl.dart';

const days = [
  'HARI',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];
const months = [
  'MONTH',
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember'
];
const shortMonths = [
  'MONTH',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agust',
  'Sept',
  'Okt',
  'Nov',
  'Des',
];

extension CustomeDate on DateTime {
  String get fullday => '$day ${months[month]} $year';
  String get shortday => '$day ${shortMonths[month]} $year';
  String get fullMonth => months[month];
  String get dayname => days[weekday];
  String get formatDB {
    var d = '$day'.length == 1 ? '0$day' : '$day';
    var m = '$month'.length == 1 ? '0$month' : '$month';
    return '$year-$m-$d';
  }

  String get dateHour {
    var d = '$day'.length == 1 ? '0$day' : '$day';
    var m = '$month'.length == 1 ? '0$month' : '$month';
    var hh = hour < 10 ? '0$hour' : '$hour';
    var mm = minute < 10 ? '0$minute' : '$minute';
    var ss = second < 10 ? '0$second' : '$second';
    return '$year-$m-$d $hh:$mm:$ss';
  }
}

String avoidWeekday({DateTime? date}) {
  var now = date ?? DateTime.now();
  var dayName = DateFormat('EEEE').format(now);
  if (dayName == 'Saturday') {
    now = now.add(const Duration(days: 2));
  }
  if (dayName == 'Sunday') {
    now = now.add(const Duration(days: 1));
  }
  return now.toString();
}
