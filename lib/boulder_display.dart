import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'models/draw_point.dart';

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

Future<Size> _getImageSize(File file) async {
  final image = await decodeImageFromList(file.readAsBytesSync());
  return Size(image.width.toDouble(), image.height.toDouble());
}

class BoulderDisplay extends StatefulWidget {
  final File? imageFile;
  final List<DrawPoint> points;
  final void Function(Offset localPos, Size? imageWidgetSize)? onTapDown;

  const BoulderDisplay({
    super.key,
    required this.imageFile,
    required this.points,
    this.onTapDown,
  });

  @override
  _BoulderDisplayState createState() => _BoulderDisplayState();
}

class _BoulderDisplayState extends State<BoulderDisplay> {
  final TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder<Size>(
            future: _getImageSize(widget.imageFile!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final imageSize = snapshot.data!;
              final containerAspect = constraints.maxWidth / constraints.maxHeight;
              final imageAspect = imageSize.width / imageSize.height;

              double displayWidth;
              double displayHeight;

              if (imageAspect > containerAspect) {
                displayWidth = constraints.maxWidth;
                displayHeight = displayWidth / imageAspect;
              } else {
                displayHeight = constraints.maxHeight;
                displayWidth = displayHeight * imageAspect;
              }

              final Size fittedSize = Size(displayWidth, displayHeight);

              return ClipRect(
                child: GestureDetector(
                  onTapUp: (details) {
                    final scenePoint = _controller.toScene(details.localPosition);
                    if (widget.onTapDown != null) {
                      widget.onTapDown!(
                        scenePoint,
                        fittedSize,
                      );
                    }
                  },
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: SizedBox(
                      width: fittedSize.width,
                      height: fittedSize.height,
                      child: Stack(
                        children: [
                          Image.file(
                            widget.imageFile!,
                            fit: BoxFit.fill,
                            width: fittedSize.width,
                            height: fittedSize.height,
                          ),
                          ...widget.points.map((p) {
                            final pos = Offset(
                              p.dx * fittedSize.width,
                              p.dy * fittedSize.height,
                            );

                            final scaleFactor = (fittedSize.width / 300 +
                                fittedSize.height / 400) / 2;
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
                                    width: sqrt(sqrt(scaledSize * 2)),
                                  ),
                                  color: Colors.transparent,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
