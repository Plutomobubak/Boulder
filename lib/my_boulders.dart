import 'boulder/boulder_card.dart';
import 'boulder/boulder_creator.dart';
import 'boulder/boulder_display.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boulder/boulder_page.dart';
import 'models/boulder.dart';
import 'dart:io';

class MyBoulders extends StatefulWidget {
  const MyBoulders({super.key});

  @override
  _MyBouldersState createState() => _MyBouldersState();
}

class _MyBouldersState extends State<MyBoulders> {
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
      appBar: null,
      body: ListView.builder(
        itemCount: boulders.length,
        itemBuilder: (_, index) {
          final boulder = boulders[index];
          return BoulderCard(
            boulder: boulder,
            onReload: _loadBoulders,  // pass your reload callback
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
