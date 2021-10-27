import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:http/http.dart' as http;

class StripeTransactionResponse {
  String message;
  bool success;
  String paymentIntentId;

  StripeTransactionResponse({
    this.message,
    this.success,
    this.paymentIntentId,
  });
}

class StripeService {
  static String _apiBase = 'https://api.stripe.com/v1';
  static String _paymentApiUrl = '$_apiBase/payment_intents';
  static String _secret = 'sk_test_51HVB0bBBj0M16v6HbP4C8zdA8nHnbYL6A2Tfp1rv0XQlB7WEShTgjNanGRhJmIZSjj9GI2hpQDDEWsNa8VyNzx6900Oboe33bG';
  static String get privateKey => _secret;
  static Map<String, String> _headers = {
    'Authorization': 'Bearer $_secret',
    'Content-type': 'application/x-www-form-urlencoded',
  };

  static bool initialized = false;

  static init() async {
    // Initialization logics
    if (!initialized) {
      Stripe.publishableKey = stripePublishableKey;
      Stripe.merchantIdentifier = 'Test';
      Stripe.urlScheme = 'flutterstripe';
      await Stripe.instance.applySettings();
      initialized = true;
    }
  }

  static Future<StripeTransactionResponse> payViaExistingCard({
    @required Restaurant restaurant,
    String amount,
    String currency,
    PaymentCard card,
  }) async {
    try {
      await Stripe.instance.dangerouslyUpdateCardDetails(
        CardDetails(
          number: card.cardNumber,
          expirationMonth: int.parse(card.expiryMonth),
          expirationYear: int.parse(card.expiryYear),
          cvc: card.securityCode,
        ),
      );
      var paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
        customerStripeKey: restaurant.customerStripeKey,
      );
      var response = await Stripe.instance.confirmPayment(
        paymentIntent['client_secret'],
        PaymentMethodParams.card(
          setupFutureUsage: PaymentIntentsFutureUsage.OnSession,
          billingDetails: BillingDetails(
            name: card.owner,
          ),
        ),
      );

      if (response.status == PaymentIntentsStatus.Succeeded) {
        return StripeTransactionResponse(
          message: 'Transaction successful',
          success: true,
          paymentIntentId: response.paymentMethodId,
        );
      } else {
        return StripeTransactionResponse(
          message: 'Transaction failed',
          success: false,
        );
      }
    } on PlatformException catch (err) {
      return _getPlatformExceptionErrorResult(err);
    } catch (err) {
      return StripeTransactionResponse(
        message: 'Transaction failed: ${err.toString()}',
        success: false,
      );
    }
  }

  static _getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(
      message: message,
      success: false,
    );
  }

  static Future<Map<String, dynamic>> _createPaymentIntent({
    String amount,
    String currency,
    String customerStripeKey,
  }) async {
    ///if customerStripeKey is not null, the payment is directly at the restaurant (compte restaurateur)
    if (customerStripeKey != null) {
      _headers['Authorization'] = 'Bearer $customerStripeKey';
    }
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
        Uri.parse(_paymentApiUrl),
        body: body,
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error charging user');
      print(error.toString());
    }
    return null;
  }
}
