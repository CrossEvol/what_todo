import 'package:flutter/material.dart';

var priorityColor = [Colors.red, Colors.orange, Colors.yellow, Colors.white];

class ColorPalette {
  final String colorName;
  final int colorValue;

  ColorPalette.none()
      : colorName = "Grey",
        colorValue = Colors.grey.value;

  ColorPalette(this.colorName, this.colorValue);

  Map<String, dynamic> toMap() {
    return {
      'colorName': this.colorName,
      'colorValue': this.colorValue,
    };
  }

  factory ColorPalette.fromMap(Map<String, dynamic> map) {
    return ColorPalette(
      map['colorName'] as String,
      map['colorValue'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorPalette &&
          runtimeType == other.runtimeType &&
          colorName == other.colorName &&
          colorValue == other.colorValue;

  @override
  int get hashCode => colorName.hashCode ^ colorValue.hashCode;
}

var colorsPalettes = <ColorPalette>[
  ColorPalette("Red", Colors.red.value),
  ColorPalette("Pink", Colors.pink.value),
  ColorPalette("Purple", Colors.purple.value),
  ColorPalette("Deep Purple", Colors.deepPurple.value),
  ColorPalette("Indigo", Colors.indigo.value),
  ColorPalette("Blue", Colors.blue.value),
  ColorPalette("Lightblue", Colors.lightBlue.value),
  ColorPalette("Cyan", Colors.cyan.value),
  ColorPalette("Teal", Colors.teal.value),
  ColorPalette("Green", Colors.green.value),
  ColorPalette("Lightgreen", Colors.lightGreen.value),
  ColorPalette("Lime", Colors.lime.value),
  ColorPalette("Yellow", Colors.yellow.value),
  ColorPalette("Amber", Colors.amber.value),
  ColorPalette("Orange", Colors.orange.value),
  ColorPalette("Deeporange", Colors.deepOrange.value),
  ColorPalette("Brown", Colors.brown.value),
  ColorPalette("Black", Colors.black.value),
  ColorPalette("Grey", Colors.grey.value),
];
