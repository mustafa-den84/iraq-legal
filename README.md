# Iraq Legal Guide - Flutter App

A multilingual (Arabic, English, Kurdish) mobile application for legal services in Iraq.

## Features

- **Home Screen**: Dynamic type cards fetched from Supabase database
- **Type List Screen**: Generic component for displaying places by type with search and filters
- **AI Advisor**: Chat interface with AI-powered legal advice (uses Gemini API)
- **Map Screen**: Interactive map showing nearby services with type filtering
- **Emergency Screen**: Quick access to emergency contacts with one-tap dialing
- **Multilingual Support**: Arabic, English, and Kurdish with RTL support
- **Dark Theme**: Modern dark theme matching the web version

## Prerequisites

- Flutter SDK 3.16+
- Android Studio or VS Code with Flutter extension
- Supabase account (backend already configured)

## Setup

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure AI API Keys**:
   - The app supports multiple free AI models with automatic fallback
   - Set API keys as environment variables or Cloudflare secrets:
     - `GEMINI_API_KEY` - Google Gemini (free tier)
     - `OPENAI_API_KEY` - OpenAI GPT-3.5 (free tier)
     - `ANTHROPIC_API_KEY` - Anthropic Claude (free tier)
     - `GROQ_API_KEY` - Groq Llama3 (free tier, fastest)
     - `HUGGINGFACE_API_KEY` - Hugging Face (free)
   - See [CLOUDFLARE_SECRETS.md](../../CLOUDFLARE_SECRETS.md) for detailed setup
   - For local development, use `--dart-define` flags:
     ```bash
     flutter run --dart-define=GEMINI_API_KEY=your_key --dart-define=OPENAI_API_KEY=your_key ...
     ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models (Place, Question, Answer)
├── services/              # API services (Supabase, AI)
├── providers/             # State management (Language)
├── screens/               # UI screens (Home, TypeList, Chat, Map, Emergency)
├── widgets/               # Reusable widgets (TypeCard, PlaceCard)
├── constants/             # App constants (Colors, Translations)
└── utils/                 # Utility functions
```

## Backend Connection

The app connects to an existing Supabase backend:
- **URL**: https://kyvmaysiyyxkwthjbozz.supabase.co
- **Tables**: places, questions, answers
- **Features**: Dynamic type fetching, Q&A caching, real-time updates

## Build for Android

### Debug Build
```bash
flutter run
```

### Release APK
```bash
flutter build apk --release
```

### Release App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Permissions

The app requires the following Android permissions:
- `INTERNET` - For API calls
- `ACCESS_FINE_LOCATION` - For map functionality
- `ACCESS_COARSE_LOCATION` - For map functionality
- `CALL_PHONE` - For emergency dialing

## Screens

### Home Screen
- Displays type cards dynamically from database
- Shows count of places per type
- Tap card to navigate to type list

### Type List Screen
- Generic component for all place types
- Search by name (supports all languages)
- Filter by city and sub-type
- Display place cards with contact options

### Chat Screen
- AI-powered legal advisor with multiple free models
- Supports Groq, Gemini, OpenAI, Anthropic, Hugging Face
- Automatic fallback between models
- Checks database for cached answers first
- Falls back to AI if no cached answer
- Stores new Q&A in database

### Map Screen
- Interactive map with OpenStreetMap tiles
- Type filter buttons
- Shows markers for places
- Color-coded by type

### Emergency Screen
- Quick access to emergency contacts
- One-tap dialing
- Multilingual contact names

## Language Support

The app supports three languages:
- **Arabic (ar)**: Default language, RTL layout
- **English (en)**: LTR layout
- **Kurdish (ku)**: RTL layout

Language can be toggled from the app header.

## Notes

- **No Admin Panel**: Mobile version does not include admin functionality
- **Android Only**: This project is configured for Android only (no iOS/web)
- **Minimum SDK**: Android 5.0 (API 21)
- **Target SDK**: Latest Android SDK

## GitHub Deployment

To push to GitHub:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-repo-url>
git push -u origin main
```

## Support

For issues or questions, refer to the main project documentation.
