import 'package:boulder/boulder/boulder_display.dart';
import 'package:boulder/services/boulder_storage.dart';
import 'package:hive/hive.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/boulder.dart';
import 'package:flutter/material.dart';
import 'package:boulder/utils/consts.dart';

import 'boulder_form.dart';

class BoulderPage extends StatefulWidget {
  final Boulder boulder;

  const BoulderPage({required this.boulder, super.key});

  @override
  _BoulderPageState createState() => _BoulderPageState();
}

class _BoulderPageState extends State<BoulderPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPublishing = false;

  Future<void> _publishBoulder() async {
    if (_isPublishing) return; // Prevent double tap

    setState(() {
      _isPublishing = true;
    });

    final authBox = Hive.box('auth');
    final token = authBox.get('token');

    if (token == null || token.isEmpty) {
      setState(() {
        _isPublishing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ You must log in to publish.')),
      );
      return;
    }

    final boulder = widget.boulder;
    final uri = Uri.parse('$apiUrl/publish');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = boulder.name
        ..fields['grade'] = boulder.grade.toString()
        ..fields['location'] = boulder.location
        ..fields['comment'] = boulder.comment
        ..fields['created_at'] = boulder.created_at.toIso8601String()
        ..fields['points'] = jsonEncode(
          boulder.points.map((point) => {
            'dx': point.dx,
            'dy': point.dy,
            'type': point.type,
            'size': point.size,
          }).toList(),
        );

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        boulder.imagePath,
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();

      setState(() {
        _isPublishing = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Boulder published successfully!')),
        );
      } else {
        final body = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Failed to publish (${response.statusCode}):\n$body',
            ),
          ),
        );
      }
    } on SocketException {
      setState(() {
        _isPublishing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚫 Cannot connect to server. Please check your internet connection.')),
      );
    } catch (e) {
      setState(() {
        _isPublishing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Unexpected error: $e')),
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
          if(boulder.isOwn)
          IconButton(
            onPressed: () async {
              // Navigate to your edit screen
              final Boulder? editedBoulder = await

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoulderEditPage.fromBoulder(boulder),
                ),
              );

              if (editedBoulder != null) {
                await BoulderStorage.updateBoulder(boulder.name,editedBoulder);
                // Optionally reset UI:
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.edit),
          ),
          if(boulder.isOwn)
          // Publish Button or Loading Indicator
          _isPublishing
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
              : IconButton(
            onPressed: _publishBoulder,
            icon: Icon(Icons.share),
          ),
          // Delete Button
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
