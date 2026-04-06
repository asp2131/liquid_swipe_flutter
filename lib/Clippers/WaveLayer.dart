import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_swipe/Helpers/Helpers.dart';

///Liquid Type PathClipper
class WaveLayer extends CustomClipper<Path> {
  double revealPercent;
  double verReveal;
  late double waveCenterY;
  late double waveHorRadius;
  late double waveVertRadius;
  late double sideWidth;
  Size iconSize;
  SlideDirection? slideDirection;
  bool enableSideReveal;
  Axis swipeAxis;

  WaveLayer({
    required this.revealPercent,
    required this.slideDirection,
    required this.iconSize,
    required this.verReveal,
    required this.enableSideReveal,
    this.swipeAxis = Axis.horizontal,
  });

  @override
  getClip(Size size) {
    if (swipeAxis == Axis.vertical) {
      return _getVerticalClip(size);
    }
    return _getHorizontalClip(size);
  }

  /// Original horizontal clip path (unchanged)
  Path _getHorizontalClip(Size size) {
    Path path = Path();
    sideWidth = sidewidth(size);
    waveVertRadius = waveVertRadiusF(size);

    waveCenterY = size.height * verReveal;
    waveHorRadius = slideDirection == SlideDirection.leftToRight
        ? waveHorRadiusFBack(size)
        : waveHorRadiusF(size);

    var maskWidth = size.width - sideWidth;
    path.moveTo(maskWidth - sideWidth, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(maskWidth, size.height);
    double curveStartY = waveCenterY + waveVertRadius;

    path.lineTo(maskWidth, curveStartY);

    path.cubicTo(
      maskWidth,
      curveStartY - waveVertRadius * 0.1346194756,
      maskWidth - waveHorRadius * 0.05341339583,
      curveStartY - waveVertRadius * 0.2412779634,
      maskWidth - waveHorRadius * 0.1561501458,
      curveStartY - waveVertRadius * 0.3322374268,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.2361659167,
      curveStartY - waveVertRadius * 0.4030805244,
      maskWidth - waveHorRadius * 0.3305285625,
      curveStartY - waveVertRadius * 0.4561193293,
      maskWidth - waveHorRadius * 0.5012484792,
      curveStartY - waveVertRadius * 0.5350576951,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.515878125,
      curveStartY - waveVertRadius * 0.5418222317,
      maskWidth - waveHorRadius * 0.5664134792,
      curveStartY - waveVertRadius * 0.5650349878,
      maskWidth - waveHorRadius * 0.574934875,
      curveStartY - waveVertRadius * 0.5689655122,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.7283715208,
      curveStartY - waveVertRadius * 0.6397387195,
      maskWidth - waveHorRadius * 0.8086618958,
      curveStartY - waveVertRadius * 0.6833456585,
      maskWidth - waveHorRadius * 0.8774032292,
      curveStartY - waveVertRadius * 0.7399037439,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.9653464583,
      curveStartY - waveVertRadius * 0.8122605122,
      maskWidth - waveHorRadius,
      curveStartY - waveVertRadius * 0.8936183659,
      maskWidth - waveHorRadius,
      curveStartY - waveVertRadius,
    );

    path.cubicTo(
      maskWidth - waveHorRadius,
      curveStartY - waveVertRadius * 1.100142878,
      maskWidth - waveHorRadius * 0.9595746667,
      curveStartY - waveVertRadius * 1.1887991951,
      maskWidth - waveHorRadius * 0.8608411667,
      curveStartY - waveVertRadius * 1.270484439,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.7852123333,
      curveStartY - waveVertRadius * 1.3330544756,
      maskWidth - waveHorRadius * 0.703382125,
      curveStartY - waveVertRadius * 1.3795848049,
      maskWidth - waveHorRadius * 0.5291125625,
      curveStartY - waveVertRadius * 1.4665102805,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.5241858333,
      curveStartY - waveVertRadius * 1.4689677195,
      maskWidth - waveHorRadius * 0.505739125,
      curveStartY - waveVertRadius * 1.4781625854,
      maskWidth - waveHorRadius * 0.5015305417,
      curveStartY - waveVertRadius * 1.4802616098,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.3187486042,
      curveStartY - waveVertRadius * 1.5714239024,
      maskWidth - waveHorRadius * 0.2332057083,
      curveStartY - waveVertRadius * 1.6204116463,
      maskWidth - waveHorRadius * 0.1541165417,
      curveStartY - waveVertRadius * 1.687403,
    );

    path.cubicTo(
      maskWidth - waveHorRadius * 0.0509933125,
      curveStartY - waveVertRadius * 1.774752061,
      maskWidth,
      curveStartY - waveVertRadius * 1.8709256829,
      maskWidth,
      curveStartY - waveVertRadius * 2,
    );

    path.lineTo(maskWidth, 0);
    path.close();

    return path;
  }

  /// Vertical clip path — transposed version of horizontal.
  /// The wave enters from the bottom edge, with the bulge center along the x-axis.
  Path _getVerticalClip(Size size) {
    Path path = Path();

    // In vertical mode, verReveal is the x-position of the wave center (0.0 - 1.0)
    double waveCenterX = size.width * verReveal;

    // sideHeight = bottom strip (analogous to sideWidth for the right strip)
    double sideHeight = _sideHeightV(size);

    // waveHorRadius in vertical mode = horizontal extent of the wave bulge
    double waveHorRadiusV = _waveHorRadiusV(size);

    // waveVertRadius in vertical mode = vertical extent of the wave bulge (into the page)
    double waveVertRadiusV = slideDirection == SlideDirection.topToBottom
        ? _waveVertRadiusVBack(size)
        : _waveVertRadiusVForward(size);

    double maskHeight = size.height - sideHeight;

    // Start path: fill from the bottom, covering the revealed area
    path.moveTo(0, maskHeight - sideHeight);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, maskHeight);

    double curveStartX = waveCenterX + waveHorRadiusV;

    path.lineTo(curveStartX, maskHeight);

    // Transposed bezier curves (x↔y swapped from horizontal version)
    path.cubicTo(
      curveStartX - waveHorRadiusV * 0.1346194756,
      maskHeight,
      curveStartX - waveHorRadiusV * 0.2412779634,
      maskHeight - waveVertRadiusV * 0.05341339583,
      curveStartX - waveHorRadiusV * 0.3322374268,
      maskHeight - waveVertRadiusV * 0.1561501458,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 0.4030805244,
      maskHeight - waveVertRadiusV * 0.2361659167,
      curveStartX - waveHorRadiusV * 0.4561193293,
      maskHeight - waveVertRadiusV * 0.3305285625,
      curveStartX - waveHorRadiusV * 0.5350576951,
      maskHeight - waveVertRadiusV * 0.5012484792,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 0.5418222317,
      maskHeight - waveVertRadiusV * 0.515878125,
      curveStartX - waveHorRadiusV * 0.5650349878,
      maskHeight - waveVertRadiusV * 0.5664134792,
      curveStartX - waveHorRadiusV * 0.5689655122,
      maskHeight - waveVertRadiusV * 0.574934875,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 0.6397387195,
      maskHeight - waveVertRadiusV * 0.7283715208,
      curveStartX - waveHorRadiusV * 0.6833456585,
      maskHeight - waveVertRadiusV * 0.8086618958,
      curveStartX - waveHorRadiusV * 0.7399037439,
      maskHeight - waveVertRadiusV * 0.8774032292,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 0.8122605122,
      maskHeight - waveVertRadiusV * 0.9653464583,
      curveStartX - waveHorRadiusV * 0.8936183659,
      maskHeight - waveVertRadiusV,
      curveStartX - waveHorRadiusV,
      maskHeight - waveVertRadiusV,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 1.100142878,
      maskHeight - waveVertRadiusV,
      curveStartX - waveHorRadiusV * 1.1887991951,
      maskHeight - waveVertRadiusV * 0.9595746667,
      curveStartX - waveHorRadiusV * 1.270484439,
      maskHeight - waveVertRadiusV * 0.8608411667,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 1.3330544756,
      maskHeight - waveVertRadiusV * 0.7852123333,
      curveStartX - waveHorRadiusV * 1.3795848049,
      maskHeight - waveVertRadiusV * 0.703382125,
      curveStartX - waveHorRadiusV * 1.4665102805,
      maskHeight - waveVertRadiusV * 0.5291125625,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 1.4689677195,
      maskHeight - waveVertRadiusV * 0.5241858333,
      curveStartX - waveHorRadiusV * 1.4781625854,
      maskHeight - waveVertRadiusV * 0.505739125,
      curveStartX - waveHorRadiusV * 1.4802616098,
      maskHeight - waveVertRadiusV * 0.5015305417,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 1.5714239024,
      maskHeight - waveVertRadiusV * 0.3187486042,
      curveStartX - waveHorRadiusV * 1.6204116463,
      maskHeight - waveVertRadiusV * 0.2332057083,
      curveStartX - waveHorRadiusV * 1.687403,
      maskHeight - waveVertRadiusV * 0.1541165417,
    );

    path.cubicTo(
      curveStartX - waveHorRadiusV * 1.774752061,
      maskHeight - waveVertRadiusV * 0.0509933125,
      curveStartX - waveHorRadiusV * 1.8709256829,
      maskHeight,
      curveStartX - waveHorRadiusV * 2,
      maskHeight,
    );

    path.lineTo(0, maskHeight);
    path.close();

    return path;
  }

