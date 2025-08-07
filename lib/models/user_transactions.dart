class UserTransaction {
  final double amount;
  final DateTime timestamp;

  UserTransaction({
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'timestamp': timestamp,
    };
  }
}
