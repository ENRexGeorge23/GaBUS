import 'dart:convert';

String? validateEmailOrUsername(String? value) {
  // Check if value is a valid email or username
  final emailRegex = RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$');
  final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,16}$');
  if (!emailRegex.hasMatch(value!) && !usernameRegex.hasMatch(value)) {
    return 'Please enter a valid email or username';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required.';
  } else if (value.length < 6) {
    return 'Password must be at least 6 characters long.';
  }
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Username is required';
  }
  return null;
}
