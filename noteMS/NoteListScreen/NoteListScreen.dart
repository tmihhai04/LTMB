import 'package:flutter/material.dart';
import '../NoteDatabaseHelper/NoteDatabaseHelper.dart';
import '../NoteModeL/note.dart';
import '../widgets/NoteItem.dart';
import 'NoteFormScreen.dart';
import 'NoteDetailScreen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  String _orderBy = 'modifiedAt DESC'; // Mặc định sắp xếp theo thời gian sửa đổi
  String _searchQuery = '';
  int? _filterPriority; // null = không lọc
  bool _isGridView = false; // Mặc định là ListView

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _notesFuture = NoteDatabaseHelper.instance.searchNotes(_searchQuery, orderBy: _orderBy);
      } else if (_filterPriority != null) {
        _notesFuture = NoteDatabaseHelper.instance.getNotesByPriority(_filterPriority!, orderBy: _orderBy);
      }
      else {
        _notesFuture = NoteDatabaseHelper.instance.getAllNotes(orderBy: _orderBy);
      }
    });
  }

  void _navigateToForm({Note? note}) async {
    // Chờ kết quả trả về từ form (có thể là true nếu có thay đổi)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormScreen(note: note),
      ),
    );
    // Nếu có thay đổi, làm mới danh sách
    if (result == true) {
      _refreshNotes();
    }
  }

  void _navigateToDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note), // Truyền cả note cho tiện
      ),
    );
  }


  void _deleteNote(int id) async {
    // Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NoteDatabaseHelper.instance.deleteNote(id);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ghi chú'))
      );
      _refreshNotes(); // Làm mới danh sách sau khi xóa
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú'),
        actions: [
          // --- Nút tìm kiếm ---
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // Hiển thị dialog hoặc trang tìm kiếm riêng
              final query = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    TextEditingController searchController = TextEditingController(text: _searchQuery);
                    return AlertDialog(
                      title: Text("Tìm kiếm ghi chú"),
                      content: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(hintText: "Nhập tiêu đề hoặc nội dung..."),
                        onSubmitted: (value) => Navigator.of(context).pop(value),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text("Hủy")),
                        TextButton(onPressed: () => Navigator.of(context).pop(searchController.text), child: Text("Tìm")),
                      ],
                    );
                  });
              if (query != null) {
                setState(() {
                  _searchQuery = query;
                  _filterPriority = null; // Reset filter khi search
                });
                _refreshNotes();
              }
            },
          ),
          // --- Nút chuyển đổi Grid/List ---
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.view_module),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // --- Menu chức năng ---
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _searchQuery = ''; // Reset search khi dùng filter/sort

                if (value.startsWith('sort_')) {
                  _orderBy = value.substring(5); // Lấy phần sau 'sort_'
                } else if (value.startsWith('filter_')) {
                  _filterPriority = int.tryParse(value.substring(7)); // Lấy phần sau 'filter_'
                } else if (value == 'refresh') {
                  _filterPriority = null;
                  _orderBy = 'modifiedAt DESC'; // Reset về mặc định
                }
              });
              _refreshNotes();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Làm mới / Bỏ lọc')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'sort_priority DESC, modifiedAt DESC', child: Text('Sắp xếp: Ưu tiên giảm dần')),
              const PopupMenuItem(value: 'sort_priority ASC, modifiedAt DESC', child: Text('Sắp xếp: Ưu tiên tăng dần')),
              const PopupMenuItem(value: 'sort_modifiedAt DESC', child: Text('Sắp xếp: Mới nhất')),
              const PopupMenuItem(value: 'sort_modifiedAt ASC', child: Text('Sắp xếp: Cũ nhất')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'filter_3', child: Text('Lọc: Cao')),
              const PopupMenuItem(value: 'filter_2', child: Text('Lọc: Trung bình')),
              const PopupMenuItem(value: 'filter_1', child: Text('Lọc: Thấp')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có ghi chú nào.'));
          } else {
            final notes = snapshot.data!;
            // Sử dụng GridView hoặc ListView dựa vào _isGridView
            return _isGridView
                ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Số cột
                childAspectRatio: 0.8, // Tỉ lệ chiều rộng/cao của item
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteItem(
                  note: note,
                  onTap: () => _navigateToDetail(note),
                  onEdit: () => _navigateToForm(note: note),
                  onDelete: () => _deleteNote(note.id!),
                );
              },
            )
                : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteItem(
                  note: note,
                  onTap: () => _navigateToDetail(note),
                  onEdit: () => _navigateToForm(note: note),
                  onDelete: () => _deleteNote(note.id!),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(), // Gọi không có note để thêm mới
        child: const Icon(Icons.add),
      ),
    );
  }
}