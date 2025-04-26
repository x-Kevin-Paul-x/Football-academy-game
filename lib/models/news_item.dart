import 'package:flutter/material.dart'; // For potential IconData usage later

enum NewsItemType {
  MatchResult,
  Scouting,
  Training,
  TransferOffer,
  TransferDecision,
  StaffChange,
  Finance, // e.g., weekly summary, low balance warning
  Facility,
  PlayerSigned, // A scouted player was signed to the academy
  Generic, // Default
}

class NewsItem {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final NewsItemType type;
  bool isRead; // To track if the user has seen it (optional for now)
  // final IconData? icon; // Optional: Icon based on type

  NewsItem({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    this.type = NewsItemType.Generic,
    this.isRead = false,
    // this.icon,
  });

  // Helper to generate a unique ID
  static String _generateId() {
    return 'news_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey()}';
  }

  // Factory constructor for easier creation with automatic ID/Date
  factory NewsItem.create({
    required String title,
    required String description,
    NewsItemType type = NewsItemType.Generic,
    DateTime? date, // Allow overriding date if needed
  }) {
    return NewsItem(
      id: _generateId(),
      date: date ?? DateTime.now(), // Use current time if not provided
      title: title,
      description: description,
      type: type,
    );
  }
}
