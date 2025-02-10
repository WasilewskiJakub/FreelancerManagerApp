import 'package:flutter/material.dart';
import '../../services/invoice/invoice_service.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final InvoiceDatabase _invoiceDatabase = InvoiceDatabase();

  Stream<List<Map<String, dynamic>>> _invoicesStream() async* {
    while (true) {
      final db = await _invoiceDatabase.database;
      final invoices = await db.query('invoices');
      yield invoices;
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _showInvoicePreview(Uint8List pdfData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePreviewScreen(pdfData: pdfData),
      ),
    );
  }

  void _saveInvoiceLocally(Uint8List pdfData, String invoiceName) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _invoicesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final invoices = snapshot.data!;

          if (invoices.isEmpty) {
            return const Center(child: Text("Brak zapisanych faktur"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      title: Text(
                        invoice['clientName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Data: ${invoice['invoiceDate'].toString().split('T')[0]}"),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == "preview") {
                            _showInvoicePreview(invoice['pdfData'] as Uint8List);
                          } else if (value == "save") {
                            _saveInvoiceLocally(invoice['pdfData'] as Uint8List, invoice['clientName']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: "preview", child: Text("Podgląd faktury")),
                          const PopupMenuItem(value: "save", child: Text("Zapisz fakturę lokalnie")),
                        ],
                      ),
                    ),
                    if (invoice['pdfData'] != null)
                      SizedBox(
                        height: 200,
                        child: PdfPreview(
                          build: (format) async => invoice['pdfData'] as Uint8List,
                          useActions: false,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class InvoicePreviewScreen extends StatelessWidget {
  final Uint8List pdfData;

  const InvoicePreviewScreen({Key? key, required this.pdfData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Podgląd faktury")),
      body: PdfPreview(
        build: (format) async => pdfData,
        useActions: true,
      ),
    );
  }
}
