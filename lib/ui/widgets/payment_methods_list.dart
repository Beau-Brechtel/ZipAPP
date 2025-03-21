import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zipapp/services/payment.dart';
import 'package:zipapp/utils.dart';


/*
  * A widget that displays a list of payment methods
  * @param context The context of the widget
  * @param uniqueKey The unique key of the widget
  * @param forceUpdate Whether to force update the payment methods
  * @param togglePaymentInfo Whether to toggle the payment info 
  * screen (if false, the payment info screen will not display when a payment method is clicked)
  * @param refreshKey The refresh key
  * @return Widget The widget
  */
class PaymentMethodListWidget {
  static Widget build({
    required BuildContext context,
    required listItemWidgetBuilder, // This allows you to dynamically pass in different list item widgets
    required UniqueKey uniqueKey,
    bool forceUpdate = false,
    bool togglePaymentInfo = true,
    refreshKey,
  }) {

    return FutureBuilder<List<Map<String, dynamic>?>>(
      key: uniqueKey,
      future: Payment.fetchPaymentMethodsIfNeeded(forceUpdate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // Create a list of PaymentListItem widgets
          List<Widget> listItems = snapshot.data!
              .map<Widget>((paymentMethod) {
                return listItemWidgetBuilder.build(
                    context: context,
                    cardType: capitalizeFirstLetter(paymentMethod?['brand']),
                    lastFourDigits: paymentMethod?['last4'] ?? '0000',
                    paymentMethodId: paymentMethod?['id'],
                    togglePaymentInfo: togglePaymentInfo,
                    refreshKey: refreshKey,
                  );
              }).toList();
              
          // Add spacing after each item
          List<Widget> spacedListItems = [];
          for (var i = 0; i < listItems.length; i++) {
            spacedListItems.add(listItems[i]);
            if (i < listItems.length - 1) {
              // Add spacing after each item, except for the last one
              spacedListItems.add(const SizedBox(height: 0));
            }
          }
          return Column(
            children: spacedListItems,
          );
        } else {
          return const Text('No data available');
        }
      },
    );
  }


}