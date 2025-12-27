import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/expense.dart';

class PdfExportScreen extends StatefulWidget {
  final List<Expense> filteredExpenses;
  final String selectedCategory;
  final String searchQuery;

  const PdfExportScreen({
    super.key,
    required this.filteredExpenses,
    required this.selectedCategory,
    required this.searchQuery,
  });

  @override
  State<PdfExportScreen> createState() => _PdfExportScreenState();
}

class _PdfExportScreenState extends State<PdfExportScreen> {
  late Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _generatePDF();
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    // Data untuk PDF
    final totalAmount = widget.filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final categories = _getCategoryTotals(widget.filteredExpenses);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.poppinsRegular(),
          bold: await PdfGoogleFonts.poppinsBold(),
          italic: await PdfGoogleFonts.poppinsItalic(),
          boldItalic: await PdfGoogleFonts.poppinsBoldItalic(),
        ),
        header:
            (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text(
                'Laporan Pengeluaran',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ),
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.center,
              margin: const pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ),
        build:
            (context) => [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN PENGELUARAN',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight:
                            pw.FontWeight.bold, // Ganti ke nilai numerik
                        color: PdfColor.fromHex('#451A2B'),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Dibuat: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),

              // Category Totals
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Total per Kategori',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#451A2B'),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F8D7DA'),
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'KATEGORI',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'TOTAL',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'PERSENTASE',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        ...categories.entries.map((entry) {
                          final percentage =
                              totalAmount > 0
                                  ? (entry.value / totalAmount * 100)
                                  : 0;
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(12),
                                child: pw.Text(
                                  entry.key,
                                  style: pw.TextStyle(fontSize: 11),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(12),
                                child: pw.Text(
                                  'Rp ${entry.value.toStringAsFixed(0)}',
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(12),
                                child: pw.Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),

              // Detail Expenses
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Detail Pengeluaran',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#451A2B'),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2.5),
                        1: const pw.FlexColumnWidth(1.5),
                        2: const pw.FlexColumnWidth(1.5),
                        3: const pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F8D7DA'),
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'DESKRIPSI',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'KATEGORI',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'TANGGAL',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'JUMLAH',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        ...widget.filteredExpenses.map((expense) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      expense.title,
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    if (expense.description.isNotEmpty)
                                      pw.Text(
                                        expense.description,
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColors.grey600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  expense.category,
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  expense.formattedDate,
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  expense.formattedAmount,
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
      ),
    );

    return await pdf.save();
  }

  Map<String, double> _getCategoryTotals(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview PDF Export'),
        backgroundColor: const Color(0xFF451A2B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdfData = await _pdfFuture;
              await Printing.sharePdf(
                bytes: pdfData,
                filename:
                    'laporan-pengeluaran-${DateTime.now().millisecondsSinceEpoch}.pdf',
              );
            },
            tooltip: 'Share PDF',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdfData = await _pdfFuture;
              await Printing.layoutPdf(onLayout: (_) => pdfData);
            },
            tooltip: 'Print',
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF451A2B)),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Membuat PDF...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF451A2B),
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 20),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }

          return PdfPreview(
            build: (format) => snapshot.data!,
            canChangeOrientation: false,
            canChangePageFormat: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: 'laporan-pengeluaran.pdf',
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pdfData = await _pdfFuture;
          await Printing.sharePdf(
            bytes: pdfData,
            filename:
                'laporan-pengeluaran-${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
        },
        icon: const Icon(Icons.download_rounded),
        label: const Text(
          'Download PDF',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF451A2B),
        foregroundColor: Colors.white,
      ),
    );
  }
}
