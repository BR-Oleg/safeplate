import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.text = 'Continuar com Google',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        side: BorderSide(color: Colors.grey.shade400, width: 1),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black54,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo do Google simplificado
                _buildGoogleLogoIcon(),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGoogleLogoIcon() {
    // Criar um ícone simplificado do Google usando formas
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Círculo azul (G)
    paint.color = const Color(0xFF4285F4);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.35),
      size.width * 0.2,
      paint,
    );
    
    // Parte verde
    paint.color = const Color(0xFF34A853);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.55, size.width * 0.25, size.height * 0.15),
      paint,
    );
    
    // Parte amarela
    paint.color = const Color(0xFFFBBC05);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.65, size.width * 0.3, size.height * 0.15),
      paint,
    );
    
    // Parte vermelha
    paint.color = const Color(0xFFEA4335);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.55, size.width * 0.2, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

