import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabus_build/common/size_config.dart';
import 'package:photo_view/photo_view.dart';
import 'admin_verificationlist.dart';

class AdminVerificationDetailScreen extends StatefulWidget {
  static const routeName = '/admin-detailverification';

  final VerificationRequest verificationRequest;

  AdminVerificationDetailScreen({required this.verificationRequest});

  @override
  _AdminVerificationDetailScreenState createState() =>
      _AdminVerificationDetailScreenState();
}

class _AdminVerificationDetailScreenState
    extends State<AdminVerificationDetailScreen> {
  Future<void> approveUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.verificationRequest.id)
          .update({
        'isVerified': true,
        'userType': widget.verificationRequest.userType
      });

      await FirebaseFirestore.instance
          .collection('verificationRequest')
          .doc(widget.verificationRequest.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User approved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve user: ${e.toString()}')),
      );
    }
  }

  Future<void> rejectUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.verificationRequest.id)
          .update({'isDeclined': true});

      await FirebaseFirestore.instance
          .collection('verificationRequest')
          .doc(widget.verificationRequest.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User rejected successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject user: ${e.toString()}')),
      );
    }
  }

  void _viewImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Container(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
              enableRotation: false,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFDB),
      appBar: AppBar(title: Text('Verification Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Front ID Image:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                child: Image.network(widget.verificationRequest.frontIdImage),
                onTap: () =>
                    _viewImage(widget.verificationRequest.frontIdImage),
              ),
              Divider(
                thickness: 1,
                color: Colors.orange.shade400,
              ),
              SizedBox(height: 10),
              Text(
                'Back ID Image:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                child: Image.network(widget.verificationRequest.backIdImage),
                onTap: () => _viewImage(widget.verificationRequest.backIdImage),
              ),
              Divider(
                thickness: 1,
                color: Colors.orange.shade400,
              ),
              SizedBox(height: 10),
              Text(
                'Selfie Image:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                child: Image.network(widget.verificationRequest.selfieImage),
                onTap: () => _viewImage(widget.verificationRequest.selfieImage),
              ),
              Divider(
                thickness: 1,
                color: Colors.orange.shade400,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: approveUser,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                      child: Text(
                        "Accept",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            fontSize: SizeConfig.blockSizeHorizontal * 4.5),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Set the desired radius here
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: rejectUser,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                      child: Text(
                        "Reject",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            fontSize: SizeConfig.blockSizeHorizontal * 4.5),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Set the desired radius here
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
