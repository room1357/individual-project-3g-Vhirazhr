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
}
