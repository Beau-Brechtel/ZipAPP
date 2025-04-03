import 'package:flutter/material.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'driver_earnings_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverIncomeScreen extends StatefulWidget {
  const DriverIncomeScreen({super.key});

  @override
  State<DriverIncomeScreen> createState() => _DriverIncomeScreenState();
}

class _DriverIncomeScreenState extends State<DriverIncomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalEarnings = 0.0;
  String stripeAccountId = '';
  String stripeAccountStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    loadDriverEarnings().then((_) {
      fetchStripeAccountStatus();
    });
  }

  Future<void> loadDriverEarnings() async {
    String driverId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get the authenticated driver's ID

    try {
      DocumentSnapshot driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      if (driverDoc.exists) {
        setState(() {
          totalEarnings = driverDoc.get('totalEarnings') ?? 0.0;
          stripeAccountId = driverDoc.get('stripeAccountId') ?? ''; // Fetch Stripe account ID
        });
      }
    } catch (e) {
      print("Error fetching driver earnings: $e");
    }
  }

  Future<void> fetchStripeAccountStatus() async {
    if (stripeAccountId.isEmpty) {
      print('Stripe account not connected.');
      setState(() {
        stripeAccountStatus = 'Not Connected';
      });
      return;
    }

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('getStripeAccountStatus');
      final response = await callable.call({
        'stripeAccountId': stripeAccountId,
      });

      setState(() {
        stripeAccountStatus = response.data['status'] ?? 'Unknown';
      });
    } catch (e) {
      print('Error fetching Stripe account status: $e');
      setState(() {
        stripeAccountStatus = 'Error';
      });
    }
  }

  Future<void> setupBankAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not authenticated.');
        return;
      }

      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createDriverAccount');
      final response = await callable.call({
        'email': user.email, // Use the authenticated user's email
        'refreshUrl': 'https://your-app.com/onboarding-failed',
        'returnUrl': 'https://your-app.com/onboarding-success',
      });

      if (response.data['success']) {
        final onboardingUrl = response.data['url'];
        print('Onboarding URL: $onboardingUrl'); // Debugging
        if (await canLaunchUrl(Uri.parse(onboardingUrl))) {
          await launchUrl(Uri.parse(onboardingUrl)); // Open the Stripe onboarding URL
        } else {
          print('Could not launch onboarding URL.');
        }
      } else {
        print('Failed to create driver account.');
      }
    } catch (e) {
      print('Error setting up bank account: $e');
    }
  }

@override
Widget build(BuildContext context) {
  const TextStyle titleStyle = TextStyle(
    color: Colors.grey,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  const TextStyle valueStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
  );

  const TextStyle detailStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Earnings',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: <Widget>[
          const SizedBox(height: 16),
          _buildInfoSection(
            'April 1 - April 7',
            label: '\$${totalEarnings.toStringAsFixed(2)}',
            titleStyle: titleStyle,
            valueStyle: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold),
            showDetailButton: true,
          ),
          const Divider(),
          _buildInfoSection(
            'Stripe Account Status',
            label: stripeAccountStatus,
            titleStyle: titleStyle,
            valueStyle: valueStyle,
          ),
          const Divider(),
          _buildInfoSection(
            '',
            label: 'Online',
            value: '0 min',
            titleStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            valueStyle: valueStyle,
            rightAlignedValueStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            isValueRightAligned: true,
          ),
          const Divider(),
          _buildInfoSection(
            '',
            label: 'Trips Completed',
            value: '0',
            titleStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            valueStyle: valueStyle,
            rightAlignedValueStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            isValueRightAligned: true,
          ),
          const Divider(),
          // Conditionally render the button
          if (stripeAccountStatus != 'Connected') // Show button only if not connected
            ElevatedButton(
              onPressed: () {
                print('Button clicked'); // Debugging
                setupBankAccount();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, // Text color
                backgroundColor: ZipColors.zipYellow, // Background color
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Set Up Bank Account'),
            ),
        ],
      ),
    ),
  );
}
 
  Widget _buildInfoSection(
    String title, {
    String label = '',
    String value = '',
    bool showDetailButton = false,
    String detailText = '',
    TextStyle? detailTextStyle,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
    TextStyle? rightAlignedValueStyle,
    bool isValueRightAligned = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: valueStyle),
              Expanded(
                child: Text(
                  value,
                  style: isValueRightAligned
                      ? (rightAlignedValueStyle ?? valueStyle)
                      : valueStyle,
                  textAlign:
                      isValueRightAligned ? TextAlign.right : TextAlign.left,
                ),
              ),
              if (showDetailButton)
                ElevatedButton(
                  onPressed: () async {
                    final updatedTotalEarnings = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EarningsDetailsScreen(
                          totalEarnings: totalEarnings,
                        ),
                      ),
                    );

                    if (updatedTotalEarnings != null) {
                      setState(() {
                        totalEarnings = updatedTotalEarnings as double;
                      });
                      //  update earnings in Firestore here
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, // Text color
                    backgroundColor: ZipColors.zipYellow, // Background color
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('See details'),
                ),
            ],
          ),
          if (detailText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(detailText, style: detailTextStyle ?? valueStyle),
            ),
        ],
      ),
    );
  }
}