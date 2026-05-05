import 'package:flutter/material.dart';

/// Indicador centralizado de carregamento ([CircularProgressIndicator])
/// com uma mensagem opcional abaixo.
///
/// Utilizado pelas telas para renderizar o estado de carregamento enquanto
/// um controller está processando um caso de uso.
class LoadingIndicator extends StatelessWidget {
  /// Legenda opcional exibida abaixo do spinner.
  final String? message;

  /// Cria um [LoadingIndicator].
  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
