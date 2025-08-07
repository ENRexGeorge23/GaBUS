import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabus_build/admin/admin_screens/admin_verification_detail_screen.dart';
import 'package:flutter/material.dart';

class AdminVerificationScreen extends StatefulWidget {
  static const routeName = '/admin-verification';

  @override
  _AdminVerificationScreenState createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  Future<List<VerificationRequest>> fetchVerificationRequests() async {
    final verificationRequestsRef =
        FirebaseFirestore.instance.collection('verificationRequest');
    final userDocsSnapshot = await verificationRequestsRef.get();
    List<VerificationRequest> verificationRequests = [];

    for (final userDoc in userDocsSnapshot.docs) {
      final data = userDoc.data() as Map<String, dynamic>;
      verificationRequests.add(VerificationRequest(
        id: userDoc.id,
        displayName: data['displayName'] ?? 'N/A',
        frontIdImage: data['frontIdImage'] ?? '',
        backIdImage: data['backIdImage'] ?? '',
        selfieImage: data['selfieImage'] ?? '',
        userType: data['userType'] ?? '',
        data: data,
      ));
    }

    return verificationRequests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFDB),
      appBar: AppBar(
        title: const Text('User Verification Requests'),
      ),
      body: FutureBuilder<List<VerificationRequest>>(
        future: fetchVerificationRequests(),
        builder: (BuildContext context,
            AsyncSnapshot<List<VerificationRequest>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          final verificationDocs = snapshot.data!;

          if (verificationDocs.isEmpty) {
            return Center(child: Text('No User Verifications for now'));
          }

          return ListView.builder(
            itemCount: verificationDocs.length,
            itemBuilder: (context, index) {
              final verificationRequest = verificationDocs[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.only(
                  top: 5,
                  left: 10,
                  right: 10,
                ),
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.black,
                      size: 50,
                    ),
                    title: Text(
                      verificationRequest.displayName,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(verificationRequest.userType),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminVerificationDetailScreen(
                              verificationRequest: verificationRequest),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VerificationRequest {
  final String id;
  final String displayName;
  final String frontIdImage;
  final String backIdImage;
  final String selfieImage;
  final String userType;
  final Map<String, dynamic> data;

  VerificationRequest({
    required this.id,
    required this.displayName,
    required this.frontIdImage,
    required this.backIdImage,
    required this.selfieImage,
    required this.userType,
    required this.data,
  });
}
