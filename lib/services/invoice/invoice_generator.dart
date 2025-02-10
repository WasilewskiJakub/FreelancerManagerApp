import 'package:flutter/material.dart';
import 'package:freelancer_manager_app/services/user/user_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/project.dart';
import '../../domain/user_details.dart';

import './invoice_service.dart';

class InvoiceFormScreen extends StatefulWidget {
  final Project project;
  final UserDetails userDetails;

  const InvoiceFormScreen({Key? key, required this.project, required this.userDetails}) : super(key: key);

  @override
  _InvoiceFormScreenState createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientCityController = TextEditingController();
  final TextEditingController clientNIPController = TextEditingController();
  final TextEditingController hourlyRateController = TextEditingController(text: "100.0");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generowanie faktury")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: clientNameController,
                decoration: const InputDecoration(labelText: "Nazwa klienta"),
                validator: (value) => value!.isEmpty ? "Pole wymagane" : null,
              ),
              TextFormField(
                controller: clientAddressController,
                decoration: const InputDecoration(labelText: "Adres klienta"),
              ),
              TextFormField(
                controller: clientCityController,
                decoration: const InputDecoration(labelText: "Miasto klienta"),
              ),
              TextFormField(
                controller: clientNIPController,
                decoration: const InputDecoration(labelText: "NIP klienta"),
              ),
              TextFormField(
                controller: hourlyRateController,
                decoration: const InputDecoration(labelText: "Stawka godzinowa (PLN)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    InvoiceGenerator.generateInvoice(
                      context,
                      widget.project,
                      widget.userDetails,
                      clientNameController.text,
                      clientAddressController.text,
                      clientCityController.text,
                      clientNIPController.text,
                      double.tryParse(hourlyRateController.text) ?? 100.0,
                    );
                  }
                },
                child: const Text("Generuj fakturę"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceGenerator {
  // static Future<void> generateInvoice(
  //     BuildContext context,
  //     Project project,
  //     UserDetails userDetails,
  //     String clientName,
  //     String clientAddress,
  //     String clientCity,
  //     String clientNIP,
  //     double hourlyRate) async {
  //   final pdf = pw.Document();
  //   final DateTime invoiceDate = DateTime.now();
  //   final String invoiceNumber = "FV-${invoiceDate.year}${invoiceDate.month}${invoiceDate.day}-${project.id}";

  //   List<InvoiceItem> invoiceItems = project.tasks
  //       .where((task) => task.isCompleted)
  //       .map((task) => InvoiceItem(title: task.title, manDays: task.manDay))
  //       .toList();

  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             _buildHeader(invoiceNumber, invoiceDate),
  //             _buildUserDetails(userDetails),
  //             _buildClientDetails(clientName, clientAddress, clientCity, clientNIP),
  //             _buildProjectDetails(project),
  //             _buildInvoiceTable(invoiceItems, hourlyRate),
  //             _buildTotalAmount(invoiceItems, hourlyRate),
  //             pw.SizedBox(height: 20),
  //             pw.Text("Dziękujemy za współpracę!",
  //                 style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   double totalAmount = invoiceItems.fold(0, (sum, item) => sum + (item.manDays * 8 * hourlyRate));
  //   totalAmount *= 1.23;

  //   await InvoiceDatabase().saveInvoice(
  //   clientName: clientName,
  //   clientAddress: clientAddress,
  //   clientCity: clientCity,
  //   clientNIP: clientNIP,
  //   projectId: project.id!,
  //   totalAmount: totalAmount,
  //   pdfData: await pdf.save(), // Zapisuje PDF jako bajty
  // );

  //   await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  // }

  static pw.Widget _buildTotalAmount(List<InvoiceItem> items, double hourlyRate) {
    double totalAmount = items.fold(0, (sum, item) => sum + (item.manDays * 8 * hourlyRate));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text("Razem do zapłaty [Netto]: ${totalAmount.toStringAsFixed(2)} PLN",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Razem do zapłaty [Brutto]: ${(totalAmount*1.23).toStringAsFixed(2)} PLN",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildHeader(String invoiceNumber, DateTime invoiceDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Faktura VAT", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text("Numer faktury: $invoiceNumber", style: pw.TextStyle(fontSize: 14)),
        pw.Text("Data wystawienia: ${_formatDate(invoiceDate)}", style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildUserDetails(UserDetails user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Wystawca: ${user.firstName} ${user.lastName}"),
        pw.Text("Adres: ${user.address}, ${user.city}, ${user.country}"),
        pw.Text("NIP: ${user.nip}"),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildClientDetails(String name, String address, String city, String nip) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Nabywca: $name"),
        pw.Text("Adres: $address, $city"),
        pw.Text("NIP: $nip"),
        pw.SizedBox(height: 16),
      ],
    );
  }
  static Future<void> generateInvoice(
    BuildContext context,
    Project project,
    UserDetails userDetails,
    String clientName,
    String clientAddress,
    String clientCity,
    String clientNIP,
    double hourlyRate) async {
  try {
    final pdf = pw.Document();
    final DateTime invoiceDate = DateTime.now();
    final String invoiceNumber = "FV-${invoiceDate.year}${invoiceDate.month}${invoiceDate.day}-${project.id}";

    List<InvoiceItem> invoiceItems = project.tasks
        .where((task) => task.isCompleted)
        .map((task) => InvoiceItem(title: task.title, manDays: task.manDay))
        .toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(invoiceNumber, invoiceDate),
              _buildUserDetails(userDetails),
              _buildClientDetails(clientName, clientAddress, clientCity, clientNIP),
              _buildProjectDetails(project),
              _buildInvoiceTable(invoiceItems, hourlyRate),
              _buildTotalAmount(invoiceItems, hourlyRate),
              pw.SizedBox(height: 20),
              pw.Text("Dziękujemy za współpracę!",
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    double totalAmount = invoiceItems.fold(0, (sum, item) => sum + (item.manDays * 8 * hourlyRate));

    UserService userService = UserService();
    UserDetails user = (await userService.getCurrentUserDetails())!;

    await InvoiceDatabase().saveInvoice(
      userId: user.id!,
      clientName: clientName,
      clientAddress: clientAddress,
      clientCity: clientCity,
      clientNIP: clientNIP,
      projectId: project.id!,
      hourlyRate: hourlyRate,
      totalNetAmount: totalAmount,
      pdfData: await pdf.save(),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Faktura została wygenerowana i zapisana")),
    );
  } catch (e) {
    debugPrint("Błąd podczas generowania faktury: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Błąd podczas generowania faktury")),
    );
  }
}


  static pw.Widget _buildProjectDetails(Project project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Projekt: ${project.name}"),
        pw.Text("Opis: ${project.description}"),
        pw.Text("Termin: ${_formatDate(project.startDate!)} - ${_formatDate(project.endDate!)}"),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(List<InvoiceItem> items, double hourlyRate) {
    return pw.Table.fromTextArray(
      headers: ["Pozycja", "godziny (h)", "Stawka (PLN/h)[Netto]", "Kwota Netto (PLN)", "Kwota Brutto (PLN)"],
      data: items.map((item) => [
        item.title,
        (item.manDays * 8) .toString(),
        hourlyRate.toString(),
        (item.manDays * 8 * hourlyRate).toStringAsFixed(2),
        (item.manDays * 8 * hourlyRate * 1.23).toStringAsFixed(2)
      ]).toList(),
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}

class InvoiceItem {
  final String title;
  final int manDays;

  InvoiceItem({required this.title, required this.manDays});
}
