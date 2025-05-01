import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'name')
enum Difficulty {
  Easy('Easy'),
  Normal('Normal'),
  Hard('Hard'),
  Hardcore('Hardcore'); // <-- ADDED

  const Difficulty(this.name);
  final String name;
}