  // ──── Horizontal mode helpers (unchanged) ────

  double sidewidth(Size size) {
    var p1 = 0.2;
    var p2 = 0.8;

    if (revealPercent <= p1) {
      return enableSideReveal ? 15.0 : 0;
    }

    if (revealPercent >= p2) {
      return size.width;
    }

    return 15 + (size.width - 15.0) * (revealPercent - p1) / (p2 - p1);
  }

  double waveVertRadiusF(Size size) {
    var p1 = 0.4;

    if (revealPercent <= 0) {
      return enableSideReveal ? iconSize.height : 0;
    }

    if (revealPercent >= p1) {
      return size.height * 0.9;
    }

    return iconSize.height +
        ((size.height * 0.9) - iconSize.height) * revealPercent / p1;
  }

  double waveHorRadiusF(Size size) {
    if (revealPercent <= 0) {
      return iconSize.width;
    }

    if (revealPercent >= 1) {
      return 0;
    }

    var p1 = 0.4;
    if (revealPercent <= p1) {
      return iconSize.width +
          revealPercent / p1 * ((size.width * 0.8) - iconSize.width);
    }

    var t = (revealPercent - p1) / (1.0 - p1);
    var A = size.width * 0.9;
    var r = 40;
    var m = 9.8;
    var beta = r / (2 * m);
    var k = 50;
    var omega0 = k / m;
    var omega = pow(-pow(beta, 2) + pow(omega0, 2), 0.5);

    return A * exp(-beta * t) * cos(omega * t);
  }

