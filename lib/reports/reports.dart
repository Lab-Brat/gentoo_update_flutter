import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gentoo_update_flutter/services/auth.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final AuthService authService = AuthService();
  late Stream<QuerySnapshot> _reportsStream;

  @override
  void initState() {
    super.initState();
    String userId = authService.uid;
    _reportsStream = _firestore
        .collection('reports')
        .doc(userId)
        .collection('user_reports')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No reports found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final report = snapshot.data!.docs[index];
              final reportData = report.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Report ID: ${report.id}'),
                subtitle: Text('Status: ${reportData['report_status']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportDetailScreen(report: reportData),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: report['report_content'].length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(report['report_content'][index]),
            );
          },
        ),
      ),
    );
  }
}
