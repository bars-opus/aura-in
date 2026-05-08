# NanoEmbryo Architecture

## Phase 0: Foundation & Quick Start

## 🎯 Overview

A production-ready Flutter starter template focusing on scalability, maintainability, and developer experience. This phase establishes the core architecture, environment configuration, design system, and essential utilities that all subsequent features depend on.

## 🚀 Quick Start

### Prerequisites

| Requirement | Version |
| ----------- | ------- |
| Flutter     | 3.16.0+ |
| Dart        | 3.2.0+  |
| Supabase    | Latest  |
| Mapbox      | Latest  |
| Sendbird    | Latest  |

### Setup Instructions

**1. Clone the repository**

```bash
git clone [repository-url]
cd nanoembryo
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Configure environment files**

```bash
mkdir -p assets/env
touch assets/env/.env.development
touch assets/env/.env.production
```

**4. Add environment variables**

`assets/env/.env.development`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SENDBIRD_APP_ID=your-sendbird-app-id
DEBUG=true
```

`assets/env/.env.production`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SENDBIRD_APP_ID=your-sendbird-app-id
DEBUG=false
```

**5. Run the app**

```bash
flutter run --flavor development
```

## 🏗️ Core Decisions

### 1. State Management: Riverpod

**Decision**: Riverpod for state management

**Why**:

- Compile-time safety and testability
- Better dependency injection than Provider
- No BuildContext required for providers
- Excellent for complex features like shop creation, booking, and worker management

### 2. Design System: Token-Based Architecture

**Decision**: Centralized design tokens in `lib/core/design_tokens/`

**Why**:

- Single source of truth for spacing, colors, typography
- Enables theming and brand consistency
- Easy design updates without code changes

**Implementation**: See `tokens.dart` for token categories

### 3. Localization Strategy

**Decision**: Flutter's official `gen-l10n` with ARB files

**Why**:

- Official Flutter solution with good IDE support
- JSON-based ARB files are translator-friendly
- Compile-time safety for missing translations

**Structure**: `lib/l10n/` for source files, `lib/l10n/generated/` for outputs

### 4. Database & Backend: Supabase

**Decision**: Supabase as backend-as-a-service (BaaS)

**Why**:

- PostgreSQL database
- Real-time subscriptions
- Row Level Security (RLS)
- Built-in authentication
- Storage for images and documents

### 5. Navigation: GoRouter

**Decision**: GoRouter for declarative routing

**Why**:

- Type-safe navigation
- Deep linking support
- Path-based navigation
- Redirection handling

## 📦 Environment Configuration

### Environment Files Structure

```
assets/
└── env/
    ├── .env.development
    └── .env.production
```

### Environment Variables

| Variable            | Purpose                | Required |
| ------------------- | ---------------------- | -------- |
| `SUPABASE_URL`      | Supabase project URL   | Yes      |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | Yes      |
| `SENDBIRD_APP_ID`   | Sendbird chat app ID   | Yes      |
| `DEBUG`             | Enable debug logging   | No       |

### Environment Class

**Location**: `lib/core/config/environment.dart`

**Features**:

- Singleton pattern prevents multiple initializations
- Automatic environment detection based on build mode
- Required variable validation with clear error messages
- Safe logging that masks sensitive keys
- Comprehensive error handling with user guidance

**Usage**:

```dart
await Environment.init();
final supabaseUrl = Environment.supabaseUrl;
```

### Supabase Client Initialization

**Location**: Integrated in `lib/main.dart`

**Initialization Flow**:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Environment.init()` - Load environment variables
3. `SharedPreferences` initialization
4. `Supabase.initialize()` - Connect to backend
5. DNS resolution test for connectivity verification
6. App run with `ProviderScope`

## 🎨 Design System

### Design Tokens

**Location**: `lib/core/design_tokens/tokens.dart`

