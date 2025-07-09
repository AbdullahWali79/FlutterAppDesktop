import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'patient.dart';
import 'visit.dart';
import 'add_visit_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'add_patient_screen.dart';
import 'package:flutter/foundation.dart';
// Only import open_file if not web
// ignore: uri_does_not_exist
import 'package:open_file/open_file.dart' if (dart.library.html) 'package:untitled2/dummy_open_file.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  List<Visit> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    setState(() => _isLoading = true);
    final visits = await DatabaseHelper().getVisits(widget.patient.id!);
    setState(() {
      _visits = visits;
      _isLoading = false;
    });
  }

  Future<void> _addVisit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVisitScreen(patientId: widget.patient.id!),
      ),
    );
    _fetchVisits();
  }

  Future<void> _exportAsPdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final fileName = 'patient_${widget.patient.name.replaceAll(' ', '_')}_${now.year}${now.month}${now.day}_${now.hour}${now.minute}.pdf';
    // Placeholder logo (draw a circle)
    final logo = pw.Container(
      width: 60,
      height: 60,
      decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.blue),
      child: pw.Center(child: pw.Text('Dr', style: pw.TextStyle(color: PdfColors.white, fontSize: 24))),
    );
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Row(
            children: [
              logo,
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Clinic Name', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Dr. John Doe'),
                  pw.Text('123 Main Street, City'),
                  pw.Text('Phone: 123-456-7890'),
                ],
              ),
            ],
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('Patient Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Name: ${widget.patient.name}'),
          pw.Text('Address: ${widget.patient.address}'),
          pw.Text('Phone: ${widget.patient.phone}'),
          pw.SizedBox(height: 16),
          pw.Text('Visit History', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (_visits.isEmpty)
            pw.Text('No visits yet.')
          else
            pw.Table.fromTextArray(
              headers: ['Date', 'Diagnosis', 'Comments'],
              data: _visits.map((visit) => [
                visit.dateTime.toLocal().toString().split('.').first,
                visit.diagnosis,
                visit.comments,
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              border: null,
            ),
        ],
      ),
    );
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF exported: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export PDF.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Patient',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPatientScreen(patient: widget.patient),
                ),
              );
              if (updated == true) {
                setState(() {}); // Refresh patient info
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Patient',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Patient'),
                  content: const Text('Are you sure you want to delete this patient and all their visits?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await DatabaseHelper().deletePatient(widget.patient.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient deleted.')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: _exportAsPdf,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: widget.patient.imagePath != null && widget.patient.imagePath!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(widget.patient.imagePath!)),
                      radius: 48,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.yellow[700],
                      radius: 48,
                      child: Text(
                        widget.patient.name.isNotEmpty ? widget.patient.name[0].toUpperCase() : '',
                        style: const TextStyle(fontSize: 40, color: Colors.black),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text('Name: ${widget.patient.name}', style: const TextStyle(fontSize: 18)),
            Text('Address: ${widget.patient.address}'),
            Text('Phone: ${widget.patient.phone}'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download All History as PDF'),
              onPressed: () async {
                final pdf = pw.Document();
                final now = DateTime.now();
                final fileName = 'patient_history_${widget.patient.name.replaceAll(' ', '_')}_${now.year}${now.month}${now.day}_${now.hour}${now.minute}.pdf';
                pdf.addPage(
                  pw.MultiPage(
                    build: (context) => [
                      pw.Text('Patient Visit History', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('Name: ${widget.patient.name}'),
                      pw.Text('Address: ${widget.patient.address}'),
                      pw.Text('Phone: ${widget.patient.phone}'),
                      pw.SizedBox(height: 16),
                      if (_visits.isEmpty)
                        pw.Text('No visits yet.')
                      else
                        pw.Table.fromTextArray(
                          headers: ['Date', 'Diagnosis', 'Comments'],
                          data: _visits.map((visit) => [
                            visit.dateTime.toLocal().toString().split('.').first,
                            visit.diagnosis,
                            visit.comments,
                          ]).toList(),
                          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          cellAlignment: pw.Alignment.centerLeft,
                          cellStyle: const pw.TextStyle(fontSize: 10),
                          border: null,
                        ),
                    ],
                  ),
                );
                try {
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/$fileName');
                  await file.writeAsBytes(await pdf.save());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: GestureDetector(
                          onTap: () {
                            if (kIsWeb) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('File path: \\${file.path} (Open not supported on web)')),
                              );
                            } else {
                              OpenFile.open(file.path);
                            }
                          },
                          child: Text('PDF saved: \\${file.path}\nTap to open.'),
                        ),
                        duration: const Duration(seconds: 6),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to export PDF.')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Visit History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Visit'),
                  onPressed: _addVisit,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: _visits.isEmpty
                        ? const Text('No visits yet.')
                        : ListView.builder(
                            itemCount: _visits.length,
                            itemBuilder: (context, index) {
                              final visit = _visits[index];
                              return Dismissible(
                                key: ValueKey(visit.id),
                                direction: DismissDirection.horizontal,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 24),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Visit'),
                                      content: const Text('Are you sure you want to delete this visit?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  return confirm == true;
                                },
                                onDismissed: (direction) async {
                                  await DatabaseHelper().deleteVisit(visit.id!);
                                  _fetchVisits();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Visit deleted.')),
                                    );
                                  }
                                },
                                child: GestureDetector(
                                  onLongPress: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddVisitScreen(patientId: widget.patient.id!, visit: visit),
                                      ),
                                    );
                                    if (updated == true) _fetchVisits();
                                  },
                                  child: Card(
                                    child: ListTile(
                                      title: Text(visit.diagnosis),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Comments: ${visit.comments}'),
                                          Text('Date: ${visit.dateTime.toLocal()}'),
                                          if (visit.imagePath != null && visit.imagePath!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: SizedBox(
                                                width: 120,
                                                height: 120,
                                                child: Image.file(
                                                  File(visit.imagePath!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.picture_as_pdf),
                                            label: const Text('Download PDF'),
                                            onPressed: () async {
                                              final pdf = pw.Document();
                                              final now = DateTime.now();
                                              final fileName = 'visit_${visit.id}_${now.year}${now.month}${now.day}_${now.hour}${now.minute}.pdf';
                                              pdf.addPage(
                                                pw.Page(
                                                  build: (context) => pw.Column(
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    children: [
                                                      pw.Text('Visit Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                                                      pw.SizedBox(height: 8),
                                                      pw.Text('Diagnosis: ${visit.diagnosis}'),
                                                      pw.Text('Comments: ${visit.comments}'),
                                                      pw.Text('Date: ${visit.dateTime.toLocal()}'),
                                                    ],
                                                  ),
                                                ),
                                              );
                                              try {
                                                final dir = await getApplicationDocumentsDirectory();
                                                final file = File('${dir.path}/$fileName');
                                                await file.writeAsBytes(await pdf.save());
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: GestureDetector(
                                                        onTap: () {
                                                          if (kIsWeb) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('File path: \\${file.path} (Open not supported on web)')),
                                                            );
                                                          } else {
                                                            OpenFile.open(file.path);
                                                          }
                                                        },
                                                        child: Text('PDF saved: \\${file.path}\nTap to open.'),
                                                      ),
                                                      duration: const Duration(seconds: 6),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Failed to export PDF.')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
} 