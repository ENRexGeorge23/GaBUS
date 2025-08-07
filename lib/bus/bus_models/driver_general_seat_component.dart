import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../bus/bus_providers/bus_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';

import '../../main.dart';

class DriverGeneralSeatComponent extends StatefulWidget {
  static void clearSelectedStatus() {
    _DriverGeneralSeatComponentState.clearSelectedStatus();
  }

  final String? title;
  final double boxHeight;
  final double boxWidth;
  final double marginTop;
  final String seatKey;
  final Function(String, bool, String) onSelected;
  final Color boxColor;
  final bool isBooked;
  final String status;
  final VoidCallback onClearSelectedStatus;

  const DriverGeneralSeatComponent({
    Key? key,
    this.title,
    this.boxHeight = 0,
    this.boxWidth = 0,
    this.marginTop = 0,
    required this.onSelected,
    required this.seatKey,
    this.boxColor = Colors.yellow,
    required this.isBooked,
    required this.status,
    required this.onClearSelectedStatus, // Add this line
  }) : super(key: key);

  @override
  State<DriverGeneralSeatComponent> createState() =>
      _DriverGeneralSeatComponentState();
}

class _DriverGeneralSeatComponentState extends State<DriverGeneralSeatComponent>
    with WidgetsBindingObserver, RouteAware {
  Timer? _availabilityTimer;
  String _lastSeatStatus = "";
  bool _isSelected = false;
  late String _seatStatus;
  static String? _selectedStatus;
  String _selectedBy = "";
  late StreamSubscription _streamSubscription;
  StreamSubscription? _seatStatusSubscription;
  StreamSubscription? _seatSensorSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  static void clearSelectedStatus() {
    _selectedStatus = null;
  }

  Timer? getAvailabilityTimer(_DriverGeneralSeatComponentState state) {
    return state._availabilityTimer;
  }

  @override
  void initState() {
    super.initState();
    _seatStatus = widget.status;
    _isSelected = false; // Initialize the isSelected state
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initSeatStatusChanges(context));
  }

  @override
  void didPop() {
    _updateSeatSelection(false, "");
  }

  void _updateSeatSelection(bool isSelected, String selectedBy) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    Bus? bus = busProvider.currentBus;
    DateTime dateTime = busProvider.dateTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference
        .child(
            "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/${widget.seatKey}")
        .update({"selectedSeat": isSelected, "selectedBy": selectedBy});
  }

  void _initSeatStatusChanges(BuildContext context) {
    _subscribeToSeatStatusChanges(context);
  }

  void _subscribeToSeatStatusChanges(BuildContext context) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    Bus? bus = busProvider.currentBus;

    // Get the date and time from busProvider
    DateTime dateTime = busProvider.dateTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    _seatStatusSubscription = databaseReference
        .child(
            "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/${widget.seatKey}")
        .onValue
        .listen((event) {
      var snapshotValue = event.snapshot.value as Map<dynamic, dynamic>;
      _seatStatus = snapshotValue["status"] ?? "available";
      _isSelected = snapshotValue["selectedSeat"] ?? false;
      _selectedBy = snapshotValue["selectedBy"] ?? ""; // Add this line
      if (mounted) {
        setState(() {});
      }
    });

    _seatSensorSubscription = databaseReference
        .child(
            "SeatSensor/buses/${bus?.busNumber}/$formattedDate/$formattedTime/${widget.seatKey}/distanceCM")
        .onValue
        .listen((event) {
      num? distanceNullable = event.snapshot.value as num?;
      double distance = distanceNullable?.toDouble() ?? 0.0;
      if (distance > 1 && _seatStatus == "reserved") {
        _seatStatus = "occupied";
        databaseReference
            .child(
                "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/${widget.seatKey}")
            .update({"status": _seatStatus});
      } else if (distance <= 0 && _seatStatus == "occupied") {
        _seatStatus = "reserved";
        databaseReference
            .child(
                "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/${widget.seatKey}")
            .update({"status": _seatStatus});
      }

      if (_lastSeatStatus == "occupied" &&
          _seatStatus == "reserved" &&
          distance <= 0) {
        _handleAvailabilityTimer();
      }

      _lastSeatStatus = _seatStatus;

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handleAvailabilityTimer() {
    final busPlateNumber = Provider.of<BusProvider>(context, listen: false);
    Bus? bus = busPlateNumber.currentBus;

    DateTime dateTime = busPlateNumber.dateTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    _availabilityTimer?.cancel(); // Cancel any existing timer
    _availabilityTimer = Timer(Duration(minutes: 1), () {
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
      databaseReference
          .child(
              "SeatSensor/buses/${bus?.busNumber}/$formattedDate/$formattedTime/${widget.seatKey}/distanceCM")
          .once()
          .then((snapshot) {
        num? distanceNullable = snapshot.snapshot.value as num?;
        double distance = distanceNullable?.toDouble() ?? 0.0;
        if (distance <= 0 && _seatStatus == "reserved") {
          _seatStatus = "available";
          databaseReference
              .child(
                  "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/${widget.seatKey}")
              .update({"status": _seatStatus, "isBooked": false});
        }
      });
    });
  }

  void _updateSeatData(String seatKey, bool isSelected) {
    final busPlateNumber = Provider.of<BusProvider>(context, listen: false);
    Bus? bus = busPlateNumber.currentBus;

    DateTime dateTime = busPlateNumber.dateTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    String? userId =
        FirebaseAuth.instance.currentUser?.uid; // Get current user ID
    if (isSelected) {
      databaseReference
          .child(
              "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/$seatKey")
          .update({
        "selectedSeat": true,
        "selectedBy": userId,
      });
    } else {
      databaseReference
          .child(
              "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/$seatKey")
          .update({
        "selectedSeat": false,
        "selectedBy": "",
      });
    }
  }

  @override
  void dispose() {
    widget.onClearSelectedStatus(); // Add this line
    _seatStatusSubscription?.cancel();
    _seatSensorSubscription?.cancel();
    _availabilityTimer?.cancel();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_seatStatus == "reserved" || _seatStatus == "available") {
          // Check if the seat is not selected by another user
          if (_selectedBy.isEmpty ||
              _selectedBy == FirebaseAuth.instance.currentUser?.uid) {
            if (_selectedStatus == null || _selectedStatus == _seatStatus) {
              setState(() {
                _isSelected = !_isSelected;
                _selectedStatus = _isSelected ? _seatStatus : null;
              });
              widget.onSelected(widget.seatKey, _isSelected, _seatStatus);
              _updateSeatData(widget.seatKey, _isSelected); // Modify this line
            } else {
              DriverGeneralSeatComponent.clearSelectedStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You can only select one type of seat status."),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("This seat is already selected by another user."),
              ),
            );
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: widget.marginTop),
        height: widget.boxHeight,
        width: widget.boxWidth,
        decoration: BoxDecoration(
          color: _getSeatColor(),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(child: Text("${widget.title}")),
      ),
    );
  }

  Color _getSeatColor() {
    final userId =
        FirebaseAuth.instance.currentUser?.uid; // Get current user ID
    if (_isSelected) {
      return _selectedBy == userId ? Colors.white : Colors.lightBlue;
    } else {
      switch (_seatStatus) {
        case "available":
          return Colors.green; // the seat is available
        case "reserved":
          return widget.boxColor; // the seat is reserved
        case "occupied":
          return Colors.red; // the seat is occupied
        default:
          return Colors.grey; // default color
      }
    }
  }
}
