# 🏦 ByteBank - Aplicativo de Simulação Bancária

<div align="center">
  <img src="assets/images/logo.png" alt="ByteBank Logo" width="200"/>
  
  **Aplicativo de simulação bancária desenvolvido em Flutter**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.10.8-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📋 Sobre o Projeto

ByteBank é uma aplicação mobile de simulação bancária desenvolvida como parte do **Tech Challenge da Fase 4** do curso de pós-graduação em **Front-End Engineering da FIAP**. 

O aplicativo permite aos usuários realizar operações bancárias simuladas como transferências, depósitos e saques, demonstrando habilidades em:
- Desenvolvimento Flutter com Material Design 3
- Clean Architecture (camadas de domínio, dados e apresentação) com modularização feature-first
- Gerenciamento de estado avançado com **Riverpod** (geração de código)
- Programação reativa com **Streams** e **RxDart**
- Roteamento declarativo com **go_router**
- Integração com Firebase (Auth, Firestore, Storage, App Check)
- Segurança em profundidade (OWASP MASVS v2.0.0): biometria, AES-GCM, Secure Storage, App Check, hardening do build
- Performance: paginação Firestore, precache de imagens, `RepaintBoundary`, R8/ProGuard

---

## ✨ Funcionalidades

### 🔐 Autenticação
- **Cadastro de usuários** com email e senha
- **Login** seguro via Firebase Authentication
- **Recuperação de senha** por e-mail
- **Logout** com confirmação

### 💰 Gestão Financeira
- **Dashboard** com saldo disponível, receitas e despesas
- **Histórico de transações** com filtros por tipo
- **Cadastro de transações** (receitas, despesas, transferências)
- **Upload de comprovantes** via Firebase Storage
- **Visualização detalhada** de cada transação
- **Busca** por descrição

### 🎨 Interface
- **Tema claro e escuro** alternável
- **Design responsivo** adaptado para diferentes telas
- **Animações fluidas** e transições suaves
- **Interface intuitiva** seguindo Material Design 3
- **Cores personalizadas** baseadas na identidade visual (verde)

---

## 🛠️ Stack Tecnológica

### Framework & Linguagem
- **Flutter**: ^3.10.8
- **Dart**: ^3.10.8

### Principais Dependências

#### Firebase
```yaml
firebase_core: ^3.13.0          # Núcleo do Firebase
firebase_auth: ^5.5.2           # Autenticação de usuários
cloud_firestore: ^5.6.5         # Banco de dados NoSQL
firebase_storage: ^12.4.4       # Armazenamento de arquivos
firebase_app_check: ^0.3.2      # Integridade de plataforma
```

#### Gerenciamento de Estado
```yaml
flutter_riverpod: ^2.5.1        # State management com AsyncNotifier/StreamProvider
riverpod_annotation: ^2.3.5     # Anotações para code generation
riverpod_generator: ^2.4.3      # (dev) Geração dos providers
build_runner: ^2.4.13           # (dev) Runner do code generation
```

#### Roteamento
```yaml
go_router: ^14.6.1              # Roteamento declarativo + redirect guard
```

#### Programação Reativa
```yaml
rxdart: ^0.28.0                 # debounceTime, BehaviorSubject, combineLatest
```

#### UI & Visualização
```yaml
fl_chart: ^0.70.2               # Gráficos e charts
intl: ^0.20.2                   # Internacionalização e formatação
animations: ^2.0.11             # Animações avançadas
```

#### Recursos de Imagem
```yaml
image_picker: ^1.1.2            # Seleção de imagens
cached_network_image: ^3.4.1   # Cache de imagens
```

#### Utilitários
```yaml
uuid: ^4.5.1                    # Geração de IDs únicos
path_provider: ^2.1.5           # Acesso a diretórios do sistema
shared_preferences: ^2.3.5      # Armazenamento local de preferências
```

#### Tipos Funcionais
```yaml
fpdart: ^1.1.0                  # Either/Failure no contrato do domínio
```

