import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'boulder/boulder_card.dart';
import 'boulder/boulder_display.dart';
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
      author: boulder['author']['username']
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
  int? grade;

  List<dynamic> boulders = [];
  bool loading = false;
  String? error;


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
      if (grade != null) queryParams['grade'] = grade.toString();

      final uri = Uri.parse(apiUrl + "search").replace(queryParameters: queryParams);

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
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 160,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (val) => name = val,
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: (val) => location = val,
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Author'),
                    onChanged: (val) => username = val,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: DropdownButton<int?>(
                    value: grade,
                    hint: const Text('Grade'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any')),
                      for (int i = 1; i <= 9; i++)
                        DropdownMenuItem(value: i, child: Text(i.toString())),
                    ],
                    onChanged: (val) => setState(() => grade = val),
                  ),
                ),
                ElevatedButton(
                  onPressed: loading ? null : () {
                    search();
                    FocusScope.of(context).unfocus();
                  },
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Search'),
                )
              ],
            ),
            const SizedBox(height: 12),
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
