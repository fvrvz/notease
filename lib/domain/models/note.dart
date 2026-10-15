import 'package:uuid/uuid.dart';

enum NoteColor {
  sage,
  lavender,
  peach,
  sky,
  butter,
  mint,
  rose;

  String get hexValue {
    switch (this) {
      case NoteColor.sage:
        return '#B5C9B7';
      case NoteColor.lavender:
        return '#C4B5D6';
      case NoteColor.peach:
        return '#F0C5B3';
      case NoteColor.sky:
        return '#B3CDE8';
      case NoteColor.butter:
        return '#EDE4A6';
      case NoteColor.mint:
        return '#B5D6C9';
      case NoteColor.rose:
        return '#E8B5C4';
    }
  }
}

class Note {
  final String id;
  final String title;
  final String content;
  final NoteColor color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isArchived;
  final List<String> tags;
  final String? syncId;
  final DateTime? syncedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.color = NoteColor.sage,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isArchived = false,
    this.tags = const [],
    this.syncId,
    this.syncedAt,
  });

  factory Note.create({String? title, String? content, NoteColor? color}) {
    final now = DateTime.now();
    return Note(
      id: const Uuid().v4(),
      title: title ?? '',
      content: content ?? '',
      color: color ?? NoteColor.sage,
      createdAt: now,
      updatedAt: now,
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteColor? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isArchived,
    List<String>? tags,
    String? syncId,
    DateTime? syncedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      tags: tags ?? this.tags,
      syncId: syncId ?? this.syncId,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'isArchived': isArchived,
      'tags': tags,
      'syncId': syncId,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      color: NoteColor.values.firstWhere(
        (c) => c.name == json['color'],
        orElse: () => NoteColor.sage,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      syncId: json['syncId'] as String?,
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
    );
  }
}
