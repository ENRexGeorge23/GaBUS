import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/bus/bus_screens/bus_home_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/selected_seat_provider.dart';
import '../bus_providers/bus_provider.dart';
import '../bus_providers/passenger_details_provider.dart';
import './map_picker_bus_screen.dart';
import '../../widgets/gradient_scaffold.dart';

class BusFormScreen extends StatefulWidget {
  const BusFormScreen({Key? key}) : super(key: key);
  static const routeName = '/bus-forms';

  @override
  State<BusFormScreen> createState() => _BusFormScreenState();
}

class _BusFormScreenState extends State<BusFormScreen>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController walkInName = TextEditingController();
  final TextEditingController walkInNum = TextEditingController();
  String? passengerType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ;

    // start the transaction timer
    // _transactionTimer = Timer(Duration(minutes: 1), _onTransactionTimeout);
  }

  List<String> passengerTypes = ['Regular', 'Student', 'Senior Citizen', 'PWD'];

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a Name';
    }

    return null;
  }

  String? _validateNum(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a Number';
    }
    final numValue = int.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  Future<void> _proceed() async {
    // _transactionTimer?.cancel();
    if (!_formKey.currentState!.validate() || passengerType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String passengerTypeField = '';
    switch (passengerType) {
      case 'Regular':
        passengerTypeField = 'isRegular';
        break;
      case 'Student':
        passengerTypeField = 'isStudent';
        break;
      case 'PWD':
        passengerTypeField = 'isPWD';
        break;
      case 'Senior Citizen':
        passengerTypeField = 'isSenior';
        break;
    }

    Provider.of<PassengerDetailsProvider>(context, listen: false)
        .setPassengerDetails(
      documentId: walkInName.text,
      contactNum: walkInNum.text,
      passengerTypeField: passengerTypeField,
      passengerTypeValue: true,
    );
    Navigator.of(context).pushNamed(MapPickerBusScreen.routeName);
  }

  void _resetTimer() {
    // Cancel the existing timer
    // _transactionTimer?.cancel();

    // Start a new timer
    // _transactionTimer = Timer(Duration(seconds: 30), _onTransactionTimeout);
  }

  @override
  void dispose() {
    super.dispose();

    walkInName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(title: const Text('Walk In Forms')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondary,
        ),
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: walkInName,
                decoration: const InputDecoration(labelText: 'Passengers Name'),
                validator: _validateName,
                onChanged: (value) {
                  _resetTimer();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: walkInNum,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: _validateNum,
                onChanged: (value) {
                  _resetTimer();
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: passengerType,
                decoration: const InputDecoration(labelText: 'Passenger Type'),
                items: passengerTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    passengerType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a passenger type';
                  }
                  return null; // Return null to indicate validation passed
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20), // Set the desired radius here
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                  child: Text(
                    "Proceed",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
