import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_organizer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Folders table [cite: 23]
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    // Create Cards table [cite: 24]
    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        folderId INTEGER
      )
    ''');
    await _prepopulateData(db);
  }
  Future<void> _prepopulateData(Database db) async {
    // Pre-defined folders
    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    Map<String, int> folderIds = {};

    for (String suit in suits) {
      int id = await db.insert('folders', {'name': suit, 'timestamp': DateTime.now().toIso8601String()});
      folderIds[suit] = id;
    }

    // Prepopulate cards (A, K, Q, J) for a fuller deck
    Map<String, String> cardRanks = {'A': 'Ace', 'K': 'King', 'Q': 'Queen', 'J': 'Jack'};
    Map<String, String> suitShort = {'Hearts': 'H', 'Spades': 'S', 'Diamonds': 'D', 'Clubs': 'C'};
    
    for (String suit in suits) {
      for (var entry in cardRanks.entries) {
        int? folderId = (entry.key == 'A') ? folderIds[suit] : null;
        await db.insert('cards', {
          'name': '${entry.value} of $suit',
          'suit': suit,
          'imageUrl': 'https://deckofcardsapi.com/static/img/${entry.key}${suitShort[suit]}.png',
          'folderId': folderId 
        });
      }
    }
  }

  // Fetch all folders
  Future<List<Map<String, dynamic>>> getFolders() async {
    Database db = await database;
    return await db.query('folders');
  }

  // Fetch cards within a specific folder [cite: 51]
  Future<List<Map<String, dynamic>>> getCardsInFolder(int folderId) async {
    Database db = await database;
    return await db.query('cards', where: 'folderId = ?', whereArgs: [folderId]);
  }

  // Fetch unassigned cards
  Future<List<Map<String, dynamic>>> getUnassignedCards() async {
    Database db = await database;
    return await db.query('cards', where: 'folderId IS NULL');
  }
  
  // Count cards in a folder
  Future<int> getCardCountInFolder(int folderId) async {
    Database db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM cards WHERE folderId = ?', [folderId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get first card image for folder preview
  Future<String?> getFirstCardImage(int folderId) async {
     Database db = await database;
     final result = await db.query('cards', where: 'folderId = ?', whereArgs: [folderId], limit: 1);
     if (result.isNotEmpty) {
       return result.first['imageUrl'] as String?;
     }
     return null;
  }

  // Update a card (e.g., assign to a folder) [cite: 42]
  Future<void> updateCardFolder(int cardId, int? folderId) async {
    Database db = await database;
    await db.update('cards', {'folderId': folderId}, where: 'id = ?', whereArgs: [cardId]);
  }

  // Delete a card from a folder (by setting folderId to null) [cite: 43]
  Future<void> removeCardFromFolder(int cardId) async {
    await updateCardFolder(cardId, null);
  }
}