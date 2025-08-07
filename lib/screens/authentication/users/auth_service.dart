import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/book_transaction.dart';
import '../../../models/user_transactions.dart';
import '../../../models/get_transactions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> registerUser(
    String email,
    String password,
    String username,
    String displayName,
    String phoneNumber,
    String birthdate,
    String sex,
    String address,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.sendEmailVerification();

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'username': username,
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'birthdate': birthdate,
        'sex': sex,
        'address': address,
      });

      User? user = userCredential.user;
      if (user != null) {
        user.updateDisplayName(displayName);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //email verification
  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      user = _auth.currentUser;
      return user!.emailVerified;
    }
    return false;
  }

  Future<double> getUserBalance() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference walletRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .doc('wallet');
        DocumentSnapshot walletDoc = await walletRef.get();
        if (walletDoc.exists) {
          Map<String, dynamic> walletData =
              walletDoc.data() as Map<String, dynamic>;
          double balance = walletData['balance']?.toDouble() ?? 0.0;
          return balance;
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    } catch (e) {
      print("Error getting user balance: $e");
      return 0.0;
    }
  }

  Future<UserTransaction?> addAmountToWallet(double amount) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference walletRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .doc('wallet');
        // Save the current timestamp
        DateTime now = DateTime.now();
        // Update the balance and transaction history in Firestore
        walletRef.set({
          'balance': FieldValue.increment(amount),
          'transactions': FieldValue.arrayUnion([
            {'amount': amount, 'timestamp': now}
          ])
        }, SetOptions(merge: true));
        // Return the transaction details
        return UserTransaction(amount: amount, timestamp: now);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  //to get added amount
  Future<List<UserTransaction>?> getTransactions() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .orderBy('timestamp', descending: true)
            .get();

        return querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return UserTransaction(
            amount: data['amount'].toDouble(),
            timestamp: data['timestamp'].toDate(),
          );
        }).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Stream<List<UserTransaction>> transactionsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wallet')
          .doc('wallet')
          .snapshots()
          .map((snapshot) {
        List<dynamic>? transactionsList = snapshot.data()?['transactions'];

        if (transactionsList != null) {
          return transactionsList.map((transactionData) {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(transactionData);
            return UserTransaction(
              amount: data['amount'].toDouble(),
              timestamp: data['timestamp'].toDate(),
            );
          }).toList();
        } else {
          return [];
        }
      });
    }
    return Stream<List<UserTransaction>>.value([]);
  }

  Stream<List<BookTransaction>> bookTransactionsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .snapshots()
          .map((snapshot) {
        List<BookTransaction> bookTransactions = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return BookTransaction(
            date: data['date'].toDate(),
            fare: data['fare'],
          );
        }).toList();
        return bookTransactions;
      });
    } else {
      return Stream<List<BookTransaction>>.value([]);
    }
  }

  Future<double> getBalance() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wallet')
          .doc('wallet')
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        return data?['balance'] ?? 0;
      }
    }
    return 0;
  }

  Future<void> deductAmountFromWallet(double amount) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference walletRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallet')
            .doc('wallet');
        walletRef.set({'balance': FieldValue.increment(-amount)},
            SetOptions(merge: true));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<List<GetTransaction>> getTransactionsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        List<GetTransaction> getTransactions = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          List<String> seatNum = List<String>.from(data['seatNum']);
          return GetTransaction(
            receiptId: data['receiptId'],
            date: (data['date'] as Timestamp).toDate(),
            fare: data['fare'],
            origin: data['origin'],
            destination: data['destination'],
            seatNum: seatNum,
            travelDate: data['travelDate'],
            terminal: data['terminal'],
            busNum: data['busNum'],
            plateNum: data['plateNum'],
          );
        }).toList();
        return getTransactions;
      });
    } else {
      return Stream<List<GetTransaction>>.value([]);
    }
  }
}
