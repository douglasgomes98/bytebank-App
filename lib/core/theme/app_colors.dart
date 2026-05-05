import 'package:flutter/material.dart';

/// Paleta de cores utilizada em toda a aplicação ByteBank.
///
/// Centralizar as cores aqui mantém telas e widgets livres de valores
/// mágicos e garante consistência entre os temas claro e escuro.
class AppColors {
  /// Cor primária - verde ByteBank.
  static const Color primary = Color(0xFF4A914F);

  /// Tom mais escuro de [primary], usado em gradientes e no tema escuro.
  static const Color primaryDark = Color(0xFF2E6B32);

  /// Tom mais claro de [primary], usado como cor primária no tema escuro.
  static const Color primaryLight = Color(0xFF6BB06F);

  /// Cor secundária de destaque.
  static const Color accent = Color(0xFF5FA463);

  /// Plano de fundo do `Scaffold` no tema claro.
  static const Color background = Color(0xFFF5F7FA);

  /// Plano de fundo do `Scaffold` no tema escuro.
  static const Color backgroundDark = Color(0xFF121212);

  /// Superfície (cartões, folhas, diálogos) no tema claro.
  static const Color surface = Color(0xFFFFFFFF);

  /// Superfície (cartões, folhas, diálogos) no tema escuro.
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Cor utilizada para destacar transações de receita.
  static const Color income = Color(0xFF2E7D32);

  /// Cor utilizada para destacar transações de despesa.
  static const Color expense = Color(0xFFC62828);

  /// Cor utilizada para destacar transações de transferência.
  static const Color transfer = Color(0xFF4A914F);

  /// Cor primária de texto no tema claro.
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Cor secundária de texto (legendas, dicas).
  static const Color textSecondary = Color(0xFF6B7280);

  /// Cor de texto utilizada sobre superfícies escuras.
  static const Color textLight = Color(0xFFFFFFFF);

  /// Cor utilizada por divisores e bordas.
  static const Color divider = Color(0xFFE5E7EB);

  /// Cor utilizada em estados de erro (snackbars, validadores).
  static const Color error = Color(0xFFD32F2F);

  /// Cor utilizada em estados de sucesso.
  static const Color success = Color(0xFF388E3C);

  /// Cor utilizada em estados de aviso.
  static const Color warning = Color(0xFFF57C00);
}
