// ignore_for_file: must_be_immutable

import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'task_model.g.dart';

enum TaskStatus { toDo, inProgress, done }
enum TaskPriority { low, medium, high }

@HiveType(typeId: 0)
class TaskModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int status;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final int priority;

  @HiveField(7)
  final DateTime? dueDate;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    int? priority,
    this.dueDate,
  }) : priority = priority ?? 1;

  TaskStatus get taskStatus => TaskStatus.values[status];
  TaskPriority get taskPriority => TaskPriority.values[priority];
  
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && status != TaskStatus.done.index;
  bool get isDueSoon => dueDate != null && dueDate!.difference(DateTime.now()).inDays <= 1 && status != TaskStatus.done.index;

  @override
  List<Object?> get props => [id, title, description, status, createdAt, updatedAt, priority, dueDate];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      priority: json['priority'] ?? 1,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}