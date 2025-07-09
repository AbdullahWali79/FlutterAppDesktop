import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'patient.dart';
import 'patient_details_screen.dart';

// This screen is now integrated into the DashboardScreen. You can remove this file if not needed.

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> _patients = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() => _isLoading = true);
    final patients = await DatabaseHelper().getPatients(query: _searchQuery);
    setState(() {
      _patients = patients;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Patients')),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search by name',
                labelStyle: const TextStyle(color: Colors.yellow),
                prefixIcon: const Icon(Icons.search, color: Colors.yellow),
                filled: true,
                fillColor: Colors.grey[900],
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _patients.isEmpty
                    ? const Center(child: Text('No patients found.', style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: _patients.length,
                        itemBuilder: (context, index) {
                          final patient = _patients[index];
                          return Card(
                            color: Colors.grey[900],
                            child: ListTile(
                              title: Text(patient.name, style: const TextStyle(color: Colors.yellow)),
                              subtitle: Text(patient.phone, style: const TextStyle(color: Colors.white70)),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.yellow),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailsScreen(patient: patient),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 