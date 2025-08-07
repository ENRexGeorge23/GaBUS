import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:connectivity/connectivity.dart';

import '../models/book_transaction.dart';
import '../models/user_transactions.dart';

import '../widgets/app_drawer.dart';
import '../widgets/gradient_scaffold.dart';
import '../common/size_config.dart';
import 'authentication/users/auth_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  static const routeName = '/user-wallet';

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  double _amount = 0;
  double _balance = 0;
  TextEditingController _amountController = TextEditingController();
  bool _isAccordionExpanded = true;
  List<UserTransaction> _transactions = [];
  TextEditingController? _passwordController;

  late ConnectivityResult _connectivityResult;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '');
    _loadBalance();
    _loadTransactions();

    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("No Internet Connection"),
                content: const Text(
                    "Please check your internet connection and try again."),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
  }

  void _loadBalance() async {
    double balance = await _authService.getBalance();
    setState(() {
      _balance = balance;
    });
  }

  Future<void> _loadTransactions() async {
    List<UserTransaction> transactions =
        await _authService.getTransactions() ?? [];
    setState(() {
      _transactions = transactions;
    });
  }

  void _showConfirmationDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Identity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Please verify your identity by inputing your current password before you can cash in \n ₱ ${double.parse(_amountController.text).toStringAsFixed(2)} to your wallet'),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Your Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                String password = controller.text;
                User? currentUser = FirebaseAuth.instance.currentUser;

                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please enter your password to save changes.'),
                    ),
                  );
                  return; // Return early if password is empty
                }

                if (currentUser != null) {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: currentUser.email!, password: password);

                  try {
                    await currentUser.reauthenticateWithCredential(credential);
                    double amount =
                        double.tryParse(_amountController.text) ?? 0;
                    UserTransaction? error =
                        await _authService.addAmountToWallet(amount);
                    if (error != null) {
                      double balance = await _authService.getBalance();
                      setState(() {
                        _amount = 0;
                        _balance = balance;
                        _transactions.add(
                          UserTransaction(
                              amount: amount, timestamp: DateTime.now()),
                        );
                        _amountController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Amount added successfully')),
                      );
                      Navigator.pop(context); // Dismiss the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => this.widget),
                      ); // Reload the screen
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error as String)),
                      );
                    }
                  } catch (e) {
                    // Show error message if reauthentication fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect password')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionRow(UserTransaction transaction) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              transaction.amount != null
                  ? Text(
                      '+ ₱ ${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox.shrink(),
              transaction.timestamp != null
                  ? Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(
                            'Cash In',
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 3.7,
                                color: Colors.black87,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy hh:mm a')
                              .format(transaction.timestamp),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: 10,
                          ),
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookTransactionRow(BookTransaction bookTransaction) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              bookTransaction.fare != null
                  ? Text(
                      '- ₱ ${bookTransaction.fare}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox.shrink(),
              bookTransaction.date != null
                  ? Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(
                            'Fare Fee',
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 3.7,
                                color: Colors.black87,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy hh:mm a')
                              .format(bookTransaction.date),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: 10,
                          ),
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  Stream<List<dynamic>> combinedTransactionsStream() {
    Stream<List<UserTransaction>> transactionsStream =
        _authService.transactionsStream();
    Stream<List<BookTransaction>> bookTransactionsStream =
        _authService.bookTransactionsStream();

    return Rx.combineLatest2<List<UserTransaction>, List<BookTransaction>,
        List<dynamic>>(
      transactionsStream,
      bookTransactionsStream,
      (List<UserTransaction> transactions,
          List<BookTransaction> bookTransactions) {
        List<dynamic> combined = List<dynamic>.from(transactions)
          ..addAll(bookTransactions);
        combined.sort((a, b) {
          DateTime dateA = (a is UserTransaction) ? a.timestamp : a.date;
          DateTime dateB = (b is UserTransaction) ? b.timestamp : b.date;
          return dateB.compareTo(dateA);
        });

        return combined;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GradientScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // removes the shadow
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(0, 115, 0, 0),
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                children: [
                                  Text(
                                    'Available GaBus Credits'.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: SizeConfig.safeBlockHorizontal *
                                          3, // adjust font size
                                    ),
                                  ),
                                  SizedBox(
                                      height: SizeConfig.safeBlockVertical *
                                          2), // adjust vertical spacing
                                  Text(
                                    '₱ ${NumberFormat('#,##0.00').format(_balance)}',
                                    style: TextStyle(
                                      fontSize: SizeConfig.safeBlockHorizontal *
                                          14.5, // adjust font size
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                      height: SizeConfig.safeBlockVertical *
                                          0.5), // adjust vertical spacing
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 60.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: ExpansionPanelList(
                                  elevation: 0,
                                  expansionCallback:
                                      (int index, bool isExpanded) {
                                    setState(() {
                                      _isAccordionExpanded = !isExpanded;
                                    });
                                  },
                                  children: [
                                    ExpansionPanel(
                                      canTapOnHeader: true,
                                      backgroundColor: const Color(0x00000000),
                                      headerBuilder: (BuildContext context,
                                          bool isExpanded) {
                                        return const ListTile(
                                          title: Text(
                                            'Add GaBus Credits',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 13),
                                          ),
                                          style: ListTileStyle.drawer,
                                        );
                                      },
                                      body: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.orange.shade50,
                                              Colors.orange.shade200,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        // margin: const EdgeInsets.all(15.0),
                                        margin: const EdgeInsets.fromLTRB(
                                            15.0, 0, 15.0, 15.0),
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 10),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Enter amount to cash in',
                                              ),
                                              style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12),
                                              validator: (val) {
                                                if (val!.isEmpty) {
                                                  return 'Please enter an amount';
                                                }
                                                double? amount =
                                                    double.tryParse(val);
                                                if (amount == null ||
                                                    amount < 100) {
                                                  return 'Amount must be at least 100';
                                                }

                                                return null;
                                              },
                                              controller: _amountController,
                                            ),
                                            SizedBox(
                                                height: SizeConfig
                                                        .safeBlockVertical *
                                                    2),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                textStyle: MaterialStateProperty
                                                    .all<TextStyle>(
                                                  const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  _showConfirmationDialog();
                                                }
                                              },
                                              child:
                                                  const Text('Add to Wallet'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      isExpanded: _isAccordionExpanded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: SizeConfig.safeBlockVertical * 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 0.65,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade50,
                      Colors.orange.shade200,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 15),
                      child: Text(
                        'Transaction History',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: StreamBuilder<List<dynamic>>(
                          stream: combinedTransactionsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<dynamic> combinedTransactions =
                                  snapshot.data!;
                              return Column(
                                children:
                                    combinedTransactions.map((transaction) {
                                  if (transaction is UserTransaction) {
                                    return _buildTransactionRow(transaction);
                                  } else if (transaction is BookTransaction) {
                                    return _buildBookTransactionRow(
                                        transaction);
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }).toList(),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Error loading transactions: ${snapshot.error}');
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
