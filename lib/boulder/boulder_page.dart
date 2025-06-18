import 'package:boulder/boulder/boulder_display.dart';
import 'package:boulder/services/boulder_storage.dart';
import 'package:hive/hive.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/boulder.dart';
import 'package:flutter/material.dart';

class BoulderPage extends StatefulWidget {
  final Boulder boulder;

  const BoulderPage({required this.boulder, super.key});

  @override
  _BoulderPageState createState() => _BoulderPageState();
}

class _BoulderPageState extends State<BoulderPage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _publishBoulder() async {
    final uri = Uri.parse('http://10.0.2.2:8000/publish'); // Replace with your actual endpoint
    final boulder = widget.boulder;
    final authBox = Hive.box('auth');

    final token = authBox.get('token');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = boulder.name
      ..fields['grade'] = boulder.grade.toString()
      ..fields['location'] = boulder.location
      ..fields['comment'] = boulder.comment
      ..fields['points'] = jsonEncode(boulder.points.map((point) => {
        'dx': point.dx,
        'dy': point.dy,
        'type': point.type,
        'size': point.size,
      }).toList());

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      boulder.imagePath,
      contentType: MediaType('image', 'jpeg'), // or 'png' based on your usage
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Boulder published successfully!')),
      );
    } else {
      final body = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: ${response.statusCode}\n$body')),
      );
    }
  }

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
            onPressed: _publishBoulder,
            icon: Icon(Icons.share),
          ),
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
                imageFile: boulder.imagePath != null && !boulder.imagePath.startsWith('http')
                    ? File(boulder.imagePath)
                    : null,
                imageUrl: boulder.imagePath != null && boulder.imagePath.startsWith('http')
                    ? boulder.imagePath
                    : null,
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