| Category           | Purpose               | Example Values                                      |
| ------------------ | --------------------- | --------------------------------------------------- |
| Spacing            | Padding/margin values | xs:4, sm:8, md:16, lg:24, xl:32, xxl:48             |
| BorderRadiusTokens | Corner rounding       | none:0, sm:4, md:8, lg:12, xl:16, full:9999         |
| ElevationTokens    | Shadow depth          | none:0, sm:2, md:4, lg:8, xl:16                     |
| AnimationDurations | Timing                | fastest:100ms, fast:200ms, medium:300ms, slow:500ms |
| AnimationCurves    | Easing curves         | standard, decelerate, accelerate, bounce, elastic   |
| IconSizes          | Icon dimensions       | xs:12, sm:16, md:24, lg:32, xl:48, xxl:64           |
| Breakpoints        | Responsive thresholds | mobile:600, tablet:905, desktop:1240                |
| OpacityTokens      | Transparency levels   | disabled:0.38, medium:0.60, high:0.87               |
| BorderWidthTokens  | Border thickness      | none:0, hairline:0.5, thin:1, thick:2               |

### App Colors

**Location**: `lib/core/theme/app_colors.dart`

**Color Categories**:

| Category          | Light Theme                              | Dark Theme                      |
| ----------------- | ---------------------------------------- | ------------------------------- |
| Primary Colors    | primary, primaryDark, primaryLight       | Same structure, inverted values |
| Neutral Colors    | black, darkGrey, grey, lightGrey, white  | Inverted for dark mode          |
| Semantic Colors   | success, warning, error, info            | Adjusted for visibility         |
| Background Colors | background, surface, card                | Darker backgrounds              |
| Text Colors       | textPrimary, textSecondary, textDisabled | Light text on dark              |
| Utility Colors    | divider, shadow                          | Subtle visibility               |

**Usage**:

```dart
Theme.of(context).appColors.primary
Theme.of(context).appColors.background
Theme.of(context).appColors.textPrimary
```

### App Text Theme

**Location**: `lib/core/theme/app_text_theme.dart`

**Text Style Categories**:

| Category       | Styles                                    |
| -------------- | ----------------------------------------- |
| Display Styles | displayLarge, displayMedium, displaySmall |
| Title Styles   | titleLarge, titleMedium, titleSmall       |
| Body Styles    | bodyLarge, bodyMedium, bodySmall          |
| Label Styles   | labelLarge, labelMedium, labelSmall       |

**Usage**:

```dart
Text('Title', style: Theme.of(context).textTheme.titleLarge)
Text('Body', style: Theme.of(context).textTheme.bodyMedium)
```

### App Theme Configuration

**Location**: `lib/core/theme/app_theme.dart`

**Key Features**:

- Material Design 3 enabled (`useMaterial3: true`)
- ColorScheme integration with LightColors/DarkColors
- Component themes (AppBar, Card, Button, Input)
- Text theme integration via `.copyWith()`
- Theme extension for easy color access

**Components Configured**:

| Component            | Styling Applied                               |
| -------------------- | --------------------------------------------- |
| colorScheme          | Core color roles                              |
| appBarTheme          | App bar styling                               |
| cardTheme            | Card styling with elevation and border radius |
| elevatedButtonTheme  | Primary button styling                        |
| textButtonTheme      | Text button styling                           |
| inputDecorationTheme | Form field styling                            |
| dividerTheme         | Divider styling                               |

## 📱 Responsive Design

### ScreenUtil Configuration

**Packages**:

- `flutter_screenutil: ^5.9.0` - Responsive sizing
- `gap: ^1.0.0` - Spacing widget

**Design Reference**: iPhone 13 (375 × 812)

**Setup in `lib/app/app.dart`**:

```dart
ScreenUtilInit(
  designSize: Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  child: MaterialApp.router(...),
)
```

**Available Methods**:

| Method | Purpose                                       |
| ------ | --------------------------------------------- |
| `.w`   | Responsive width scaling                      |
| `.h`   | Responsive height scaling                     |
| `.sp`  | Responsive font size (respects accessibility) |
| `.r`   | Responsive border radius                      |

**Usage Examples**:

```dart
Container(width: 100.w, height: 50.h)
Text('Hello', style: TextStyle(fontSize: 16.sp))
BorderRadius.circular(12.r)
SizedBox(height: 24.h)
```

### ScreenUtilConfig

**Location**: `lib/core/utils/screen_util_config.dart`

