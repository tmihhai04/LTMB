import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Nếu dùng color picker
import '../NoteDatabaseHelper/NoteDatabaseHelper.dart';
import '../NoteModeL/note.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note; // note sẽ là null nếu là thêm mới

  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController; // Để nhập tags mới
  late int _selectedPriority;
  String? _selectedColor; // Mã màu Hex
  List<String> _tags = []; // Danh sách tags hiện tại

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedPriority = widget.note?.priority ?? 2; // Mặc định là Trung bình
    _selectedColor = widget.note?.color;
    _tags = widget.note?.tags?.toList() ?? []; // Tạo bản sao để sửa đổi
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final newTag = _tagsController.text.trim();
    if (newTag.isNotEmpty && !_tags.contains(newTag)) {
      setState(() {
        _tags.add(newTag);
      });
      _tagsController.clear(); // Xóa text field sau khi thêm
    }
  }

  void _removeTag(String tagToRemove) {
    setState(() {
      _tags.remove(tagToRemove);
    });
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final content = _contentController.text;
      final now = DateTime.now();

      final noteToSave = Note(
        id: widget.note?.id, // Giữ nguyên id nếu là sửa
        title: title,
        content: content,
        priority: _selectedPriority,
        createdAt: widget.note?.createdAt ?? now, // Giữ nguyên nếu sửa, nếu không là now
        modifiedAt: now, // Luôn là now khi lưu
        tags: _tags.isNotEmpty ? _tags : null, // Lưu null nếu không có tag
        color: _selectedColor,
      );

      try {
        if (widget.note == null) {
          // Thêm mới
          await NoteDatabaseHelper.instance.insertNote(noteToSave);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm ghi chú mới!'))
          );
        } else {
          // Cập nhật
          await NoteDatabaseHelper.instance.updateNote(noteToSave);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật ghi chú!'))
          );
        }
        // Trả về true để báo hiệu cho màn hình list là cần refresh
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi lưu: $e'))
        );
      }
    }
  }

  // --- Hàm chọn màu (Ví dụ đơn giản, nên dùng package flutter_colorpicker) ---
  void _pickColor() async {
    // // Ví dụ với flutter_colorpicker
    // Color pickerColor = _selectedColor != null
    //     ? Color(int.parse(_selectedColor!.replaceFirst('#', '0xFF')))
    //     : Colors.white; // Màu mặc định
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text('Chọn màu nền'),
    //     content: SingleChildScrollView(
    //       child: ColorPicker(
    //         pickerColor: pickerColor,
    //         onColorChanged: (color) => pickerColor = color,
    //         // enableAlpha: false, // Tùy chọn
    //         // displayThumbColor: true, // Tùy chọn
    //         // pickerAreaHeightPercent: 0.8, // Tùy chọn
    //       ),
    //     ),
    //     actions: <Widget>[
    //       ElevatedButton(
    //         child: const Text('Chọn'),
    //         onPressed: () {
    //           setState(() => _selectedColor = '#${pickerColor.value.toRadixString(16).substring(2).toUpperCase()}');
    //           Navigator.of(context).pop();
    //         },
    //       ),
    //     ],
    //   ),
    // );

    // Ví dụ đơn giản hơn với danh sách màu cố định
    final List<String?> availableColors = [null, '#FFFACD', '#ADD8E6', '#90EE90', '#FFB6C1', '#FFDEAD', '#E6E6FA'];
    final selected = await showDialog<String?>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Chọn màu'),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: availableColors.map((hexColor) {
              final color = hexColor == null ? Colors.grey.shade300 : Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(hexColor),
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 20,
                  child: _selectedColor == hexColor ? Icon(Icons.check, color: Colors.black) : null,
                ),
              );
            }).toList(),
          ),
        )
    );
    if (selected != null) {
      setState(() {
        _selectedColor = selected;
      });
    } else if (selected == null && availableColors.contains(null)) { // Xử lý trường hợp chọn màu "không màu" / mặc định
      setState(() {
        _selectedColor = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm ghi chú mới' : 'Sửa ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Sử dụng ListView để tránh lỗi overflow khi bàn phím hiện lên
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Canh label lên trên khi có nội dung
                ),
                maxLines: 8, // Cho phép nhập nhiều dòng
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Chọn độ ưu tiên ---
              DropdownButtonFormField<int>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // --- Chọn màu ---
              ListTile(
                title: const Text('Màu nền'),
                trailing: CircleAvatar(
                  backgroundColor: _selectedColor != null
                      ? Color(int.parse(_selectedColor!.replaceFirst('#', '0xFF')))
                      : Colors.transparent, // Hoặc một màu mặc định
                  radius: 15,
                  child: _selectedColor == null ? Icon(Icons.format_color_reset) : null,
                ),
                onTap: _pickColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey)),
                tileColor: Colors.grey[50],
              ),

              const SizedBox(height: 16),
              // --- Quản lý Tags ---
              Text('Nhãn (Tags)', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag), // Cho phép xóa tag
                )).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: 'Thêm nhãn mới...',
                      ),
                      onSubmitted: (_) => _addTag(), // Thêm khi nhấn Enter
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag, // Thêm khi nhấn nút
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}