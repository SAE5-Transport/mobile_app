import 'package:hive/hive.dart';

part 'parameters.g.dart';

@HiveType(typeId: 1)
class Parameters {
  Parameters({
    required this.name,
    required this.themeId,
  });

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String themeId;
}