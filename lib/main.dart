import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/security/app_check_bootstrap.dart';
import 'firebase_options.dart';

/// Ponto de entrada da aplicação.
///
/// Inicializa o Firebase, ativa o App Check (verificação de
/// integridade de plataforma) e prepara a formatação de datas para o
/// locale `pt_BR` antes de subir a [ByteBankApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppCheckBootstrap.activate();

  await initializeDateFormatting('pt_BR', null);

  runApp(ByteBankApp());
}
