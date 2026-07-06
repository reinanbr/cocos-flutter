import 'package:intl/intl.dart';

String formatDate(String iso) {
  final d = DateTime.parse(iso).toLocal();
  return DateFormat('dd/MM/yyyy').format(d);
}

String formatTime(String iso) {
  final d = DateTime.parse(iso).toLocal();
  return DateFormat('HH:mm').format(d);
}