**Features**:

- Centralized design size definition
- Device type detection (mobile/tablet/desktop)
- Web platform detection
- Helper methods for responsive layouts

## 🧭 Navigation System

### GoRouter Configuration

**Location**: `lib/app/app_router.dart`

**Package**: `go_router: ^10.1.2`

**Route Names**:

```dart
class RouteNames {
  static const String intro = '/intro';
  static const String home = '/home';
  static const String login = '/login';
}
```

**Route Configuration**:

```dart
final appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: RouteNames.intro,
  routes: [
    GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  ],
);
```

**Navigation Methods**:

| Method                  | Purpose                          |
| ----------------------- | -------------------------------- |
| `context.go('/path')`   | Replace entire navigation stack  |
| `context.push('/path')` | Add to stack (preserves history) |
| `context.pop()`         | Remove from stack (go back)      |

### Main App Integration

**Location**: `lib/app/app.dart`

**Key Features**:

- `ScreenUtilInit` for responsive design
- `MaterialApp.router` for GoRouter integration
- Theme configuration (light/dark)
- Global `GestureDetector` for keyboard dismissal
- Debug banner removal in production

## 🗂️ Core Utilities

### Exports Management

**Location**: `lib/core/utils/exports.dart`

**Purpose**: Centralized import management

**Exports**:

```dart
export 'package:flutter/material.dart';
export 'package:go_router/go_router.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:gap/gap.dart';
export '../theme/app_colors.dart';
export '../theme/app_text_theme.dart';
export '../theme/app_theme.dart';
export '../../app/app_router.dart';
export './screen_util_config.dart';
```

## 📁 Phase 0 Folder Structure

```
lib/
├── main.dart                         # App entry point
├── app/
│   ├── app.dart                      # Main App widget with ScreenUtil
│   └── app_router.dart               # GoRouter configuration
├── core/
│   ├── config/
│   │   └── environment.dart          # Environment variable manager
│   ├── design_tokens/
│   │   └── tokens.dart               # Centralized design tokens
│   ├── theme/
│   │   ├── app_colors.dart           # Light/Dark theme colors
│   │   ├── app_text_theme.dart       # Typography system
│   │   └── app_theme.dart            # ThemeData configuration
│   └── utils/
│       ├── exports.dart              # Centralized exports
│       └── screen_util_config.dart   # Responsive configuration
├── l10n/
│   ├── app_en.arb                    # English localization strings
│   └── generated/                    # Auto-generated localization files
└── presentation/
    ├── features/
    │   ├── intro/
    │   │   ├── intro_screen.dart     # Onboarding screen
    │   │   └── models/
    │   │       └── intro_page.dart   # Intro data model
    │   └── home/
    │       └── home_screen.dart      # Home screen
    └── shared/
        └── widgets/
            └── tabs/
                ├── simple_tabs.dart  # Universal tab widget
                └── tabs_with_content.dart
```

## 📦 Dependencies

### Pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Navigation
  go_router: ^10.1.2

  # Backend
  supabase_flutter: ^2.1.0

  # Local Storage
  shared_preferences: ^2.2.2

  # Environment
  flutter_dotenv: ^5.1.0

  # Responsive
  flutter_screenutil: ^5.9.0
  gap: ^1.0.0

  # Localization
  flutter_localizations:
    sdk: flutter

  # Utilities
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6

flutter:
  uses-material-design: true

  assets:
    - assets/env/.env.development
    - assets/env/.env.production

  generate: true
```

## 🔐 Security Notes

| Concern               | Mitigation                                 |
| --------------------- | ------------------------------------------ |
| API Keys              | Stored in `.env` files, git-ignored        |
| Mapbox Tokens         | Native platform storage (not in Dart code) |
| Environment Isolation | Separate dev/prod files                    |
| Key Masking           | Sensitive keys masked in console logs      |
| Validation            | Required vars validated before startup     |
| Error Messages        | No sensitive data exposed to users         |

## ⏭️ Next Phase

After completing Phase 0, proceed to **Phase 1: Shop Management**, which builds on this foundation to implement shop creation, worker management, and service definitions.
