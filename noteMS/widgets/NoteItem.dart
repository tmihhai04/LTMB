import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format ngày tháng
import '../NoteModeL/note.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  // Hàm lấy màu dựa trên độ ưu tiên (ví dụ)
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3: return Colors.red.shade100; // Cao
      case 2: return Colors.orange.shade100; // Trung bình
      case 1: return Colors.green.shade100; // Thấp
      default: return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng màu từ note.color nếu có, nếu không thì dựa vào priority
    final cardColor = note.color != null
        ? Color(int.parse(note.color!.replaceFirst('#', '0xFF'))) // Chuyển hex string sang Color
        : _getPriorityColor(note.priority);


    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              note.content,
              maxLines: 2, // Giới hạn nội dung hiển thị
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (note.tags != null && note.tags!.isNotEmpty)
              Wrap( // Hiển thị tags
                spacing: 4.0,
                runSpacing: 4.0,
                children: note.tags!
                    .map((tag) => Chip(
                  label: Text(tag),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  visualDensity: VisualDensity.compact,
                ))
                    .toList(),
              ),
            const SizedBox(height: 8),
            Text(
              'Sửa đổi: ${DateFormat.yMd().add_Hm().format(note.modifiedAt)}', // Định dạng ngày giờ
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onTap, // Gọi hàm khi nhấn vào item
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Để Row chỉ chiếm đủ không gian cần thiết
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Sửa',
              visualDensity: VisualDensity.compact, // Làm icon nhỏ gọn hơn
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Xóa',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}