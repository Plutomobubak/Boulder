import 'dart:io';

import 'package:flutter/material.dart';
import 'boulder_display.dart';  // Adjust the import according to your project structure
import 'boulder_page.dart';     // Your page to navigate on tap

class BoulderCard extends StatelessWidget {
  final dynamic boulder;
  final VoidCallback onReload;

  const BoulderCard({
    Key? key,
    required this.boulder,
    required this.onReload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12), // match Card's radius
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BoulderPage(boulder: boulder)),
          );
          onReload();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              SizedBox(
                width: 180,
                height: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
              ),
              const SizedBox(width: 16),

              // Text on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boulder.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Grade: ${boulder.grade}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Location: ${boulder.location}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Author: ${boulder.author}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (boulder.comment.isNotEmpty)
                      Text(
                        'Comment: ${boulder.comment}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
