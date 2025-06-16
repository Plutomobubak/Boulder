import 'package:boulder/boulder_display.dart';
import 'package:boulder/services/boulder_storage.dart';

import 'dart:io';
import 'models/boulder.dart';
import 'package:flutter/material.dart';

class BoulderPage extends StatefulWidget {
  final Boulder boulder;

  const BoulderPage({required this.boulder, super.key});

  @override
  _BoulderPageState createState() => _BoulderPageState();
}

class _BoulderPageState extends State<BoulderPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final boulder = widget.boulder;

    return Scaffold(
      appBar: AppBar(
        title: Text(boulder.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Boulder'),
                  content: Text('Are you sure you want to delete "${boulder.name}"? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Cancel
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async{
                        await BoulderStorage.deleteBoulder(boulder);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back
                      },
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // BoulderDisplay
            AspectRatio(
              aspectRatio: 3 / 4,
              child: BoulderDisplay(
                imageFile: File(boulder.imagePath),
                points: boulder.points,
              ),
            ),

            // Info section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          Icon(Icons.fitness_center, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Grade: ${boulder.grade}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Location: ${boulder.location}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    if (boulder.comment.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          '"${boulder.comment}"',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
