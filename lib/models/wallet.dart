class Wallet {
  double _balance = 0;

  double get balance => _balance;

  void addAmount(double amount) {
    _balance += amount;
  }

  void subtractAmount(double amount) {
    _balance -= amount;
  }
}
