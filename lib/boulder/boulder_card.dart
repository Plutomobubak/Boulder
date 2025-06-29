import 'dart:io';
import 'package:intl/intl.dart';

import 'package:boulder/utils/grades.dart';
import 'package:flutter/material.dart';
import 'boulder_display.dart';  // Adjust the import according to your project structure
import 'boulder_page.dart';     // Your page to navigate on tap


class BoulderCard extends StatefulWidget {
  final dynamic boulder;
  final VoidCallback onReload;

  const BoulderCard({
    Key? key,
    required this.boulder,
    required this.onReload,
  }) : super(key: key);

  @override
  State<BoulderCard> createState() => _BoulderCardState();
}

class _BoulderCardState extends State<BoulderCard> {
  Map<int, String>? reverseScale;

  @override
  void initState() {
    super.initState();
    _loadReverseScale();
  }

  Future<void> _loadReverseScale() async {
    final scale = await getReverseScale();
    setState(() {
      reverseScale = scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final boulder = widget.boulder;
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
          widget.onReload();
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
                      'Diff ${reverseScale?[boulder.grade]}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'At ${boulder.location}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    if(boulder.isOwn)const SizedBox(height: 8),
                    Text(
                      'By ${boulder.isOwn?"You":boulder.author}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'On ${DateFormat.yMMMd().add_jm().format(boulder.created_at)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (boulder.comment.isNotEmpty)
                      Text(
                        '${boulder.comment}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
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
