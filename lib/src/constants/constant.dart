const String phonePrefix = "+261"; //TODO: change it test : +261 / prod : +33
String get logTrace => '[LOG_TRACE] ' + StackTrace.current.toString().split("\n").toList()[1].split("      ").last;
