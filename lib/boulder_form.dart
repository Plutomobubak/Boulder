import 'package:flutter/material.dart';

import 'dart:io';
import 'models/boulder.dart';
import 'models/draw_point.dart';

class BoulderSavePage extends StatefulWidget {
  final File image;
  final List<DrawPoint> points;

  const BoulderSavePage({required this.image, required this.points, Key? key}) : super(key: key);

  @override
  _BoulderSavePageState createState() => _BoulderSavePageState();
}

class _BoulderSavePageState extends State<BoulderSavePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _grade = '';
  String _location = '';
  String _comment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Save Boulder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (val) => _name = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Enter a name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Grade'),
                onSaved: (val) => _grade = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Enter a grade' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (val) => _location = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Enter a location' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Comment'),
                onSaved: (val) => _comment = val ?? '',
                maxLines: 3,
              ),
              Spacer(),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();


                    final boulder = Boulder(
                      imagePath: widget.image.path,
                      points: widget.points,
                      name: _name,
                      grade: _grade,
                      location: _location,
                      comment: _comment,
                    );


                    Navigator.pop(context, boulder);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
