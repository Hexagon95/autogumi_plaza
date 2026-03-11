import 'package:flutter/material.dart';

class PdfSignaturePage extends StatelessWidget {
  const PdfSignaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Aláírás (Web placeholder)'),
      ),
      body: const Center(
        child: Text(
          'A PDF aláírés még nem elérhető a web alkamazásunkban.',
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Vissza'),
          ),
        ),
      ),
    );
  }
}