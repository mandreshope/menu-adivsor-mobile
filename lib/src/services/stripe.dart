import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  bool success;

  StripeTransactionResponse({
    this.message,
    this.success,
  });
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String secret =
      'sk_test_51HVB0bBBj0M16v6HbP4C8zdA8nHnbYL6A2Tfp1rv0XQlB7WEShTgjNanGRhJmIZSjj9GI2hpQDDEWsNa8VyNzx6900Oboe33bG';

  static init() {
    // Initialization logics
    StripePayment.setOptions(
      StripeOptions(
        publishableKey:
            'pk_test_51HVB0bBBj0M16v6H7XMi6OeecfyebnUynW3gQ4N6DhPQ5ynDZOEfoLPmZh8RSgTf1XoA7VnsFGEooySSfuhdHYWu00YJQCvxbS',
        merchantId: 'Test',
        androidPayMode: 'test',
      ),
    );
  }

  static payViaExistingCard({String amount, String currency, card}) {}

  static payWithNewCard({
    String amou,
    String currency,
  }) {}
}
