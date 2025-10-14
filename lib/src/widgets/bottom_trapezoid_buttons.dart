//import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class BottomTrapezoidButtons extends StatelessWidget {
  const BottomTrapezoidButtons({
    super.key,
    required this.onStart,
    required this.onContinue,
    required this.onOptions,
    this.height = 170,
    this.topLeftY = 0,     // sin “metida”: lado izquierdo arranca en y=0
    this.topRightY = 0,    // sin “metida”: lado derecho arranca en y=0
    this.splitRatio = 0.55,
    this.containerColor,
    this.buttonFillOpacity = 0.08,
    this.buttonStrokeOpacity = 0.30,
    this.yLeftSplit = 56, // valor x defecto para la caida de la división izquierda horizontal
    this.leftSplitLeftY = 56,   // altura en el lado izquierdo de la división izquierda
    this.leftSplitRightY = 30, // altura en el lado derecho de la división izquierda
  });

  final VoidCallback onStart;
  final VoidCallback onContinue;
  final VoidCallback onOptions;

  /// Altura del trapecio contenedor
  final double height;

  final double topLeftY;   // altura del borde superior en la izquierda (px)
  final double topRightY;  // altura del borde superior en la derecha (px)

  /// Porción horizontal de la columna izquierda (0…1)
  final double splitRatio;

  /// Color del trapecio de fondo (si null, usa un tono del tema)
  final Color? containerColor;

  /// Estética de los botones (fill/stroke)
  final double buttonFillOpacity;
  final double buttonStrokeOpacity;

  // distancia vertical desde el top hasta la división izq
  final double yLeftSplit;
  final double leftSplitLeftY;   
  final double leftSplitRightY;  

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            // y en el borde superior para cualquier x (recta entre topLeftY y topRightY)
            double yTop(double x) => topLeftY + (topRightY - topLeftY) * (x / w);
            

            // contenedor (laterales verticales; top inclinado)
            Path containerPath() {
              return Path()
                ..moveTo(0, yTop(0))     // (0, topLeftY)
                ..lineTo(w, yTop(w))     // (w, topRightY)
                ..lineTo(w, h)           // (w, h)
                ..lineTo(0, h)           // (0, h)
                ..close();
            }

            // división vertical fija (x constante)
            final xSplit = w * splitRatio;
            // división horizontal para los dos botones izquierdos
            final midY = h / 1.6;

            //caida de la división izquierda
            double yLeftSplit(double x) {
              final t = (x / xSplit).clamp(0.0, 1.0);
              return leftSplitLeftY + (leftSplitRightY - leftSplitLeftY) * t;
            }

            // polígonos
            Path leftTop() => Path()
              ..moveTo(0, yTop(0))
              ..lineTo(xSplit, yTop(xSplit))
              ..lineTo(xSplit, yLeftSplit(xSplit))
              ..lineTo(0, yLeftSplit(0))
              ..close();

            Path leftBottom() => Path()
              ..moveTo(0, yLeftSplit(0))
              ..lineTo(xSplit, yLeftSplit(xSplit))
              ..lineTo(xSplit, h)
              ..lineTo(0, h)
              ..close();

            Path rightFull() => Path()
              ..moveTo(xSplit, yTop(xSplit))
              ..lineTo(w, yTop(w))
              ..lineTo(w, h)
              ..lineTo(xSplit, h)
              ..close();

            final cs = Theme.of(context).colorScheme;
            final bgColor = containerColor ?? const Color(0xFF7A1E1A);
            final fill   = cs.primary.withOpacity(buttonFillOpacity);
            final border = cs.primary.withOpacity(buttonStrokeOpacity);

            Widget polyButton({
              required Path Function() pathBuilder,
              required VoidCallback onTap,
              required Widget label,
            }) {
              return CustomPaint(
                painter: _PolyPainter(pathBuilder, fill, border),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    customBorder: _PolygonBorder((_) => pathBuilder()),
                    splashFactory: InkRipple.splashFactory,
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            }

            return ClipPath(
              clipper: _PathClipper(containerPath),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _PolyFillOnly(containerPath, bgColor)),

                  // Izquierda arriba
                  polyButton(
                    pathBuilder: leftTop,
                    onTap: onStart,
                    label: _btnLabel(context, 'COMENZAR', Icons.play_arrow_rounded),
                  ),

                  // Izquierda abajo
                  polyButton(
                    pathBuilder: leftBottom,
                    onTap: onContinue,
                    label: _btnLabel(context, 'CONTINUAR', Icons.history_rounded),
                  ),

                  // Derecha completa
                  polyButton(
                    pathBuilder: rightFull,
                    onTap: onOptions,
                    label: _btnLabel(context, 'OPCIONES', Icons.tune_rounded),
                  ),

                  // Etiquetas centradas (opcional y editable)
                  _centerLabel(leftTop,     _btnLabel(context, 'COMENZAR',  Icons.play_arrow_rounded)),
                  _centerLabel(leftBottom,  _btnLabel(context, 'CONTINUAR', Icons.history_rounded)),
                  _centerLabel(rightFull,   _btnLabel(context, 'OPCIONES',  Icons.tune_rounded)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _centerLabel(Path Function() path, Widget child) {
    // Centrado visual simple: usamos Stack + Center
    
    return IgnorePointer(child: Center(child: child));
  }

  static Widget _btnLabel(BuildContext context, String text, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onPrimary),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onPrimary)),
        ],
      ),
    );
  }
}

/// ==== helpers privados ====

class _PolygonBorder extends ShapeBorder {
  final Path Function(Rect) buildPath;
  const _PolygonBorder(this.buildPath);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => buildPath(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);
}

class _PolyPainter extends CustomPainter {
  final Path Function() build;
  final Color fill;
  final Color stroke;
  _PolyPainter(this.build, this.fill, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final p = build();
    final fillPaint = Paint()..color = fill..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(p, fillPaint);
    canvas.drawPath(p, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _PolyPainter old) => false;
}

class _PolyFillOnly extends CustomPainter {
  final Path Function() build;
  final Color fill;
  _PolyFillOnly(this.build, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    final p = build();
    final paint = Paint()..color = fill..style = PaintingStyle.fill;
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant _PolyFillOnly old) => false;
}

class _PathClipper extends CustomClipper<Path> {
  final Path Function() build;
  _PathClipper(this.build);

  @override
  Path getClip(Size size) => build();

  @override
  bool shouldReclip(covariant _PathClipper oldClipper) => false;
}
// Fin de este horror