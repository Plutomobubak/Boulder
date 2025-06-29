import 'package:boulder/utils/grades.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'boulder/boulder_card.dart';
import 'models/boulder.dart';
import 'models/draw_point.dart';
import 'utils/consts.dart';


Future<File> urlToFile(String imageUrl) async {
  final tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
  final response = await http.get(Uri.parse(imageUrl));
  final file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return file;
}

Boulder parseBoulder(dynamic boulder){
  print(boulder);
  var points = <DrawPoint>[];
  for (var p in boulder['points']){
    points.add(DrawPoint(dx: p['dx'], dy: p['dy'], type: p['type'], size: p['size']));
  }
  return Boulder(
      imagePath: boulder['image_path'],
      points: points,
      name: boulder['name'],
      grade: boulder['grade'],
      location: boulder['location'],
      comment: boulder['comment'],
      author: boulder['author']['username'],
      isOwn: false,
      created_at: DateTime.parse(boulder['created_at']),
  );
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String? name;
  String? location;
  String? username;
  int? minGrade;
  int? maxGrade;
  String? _selectedMinGrade;
  String? _selectedMaxGrade;
  Map<String, int> scale = {};
  String? timeFilter;

  List<dynamic> boulders = [];
  bool loading = false;
  String? error;

  DateTime? getTimeQuery() {
    final now = DateTime.now();
    if (timeFilter == 'today') {
      return DateTime(now.year, now.month, now.day);
    } else if (timeFilter == 'week') {
      return now.subtract(const Duration(days: 7));
    } else if (timeFilter == 'month') {
      return DateTime(now.year, now.month - 1, now.day);
    } else if (timeFilter == 'year') {
      return DateTime(now.year - 1, now.month, now.day);
    }
    return null; // No filter
  }

  @override
  void initState() {
    super.initState();
    _loadReverseScale();
  }
  Future<void> _loadReverseScale() async {
    var sscale = await getScale();
    sscale["Any"] = -1;
    setState(() {
      scale = sscale;
      _selectedMinGrade = "Any";
      _selectedMaxGrade = "Any";
    });
  }
  Future<void> search() async {
    setState(() {
      loading = true;
      error = null;
      boulders = [];
    });

    try {
      Map<String, String> queryParams = {};
      if (name != null && name!.isNotEmpty) queryParams['name'] = name!;
      if (location != null && location!.isNotEmpty) queryParams['location'] = location!;
      if (username != null && username!.isNotEmpty) queryParams['username'] = username!;
      if (minGrade != null && minGrade! >= 0) queryParams['min_grade'] = minGrade.toString();
      if (maxGrade != null && maxGrade! >= 0) queryParams['max_grade'] = maxGrade.toString();
      if(timeFilter != null) {
        final DateTime? time = getTimeQuery();
        final String? timeIso = time?.toIso8601String();
        queryParams['created_at'] = timeIso!;
      }

      final uri = Uri.parse("$apiUrl/search").replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          boulders = data;
        });
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load results: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: [
                SizedBox(
                  width: 140, // slightly smaller
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => name = val,
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => location = val,
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 48,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Author',
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => username = val,
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Min Grade',
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMinGrade,
                    items: scale.keys.map((grade) {
                      return DropdownMenuItem<String>(
                        value: grade,
                        child: Text(grade),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMinGrade = newValue;
                        minGrade = newValue != null ? scale[newValue]! : null;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Max Grade',
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMaxGrade,
                    items: scale.keys.map((grade) {
                      return DropdownMenuItem<String>(
                        value: grade,
                        child: Text(grade),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMaxGrade = newValue;
                        maxGrade = newValue != null ? scale[newValue]! : null;
                      });
                    },
                  ),
                ),


                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String?>(
                    value: timeFilter,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Any time')),
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(value: 'week', child: Text('Last week')),
                      DropdownMenuItem(value: 'month', child: Text('Last month')),
                      DropdownMenuItem(value: 'year', child: Text('Last year')),
                    ],
                    onChanged: (val) => setState(() => timeFilter = val),
                  ),
                ),

                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                    search();
                    FocusScope.of(context).unfocus();
                  },
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Search'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Expanded(
              child: error != null
                  ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                  : boulders.isEmpty
                  ? const Center(child: Text('No results'))
                  : ListView.builder(
                itemCount: boulders.length,
                itemBuilder: (_, i) => BoulderCard(boulder:parseBoulder(boulders[i]), onReload: () {  },),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
