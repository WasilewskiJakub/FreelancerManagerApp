import 'dart:async';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InvoiceDatabase {
  static Database? _database;
  
  final StreamController<double> _invoiceValueController = StreamController<double>.broadcast();

  Stream<double> get invoiceValueStream => _invoiceValueController.stream;

  InvoiceDatabase() {
    _initDB().then((db) async {
      _database = db;
    });
  }

  Future<Database> get database async {
    // Zwraca już zainicjowaną bazę lub czeka na inicjalizację
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'invoices.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            projectId TEXT NOT NULL,
            clientName TEXT NOT NULL,
            clientAddress TEXT,
            clientCity TEXT,
            clientNIP TEXT,
            hourlyRate REAL NOT NULL,
            totalNetAmount REAL NOT NULL,
            vatAmount REAL NOT NULL,
            totalBruttoAmount REAL NOT NULL,
            invoiceDate TEXT NOT NULL,
            invoiceMonth TEXT NOT NULL,
            invoiceYear TEXT NOT NULL,
            pdfData BLOB
          )
        ''');
      },
    );
  }

  Future<void> saveInvoice({
    required String userId,
    required String clientName,
    required String clientAddress,
    required String clientCity,
    required String clientNIP,
    required String projectId,
    required double hourlyRate,
    required double totalNetAmount,
    required Uint8List pdfData,
  }) async {
    final db = await database;
    final now = DateTime.now();

    final vatAmount = totalNetAmount * 0.23;
    final totalBruttoAmount = totalNetAmount + vatAmount;

    await db.insert('invoices', {
      'userId': userId,
      'projectId': projectId,
      'clientName': clientName,
      'clientAddress': clientAddress,
      'clientCity': clientCity,
      'clientNIP': clientNIP,
      'hourlyRate': hourlyRate,
      'totalNetAmount': totalNetAmount,
      'vatAmount': vatAmount,
      'totalBruttoAmount': totalBruttoAmount,
      'invoiceDate': now.toIso8601String(),
      'invoiceMonth': "${now.year}-${now.month.toString().padLeft(2, '0')}",
      'invoiceYear': now.year.toString(),
      'pdfData': pdfData,
    });

    await _emitInvoiceValueForUser(userId);
  }

  Future<void> _emitInvoiceValueForUser(String userId) async {
    final total = await getTotalInvoiceValueForUser(userId);
    _invoiceValueController.add(total); // emitujemy do streamu
  }

  Future<double> getTotalInvoiceValueForUser(String userId) async {
    final db = await database;
    final invoices = await db.query(
      'invoices',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return invoices.fold<double>(
      0.0,
      (sum, invoice) => sum + (invoice['totalBruttoAmount'] as double? ?? 0.0),
    );
  }

  /// Gdy pobierasz PDF:
  Future<Uint8List?> getInvoicePdf(int invoiceId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
    if (results.isNotEmpty) {
      return results.first['pdfData'];
    }
    return null;
  }
}