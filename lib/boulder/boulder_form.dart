import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'dart:io';
import '../models/boulder.dart';
import '../models/draw_point.dart';
import '../utils/grades.dart';

class BoulderEditPage extends StatefulWidget {
  final File image;
  final List<DrawPoint> points;
  final String? initialName;
  final int? initialGrade;
  final String? initialLocation;
  final String? initialComment;

  const BoulderEditPage({
    required this.image,
    required this.points,
    this.initialName,
    this.initialGrade,
    this.initialLocation,
    this.initialComment,
    super.key,
  });

  /// Named constructor for convenience when passing a full Boulder object
  factory BoulderEditPage.fromBoulder(Boulder boulder) {
    return BoulderEditPage(
      image: File(boulder.imagePath),
      points: boulder.points,
      initialName: boulder.name,
      initialGrade: boulder.grade,
      initialLocation: boulder.location,
      initialComment: boulder.comment,
    );
  }

  @override
  _BoulderEditPageState createState() => _BoulderEditPageState();
}

class _BoulderEditPageState extends State<BoulderEditPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, int> scale;
  String _name = '';
  int _grade = 0;
  String? _selectedGradeKey;
  String _location = '';
  String _comment = '';

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _loadReverseScale();
    _name = widget.initialName ?? '';


    _grade = widget.initialGrade ?? 0;
    _location = widget.initialLocation ?? '';
    _comment = widget.initialComment ?? '';

    _nameController = TextEditingController(text: _name);
    _locationController = TextEditingController(text: _location);
    _commentController = TextEditingController(text: _comment);
  }

  Future<void> _loadReverseScale() async {
    final sscale = await getScale();
    setState(() {
      scale = sscale;
      _selectedGradeKey = scale.entries
          .firstWhere(
            (entry) => entry.value == widget.initialGrade,
        orElse: () => scale.entries.first,
      )
          .key;
    });
  }
  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

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
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (val) => _name = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Enter a name' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Grade'),
                value: _selectedGradeKey, // pre-selected value
                items: scale.keys.map((grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGradeKey = newValue;
                    _grade = newValue != null ? scale[newValue]! : -1;
                  });
                },
                validator: (val) => (val == null || val.isEmpty) ? 'Enter a grade' : null,
                onSaved: (val) {
                  _grade = val != null ? scale[val]! : -1;
                },
              ),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (val) => _location = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Enter a location' : null,
              ),
              TextFormField(
                controller: _commentController,
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

                    final authBox = Hive.box('auth');
                    final savedUsername = authBox.get('username');
                    final boulder = Boulder(
                      imagePath: widget.image.path,
                      points: widget.points,
                      name: _name,
                      grade: _grade,
                      location: _location,
                      comment: _comment,
                      author: savedUsername,
                      isOwn: true,
                      created_at: DateTime.now()
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
