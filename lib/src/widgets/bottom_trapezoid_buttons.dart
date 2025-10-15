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
            // división horizontal para los dos botones izquierdos -> se dejo de usar para poder hacer linea con caida
            // final midY = h / 1.6;

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

            //final cs = Theme.of(context).colorScheme;
            //final bgColor = containerColor ?? const Color(0xFF7A1E1A);
            //final fill   = cs.primary.withAlpha((255 * buttonFillOpacity).round());
            //final border = cs.primary.withAlpha((255 * buttonStrokeOpacity).round());

            /*
            para poder usar imagen onTapDown, hubo que eliminar este Widget y crear un class que maneje estados
            Widget polyButton({
              required Path Function() pathBuilder,
              required VoidCallback onTap,
              // required Widget label,
              String? pngAsset,                 // <-- PNG de fondo!
              BoxFit imageFit = BoxFit.cover,
              Alignment imageAlignment = Alignment.center
            }) {
              final p = pathBuilder();
              final bounds = p.getBounds();
              // Path trasladado a (0,0) para el ClipPath local
              final localPath = p.shift(-bounds.topLeft);


              return Stack(
                fit: StackFit.expand,
                children: [
                  if (pngAsset != null)
                    Positioned.fromRect(
                      rect: bounds,
                      child: ClipPath(
                        clipper: _LocalPathClipper(localPath),
                        child: Image.asset(
                          pngAsset,
                          // fit: imageFit,
                          fit: BoxFit.fill,              // cover para llenar el polígono!
                          alignment: imageAlignment,
                        ),
                      ),
                    ),
                
                    // interacción y splash, recortada al polígono
                    /* Imagenes ok, pero no hit-test de los botones
                     Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: onTap,
                          //customBorder: _PolygonBorder((_) => pathBuilder()), // <- hit-test poligonal
                          customBorder: _PolygonBorder((_) => p),
                          splashFactory: InkRipple.splashFactory,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      */

                    // PRUEBA: limitar al rectángulo del polígono + clip de hit-test
                      Positioned.fromRect(
                        rect: bounds,
                        child: ClipPath(
                          clipper: _LocalPathClipper(localPath), // <- clippea pintura y hit-test
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: onTap,
                              
                              customBorder: _PolygonBorder((_) => p),
                              splashFactory: InkRipple.splashFactory,
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    // Overlay (texto/icono) centrado y sin interceptar taps
                    //  if (overlay != null)
                    //    IgnorePointer(
                    //      child: Center(child: overlay),
                    //    ),
                    ],
                  );
                }
                 */ 
                

            

            return ClipPath(
              clipper: _PathClipper(containerPath),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // CustomPaint(painter: _PolyFillOnly(containerPath, bgColor)),

                  // Izquierda arriba
                  _PolyImageButton(
                    pathBuilder: leftTop,
                    onTap: onStart,
                    // label: _btnLabel(context, 'COMENZAR', Icons.play_arrow_rounded),
                    assetNormal: 'assets/images/btn_start1.png',
                    assetPressed: 'assets/images/btn_start2.png',
                  ),

                  // Izquierda abajo
                  _PolyImageButton(
                    pathBuilder: leftBottom,
                    onTap: onContinue,
                    //label: _btnLabel(context, 'CONTINUAR', Icons.history_rounded),
                    assetNormal: 'assets/images/btn_cont1.png',
                    assetPressed: 'assets/images/btn_cont2.png',
                  ),

                  // Derecha completa
                  _PolyImageButton(
                    pathBuilder: rightFull,
                    onTap: onOptions,
                    //label: _btnLabel(context, 'OPCIONES', Icons.tune_rounded),
                    assetNormal: 'assets/images/btn_opt1.png',
                    assetPressed: 'assets/images/btn_opt2.png',
                  ),

                  // Etiquetas centradas (opcional y editable)
                  //_centerLabel(leftTop,     _btnLabel(context, 'COMENZAR',  Icons.play_arrow_rounded)),
                  //_centerLabel(leftBottom,  _btnLabel(context, 'CONTINUAR', Icons.history_rounded)),
                  //_centerLabel(rightFull,   _btnLabel(context, 'OPCIONES',  Icons.tune_rounded)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /*
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
  }*/
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

/* Prueba inicial con pintura. Despues se optó por usar imágenes.
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
*/
class _PathClipper extends CustomClipper<Path> {
  final Path Function() build;
  _PathClipper(this.build);

  @override
  Path getClip(Size size) => build();

  @override
  bool shouldReclip(covariant _PathClipper oldClipper) => false;
}
/// Clipper que recibe un path ya en coordenadas locales (0..width, 0..height)
class _LocalPathClipper extends CustomClipper<Path> {
  final Path path;
  _LocalPathClipper(this.path);
  @override
  Path getClip(Size size) => path;
  @override
  bool shouldReclip(covariant _LocalPathClipper oldClipper) => false;
}


// Widget para usar imagenes para estados normal/pressed
class _PolyImageButton extends StatefulWidget {
  const _PolyImageButton({
    super.key,
    required this.pathBuilder,
    required this.onTap,
    required this.assetNormal,
    required this.assetPressed,
    //this.fit = BoxFit.fill,
    //this.alignment = Alignment.center,
    
  });

  final Path Function() pathBuilder;
  final VoidCallback onTap;
  final String assetNormal;
  final String assetPressed;
  //final BoxFit fit;
  //final Alignment alignment;

  @override
  State<_PolyImageButton> createState() => _PolyImageButtonState();
}

class _PolyImageButtonState extends State<_PolyImageButton> {
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    // Precarga para que no haya flicker al primer press
    precacheImage(AssetImage(widget.assetNormal), context);
    precacheImage(AssetImage(widget.assetPressed), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pathBuilder();
    final bounds = p.getBounds();
    final localPath = p.shift(-bounds.topLeft);
    final asset = _pressed ? widget.assetPressed : widget.assetNormal;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen recortada al polígono, escalada al bounding box del polígono
        Positioned.fromRect(
          rect: bounds,
          child: ClipPath(
            clipper: _LocalPathClipper(localPath),
            child: Image.asset(
              asset,
              fit: BoxFit.fill,
              alignment: Alignment.center,
            ),
          ),
        ),

        // Interacción: limitada al polígono (clip) y splash recortado
        Positioned.fromRect(
          rect: bounds,
          child: ClipPath(
            clipper: _LocalPathClipper(localPath),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                customBorder: _PolygonBorder((_) => p),
                // Desactiva overlays para ver solo el  solo el swap de imagen
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// Fin de este horror