#### Segurança
```yaml
flutter_secure_storage: ^9.2.2  # Keystore/Keychain
local_auth: ^2.3.0              # Biometria local
cryptography: ^2.7.0            # AES-GCM (NIST SP 800-38D)
```

#### Testes
```yaml
flutter_test                    # Núcleo de testes Flutter
mocktail: ^1.0.4                # (dev) Mocks para repositórios e casos de uso
fake_cloud_firestore: ^3.0.3    # (dev) Firestore em memória
```

---

## 📁 Estrutura do Projeto

O projeto adota **Clean Architecture** com organização **feature-first**: cada
feature é um diretório autocontido subdividido em `domain/`, `data/` e
`presentation/`. O diretório `core/` agrega exclusivamente código transversal
sem regra de negócio.

```
lib/
├── main.dart                                  # Bootstrap: Firebase + App Check + Riverpod ProviderScope
├── app.dart                                   # MaterialApp.router + lock biométrico de ciclo de vida
├── firebase_options.dart                      # Configurações do Firebase
│
├── core/                                      # Código transversal sem regra de negócio
│   ├── providers/
│   │   └── core_providers.dart                # Providers de FirebaseAuth/Firestore/Storage
│   ├── error/
│   │   ├── failure.dart                       # Hierarquia selada de Failure
│   │   └── exceptions.dart                    # Exceções da camada de dados
│   ├── network/
│   │   └── network_info.dart                  # Contrato de checagem de rede
│   ├── security/
│   │   ├── secure_storage.dart                # Contrato de armazenamento seguro
│   │   ├── secure_storage_keys.dart           # Chaves usadas no Keychain/Keystore
│   │   ├── crypto_service.dart                # Contrato AES-GCM
│   │   ├── biometric_authenticator.dart       # Contrato de biometria
│   │   ├── app_check_bootstrap.dart           # Ativa Play Integrity/App Attest/Debug
│   │   └── session_lock_notifier.dart         # Notifier que bloqueia ao perder foco
│   ├── theme/
│   │   ├── app_theme.dart                     # ThemeData light/dark
│   │   └── app_colors.dart                    # Paleta de cores
│   ├── router/
│   │   ├── app_router.dart                    # GoRouter + redirect guard por auth
│   │   └── go_router_refresh_notifier.dart    # Ponte Riverpod → GoRouter refresh
│   ├── widgets/                               # Widgets reutilizáveis
│   │   ├── custom_button.dart
│   │   ├── loading_indicator.dart
│   │   └── splash_screen.dart
│   └── utils/
│       ├── constants.dart                     # Constantes da aplicação
│       ├── formatters.dart                    # Formatação de moeda/datas
│       ├── validators.dart                    # Validadores de formulário
│       └── secure_logger.dart                 # Logger no-op em kReleaseMode
│
└── features/                                  # Features do produto
    ├── auth/
    │   ├── providers/
    │   │   └── auth_providers.dart            # @Riverpod para repo, datasource e use cases
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── app_user.dart              # Entidade de usuário (Dart puro)
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart       # Contrato (abstract class)
    │   │   └── usecases/
    │   │       ├── sign_in.dart
    │   │       ├── sign_up.dart
    │   │       ├── sign_out.dart
    │   │       ├── reset_password.dart
    │   │       ├── get_current_user.dart
    │   │       ├── watch_auth_state.dart
    │   │       └── ensure_fresh_session.dart  # Força refresh do ID token
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── firebase_auth_data_source.dart
    │   │   ├── dtos/
    │   │   │   └── user_dto.dart              # fromMap/toMap, toEntity/fromEntity
    │   │   ├── repositories/
    │   │   │   └── auth_repository_impl.dart  # Traduz Exception em Failure
    │   │   └── security/                      # Implementações de contratos do core
    │   │       ├── aes_gcm_crypto_service.dart
    │   │       ├── flutter_secure_storage_adapter.dart
    │   │       └── local_auth_biometric_authenticator.dart
    │   └── presentation/
    │       ├── controllers/
    │       │   └── auth_notifier.dart         # AsyncNotifier + StreamProvider
    │       └── screens/
    │           ├── login_screen.dart
    │           └── register_screen.dart
    │
    ├── transactions/
    │   ├── providers/
    │   │   └── transaction_providers.dart     # @Riverpod para repo, datasources, use cases
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── transaction_entity.dart    # Renomeada para evitar colisão
    │   │   │   ├── transaction_type.dart
    │   │   │   ├── transaction_category.dart
    │   │   │   └── transaction_ui_state.dart
    │   │   ├── repositories/
    │   │   │   └── transaction_repository.dart
    │   │   └── usecases/
    │   │       ├── watch_transactions.dart    # Stream<Either<Failure, List<...>>>
    │   │       ├── fetch_next_page.dart       # Paginação cursor-based
    │   │       ├── create_transaction.dart
    │   │       ├── update_transaction.dart
    │   │       └── delete_transaction.dart
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── firestore_transaction_data_source.dart
    │   │   │   └── firebase_storage_data_source.dart
    │   │   ├── dtos/
    │   │   │   └── transaction_dto.dart
    │   │   └── repositories/
    │   │       └── transaction_repository_impl.dart
    │   └── presentation/
    │       ├── controllers/
    │       │   └── transaction_notifier.dart  # AsyncNotifier + merge realtime/pagination
    │       ├── providers/
    │       │   └── filtered_transactions_provider.dart  # debounceTime + filtro derivado
    │       ├── screens/
    │       │   ├── dashboard_screen.dart
    │       │   ├── transaction_list_screen.dart
    │       │   ├── transaction_form_screen.dart
    │       │   └── transaction_detail_screen.dart
    │       └── widgets/
    │           └── transaction_card.dart
    │
    └── profile/
        ├── providers/
        │   └── profile_providers.dart         # @Riverpod do repo e use cases de tema
        ├── domain/
        │   ├── entities/
        │   │   └── app_theme_mode.dart        # Enum de domínio para tema
        │   ├── repositories/
        │   │   └── theme_repository.dart
        │   └── usecases/
        │       ├── get_theme_mode.dart
        │       └── set_theme_mode.dart
        ├── data/
        │   ├── datasources/
        │   │   └── preferences_data_source.dart
        │   └── repositories/
        │       └── theme_repository_impl.dart
        └── presentation/
            ├── controllers/
            │   └── theme_notifier.dart        # AsyncNotifier de ThemeMode
            └── screens/
                └── profile_screen.dart
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

Certifique-se de ter instalado:
- **Flutter SDK** (versão 3.10.8 ou superior)
- **Dart SDK** (versão 3.10.8 ou superior)
- **Android Studio** ou **Xcode** (para iOS)
- **Git**
- Conta no **Firebase Console**

### Passo 1: Clone o Repositório

```bash
git clone https://github.com/seu-usuario/bytebankApp.git
cd bytebankApp
```

### Passo 2: Configuração do Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto Firebase
3. Adicione um app Android e/ou iOS ao projeto
4. Baixe os arquivos de configuração:
   - **Android**: `google-services.json` → coloque em `android/app/`
   - **iOS**: `GoogleService-Info.plist` → coloque em `ios/Runner/`

5. **Configure o arquivo firebase_options.dart:**
   ```bash
   # Copie o arquivo de exemplo
   cp lib/firebase_options.dart.example lib/firebase_options.dart
   ```
   - Abra `lib/firebase_options.dart`
   - Substitua os valores de placeholder (`YOUR_*`) com as configurações reais do seu projeto Firebase
   - **IMPORTANTE**: NÃO faça commit deste arquivo! Ele já está no `.gitignore`

6. **Habilite os serviços no Firebase Console:**

   **Authentication:**
   - Acesse `Authentication` > `Sign-in method`
   - Habilite **Email/Password**

   **Cloud Firestore:**
   - Acesse `Firestore Database`
   - Crie um banco de dados
   - Configure as regras de segurança (use as de `firestore.rules`)

   **Storage:**
   - Acesse `Storage`
   - Ative o Firebase Storage
   - Configure as regras de segurança (use as de `storage.rules`)

### Passo 3: Instalar Dependências

```bash
flutter pub get
```

### Passo 4: Executar a Aplicação

#### Android
```bash
flutter run
```

#### iOS (somente em macOS)
```bash
cd ios
pod install
cd ..
flutter run
```

#### Build para Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 🎨 Personalização do Ícone

O projeto usa `flutter_launcher_icons` para gerenciar os ícones da aplicação.

Para personalizar o ícone:

1. Coloque seu logo em `assets/images/logo.png` (recomendado: 1024x1024px)
2. Execute:
```bash
flutter pub run flutter_launcher_icons
```

---

## 🔥 Configuração do Firebase

### Arquivos versionados

| Arquivo | Função |
|---------|--------|
| `firebase.json` | Aponta para `firestore.rules`, `firestore.indexes.json` e `storage.rules`, permitindo deploy via CLI. |
| `firestore.rules` | Rules do Firestore com validação de schema (`hasOnly`, tipos, limites de valor e tamanho, imutabilidade de `userId`/`createdAt` em update). |
| `firestore.indexes.json` | Índice composto `(userId ASC, date DESC)` exigido pelo listener em tempo real de transações. |
| `storage.rules` | Rules de Storage que isolam comprovantes por `userId`, exigem `image/*` e tamanho máximo de 5 MiB. |

### Regras do Firestore (resumo)

- `users/{userId}`: leitura/escrita só pelo próprio usuário; payload
  validado por `isUserPayload` (`name`, `email`, `balance`,
  `createdAt`, `avatarUrl?`).
- `transactions/{id}`: leitura/escrita só pelo dono (`auth.uid ==
  resource.data.userId`). Em `create`, payload validado por
  `isTransactionPayload` — bloqueia `amount` inválido, tipo fora do
  enum, descrição vazia ou maior que 200 caracteres, etc. Em `update`,
  `userId` e `createdAt` são imutáveis.

### Regras do Storage (resumo)

- `receipts/{userId}/**`: leitura e escrita apenas pelo próprio usuário.
- Upload bloqueado se `request.resource.size >= 5 MiB` ou
  `contentType` não corresponder a `image/.*`.

### Deploy via Firebase CLI

```bash
# Login interativo (uma vez por máquina)
firebase login

# Seleciona o projeto
firebase use bytebankapp-3fe6b

# Deploy granular
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only storage

# Ou tudo de uma vez:
firebase deploy
```

> **Atenção**: o "modo teste" padrão do Firestore/Storage tem expiração
> em 30 dias (rule `allow read, write: if request.time <
> timestamp.date(...)`). Se o projeto foi criado em modo teste e
> nunca recebeu deploy, todas as escritas começam a falhar com
> `Permission denied` ao expirar. Use os arquivos do repo.

---

## Segurança

A camada transversal de segurança implementa os controles previstos no item 9
da proposta arquitetural, com referências aos requisitos do OWASP MASVS v2.0.0.

### Controles aplicados

- **Autenticação**: Firebase Authentication mantido como provedor remoto;
  biometria local opcional (`local_auth`) gateando a reabertura do app
  quando habilitada pelo usuário.
- **Token freshness**: cada operação sensível (criação, atualização e
  exclusão de transação) força um refresh do ID token via caso de uso
  `EnsureFreshSession` antes da gravação no Firestore.
- **Armazenamento seguro**: dados sensíveis em Keychain (iOS) e
  EncryptedSharedPreferences/Keystore (Android), via
  `flutter_secure_storage`.
- **Criptografia em repouso**: AES-GCM 256 (NIST SP 800-38D) sobre dados
  cacheados localmente, com chave mestra gerada na primeira execução e
  persistida exclusivamente no enclave do sistema operacional.
- **Comunicação**: TLS obrigatório. Tráfego cleartext bloqueado em Android
  (`usesCleartextTraffic="false"` + Network Security Config) e em iOS
  (`NSAppTransportSecurity` com `NSAllowsArbitraryLoads=false`).
- **Integridade de plataforma**: Firebase App Check com Play Integrity
  (Android), App Attest com fallback para DeviceCheck (iOS) e
  DebugProvider em modo desenvolvimento.
- **Hardening do build (Android release)**: R8/ProGuard com regras
  específicas para Firebase, Flutter Engine, `local_auth` e
  `flutter_secure_storage`; `allowBackup="false"` e
  `dataExtractionRules` excluindo dados do app.
- **Logger seguro**: utilitário com supressão automática em
  `kReleaseMode` e helper para redatar identificadores antes de
  qualquer escrita.
- **Regras Firebase**: validação de schema (campos obrigatórios, tipos,
  limites de valor e tamanho) em `firestore.rules`; restrição a
  `image/*` e tamanho máximo de 5 MiB em `storage.rules`.

### Configuração obrigatória no Firebase Console

App Check exige cadastro fora do código:

1. `Build > App Check > Apps > [app Android]` > `Manage debug tokens`:
   adicionar o UUID que o SDK imprime no log na primeira execução em
   debug. Sem esse passo, builds debug são bloqueados quando o
   enforcement estiver ativo.
2. Em release, registrar Play Integrity (Android) com o SHA-256 da
   chave de assinatura e App Attest (iOS) com Team ID + Key ID.
3. Manter App Check em modo **Monitor** em Firestore, Storage e
   Authentication antes de habilitar **Enforce**, evitando bloquear
   versões antigas em produção durante a transição.

Após atualizar `firestore.rules` e `storage.rules` localmente, publicar:

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

### Build endurecido (release Android)

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols/
```

A flag `--obfuscate` ofusca os símbolos Dart; `--split-debug-info`
preserva os símbolos fora do APK para depuração futura. R8/ProGuard são
acionados automaticamente pelo `build.gradle.kts`.

### Validação da biometria em emulador Android

Em emuladores, a UI de cadastro de impressão digital frequentemente não
persiste a biometria no `BiometricService` se o evento de toque do
sensor virtual não for explicitamente sinalizado. O fluxo de validação
é:

1. Em **Settings > Security & privacy > Device unlock**, configurar um
   PIN como bloqueio de tela (sem isso o Android não permite biometria
   real).
2. Em **Fingerprint Unlock**, iniciar o cadastro.
3. Quando o sistema solicitar **"Touch the sensor"**, simular o toque
   pelo `adb`:

   ```bash
   adb -e emu finger touch 1
   ```

   Repetir o comando até o sistema concluir o cadastro.
4. Verificar a contagem efetiva de impressões registradas:

   ```bash
   adb shell 'dumpsys fingerprint | grep count'
   ```

   `count: 1` (ou maior) indica que o `BiometricService` reconhece a
   biometria.
5. Após login no app, abrir **Perfil** e ativar **"Bloqueio por
   biometria"**. Mover o app para background e retornar (ou matar e
   reabrir): a tela "Acesso bloqueado" exigirá reconfirmação biométrica
   antes de mostrar conteúdo sensível.

---

## 🏗️ Arquitetura

O projeto adota **Clean Architecture** em três camadas, organizadas por feature
(`auth`, `transactions`, `profile`). A regra de dependência aponta sempre para
o domínio: `Presentation → Domain ← Data`.

### 1. Domínio (`features/<x>/domain/`)

- **Entidades**: classes Dart puras, imutáveis, sem qualquer import de
  `package:flutter`, `package:firebase_*` ou `package:cloud_firestore`.
- **Repositórios (interfaces)**: contratos `abstract class` que descrevem
  operações de negócio em termos de entidades, retornando
  `Future<Either<Failure, T>>` ou `Stream<T>`.
- **Casos de Uso**: classes com método único `call(...)` encapsulando uma
  intenção do usuário (`SignIn`, `CreateTransaction`, `WatchTransactions`,
  etc.).

### 2. Dados (`features/<x>/data/`)

- **DTOs**: representam o formato remoto (Firestore). Possuem `fromMap`/
  `toMap` e `toEntity()`/`fromEntity()`, isolando o esquema remoto do
  domínio.
- **Data Sources**: classes que falam diretamente com Firebase
  (`firebase_auth`, `cloud_firestore`, `firebase_storage`) e
  `shared_preferences`. Não conhecem entidades.
- **Repositórios (implementações)**: traduzem `Exception` em `Failure`
  tipadas e orquestram fontes de dados.

### 3. Apresentação (`features/<x>/presentation/`)

- **Notifiers** (Riverpod `AsyncNotifier` / `StreamProvider`): invocam
  casos de uso e expõem `AsyncValue<UiState>` para a UI consumir via
  `ref.watch`. Não conhecem Firebase nem repositórios diretamente.
- **Screens e Widgets**: consomem o estado dos notifiers com `ref.watch`
  e renderizam a UI; nunca chamam casos de uso ou Firebase diretamente.
  Efeitos colaterais (navegação, snackbars) usam `ref.listen` sem
  rebuild.

### Diagrama de Dependências

```
Presentation ──► Domain ◄── Data
   (Flutter)    (Dart puro)   (Firebase, shared_preferences)
```

Apresentação e Dados dependem do Domínio; o Domínio não depende de ninguém.

### Composition Root

Não há DI manual nem `get_it`. Cada feature mantém um arquivo
`providers/<x>_providers.dart` anotado com `@Riverpod(keepAlive: true)`
que monta a árvore de objetos da feature (datasources → repositórios →
casos de uso). Esses providers são consumidos pelos notifiers via
`ref.watch`. A árvore inteira é instanciada lazily na primeira leitura e
mantida viva pelo `ProviderScope` em `main.dart`.

---

## 📱 Fluxo da Aplicação

1. **Autenticação**
   - Usuário acessa a tela de login
   - Pode criar uma nova conta ou fazer login
   - Após login, é redirecionado ao Dashboard

2. **Dashboard**
   - Exibe resumo financeiro (saldo, receitas, despesas)
   - Lista últimas transações
   - Acesso rápido às funcionalidades

3. **Transações**
   - Visualizar todas as transações
   - Filtrar por tipo (receitas, despesas, transferências)
   - Adicionar nova transação com upload de comprovante
   - Ver detalhes e editar/excluir transações

4. **Perfil**
   - Visualizar informações do usuário
   - Alternar tema claro/escuro
   - Fazer logout

---

## 🧠 Gerenciamento de Estado (Riverpod)

O projeto substitui o `provider`/`ChangeNotifier` da Fase 3 por
**Riverpod com geração de código**:

- **`@Riverpod(keepAlive: true)`** declara providers para repositórios e
  casos de uso, substituindo containers de DI tradicionais.
- **`AsyncNotifier<T>`** controla telas com efeitos colaterais (login,
  criação de transação). O estado é `AsyncValue<T>` — `loading`,
  `error` e `data` exaustivos via `.when(...)`.
- **`StreamProvider<T>`** expõe a stream de autenticação. O notifier de
  transações abre seu próprio listener Firestore e mescla os snapshots
  em tempo real com a página corrente.
- **`ref.watch`** declara dependências reativas entre providers.
- **`ref.listen`** dispara efeitos colaterais (navegação, refresh do
  router) sem causar rebuild.
- **`ref.invalidate(provider)`** força reconstrução — usado no
  pull-to-refresh do dashboard.

Geração de código (necessária após alterar providers):

```bash
dart run build_runner build --delete-conflicting-outputs
# ou em modo watch durante o desenvolvimento:
dart run build_runner watch --delete-conflicting-outputs
```

---

## 🔄 Programação Reativa

Streams são cidadãos de primeira classe na camada de dados:

- **Firestore reativo**: `TransactionRepository.watchTransactions` retorna
  `Stream<Either<Failure, List<TransactionEntity>>>` — o snapshot
  listener do Firestore não é "achatado" em `Future`.
- **Composição com RxDart**:
  - `BehaviorSubject<String>` + `debounceTime(300ms)` no campo de busca
    de transações, para reduzir custo de filtragem.
  - `startWith('')` para garantir emissão inicial e permitir que o
    provider derivado renderize imediatamente.
- **Estados derivados**:
  `filteredTransactionsProvider` combina o estado do notifier de
  transações com a query debounced via `ref.watch`, atualizando
  automaticamente quando qualquer um dos dois muda.

---

## ⚡ Performance

- **Roteamento declarativo**: `go_router` substitui o `Navigator`
  imperativo, permite redirect guard por estado de autenticação e
  inicialização preguiçosa das telas.
- **Paginação cursor-based** no Firestore (`query.limit(N) +
  startAfterDocument(lastDoc)`) através do caso de uso
  `FetchNextPage`. O `TransactionNotifier` faz merge entre a página
  paginada e o stream em tempo real, deduplicando por id.
- **Persistência offline explícita**:
  `FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED)`
  em `main.dart`.
- **Índice composto Firestore**: declarado em
  `firestore.indexes.json` (`userId ASC, date DESC`), requerido pelo
  listener em tempo real. Sem ele a query `.snapshots()` falha com
  `FAILED_PRECONDITION`.
- **`precacheImage`** do logo na primeira `didChangeDependencies` do
  `ByteBankApp`.
- **`RepaintBoundary`** isolando o card de saldo do dashboard.
- **`const` agressivo** em widgets folhas; reforçado pelo lint
  `prefer_const_constructors`.
- **R8/ProGuard**: `isMinifyEnabled = true` e `isShrinkResources = true`
  no `android/app/build.gradle.kts` (build release).
- **Ofuscação de símbolos Dart** disponível via flag
  `--obfuscate --split-debug-info=build/symbols/` no `flutter build`.

---

## 🧪 Testes

A separação de camadas habilita estratégia piramidal:

| Tipo | Onde | Ferramentas |
|------|------|-------------|
| Unitário (domínio) | `test/features/<x>/domain/usecases/` | `flutter_test`, `mocktail` |
| Unitário (data) | `test/features/transactions/data/datasources/` | `flutter_test`, `fake_cloud_firestore` |
| Controller | `test/features/<x>/presentation/controllers/` | `ProviderContainer.overrideWith*`, `mocktail` |

Cobertura atual inclui:

- Todos os casos de uso de `auth` (`SignIn`, `SignUp`, `SignOut`,
  `ResetPassword`, `EnsureFreshSession`).
- Todos os casos de uso de `transactions` (`WatchTransactions`,
  `CreateTransaction`, `UpdateTransaction`, `DeleteTransaction`,
  `FetchNextPage`).
- Casos de uso de tema em `profile`.
- `FirestoreTransactionDataSource` com `fake_cloud_firestore`.
- `TransactionNotifier`: inicialização, paginação,
  `fetchNextPage`, deduplicação por id e gating por
  `EnsureFreshSession`.

```bash
flutter test
```

Para rodar um teste específico:

```bash
flutter test test/features/transactions/presentation/controllers/transaction_notifier_test.dart
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

---

## 👥 Autores

**Grupo 30 - FIAP Fase 4**

- Desenvolvido como Tech Challenge da Pós-Graduação Front-End Engineering

- Vitor Oliveira | RM368082
- Douglas Matos Gomes | RM366779

---

## 📄 Licença

Este projeto está sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---