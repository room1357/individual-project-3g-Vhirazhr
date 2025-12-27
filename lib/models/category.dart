import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color.value,
    'icon': icon.codePoint,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    color: Color(map['color']),
    icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
    createdAt: DateTime.parse(map['createdAt']),
  );
}
