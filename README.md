# Momentum

Passive wellness web app — on-device AI, fitness reels, nutrition tracking, energy forecast, and personalized wellness insights.

## Features

- **Zen Dashboard**: Energy blob visualization, sub-score rings, weekly summary
- **Energy Forecast**: 4-block weather-style prediction (High/Medium/Low/Rest)
- **Anti-Burnout Shield**: Recovery mode with amber UI shift
- **Reels**: TikTok-style vertical swipe feed
- **Nutrition (CAL AI style)**: Camera, barcode scanner, food description with AI recognition, photo diary, macro rings, meal timeline, water tracker, fasting timer
- **Coach**: AI message feed, journal entry, recovery readiness
- **Focus**: Pomodoro timer (25/15/45/60 min) with animated ring
- **Profile**: Stats, badges, settings, quick actions

## Usage

Open `index.html` in a browser. No server required for basic functionality.

For full interactivity (camera simulation, barcode lookup, AI food recognition), serve with any HTTP server:

```
python3 -m http.server 8000
```

Then open http://localhost:8000.

## Tech

- Pure HTML/CSS/JavaScript
- No external dependencies
- All data processing on-device (privacy-first)
- Dark mode, minimalist UI
