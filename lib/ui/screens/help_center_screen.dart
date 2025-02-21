import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setEmail();
  }

  Future<void> _setEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _sendEmail() async {
  final String name = _nameController.text;
  final String email = _emailController.text;
  final String message = _messageController.text;

  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'info@zipgameday.com',
    queryParameters: {
      'subject': 'Help Center Inquiry',
      'body': 'Name: $name\nEmail: $email\n\n$message',
    },
  );

  print('Attempting to launch email client with URI: $emailUri');

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
    _clearForm();
    _showConfirmation();
  } else {
    print('Could not launch $emailUri');
    _showError();
  }
}


  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  void _showConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email sent successfully!')),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not launch email client. Please try again later.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendEmail();
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}