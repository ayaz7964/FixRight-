// lib/src/models/order_model.dart
import 'package:flutter/foundation.dart';

class Attachment {
  final String id;
  final String name;
  final String mime;
  final int sizeBytes;
  final String url;

  Attachment({
    required this.id,
    required this.name,
    required this.mime,
    required this.sizeBytes,
    required this.url,
  });
}

class OrderEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime at;
  final String icon; // optional string icon name or url

  OrderEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.at,
    this.icon = '',
  });
}

class Order {
  final String id;
  final String title;
  final String price; // keep string for formatting flexibility
  final String shortDesc;
  final String seller;
  final String status;
  final DateTime createdAt;
  final String thumbnail;
  final List<Attachment> attachments;
  final Map<String, String> requirements; // question -> answer
  final List<OrderEvent> timeline;

  const Order({
    required this.id,
    required this.title,
    required this.price,
    required this.shortDesc,
    required this.seller,
    required this.status,
    required this.createdAt,
    required this.thumbnail,
    this.attachments = const [],
    this.requirements = const {},
    this.timeline = const [],
  });
}
