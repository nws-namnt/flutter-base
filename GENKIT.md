# Genkit AI Integration

This document describes how the Genkit AI feature is integrated into the Flutter Base project —
architecture decisions, configuration steps, and extension patterns.

---

## Overview

The AI Support chat feature allows users to ask questions about the app directly from the **Settings**
screen. The assistant is context-aware: it knows which screen the user came from and the current
app version, giving it enough context to provide relevant help.

**Tech stack:**
- [`genkit`](https://pub.dev/packages/genkit) `^0.14.1` — Dart AI SDK (Google)
- [`genkit_google_genai`](https://pub.dev/packages/genkit_google_genai) `^0.14.1` — Google AI (Gemini) plugin
- Model: `gemini-2.5-flash` — best free-tier availability as of June 2026
- State management: Cubit (matches project convention)
- Navigation: GoRouter with `context.pushNamed` (preserves back stack)

---

## Directory structure

```
lib/
├── services/
│   └── ai_service.dart           # Singleton wrapping Genkit — streaming, retry, system prompt
└── pages/
    └── ai_support/
        ├── ai_support_page.dart  # Full-screen chat UI
        ├── ai_support_cubit.dart # Business logic: send message, stream chunks, history
        ├── ai_support_state.dart # Sealed state + AiChatMessage model
        └── widgets/
            ├── chat_bubble_widget.dart   # User/AI bubbles + long-press context menu
            └── chat_input_widget.dart    # Text field + send button

assets/env/
├── .env.dev    # GEMINI_API_KEY=...
├── .env.uat    # GEMINI_API_KEY=...
└── .env.prod   # GEMINI_API_KEY=...
```

---

## Setup

### 1. Get a Gemini API key

1. Go to <https://aistudio.google.com/apikey>
2. Click **"Create API key in new project"** (creates a clean project with free-tier quota)
3. Copy the key

> **Important:** Always use a key created from Google AI Studio, not from Google Cloud Console.
> Cloud Console keys may have `limit: 0` on free-tier metrics and will fail immediately.

### 2. Add the key to your environment files

```dotenv
# assets/env/.env.dev
GEMINI_API_KEY=AIza...your_key_here
```

Repeat for `.env.uat` and `.env.prod`. Never commit real keys — add `.env.*` to `.gitignore`
or use CI/CD secrets for production builds.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run

```bash
flutter run --flavor dev
```

Navigate to **Settings → AI Support FAB**.

---

## Architecture

### `AiService` (singleton)

```
lib/services/ai_service.dart
```

Wraps the `Genkit` instance. Key responsibilities:

| Method | Description |
|---|---|
| `initialize()` | Lazy init — reads `AppEnv.geminiApiKey`, creates `Genkit` with `googleAI` plugin. Safe to call multiple times. |
| `streamResponse(...)` | Returns `Stream<String>` of text chunks. Builds system prompt with app + screen context. Retries up to 3× on transient server errors (INTERNAL / UNAVAILABLE / high demand). |

**Retry logic:**
Transient errors (Gemini server overload) are retried with linear back-off: 2 s → 4 s → 6 s.
Once chunks start streaming, retry is skipped (can't unsend emitted data).

**System prompt template:**
```
You are a friendly in-app support assistant for {appName} (version {appVersion}).
The user is currently on the "{screenName}" screen.
Help users understand how to use the app. Be concise. Reply in the user's language.
```

### `AiSupportCubit`

Owns conversation history (`List<AiChatMessage>`) and streaming state. On each `sendMessage()`:

1. Appends user message immediately (instant UI feedback)
2. Appends an empty AI placeholder
3. Subscribes to `AiService.streamResponse()` stream
4. Updates the placeholder in-place for each chunk → typing effect in UI
5. On error: removes empty placeholder, sets `errorMessage` (conversation is preserved)

### State model

```dart
sealed class AiSupportState {}
class AiSupportInitial extends AiSupportState {}      // before initialize()
class AiSupportReady  extends AiSupportState {        // active conversation
  final List<AiChatMessage> messages;
  final bool isStreaming;
  final String? errorMessage;                         // inline, non-destructive
}
class AiSupportError  extends AiSupportState {}       // init failed (bad API key, etc.)
```

### Navigation

The route is defined in `lib/routing/routers.dart` as `Routers.aiSupport` (`/aiSupport`).

Always navigate using **`context.pushNamed`**, not `context.goNamed`:

```dart
// ✅ Pushes on top of shell — back button works
context.pushNamed(
  Routers.aiSupport.routerName,
  extra: {'screenName': 'Settings'},
);

// ❌ Replaces the stack — no back navigation
context.goNamed(Routers.aiSupport.routerName);
```

The `screenName` extra is read in `router_config.dart` and passed to `AiSupportPage` as a
constructor argument, then forwarded to `AiSupportCubit` and ultimately into the system prompt.

---

## User interactions

### Chat input
- Multi-line `TextField` (max 4 lines)
- **Send** button is disabled while AI is streaming
- `TextEditingController` and `FocusNode` are owned by `_AiSupportPageState` and injected
  into `ChatInputWidget` — allowing the page to pre-fill the field programmatically

### Bubble long-press / tap menu (user messages only)

Tap a user bubble to open a context menu with two actions:

| Icon | Action | Behaviour |
|---|---|---|
| `Icons.copy_rounded` | **Copy** | Writes message content to clipboard, shows `SnackBar` |
| `Icons.replay_rounded` | **Re-ask** | Pre-fills `ChatInputWidget` with the message text and requests keyboard focus |

Implementation: `GestureDetector.onTapUp` captures the tap position → `showMenu` positioned at
that offset. The `onReAsk` callback is threaded from `_AiSupportPageState._fillInput` through
`_ChatView` into each `ChatBubbleWidget`.

---

## Changing the model

The active model is a single constant at the top of `ai_service.dart`:

```dart
// lib/services/ai_service.dart
const _kModel = 'gemini-2.5-flash';
```

**Available free-tier models (June 2026):**

| Model string | RPM | TPM | Notes |
|---|---|---|---|
| `gemini-2.5-flash` | 5 | 250K | Recommended — best capability |
| `gemini-2.5-flash-lite` | 10 | 250K | Higher RPM, lighter model |
| `gemini-flash-latest` | 5 | 250K | Resolves to latest Flash (currently 3.5) |

> Check your actual quota at <https://aistudio.google.com> → Rate Limit.

---

## Extending the feature

### Add AI support entry point from another page

```dart
// Any page in the shell
context.pushNamed(
  Routers.aiSupport.routerName,
  extra: {'screenName': 'Home'},   // or 'Profile', 'Checkout', etc.
);
```

The `screenName` is injected verbatim into the system prompt, so name it descriptively.

### Add tools (function calling)

Define a Genkit tool in `AiService` to let the AI call your app's data:

```dart
final appInfoTool = _ai!.defineTool(
  name: 'getAppInfo',
  description: 'Returns current app version and active feature flags.',
  inputSchema: .object(),
  fn: (_, __) async => {
    'version': _appVersion,
    'flavor': AppEnv.flavor,
  },
);
```

Then include the tool name in `generateStream`:

```dart
_ai!.generateStream(
  model: googleAI.gemini(_kModel),
  messages: messages,
  toolNames: ['getAppInfo'],
);
```

### Add conversation flows

Wrap multi-step logic (e.g. guided troubleshooting) in a `defineFlow`:

```dart
final troubleshootFlow = _ai!.defineFlow(
  name: 'troubleshoot',
  inputSchema: .string(),
  outputSchema: .string(),
  fn: (issue, _) async {
    // multi-step: diagnose → suggest → escalate
  },
);
```

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `RESOURCE_EXHAUSTED / limit: 0` | Key from Google Cloud Console, not AI Studio | Create a new key at aistudio.google.com |
| `NOT_FOUND` | Wrong model name string | Check the model string in `_kModel` against the table above |
| `INTERNAL / high demand` | Gemini server overloaded | Handled automatically by retry logic (up to 3×). If persistent, switch to `gemini-2.5-flash-lite` |
| `StateError: GEMINI_API_KEY missing` | Key not set in `.env.<flavor>` | Add `GEMINI_API_KEY=...` to the relevant env file |
| No back button on AI Support | Navigated with `context.goNamed` instead of `context.pushNamed` | Use `pushNamed` — see Navigation section above |
