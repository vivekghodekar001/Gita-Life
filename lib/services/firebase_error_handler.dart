/// Maps common Firebase/Firestore error codes to user-friendly messages.
String getFirebaseErrorMessage(dynamic error) {
  final errorString = error.toString().toLowerCase();

  // Firebase Auth errors
  if (errorString.contains('user-not-found')) {
    return 'No account found with this email. Please register first.';
  }
  if (errorString.contains('wrong-password') || errorString.contains('invalid-credential')) {
    return 'Incorrect password. Please try again.';
  }
  if (errorString.contains('email-already-in-use')) {
    return 'An account with this email already exists.';
  }
  if (errorString.contains('weak-password')) {
    return 'Password is too weak. Use at least 6 characters.';
  }
  if (errorString.contains('invalid-email')) {
    return 'Please enter a valid email address.';
  }
  if (errorString.contains('too-many-requests')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (errorString.contains('user-disabled')) {
    return 'This account has been disabled. Contact your administrator.';
  }
  if (errorString.contains('network-request-failed') || errorString.contains('unavailable')) {
    return 'Network error. Please check your internet connection.';
  }

  // Firestore errors
  if (errorString.contains('permission-denied')) {
    return 'You don\'t have permission to perform this action.';
  }
  if (errorString.contains('not-found')) {
    return 'The requested data was not found.';
  }
  if (errorString.contains('already-exists')) {
    return 'This record already exists.';
  }
  if (errorString.contains('resource-exhausted')) {
    return 'Service temporarily unavailable. Please try again later.';
  }
  if (errorString.contains('deadline-exceeded')) {
    return 'Request timed out. Please try again.';
  }

  // Firebase Storage errors
  if (errorString.contains('object-not-found')) {
    return 'The requested file was not found.';
  }
  if (errorString.contains('unauthorized')) {
    return 'You are not authorized to access this file.';
  }
  if (errorString.contains('quota-exceeded')) {
    return 'Storage quota exceeded. Contact your administrator.';
  }

  // Generic fallback
  return 'Something went wrong. Please try again.';
}
