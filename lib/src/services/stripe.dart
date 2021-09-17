import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:stripe_payment/stripe_payment.dart';
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

  static init() {
    // Initialization logics
    if (!initialized) {
      StripePayment.setOptions(
        StripeOptions(
          publishableKey: 'pk_test_51HVB0bBBj0M16v6H7XMi6OeecfyebnUynW3gQ4N6DhPQ5ynDZOEfoLPmZh8RSgTf1XoA7VnsFGEooySSfuhdHYWu00YJQCvxbS',
          merchantId: 'Test',
          androidPayMode: 'test',
        ),
      );
      initialized = true;
    }
  }

  static Future<StripeTransactionResponse> payViaExistingCard({
    String amount,
    String currency,
    PaymentCard card,
  }) async {
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: CreditCard(
            number: card.cardNumber.toString(),
            cvc: card.securityCode.toString(),
            expMonth: int.parse(card.expiryMonth),
            expYear: int.parse(card.expiryYear),
          ),
        ),
      );
      var paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );
      var response = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id,
        ),
      );
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
          message: 'Transaction successful',
          success: true,
          paymentIntentId: response.paymentIntentId,
        );
      } else {
        return new StripeTransactionResponse(
          message: 'Transaction failed',
          success: false,
        );
      }
    } on PlatformException catch (err) {
      return _getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
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

  static Future<Map<String, dynamic>> _createPaymentIntent({String amount, String currency}) async {
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
