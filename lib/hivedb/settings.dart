import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId : 1)
class GlobalSettings extends HiveObject {
  @HiveField(0)
  Color primaryColor;

  @HiveField(1)
  Color accentColor;
}