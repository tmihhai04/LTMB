import 'dart:convert'; // Để mã hóa/giải mã List<String>

class Note {
  final int? id;
  final String title;
  final String content;
  final int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String>? tags;
  final String? color; // Lưu mã màu Hex (vd: '#FF0000')

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  // Chuyển đổi từ Map (đọc từ DB) sang đối tượng Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      priority: map['priority'] as int,
      // Chuyển int (millisecondsSinceEpoch) thành DateTime
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(map['modifiedAt'] as int),
      // Giải mã chuỗi JSON thành List<String> nếu không null
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : null,
      color: map['color'] as String?,
    );
  }

  // Chuyển đổi từ đối tượng Note sang Map (để lưu vào DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id sẽ null khi insert, DB tự gán
      'title': title,
      'content': content,
      'priority': priority,
      // Chuyển DateTime thành int (millisecondsSinceEpoch)
      'createdAt': createdAt.millisecondsSinceEpoch,
      'modifiedAt': modifiedAt.millisecondsSinceEpoch,
      // Mã hóa List<String> thành chuỗi JSON nếu không null
      'tags': tags != null ? jsonEncode(tags) : null,
      'color': color,
    };
  }

  // Tạo bản sao với một số thuộc tính được cập nhật
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, priority: $priority, modifiedAt: $modifiedAt, tags: $tags, color: $color)';
  }
}