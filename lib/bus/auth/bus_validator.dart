String? validateBusNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the bus number';
  }
  return null;
}

String? validateBusPlateNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the bus plate number';
  }
  return null;
}

String? validateNumberOfSeats(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the number of seats';
  }
  final parsedValue = int.tryParse(value);
  if (parsedValue == null || parsedValue <= 0) {
    return 'Please enter a valid number of seats';
  }
  return null;
}

String? validateRouteOne(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the first route';
  }
  return null;
}

String? validateRouteTwo(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the second route';
  }
  return null;
}

String? validateTimeOne(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the first schedule';
  }
  return null;
}

String? validateTimeTwo(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the second schedule';
  }
  return null;
}
