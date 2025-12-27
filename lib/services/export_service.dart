import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/expense.dart';

class ExportService {
  static Future<void> exportExpensesToPdf(List<Expense> expenses) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
              pw.Text(
                'Laporan Pengeluaran',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              _buildExpenseTable(expenses),
              pw.SizedBox(height: 12),
              pw.Text('Total: Rp ${_total(expenses).toStringAsFixed(0)}'),
            ],
      ),
    );

    // Preview + bisa save/share/print
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'laporan_pengeluaran.pdf',
    );
  }

  static pw.Widget _buildExpenseTable(List<Expense> expenses) {
    final headers = ['Tanggal', 'Judul', 'Kategori', 'Jumlah'];

    final data =
        expenses
            .map(
              (e) => [e.formattedDate, e.title, e.category, e.formattedAmount],
            )
            .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(2),
      },
    );
  }

  static double _total(List<Expense> expenses) =>
      expenses.fold(0, (s, e) => s + e.amount);
}
