# JARVIS

An AI assistant that generates its own native UI. You talk to it (voice or text),
and instead of just replying with words, it returns a JSON "blueprint" that the app
renders into real SwiftUI components: stat cards, charts, progress rings, weather
panels, status grids, and more.

Built in Swift / SwiftUI. Runs on iOS, macOS, and tvOS.

> Add 2 to 3 screenshots or a screen recording here. This app is very visual and
> a GIF sells it far better than text.

## What it does

- **Generative UI.** The model responds with a structured blueprint (layout, title,
  styling, animation, child components). A parser turns that into native SwiftUI views
  at runtime, so the interface adapts to each answer instead of being hard-coded.
- **Voice input.** Hands-free interaction using Apple's Speech framework
  (`SFSpeechRecognizer`) for live speech-to-text.
- **Chat + canvas.** A chat thread on one side, a dynamic canvas that draws the
  generated components on the other.
- **Bring your own model.** Point it at any OpenAI-compatible gateway from Settings
  (base URL, API key, model). Works with GPT, Claude, or anything your gateway exposes.
- **Cross-platform.** One SwiftUI codebase for iOS, macOS, and tvOS. Dark mode first.

## Architecture

```
Voice / text input
   → OpenClawService  (sends prompt + JARVIS system prompt to the LLM)
   → LLM returns a JSON Blueprint
   → BlueprintParser  (decodes into typed components)
   → ComponentRegistry → DynamicCanvasView  (renders native SwiftUI)
```

Key pieces:
- `Services/OpenClawService.swift` — LLM communication, streaming, blueprint extraction
- `Services/VoiceService.swift` — speech-to-text
- `Models/Blueprint.swift`, `Models/BlueprintComponents.swift` — the UI schema
- `Utilities/BlueprintParser.swift`, `Utilities/ComponentRegistry.swift` — JSON to views

## Tech

Swift · SwiftUI · Apple Speech framework · Codable · async/await · OpenAI-compatible LLM API

## Run it

1. Open `JARVIS.xcodeproj` in Xcode.
2. Build and run on a simulator or device.
3. Open Settings in the app and set your gateway base URL, API key, and model.

## Why I built it

I wanted to see how far "the model designs the interface" could go on Apple platforms,
turning an LLM response into a live, native UI rather than a wall of text.
