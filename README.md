<div align="center">

# WhatStat

### *Your WhatsApp chats, beautifully decoded.*

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue.svg?style=for-the-badge)

<br/>

**WhatStat** is a **privacy-first** WhatsApp chat analyzer that transforms your exported chat files into stunning, interactive analytics dashboards -- **100% offline**.

<img src="https://via.placeholder.com/800x400/0a0a0f/00f0ff?text=WhatStat+Dashboard" alt="Dashboard Preview" width="700"/>

</div>

---

## Features

<table>
<tr>
<td width="50%">

### **Analytics at a Glance**
- Total messages, words & media counts
- Per-participant breakdowns
- Average messages per day
- Chat duration & activity timeline

</td>
<td width="50%">

### **Activity Heatmap**
- 7x24 day-hour activity grid
- Night owl / early bird detection
- Peak activity hour identification
- Visual color-coded intensity

</td>
</tr>
<tr>
<td>

### **Emoji Intelligence**
- Top emoji rankings
- Per-participant emoji profiles
- Emoji usage over time
- Most expressive moments

</td>
<td>

### **Response Time Analysis**
- Average reply speed per person
- Who responds fastest to whom
- Response time distributions
- Conversation flow insights

</td>
</tr>
<tr>
<td>

### **Fun Insights**
- Longest chatting streak
- Busiest day ever
- Night owl detection
- Auto-generated chat facts

</td>
<td>

### **Privacy First**
- 100% local processing
- No data sent anywhere
- Works fully offline
- Your chats stay yours

</td>
</tr>
</table>

---

## Theme

WhatStat features a custom **Cyberpunk Neon Dark** theme with:

> Electric Cyan accents &nbsp;&nbsp; Neon Pink highlights &nbsp;&nbsp; Glassmorphic cards
> Gradient text &nbsp;&nbsp; Glow effects &nbsp;&nbsp; Smooth animations

---

## Getting Started

### Prerequisites

| Requirement | Version |
|-------------|---------|
| Flutter SDK | `stable channel` |
| Dart SDK | `>=3.2.0 <4.0.0` |

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/WhatStat.git

# 2. Navigate to the project
cd WhatStat

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

---

## How to Use

### Step 1 -- Export your WhatsApp chat

> Open **WhatsApp** -> Select a chat -> **...** More -> **Export chat** -> Choose *Without media*

### Step 2 -- Import into WhatStat

> Open WhatStat -> Tap **Choose File** -> Select the exported `.txt` file

### Step 3 -- Explore your analytics

> View your beautiful dashboard with charts, heatmaps, emoji stats, and fun insights!

---

## Project Structure

```
WhatStat/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── core/
│   │   ├── models.dart            # Data models
│   │   ├── theme.dart             # Cyberpunk theme
│   │   ├── utils.dart             # Utility functions
│   │   └── widgets.dart           # Reusable UI components
│   ├── pages/
│   │   ├── import_page.dart       # File import screen
│   │   └── dashboard_page.dart    # Analytics dashboard
│   ├── providers/
│   │   └── providers.dart         # Riverpod providers
│   └── services/
│       ├── parser.dart            # WhatsApp chat parser
│       └── analytics.dart         # Analytics engine
├── android/                       # Android platform
├── ios/                           # iOS platform
├── web/                           # Web platform
└── windows/                       # Windows platform
```

---

## Built With

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Riverpod** | State management |
| **fl_chart** | Beautiful chart visualizations |
| **Hive** | Fast local storage |
| **flutter_animate** | Smooth animations |
| **Google Fonts** | Space Grotesk & JetBrains Mono |
| **file_picker** | Native file selection |
| **screenshot** | Dashboard export & sharing |

---

## Supported Chat Formats

WhatStat automatically detects and parses:

| Platform | Format |
|----------|--------|
| Android | `DD/MM/YY, HH:MM - Sender: Message` |
| iOS | `[DD/MM/YY, HH:MM:SS] Sender: Message` |
| US | `MM/DD/YY, HH:MM AM - Sender: Message` |
| Alternative | Dots, dashes, and various separators |

---

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

```bash
# Fork the repo
# Create your feature branch
git checkout -b feature/amazing-feature

# Commit your changes
git commit -m "Add amazing feature"

# Push to the branch
git push origin feature/amazing-feature

# Open a Pull Request
```

---

<div align="center">

### Your chats deserve better than plain text.

**Made with Flutter**

![Visitors](https://api.visitorbadge.io/api/visitors?path=your-username%2FWhatStat&countColor=%2300f0ff&style=for-the-badge)

</div>
