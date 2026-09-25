# FoundationModels-SwiftData-Demo
A demo iOS app showcasing Apple's on-device Foundation Models framework combined with SwiftData — intelligent expense tracking where AI auto-classifies entries and assigns the right icon + color, with a clean SwiftUI list, sorting, and persistent storage.


# FoundationModels-SwiftData-Demo

A hands-on iOS demo exploring how to combine Apple's on-device
**Foundation Models** framework with **SwiftData** to build an
intelligent expense tracking app.

Type an expense name like *"Grocery"* or *"Fuel"* — the on-device
language model classifies it into a category (Food, Travel, Shopping,
Bills, etc.) and instantly assigns the matching SF Symbol and tint
color. No network calls. No cloud. Everything runs privately on device.

## ✨ Features

- 🧠 **On-device AI classification** using Foundation Models
  (`@Generable` enum-constrained output — no hallucinated categories)
- 💾 **SwiftData persistence** with a clean `@Model` schema
- 🎨 **Dynamic SF Symbols + tint colors** stored per expense
- 📊 **Sort options** — Date (Newest / Oldest) and Amount (High / Low)
- 🌗 **Adaptive UI** built with system materials and semantic colors
- 🔒 **Fully offline** — no network, no analytics, no tracking
- 🍎 **Apple Intelligence-ready** — falls back gracefully to keyword
  matching on devices that don't support it

## 🛠 Tech Stack

| Layer            | Technology                          |
| ---------------- | ----------------------------------- |
| UI               | SwiftUI (iOS 18+)                   |
| Persistence      | SwiftData                           |
| AI / ML          | Foundation Models (on-device LLM)   |
| Concurrency      | Swift Concurrency (async/await)     |
| Design Language  | Apple HIG, SF Symbols               |

## 🚀 What You'll Learn

- How to integrate `LanguageModelSession` into a SwiftUI app
- Using `@Generable` to constrain LLM output to a Swift enum
- Persisting AI-generated metadata (SF Symbol name + tint hex) with SwiftData
- Debouncing AI calls with `.task(id:)` for efficient keystroke handling
- Building reusable, testable AI services (shared classifier pattern)
- Graceful degradation when Apple Intelligence is unavailable

## 📱 Requirements

- iOS 26+ (Foundation Models framework)
- Xcode 26+
- Apple Intelligence–capable device (iPhone 15 Pro or later, M1+ iPad/Mac)
- Fallback keyword classifier works on any device
