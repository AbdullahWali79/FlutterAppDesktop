import 'package:flutter/material.dart';
import 'add_patient_screen.dart';
import 'database_helper.dart';
import 'patient.dart';
import 'patient_details_screen.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _addPatientOffset;
  late Animation<Offset> _allPatientsOffset;

  List<Patient> _patients = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _addPatientOffset = Tween<Offset>(begin: const Offset(-2, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _allPatientsOffset = Tween<Offset>(begin: const Offset(2, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
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
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
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
                                  leading: patient.imagePath != null && patient.imagePath!.isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage: FileImage(File(patient.imagePath!)),
                                          radius: 24,
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.yellow[700],
                                          radius: 24,
                                          child: Text(
                                            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '',
                                            style: const TextStyle(fontSize: 24, color: Colors.black),
                                          ),
                                        ),
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
          Positioned(
            bottom: 32,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SlideTransition(
                  position: _addPatientOffset,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: FloatingActionButton(
                      heroTag: 'addPatient',
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddPatientScreen()),
                        );
                        if (result == true) {
                          _fetchPatients();
                        }
                      },
                      child: const Icon(Icons.person_add, size: 32),
                    ),
                  ),
                ),
                // Removed the All Patients button
              ],
            ),
          ),
        ],
      ),
    );
  }
} 