  double waveHorRadiusFBack(Size size) {
    if (revealPercent <= 0) {
      return iconSize.width;
    }

    if (revealPercent >= 1) {
      return 0;
    }

    var p1 = 0.4;
    if (revealPercent <= p1) {
      return iconSize.width + revealPercent / p1 * iconSize.width;
    }

    var t = (revealPercent - p1) / (1.0 - p1);
    var A = iconSize.width + 8;
    var r = 40;
    var m = 9.8;
    var beta = r / (2 * m);
    var k = 50;
    var omega0 = k / m;
    var omega = pow(-pow(beta, 2) + pow(omega0, 2), 0.5);

    return A * exp(-beta * t) * cos(omega * t);
  }

  // ──── Vertical mode helpers (transposed from horizontal) ────

  /// Bottom strip height (analogous to sidewidth for horizontal)
  double _sideHeightV(Size size) {
    var p1 = 0.2;
    var p2 = 0.8;

    if (revealPercent <= p1) {
      return enableSideReveal ? 15.0 : 0;
    }

    if (revealPercent >= p2) {
      return size.height;
    }

    return 15 + (size.height - 15.0) * (revealPercent - p1) / (p2 - p1);
  }

  /// Horizontal extent of the wave (analogous to waveVertRadiusF)
  double _waveHorRadiusV(Size size) {
    var p1 = 0.4;

    if (revealPercent <= 0) {
      return enableSideReveal ? iconSize.width : 0;
    }

    if (revealPercent >= p1) {
      return size.width * 0.9;
    }

    return iconSize.width +
        ((size.width * 0.9) - iconSize.width) * revealPercent / p1;
  }

  /// Vertical extent of the wave bulge going forward (analogous to waveHorRadiusF)
  double _waveVertRadiusVForward(Size size) {
    if (revealPercent <= 0) {
      return iconSize.height;
    }

    if (revealPercent >= 1) {
      return 0;
    }

    var p1 = 0.4;
    if (revealPercent <= p1) {
      return iconSize.height +
          revealPercent / p1 * ((size.height * 0.8) - iconSize.height);
    }

    var t = (revealPercent - p1) / (1.0 - p1);
    var A = size.height * 0.9;
    var r = 40;
    var m = 9.8;
    var beta = r / (2 * m);
    var k = 50;
    var omega0 = k / m;
    var omega = pow(-pow(beta, 2) + pow(omega0, 2), 0.5);

    return A * exp(-beta * t) * cos(omega * t);
  }

  /// Vertical extent of the wave bulge going back (analogous to waveHorRadiusFBack)
  double _waveVertRadiusVBack(Size size) {
    if (revealPercent <= 0) {
      return iconSize.height;
    }

    if (revealPercent >= 1) {
      return 0;
    }

    var p1 = 0.4;
    if (revealPercent <= p1) {
      return iconSize.height + revealPercent / p1 * iconSize.height;
    }

    var t = (revealPercent - p1) / (1.0 - p1);
    var A = iconSize.height + 8;
    var r = 40;
    var m = 9.8;
    var beta = r / (2 * m);
    var k = 50;
    var omega0 = k / m;
    var omega = pow(-pow(beta, 2) + pow(omega0, 2), 0.5);

    return A * exp(-beta * t) * cos(omega * t);
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
