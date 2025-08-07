import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/common/theme_helper.dart';

import '../auth/bus_validator.dart';
import '../bus_providers/bus_provider.dart';

enum BusRoutes {
  CSBTToBatoViaBarili,
  CSBTToBatoViaOslob,
  BatoToCSBTViaBarili,
  BatoToCSBTViaOslob,
}

class BusRegistrationScreen extends StatefulWidget {
  const BusRegistrationScreen({super.key});
  static const routeName = '/bus-registration';

  @override
  State<BusRegistrationScreen> createState() => _BusRegistrationScreenState();
}

class _BusRegistrationScreenState extends State<BusRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _busPlateNumberController =
      TextEditingController();
  final TextEditingController _numberOfSeatsController =
      TextEditingController();
  final TextEditingController _timeOneController = TextEditingController();
  final TextEditingController _timeTwoController = TextEditingController();
  final TextEditingController _routeOneController = TextEditingController();
  final TextEditingController _routeTwoController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedBusRouteOne = '';
  String _selectedBusRouteTwo = '';
  Future<void> _registerBus(BusProvider busProvider) async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: '${_busNumberController.text}@bus.com',
          password: _busPlateNumberController.text,
        );
        final user = userCredential.user;
        if (user != null) {
          final bus = Bus(
            busNumber: _busNumberController.text,
            busPlateNumber: _busPlateNumberController.text,
            numberOfSeats: int.parse(_numberOfSeatsController.text),
            timeOne: _timeOneController.text,
            timeTwo: _timeTwoController.text,
            routeOne: _selectedBusRouteOne.toString(),
            routeTwo: _selectedBusRouteTwo.toString(),
          );
          await busProvider.addBus(bus, user.uid);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bus successfully registered!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to register bus.'),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register bus: ${e.message}'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register bus: ${e.toString()}'),
          ),
        );
      }
    }
  }

  String _getFormattedRouteName(BusRoutes busRoute) {
    switch (busRoute) {
      case BusRoutes.CSBTToBatoViaBarili:
        return 'CSBT to Bato (via Barili)';
      case BusRoutes.CSBTToBatoViaOslob:
        return 'CSBT to Bato (via Oslob)';
      case BusRoutes.BatoToCSBTViaBarili:
        return 'Bato to CSBT (via Barili)';
      case BusRoutes.BatoToCSBTViaOslob:
        return 'Bato to CSBT (via Oslob)';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _busNumberController.dispose();
    _busPlateNumberController.dispose();
    _numberOfSeatsController.dispose();
    _timeOneController.dispose();
    _timeTwoController.dispose();
    _routeOneController.dispose();
    _routeTwoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = Provider.of<BusProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: const Text('Bus Registration'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: Column(children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Register a Bus',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: _busNumberController,
                            decoration: ThemeHelper().textInputDecoration(
                                'Bus Number', 'Enter the bus number'),
                            validator: validateBusNumber,
                            onSaved: (value) {
                              _busNumberController.text = value.toString();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: _busPlateNumberController,
                            decoration: ThemeHelper().textInputDecoration(
                                'Bus Plate Number',
                                'Enter the Bus Plate Number'),
                            validator: validateBusPlateNumber,
                            onSaved: (value) {
                              _busPlateNumberController.text = value.toString();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          child: DropdownButtonFormField<String>(
                            decoration: ThemeHelper().textInputDecoration(
                              'First Route',
                              'Enter the bus first route',
                            ),
                            items: BusRoutes.values.map((busRouteOne) {
                              String formattedRouteName =
                                  _getFormattedRouteName(busRouteOne);
                              return DropdownMenuItem<String>(
                                value: formattedRouteName,
                                child: Text(formattedRouteName),
                              );
                            }).toList(),
                            onChanged: (String? selectedRoute) {
                              setState(() {
                                _selectedBusRouteOne = selectedRoute!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select the bus first route';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          child: DropdownButtonFormField<String>(
                            decoration: ThemeHelper().textInputDecoration(
                              'Second Route',
                              'Enter the bus second route',
                            ),
                            items: BusRoutes.values.map((busRouteTwo) {
                              String formattedRouteName =
                                  _getFormattedRouteName(busRouteTwo);
                              return DropdownMenuItem<String>(
                                value: formattedRouteName,
                                child: Text(formattedRouteName),
                              );
                            }).toList(),
                            onChanged: (String? selectedRoute) {
                              setState(() {
                                _selectedBusRouteTwo = selectedRoute!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select the bus second route';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  _timeOneController.text =
                                      pickedTime.format(context);
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _timeOneController,
                                decoration: ThemeHelper().textInputDecoration(
                                  'First schedule',
                                  'Enter the bus first schedule',
                                ),
                                validator: validateTimeOne,
                                onSaved: (value) {
                                  _timeOneController.text = value.toString();
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  _timeTwoController.text =
                                      pickedTime.format(context);
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _timeTwoController,
                                decoration: ThemeHelper().textInputDecoration(
                                  'Second schedule',
                                  'Enter the bus second schedule',
                                ),
                                validator: validateTimeOne,
                                onSaved: (value) {
                                  _timeTwoController.text = value.toString();
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: _numberOfSeatsController,
                            decoration: ThemeHelper().textInputDecoration(
                                'Number of Seats',
                                'Enter the bus number of seats'),
                            validator: validateNumberOfSeats,
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              _numberOfSeatsController.text = value.toString();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            await _registerBus(busProvider);
                          },
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
