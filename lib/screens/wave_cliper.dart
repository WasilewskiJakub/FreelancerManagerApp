import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Zaczynamy w lewym GÓRNYM rogu
    path.moveTo(0, 0);

    // Pierwsza krzywa
    final firstControlPoint = Offset(size.width * 0.5, size.height * 0.15);
    final firstEndPoint = Offset(size.width, 0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    // Prawy dolny róg
    path.lineTo(size.width, size.height);
    // Lewy dolny róg
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

