/*
const String phonePrefix = "+261"; //TODO: change it test : +261 / prod : +33
*/

import 'package:intl_phone_number_input/intl_phone_number_input.dart';

final PhoneNumber phoneInitialCountryCode =
    PhoneNumber(isoCode: 'MG'); //TODO: Change this to FR in PROD
String get logTrace =>
    '[LOG_TRACE] ' +
    StackTrace.current.toString().split("\n").toList()[1].split("      ").last;
const QR_CODE_URL = "https://advisor.voirlemenu.fr";
const GOOGLE_API_KEY = "AIzaSyCL8_ZHnuPxDiElzyy4CCZEbJBv4ankXVc";
const stripePublishableKey =
    'pk_test_51HVB0bBBj0M16v6H7XMi6OeecfyebnUynW3gQ4N6DhPQ5ynDZOEfoLPmZh8RSgTf1XoA7VnsFGEooySSfuhdHYWu00YJQCvxbS';
