import 'package:flutter/material.dart';

import 'NewPage.dart';

class SecondPage extends StatelessWidget {
  final Note note;

  const SecondPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter text here',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: TextEditingController(text: note.content),
                  onChanged: (newContent) {
                    note.content = newContent; // Update note content on change
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
