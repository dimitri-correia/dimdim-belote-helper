enum Position {
  nord,
  est,
  sud,
  ouest,
}

extension PositionExtension on Position {
  String get nom {
    switch (this) {
      case Position.nord:
        return 'Nord';
      case Position.est:
        return 'Est';
      case Position.sud:
        return 'Sud';
      case Position.ouest:
        return 'Ouest';
    }
  }

  Position get suivant {
    switch (this) {
      case Position.nord:
        return Position.est;
      case Position.est:
        return Position.sud;
      case Position.sud:
        return Position.ouest;
      case Position.ouest:
        return Position.nord;
    }
  }

  Position get precedent {
    switch (this) {
      case Position.nord:
        return Position.ouest;
      case Position.est:
        return Position.nord;
      case Position.sud:
        return Position.est;
      case Position.ouest:
        return Position.sud;
    }
  }
}
