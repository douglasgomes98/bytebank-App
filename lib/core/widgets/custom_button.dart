import 'package:flutter/material.dart';

/// Botão de ação primário reutilizado em toda a aplicação.
///
/// Encapsula um [ElevatedButton] (ou [OutlinedButton] quando [isOutlined]
/// é `true`) e renderiza um [CircularProgressIndicator] no lugar do rótulo
/// enquanto [isLoading] estiver `true`, desabilitando o botão para evitar
/// toques duplicados.
class CustomButton extends StatelessWidget {
  /// Texto exibido dentro do botão.
  final String label;

  /// Callback invocado ao toque. Ignorado quando [isLoading] é `true`.
  final VoidCallback? onPressed;

  /// Quando `true`, exibe o spinner e o botão fica não-interativo.
  final bool isLoading;

  /// Renderiza o botão usando [OutlinedButton] em vez de [ElevatedButton].
  final bool isOutlined;

  /// Ícone opcional exibido à esquerda do [label].
  final IconData? icon;

  /// Sobrescreve a cor de fundo (ou da borda, quando [isOutlined]).
  final Color? color;

  /// Cria um [CustomButton].
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: color != null
          ? ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )
          : null,
      child: child,
    );
  }
}
