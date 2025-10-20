import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final Map<String, dynamic> folder;
  CardsScreen({required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}