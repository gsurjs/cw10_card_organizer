import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final Map<String, dynamic> folder;
  CardsScreen({required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}
class _CardsScreenState extends State<CardsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _cards;

  @override
  void initState() {
    super.initState();
    _refreshCards();
  }

  void _refreshCards() {
    setState(() {
      _cards = _dbHelper.getCardsInFolder(widget.folder['id']);
    });
    _checkCardLimits();
  }
  
  void _checkCardLimits() async {
    int count = await _dbHelper.getCardCountInFolder(widget.folder['id']);
    if (count < 3) { // [cite: 46]
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warning: You need at least 3 cards in this folder.')) // [cite: 48]
      );
    }
  }

  void _showAddCardDialog() async {
    final unassignedCards = await _dbHelper.getUnassignedCards();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Card to ${widget.folder['name']}'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: unassignedCards.length,
            itemBuilder: (context, index) {
              final card = unassignedCards[index];
              return ListTile(
                title: Text(card['name']),
                onTap: () async {
                  int currentCount = await _dbHelper.getCardCountInFolder(widget.folder['id']);
                  if (currentCount >= 6) { // [cite: 46]
                    Navigator.of(context).pop();
                     _showErrorDialog('This folder can only hold 6 cards.'); // [cite: 47]
                  } else {
                    await _dbHelper.updateCardFolder(card['id'], widget.folder['id']); // [cite: 40]
                    Navigator.of(context).pop();
                    _refreshCards();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.folder['name']} Cards')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cards,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text('No cards in this folder.'));
          
          return GridView.builder( // [cite: 32, 50]
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final card = snapshot.data![index];
              return Card(
                child: GridTile(
                  header: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red), // Delete option [cite: 44]
                      onPressed: () async {
                        await _dbHelper.removeCardFromFolder(card['id']); // [cite: 43]
                        _refreshCards();
                      },
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.network(card['imageUrl']), // [cite: 53]
                  ),
                  footer: GridTileBar(
                    backgroundColor: Colors.black45,
                    title: Text(card['name'], textAlign: TextAlign.center),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddCardDialog, // Option to add cards [cite: 33]
      ),
    );
  }
}