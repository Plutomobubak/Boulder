import 'package:boulder/boulder_creator.dart';
import 'package:boulder/boulder_display.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boulder_page.dart';
import 'models/boulder.dart';
import 'dart:io';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Boulder> boulders = [];

  @override
  void initState() {
    super.initState();
    // Load boulders after widget is initialized
    _loadBoulders();
  }

  void _loadBoulders() {
    var box = Hive.box<Boulder>('boulders');
    setState(() {
      boulders = box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Boulders')),
      body: ListView.builder(
        itemCount: boulders.length,
        itemBuilder: (_, index) {
          final boulder = boulders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12), // match Card's radius
              onTap: () async{
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BoulderPage(boulder: boulder,)),
                );
                _loadBoulders();
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
                          imageFile: File(boulder.imagePath),
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
                          if(boulder.comment.isNotEmpty)
                              Text(
                                  'Comment: ${boulder.comment}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                )
                              ,
                          // Optional: add more info or tags here
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BoulderCreate()),
          );
          _loadBoulders();
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}
