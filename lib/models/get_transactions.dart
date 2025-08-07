class GetTransaction {
  final String receiptId;
  final DateTime date;
  final String fare;
  final String origin;
  final String destination;
  final List<String> seatNum;
  final String travelDate;
  final String terminal;
  final String plateNum;
  final String busNum;

  GetTransaction({
    required this.receiptId,
    required this.date,
    required this.fare,
    required this.origin,
    required this.destination,
    required this.seatNum,
    required this.travelDate,
    required this.terminal,
    required this.plateNum,
    required this.busNum,
  });
}
