import 'package:flutter/material.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.preview,
    required this.detail,
  });

  final String id, title, category, date, preview, detail;
}

class CampusService {
  const CampusService({
    required this.id,
    required this.label,
    required this.icon,
    required this.detailDestination,
  });

  final String id, label;
  final IconData icon;
  final ServiceDestination detailDestination;
}

class ServiceDestination {
  const ServiceDestination({
    required this.title,
    required this.description,
    required this.location,
    required this.hours,
  });

  final String title, description, location, hours;
}
