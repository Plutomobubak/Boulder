import 'dart:io';
import 'dart:math';
import 'package:boulder/boulder/boulder_display.dart';
import 'package:boulder/services/boulder_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/boulder.dart';
import '../models/draw_point.dart';
import 'boulder_form.dart';



class BoulderCreate extends StatefulWidget {
  const BoulderCreate({super.key});

  @override
  _BoulderCreateState createState() => _BoulderCreateState();
}

class _BoulderCreateState extends State<BoulderCreate> {
  File? _image;
  int? _currentType;
  final List<DrawPoint> _points = [];
  double _circleSize = 25.0;  // default diameter


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      // Get original image dimensions
      final decodedImage = await decodeImageFromList(File(pickedFile.path).readAsBytesSync());
      setState(() {
        _image = File(pickedFile.path);
        //_rawImageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      });
    }
  }

  void _onTapDown(Offset localPos, Size? imageWidgetSize) {
    if (imageWidgetSize == null || _currentType == null) return;

    final relative = Offset(
      localPos.dx / imageWidgetSize!.width,
      localPos.dy / imageWidgetSize!.height,
    );

    setState(() {
      _points.add(DrawPoint(
        dx: relative.dx,
        dy: relative.dy,
        type: _currentType!,
        size: _circleSize,
      ));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if(_image == null){
                      Navigator.pop(context);
                    }
                    else {
                      setState(() {
                        _image = null;
                      });
                    }
                  },
              ),
                Slider(
                  min: 15,
                  max: 75,
                  divisions: 42,
                  value: _circleSize,
                  label: _circleSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _circleSize = value;
                    });
                  },
                ),
                Container(
                    width: _circleSize,
                    height: _circleSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width:sqrt(sqrt(_circleSize*2)),
                      ),
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Center(
                child: _image != null
                    ? BoulderDisplay(imageFile: _image!, points: _points, onTapDown: _onTapDown)
                    : Text('No image selected', style: TextStyle(fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: _image == null
                  ?Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ): Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  IconButton(
                    icon: Icon(Icons.undo),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      minimumSize: Size(0, 0), // remove default minimum size
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduce extra padding
                    ),
                    onPressed: () {
                      setState(() {
                        if (_points.isNotEmpty) {
                          _points.removeLast();
                        }
                      });
                      },),
                  SizedBox(width: 12),
                  ElevatedButton.icon(icon: Icon(Icons.flag),
                    label: Text("Start/Top"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentType == 0? Color.fromRGBO(200, 200, 200, 255): Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size(0, 0), // remove default minimum size
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduce extra padding
                      ),
                    onPressed: (){
                      setState(() => _currentType = 0);
                  }),
                  SizedBox(width: 9),
                  ElevatedButton.icon(icon: Icon(Icons.back_hand),
                      label:Text("Hold"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentType == 1? Color.fromRGBO(200, 200, 200, 255): Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size(0, 0), // remove default minimum size
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduce extra padding
                      ),
                      onPressed: (){
                        setState(() => _currentType = 1);
                      }),
                  SizedBox(width: 9),
                  ElevatedButton.icon(icon: null,
                      label: Text("Foot"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentType == 2? Color.fromRGBO(200, 200, 200, 255): Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size(0, 0), // remove default minimum size
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduce extra padding
                      ),
                      onPressed: (){
                        setState(() => _currentType = 2);
                      }),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.save),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      minimumSize: Size(0, 0), // remove default minimum size
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduce extra padding
                    ),
                    onPressed: () async {
                      if (_image == null) return;

                      final Boulder? boulder = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoulderEditPage(
                            image: _image!,
                            points: List.from(_points), // pass current points
                          ),
                        ),
                      );

                      if (boulder != null) {
                        await BoulderStorage.saveBoulder(boulder);
                        // Optionally reset UI:
                        Navigator.pop(context);
                      }
                    },
                  ),
                ]
            ),
          ),
          ],
        ),
      ),
    );
  }
}
