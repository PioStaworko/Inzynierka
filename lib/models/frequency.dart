// Compatibility shim for Frequency (older code used Frequency enum)

enum Frequency { daily, weekly, monthly, yearly }

String frequencyToString(Frequency f) {
  switch (f) {
    case Frequency.daily:
      return 'daily';
    case Frequency.weekly:
      return 'weekly';
    case Frequency.monthly:
      return 'monthly';
    case Frequency.yearly:
      return 'yearly';
  }
}