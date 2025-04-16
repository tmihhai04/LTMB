import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../NoteModeL/note.dart';
import 'NoteFormScreen.dart'; // Để điều hướng đến màn hình sửa


class NoteDetailScreen extends StatelessWidget {
  final Note note; // Nhận note từ màn hình list

  const NoteDetailScreen({super.key, required this.note});

  String _getPriorityText(int priority) {
    switch (priority) {
      case 3: return 'Cao';
      case 2: return 'Trung bình';
      case 1: return 'Thấp';
      default: return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = note.color != null
        ? Color(int.parse(note.color!.replaceFirst('#', '0xFF')))
        : Theme.of(context).scaffoldBackgroundColor; // Màu nền mặc định

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Điều hướng sang màn hình sửa, truyền note hiện tại
              Navigator.pushReplacement( // Dùng replace để không quay lại detail sau khi sửa xong
                context,
                MaterialPageRoute(
                  builder: (context) => NoteFormScreen(note: note),
                ),
              );
            },
            tooltip: 'Sửa ghi chú',
          ),
        ],
      ),
      backgroundColor: cardColor, // Set màu nền cho cả màn hình
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Dùng ListView phòng khi nội dung quá dài
          children: [
            SelectableText( // Cho phép chọn và copy tiêu đề
              note.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ưu tiên: ${_getPriorityText(note.priority)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if(note.color != null)
                  Row(
                    children: [
                      Text('Màu: ', style: Theme.of(context).textTheme.titleSmall),
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(color: Color(int.parse(note.color!.replaceFirst('#', '0xFF'))), shape: BoxShape.circle),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 24),
            if (note.tags != null && note.tags!.isNotEmpty) ...[ // Toán tử spread (...) để thêm nhiều widget vào list
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: note.tags!
                    .map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(context).chipTheme.backgroundColor?.withOpacity(0.7),
                ))
                    .toList(),
              ),
              const Divider(height: 24),
            ],
            SelectableText( // Cho phép chọn và copy nội dung
              note.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5), // Tăng chiều cao dòng cho dễ đọc
            ),
            const SizedBox(height: 24),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tạo lúc: ${DateFormat.yMd().add_Hm().format(note.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Sửa lúc: ${DateFormat.yMd().add_Hm().format(note.modifiedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}