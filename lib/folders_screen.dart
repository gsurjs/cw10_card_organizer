// lib/folders_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});
  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _folders;

  @override
  void initState() {
    super.initState();
    _refreshFolders();
  }

  void _refreshFolders() {
    setState(() {
      _folders = _dbHelper.getFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Folders')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _folders,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final folder = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: FutureBuilder<String?>(
                    future: _dbHelper.getFirstCardImage(folder['id']),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.hasData && imageSnapshot.data != null) {
                        return Image.network(imageSnapshot.data!, width: 40);
                      }
                      return Icon(Icons.folder, size: 40, color: Colors.grey);
                    },
                  ),
                  title: Text(folder['name']),
                  subtitle: FutureBuilder<int>(
                    future: _dbHelper.getCardCountInFolder(folder['id']),
                    builder: (context, countSnapshot) {
                      return Text('${countSnapshot.data ?? 0} cards');
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CardsScreen(folder: folder)),
                    );
                    _refreshFolders(); // Refresh counts when returning
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}