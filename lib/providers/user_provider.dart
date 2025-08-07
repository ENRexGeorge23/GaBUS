import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? userData;
  late StreamSubscription<DocumentSnapshot> _subscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void fetchUserDataRealTime(String userId) {
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        userData = doc.data() as Map<String, dynamic>?;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
