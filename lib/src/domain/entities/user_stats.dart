import 'package:flutter/foundation.dart';

@immutable
class UserStats {
  final int strength;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int dexterity;
  final int luck;

  const UserStats({
    this.strength = 0,
    this.intelligence = 0,
    this.wisdom = 0,
    this.charisma = 0,
    this.dexterity = 0,
    this.luck = 0,
  });

  UserStats copyWith({
    int? strength,
    int? intelligence,
    int? wisdom,
    int? charisma,
    int? dexterity,
    int? luck,
  }) {
    return UserStats(
      strength: strength ?? this.strength,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      dexterity: dexterity ?? this.dexterity,
      luck: luck ?? this.luck,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      strength: json['strength'] as int,
      intelligence: json['intelligence'] as int,
      wisdom: json['wisdom'] as int,
      charisma: json['charisma'] as int,
      dexterity: json['dexterity'] as int,
      luck: json['luck'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'strength': strength,
        'intelligence': intelligence,
        'wisdom': wisdom,
        'charisma': charisma,
        'dexterity': dexterity,
        'luck': luck,
      };
}