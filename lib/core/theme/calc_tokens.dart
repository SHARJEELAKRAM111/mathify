import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class CalcTokens extends ThemeExtension<CalcTokens> {
  final Color displayBg;
  final Color displayFg;
  final Color keyBg;
  final Color keyFg;
  final Color keyBorder;
  final Color keyShadow;
  final Color operatorBg;
  final Color operatorFg;
  final Color actionBg;
  final Color actionFg;
  final Color equalsBg;
  final Color equalsFg;
  final double keyRadius;
  final double keyElevation;

  const CalcTokens({
    required this.displayBg,
    required this.displayFg,
    required this.keyBg,
    required this.keyFg,
    required this.keyBorder,
    required this.keyShadow,
    required this.operatorBg,
    required this.operatorFg,
    required this.actionBg,
    required this.actionFg,
    required this.equalsBg,
    required this.equalsFg,
    required this.keyRadius,
    required this.keyElevation,
  });

  @override
  CalcTokens copyWith({
    Color? displayBg,
    Color? displayFg,
    Color? keyBg,
    Color? keyFg,
    Color? keyBorder,
    Color? keyShadow,
    Color? operatorBg,
    Color? operatorFg,
    Color? actionBg,
    Color? actionFg,
    Color? equalsBg,
    Color? equalsFg,
    double? keyRadius,
    double? keyElevation,
  }) {
    return CalcTokens(
      displayBg: displayBg ?? this.displayBg,
      displayFg: displayFg ?? this.displayFg,
      keyBg: keyBg ?? this.keyBg,
      keyFg: keyFg ?? this.keyFg,
      keyBorder: keyBorder ?? this.keyBorder,
      keyShadow: keyShadow ?? this.keyShadow,
      operatorBg: operatorBg ?? this.operatorBg,
      operatorFg: operatorFg ?? this.operatorFg,
      actionBg: actionBg ?? this.actionBg,
      actionFg: actionFg ?? this.actionFg,
      equalsBg: equalsBg ?? this.equalsBg,
      equalsFg: equalsFg ?? this.equalsFg,
      keyRadius: keyRadius ?? this.keyRadius,
      keyElevation: keyElevation ?? this.keyElevation,
    );
  }

  @override
  ThemeExtension<CalcTokens> lerp(ThemeExtension<CalcTokens>? other, double t) {
    if (other is! CalcTokens) return this;
    return CalcTokens(
      displayBg: Color.lerp(displayBg, other.displayBg, t)!,
      displayFg: Color.lerp(displayFg, other.displayFg, t)!,
      keyBg: Color.lerp(keyBg, other.keyBg, t)!,
      keyFg: Color.lerp(keyFg, other.keyFg, t)!,
      keyBorder: Color.lerp(keyBorder, other.keyBorder, t)!,
      keyShadow: Color.lerp(keyShadow, other.keyShadow, t)!,
      operatorBg: Color.lerp(operatorBg, other.operatorBg, t)!,
      operatorFg: Color.lerp(operatorFg, other.operatorFg, t)!,
      actionBg: Color.lerp(actionBg, other.actionBg, t)!,
      actionFg: Color.lerp(actionFg, other.actionFg, t)!,
      equalsBg: Color.lerp(equalsBg, other.equalsBg, t)!,
      equalsFg: Color.lerp(equalsFg, other.equalsFg, t)!,
      keyRadius: lerpDouble(keyRadius, other.keyRadius, t)!,
      keyElevation: lerpDouble(keyElevation, other.keyElevation, t)!,
    );
  }
}
