import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificateService {
  Future<File> generateCertificate({
    required String studentName,
    required String moduleName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "CERTIFICATE OF COMPLETION",
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 40),

                pw.Text(
                  studentName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  "has successfully completed",
                  style: const pw.TextStyle(fontSize: 18),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  moduleName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 40),

                pw.Text(
                  "Navyoga Academy",
                  style: const pw.TextStyle(fontSize: 18),
                ),

                pw.SizedBox(height: 10),

                pw.Text(
                  DateTime.now().toString().split(' ').first,
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();

    final file = File(
      "${dir.path}/certificate.pdf",
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    return file;
  }
}