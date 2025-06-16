import 'package:flutter/material.dart';
import 'models/draw_point.dart';
import 'dart:io';

Color colorForType(int type) {
  switch (type) {
    case 0:
      return Colors.green;
    case 1:
      return Colors.blue;
    case 2:
      return Colors.red;
    default:
      return Colors.transparent;
  }
}

class BoulderDisplay extends StatefulWidget {
  final File? imageFile;
  final List<DrawPoint> points;
  final void Function(Offset localPos, Size? imageWidgetSize)? onTapDown;

  const BoulderDisplay({
    Key? key,
    required this.imageFile,
    required this.points,
    this.onTapDown,
  }) : super(key: key);

  @override
  _BoulderDisplayState createState() => _BoulderDisplayState();
}

class _BoulderDisplayState extends State<BoulderDisplay> {
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;

  void _updateImageSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        setState(() {
          _imageSize = renderBox.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateImageSize();

    const referenceWidth = 300.0; // You can adjust this to your design size
    const referenceHeight = 400.0;

    return _imageSize == null
        ? Image.file(widget.imageFile!, key: _imageKey, fit: BoxFit.contain)
        : Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            if (widget.onTapDown != null) {
              widget.onTapDown!(details.localPosition, _imageSize);
            }
          },
          child: Image.file(
            widget.imageFile!,
            key: _imageKey,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        ...widget.points.map((p) {
          final pos = Offset(
            p.dx * _imageSize!.width,
            p.dy * _imageSize!.height,
          );

          // Scale size relative to container size
          final scaleFactor = (_imageSize!.width / referenceWidth + _imageSize!.height / referenceHeight) / 2;
          final scaledSize = p.size * scaleFactor;

          return Positioned(
            left: pos.dx - scaledSize / 2,
            top: pos.dy - scaledSize / 2,
            child: Container(
              width: scaledSize,
              height: scaledSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorForType(p.type),
                  width: scaledSize / 8,
                ),
                color: Colors.transparent,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}