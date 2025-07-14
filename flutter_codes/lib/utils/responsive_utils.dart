import 'package:flutter/material.dart';

// Responsive o'lchamlar uchun yordamchi funksiyalar
double responsiveSize(BuildContext context, double baseSize) {
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  const double baseShortestSide = 360.0;
  return baseSize * (shortestSide / baseShortestSide);
}

double responsiveTextSize(BuildContext context, double baseFontSize) {
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  const double baseShortestSide = 360.0;
  return baseFontSize * (shortestSide / baseShortestSide).clamp(0.8, 1.5);
}