import 'package:flutter/material.dart'; // For potential IconData usage later
import 'package:json_annotation/json_annotation.dart'; // Added for JSON serialization
import 'package:uuid/uuid.dart'; // Import Uuid for reliable ID generation

part 'news_item.g.dart'; // Added for generated code

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
  Tournament, // Added for tournament-related news (scheduled, started, finished, cancelled)
  LeagueUpdate, // Promotion/Relegation news
  Generic, // Default
}

@JsonSerializable() // Added annotation
class NewsItem {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final NewsItemType type;
  bool isRead; // To track if the user has seen it
  // final IconData? icon; // Optional: Icon based on type - Icons cannot be easily serialized

  NewsItem({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    this.type = NewsItemType.Generic,
    this.isRead = false,
    // this.icon,
  });

  // Helper to generate a unique ID using uuid
  @JsonKey(
      includeFromJson: false, includeToJson: false) // Exclude static helper
  static String _generateId() {
    return const Uuid().v4(); // Use v4 for random UUIDs
  }

  // Factory constructor for easier creation with automatic ID/Date
  // Exclude this factory from serialization
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  // Added methods for JSON serialization
  factory NewsItem.fromJson(Map<String, dynamic> json) =>
      _$NewsItemFromJson(json);
  Map<String, dynamic> toJson() => _$NewsItemToJson(this);
}
