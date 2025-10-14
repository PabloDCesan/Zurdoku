import 'package:flutter/material.dart';

class NumberButtons extends StatelessWidget {
  final Function(int) onNumberPressed;
  final Function()? onClearPressed;
  final Function()? onUndoPressed;

  const NumberButtons({
    super.key,
    required this.onNumberPressed,
    this.onClearPressed,
    this.onUndoPressed,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botones de números
          Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            //mainAxisSize: MainAxisSize.min,
            
            children: List.generate(9, (index) {
              final number = index + 1;
              return _buildNumberButton(
                context,
                number.toString(),
                () => onNumberPressed(number),
              );
            }),
          ),
          
          // box para separarar los numeros de los botones de acción
          const SizedBox(height: 16),
          
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (onUndoPressed != null)
                _buildActionButton(
                  context,
                  'Deshacer',
                  Icons.undo,
                  onUndoPressed!,
                ),
              
              _buildActionButton(
                context,
                'Borrar',
                Icons.clear,
                onClearPressed ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(BuildContext context, String text, VoidCallback onPressed) {
    // el widget que contiene el espacio
    final screenWidth = MediaQuery.of(context).size.width;
    // El tamaño del num es el ancho disponible dividido por 10
    final numSize = screenWidth / 10;
    
    return SizedBox(
      width: numSize,
      //height: 30,
      
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Theme.of(context).primaryColor.withValues(alpha:0.3),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    //final theme = Theme.of(context);
    
    return SizedBox(
      height:  (MediaQuery.of(context).size.height) * 0.05,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade600,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
