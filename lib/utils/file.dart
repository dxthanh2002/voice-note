import 'package:path/path.dart' as p;

String getFileName(String path) {
  final name = p.basename(path);
  if (name.isEmpty) {
    return 'file_${DateTime.now().millisecondsSinceEpoch}';
  }
  return name;
}
