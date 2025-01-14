import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveHandler {
  static void initHive() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  }
}