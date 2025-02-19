import 'package:flutter/material.dart';
import 'package:zipapp/services/bank_account_service.dart'; // Assuming you have a service to handle bank account logic

class BankAccountInputScreen extends StatefulWidget {
  @override
  _BankAccountInputScreenState createState() => _BankAccountInputScreenState();
}

class _BankAccountInputScreenState extends State<BankAccountInputScreen> {
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _routingNumberController = TextEditingController();
  String statusMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bank Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _routingNumberController,
              decoration: const InputDecoration(
                labelText: 'Routing Number',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            Visibility(
              visible: statusMessage.isNotEmpty,
              child: Text(
                statusMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  statusMessage = "Connecting...";
                });

                try {
                  await BankAccountService.connectBankAccount(
                    accountNumber: _accountNumberController.text,
                    routingNumber: _routingNumberController.text,
                  );
                  setState(() {
                    statusMessage = "Bank account connected successfully.";
                  });
                  Navigator.pop(context);
                } catch (e) {
                  setState(() {
                    statusMessage = "Failed to connect bank account. Please try again.";
                  });
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
