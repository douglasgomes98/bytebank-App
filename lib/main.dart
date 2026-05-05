import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Ponto de entrada da aplicação.
///
/// Inicializa o Firebase, prepara a formatação de datas para o locale
/// `pt_BR` e dispara a [ByteBankApp], que constrói o composition root
/// (camada `core/di/`) e disponibiliza os controllers via
/// `MultiProvider`.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('pt_BR', null);

  runApp(ByteBankApp());
}
