import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../bus/bus_providers/bus_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../providers/selected_seat_provider.dart';
import '../screens/terminal_bus_list_screen.dart';

class GeneralSeatComponent extends StatefulWidget {
  final String? title;
  final double boxHeight;
  final double boxWidth;
  final double marginTop;
  final String seatKey;
  final void Function(String seatKey, bool isSelected, {String? seatTitle})
      onSelected;

  final Color boxColor;
  final bool isBooked;
  final String status;

  GeneralSeatComponent({
    Key? key,
    this.title,
    this.boxHeight = 0,
    this.boxWidth = 0,
    this.marginTop = 0,
    required this.onSelected,
    required this.seatKey,
    this.boxColor = Colors.green,
    required this.isBooked,
    required this.status,
  }) : super(key: key);

  @override
  State<GeneralSeatComponent> createState() => _GeneralSeatComponentState();

  /// Returns the status of the seat.
  String getSeatStatus(_GeneralSeatComponentState state) {
    return state._seatStatus;
  }

  /// Returns the availability timer of the seat.
  Timer? getAvailabilityTimer(_GeneralSeatComponentState state) {
    return state._availabilityTimer;
  }
}

class _GeneralSeatComponentState extends State<GeneralSeatComponent>
    with WidgetsBindingObserver, RouteAware {
  String _lastSeatStatus = "";
  Timer? _availabilityTimer;
  late StreamSubscription _streamSubscription;
  StreamSubscription? _seatStatusSubscription;
  StreamSubscription? _seatSensorSubscription;
  bool _isSelected = false;
  String _selectedBy = "";
  late String _seatStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void initState() {
    super.initState();
    _seatStatus = widget.status;
    _isSelected = false;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initSeatStatusChanges(context));
  }

  void _initSeatStatusChanges(BuildContext context) {
    _subscribeToSeatStatusChanges(context);
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

  @override
  void dispose() {
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
        if (!widget.isBooked) {
          final userId =
              FirebaseAuth.instance.currentUser?.uid; // Get current user ID

          // Allow deselect only if the seat is selected by the current user
          if (_isSelected && _selectedBy != userId) {
            return;
          }

          setState(() {
            _isSelected = !_isSelected;
          });

          // Update the isSelected state and selectedBy in Firebase
          final busProvider = Provider.of<BusProvider>(context, listen: false);
          Bus? bus = busProvider.currentBus;
          DateTime dateTime = busProvider.dateTime;
          String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          String formattedTime = DateFormat('HH:mm').format(dateTime);
          DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
          databaseReference
              .child(
                  "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/${widget.seatKey}")
              .update({
            "selectedSeat": _isSelected,
            "selectedBy": _isSelected
                ? userId
                : "" // Update the selectedBy field accordingly
          });

          widget.onSelected(widget.seatKey, _isSelected,
              seatTitle: widget.title);
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
          return widget.boxColor;
        case "reserved":
          return Colors.yellow;
        case "occupied":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
  }
}
