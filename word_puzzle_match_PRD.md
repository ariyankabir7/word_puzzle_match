# 📄 Product Requirements Document (PRD)
# Word Puzzle Match — Flutter Mobile Game

> **Version:** 1.1.0  
> **Updated:** July 2026  
> **Platform:** Android & iOS (Flutter)  
> **Package ID:** com.vishal.word_puzzle_match  
> **Target Audience:** Casual gamers, ages 8 and above  
> **Genre:** Word Puzzle / Casual (Single Player)  

---

## 🎯 1. Product Overview

### 1.1 Vision
**Word Puzzle Match** is a delightful, family-friendly word-search puzzle mobile game featuring an adorable owl mascot. Players find hidden words within a letter grid, progressing through 500+ levels across themed worlds on a colorful map. The game combines the satisfaction of word discovery with rewarding progression mechanics, daily events, and a polished single-player experience.

### 1.2 Core Concept
Players are presented with a grid of letters and a list of words to find. They trace/swipe across the grid to select letters forming the target words. Each completed level awards Stars (1–3), Coins, and Gems, unlocking the next level on the world map.

### 1.3 Tagline
> *"Fun Words, Big Smiles!"*

### 1.4 USP (Unique Selling Points)
- 500+ hand-crafted levels with smooth progressive difficulty curve
- Quick early wins to hook players & deliver rewarding feelings of accomplishment
- Expressive Owl mascot with interactive animations
- Multiple power-ups (Hint, Shuffle, Freeze)
- Daily Rewards, Personal Best Achievements & Solo Events
- 100% offline-playable local single-player gameplay (No cloud login needed)
- Clean architecture with ready-to-enable Ad Placement hooks (Google Ads Manager / ADX)

---

## 🎨 2. Visual & Art Direction

### 2.1 Theme & Aesthetic
- **Style:** Bright, cartoon-ish, cheerful
- **Mascot:** A graduation-cap owl with expressive interactive animations (Rive / Lottie / Flutter Canvas)
- **Color Palette:**
  - Primary: Sky Blue `#5CB8E4`, Sunshine Yellow `#F9C74F`
  - Accent: Lush Green `#6BCB77`, Soft Purple `#9B72CF`
  - Background: Gradient sky blue to light teal
  - UI Cards: White with soft rounded corners and drop shadows
- **Typography:**
  - Title Font: Rounded bold (e.g., Fredoka One or Baloo 2)
  - Body Font: Clean rounded sans-serif (e.g., Nunito)

### 2.2 Screen Layouts (from Reference Image)

| Screen | Key Elements |
|--------|-------------|
| **Home / Splash** | Owl mascot, "Word Puzzle Match" logo, PLAY button, Level progress badge ("Level 1 of 500"), Bottom nav icons |
| **World Map** | Winding path with numbered level nodes (locked/unlocked/complete), Star progress bar, Trophy/Gift markers, Bottom nav (Map, Events, Store) |
| **Gameplay** | Timer (01:45), Move counter, Coin display, Word list panel, Letter grid (6x6 to 9x9), Power-up buttons (Hint, Shuffle, Freeze), "Great Job!" overlay |
| **Level Complete** | Stars earned (1–3), Rewards shown (+Coins, +Gems), Owl celebration, "Next Level" & "Back to Map" buttons |

---

## 📱 3. Screen & Navigation Structure

```
App Launch
  └── Splash Screen (Logo + Owl animation, 2s)
        └── Home Screen
              ├── PLAY → World Map
              ├── Achievements
              ├── Daily Reward
              ├── Shop
              └── Offers
                    └── World Map
                          ├── Level Node (tap) → Gameplay Screen
                          ├── Events Tab → Events Screen
                          └── Store Tab → Shop Screen
                                └── Gameplay Screen
                                      └── Level Complete Screen
                                            ├── Next Level → Next Gameplay Screen
                                            └── Back to Map → World Map
```

---

## 🕹️ 4. Core Gameplay Mechanics

### 4.1 Progressive Difficulty & Grid Sizes
- **Grid Sizes & Word Placement:**
  - **Easy levels (1–50):** 6×6 Grid. Horizontal (L→R) & Vertical (T→B) only. Straightforward words to grant instant wins, build confidence, and maximize early retention.
  - **Medium levels (51–200):** 7×7 Grid. Unlocks Diagonal Down/Up placements.
  - **Hard levels (201–350):** 8×8 Grid. Unlocks Reverse Horizontal & Reverse Vertical placements.
  - **Expert levels (351–500):** 9×9 Grid. All 8 directions active (Reverse Diagonal included).
- **Letter Selection:** Tap first letter + drag to last letter; valid path highlights in a solid color; release to confirm.
- **Visual Feedback:** 
  - Valid selection: Blue highlight trail
  - Word found: Row highlights in a unique color (green, orange, purple, etc.) with a "pop" animation
  - Wrong selection: Red flash + subtle shake
- **Word List Panel:** Shows all target words; found words get a strikethrough + checkmark.

### 4.2 Scoring & Stars

| Stars | Condition |
|-------|-----------|
| ⭐ 1 Star | Level completed (all words found) |
| ⭐⭐ 2 Stars | Completed with > 50% time remaining OR < 5 wrong swipes |
| ⭐⭐⭐ 3 Stars | Completed with > 75% time remaining AND 0 wrong swipes |

- **Coins Earned per Level:** 20–100 (based on stars + speed)
- **Gems Earned:** Random bonus (5–15) per milestone level

### 4.3 Power-Ups

| Power-Up | Icon | Effect | Default Count |
|----------|------|--------|---------------|
| 💡 Hint | Light bulb | Highlights one letter of a random unfound word | 3 per level |
| 🔄 Shuffle | Arrows | Re-arranges non-found letters in the grid | 3 per level |
| ❄️ Freeze | Snowflake | Pauses the countdown timer for 15 seconds | 2 per level |

- Power-ups are consumed on use; can be replenished via in-game Coin/Gem shop.
- Each power-up button displays the remaining count badge.

### 4.4 Timer
- Fixed countdown duration per difficulty tier:
  - Easy: 3:00 minutes
  - Medium: 2:30 minutes
  - Hard: 2:00 minutes
  - Expert: 1:45 minutes
- Timer turns red when < 30 seconds remain.
- Timer pauses when game is backgrounded or Freeze power-up is activated.
- If timer hits 0: "Time's Up!" overlay appears with Retry option.

### 4.5 Move Counter
- Tracks total swipe attempts.
- Displayed in header ("Moves: 12").

---

## 🗺️ 5. World Map & Level Progression

### 5.1 Map Structure
- Winding path with 500 numbered level nodes across 10 themed worlds (50 levels per world):
  - World 1 (Levels 1–50): **Green Valley**
  - World 2 (Levels 51–100): **Sunny Beach**
  - World 3 (Levels 101–150): **Mystic Forest**
  - World 4 (Levels 151–200): **Snowy Peaks**
  - World 5 (Levels 201–250): **Desert Dunes**
  - World 6 (Levels 251–300): **Sky Kingdom**
  - World 7 (Levels 301–350): **Ocean Deep**
  - World 8 (Levels 351–400): **Candy Land**
  - World 9 (Levels 401–450): **Volcano Isle**
  - World 10 (Levels 451–500): **Star Galaxy**

### 5.2 Node States

| State | Visual |
|-------|--------|
| Locked | Grayed out, lock icon |
| Unlocked (0 stars) | White node, level number |
| Completed 1 Star | Yellow node, ⭐ |
| Completed 2 Stars | Yellow node, ⭐⭐ |
| Completed 3 Stars | Gold node, ⭐⭐⭐ |
| Current Level | Animated pulsing blue border |

---

## 💰 6. Economy & Ad Placement Architecture

### 6.1 Virtual Currencies & Local Economy
- 💰 **Coins:** Earned by beating levels; spent on Hints, Shuffles, and Freezes.
- 💎 **Gems:** Earned via milestone achievements, level chests, daily rewards; spent on power-up bundles.
- ❤️ **Lives:** 5 maximum lives stored locally (recharges 1 life every 30 mins locally).

### 6.2 Ad Manager (ADX) Architecture (Hooks & Placeholders)
*Note: Active ad serving is disabled for initial release, but codebase & UI layouts include clean hooks for future Google Ads Manager (ADX) / AdMob activation.*

| Component | UI / Code Hook Placement | Status at Launch |
|-----------|--------------------------|------------------|
| Banner Ad Container | Fixed bottom container widget on World Map & Gameplay | Hidden / Zero-height container |
| Rewarded Ad Hook | Level Complete double-reward button & Time's Up +60s button | Disabled / Hidden |
| Interstitial Ad Hook | Level transition controller (`AdService.showInterstitialIfReady()`) | No-op callback |

---

## 🎁 7. Daily Rewards & Solo Engagement

### 7.1 Daily Reward System (7-Day Streak)
- Local 24-hour cycle timer checking last login timestamp stored in Hive.
- Rewards:
  - Day 1: 50 Coins
  - Day 2: 100 Coins
  - Day 3: 2 Hints
  - Day 4: 200 Coins
  - Day 5: 10 Gems
  - Day 6: 300 Coins + 2 Shuffles
  - Day 7: 25 Gems + Power-Up Pack

### 7.2 Personal Achievements (Single-Player Progress)
- Local tracking of milestones (First Word, Speed Solver, 3-Star Collector, Word Master).
- Rewards claimed directly in local UI.

---

## 📊 8. Technical Architecture

### 8.1 Tech Stack (100% Local First)

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Framework | Flutter 3.x (Dart) | Cross-platform high performance |
| State Management | Riverpod | Clean, testable single-player state |
| Local Storage / Database | Hive + SharedPreferences | Super-fast NoSQL local storage for level stars, progress, coins, gems |
| Level Database | Bundled JSON Assets | 500 pre-generated level JSON files inside `assets/levels/` (perfect for solo dev) |
| Language | English Only | High efficiency initial release |
| Audio | audioplayers / flame_audio | Crisp sound effects and cheerful background tracks |
| Mascot Animation | Rive / Lottie / Flutter Custom Canvas | Maximum emotional engagement & lively owl reactions |
| Ad Placement | Modular `AdsService` abstraction | Pre-built ADX / AdMob interface with stubbed local implementation |

### 8.2 Data Models

#### Level Model
```dart
class Level {
  final int id;
  final String world;
  final int difficulty; // 1=Easy, 2=Medium, 3=Hard, 4=Expert
  final int gridSize;   // 6, 7, 8, or 9
  final List<String> words;
  final List<List<String>> grid;
  final List<WordPosition> wordPositions;
  final int timeLimit; // in seconds
}
```

#### Player Progress Model (Hive Box `player_progress`)
```dart
class PlayerProgress {
  int coins;
  int gems;
  int lives;
  DateTime lastLifeTime;
  int currentLevel;
  Map<int, int> levelStars; // levelId -> stars (0-3)
  int hints;
  int shuffles;
  int freezes;
  int loginStreak;
  DateTime lastLoginDate;
}
```

---

## 🚀 9. Development Phases

---

### ✅ Phase 1 — Foundation & Core Gameplay (Weeks 1–3)

**Goal:** Playable word puzzle engine, local Hive persistence, Green Valley (Levels 1–50)

#### Deliverables:
- [ ] Flutter project setup with modular architecture
- [ ] Design system: colors, fonts, spacing tokens
- [ ] Splash screen with Owl animation logo
- [ ] Local persistence layer using Hive (`player_progress` box)
- [ ] Core Gameplay Engine:
  - [ ] Letter grid rendering (6×6)
  - [ ] Drag-to-select letter gesture handler
  - [ ] Word matching & pop animations
  - [ ] Progressive word placement logic (L→R, T→B for early levels)
  - [ ] Timer & Move Counter
  - [ ] Audio manager (Sound FX + BG music)
- [ ] Level Complete dialog with star rating system
- [ ] 50 hand-crafted easy levels bundled in `assets/levels/world1.json`

---

### ✅ Phase 2 — Progression, World Map & Mascot Polish (Weeks 4–6)

**Goal:** Complete 500 levels, 10 themed worlds, interactive Owl Mascot

#### Deliverables:
- [ ] World Map screen with 500 winding level nodes
- [ ] 10 distinct World Theme visuals
- [ ] Pre-compiled JSON assets generated for all 500 levels (Worlds 1–10)
- [ ] Progressive mechanics unlock system (Diagonals at level 51+, Reverses at level 201+)
- [ ] Power-ups implementation:
  - [ ] Hint (letter highlight)
  - [ ] Shuffle (grid rearrangement)
  - [ ] Freeze (15s timer pause)
- [ ] Interactive Owl Mascot animations (Happy, Cheering, Surprised reactions)
- [ ] In-level celebration overlay ("Great Job!")

---

### ✅ Phase 3 — Single-Player Economy & ADX Placeholder Hooks (Weeks 7–9)

**Goal:** Local economy, shop UI, local lives system, Google ADX placement architecture

#### Deliverables:
- [ ] Coin & Gem local transaction system
- [ ] Local 5-Lives regeneration timer (30-min recharge cycle)
- [ ] Power-up shop UI (buy Hints/Shuffles with Coins)
- [ ] Modular `AdsService` wrapper:
  - [ ] Banner Ad widget container (collapsible/ready for ADX ID)
  - [ ] Rewarded Ad listener hooks
  - [ ] Interstitial Ad trigger points
- [ ] Settings screen (Audio, Music, Haptic vibration toggles)

---

### ✅ Phase 4 — Daily Engagement & Solo Content (Weeks 10–12)

**Goal:** Daily reward streak, achievement system, offline polish

#### Deliverables:
- [ ] 7-Day Daily Reward calendar popup
- [ ] Single-Player Achievement system with 8 rewardable badges
- [ ] Local high-score & level completion statistics
- [ ] Haptic feedback integrations
- [ ] UX polish & dynamic layout scaling across portrait phones

---

### ✅ Phase 5 — QA, Optimization & Store Release (Weeks 13–14)

**Goal:** 60fps performance optimization, release build signing, Play Store & App Store deployment

#### Deliverables:
- [ ] Performance profiling (sub-3s cold start, 60fps steady gameplay)
- [ ] Android APK / AAB signing setup (`com.vishal.word_puzzle_match`)
- [ ] iOS Xcode provisioning & build verification
- [ ] Offline resilience pass (100% functional without internet)
- [ ] Final store listing screenshots & metadata creation
- [ ] Production deployment

---

## 🎯 16. Resolved Architectural Decisions

All open design and architectural questions have been explicitly resolved as follows:

| # | Question / Area | Final Resolved Decision |
|---|-----------------|-------------------------|
| **16.1** | **Data Source & Storage** | **Local Database (Hive + SharedPreferences)** for all user data, level progress, coins, gems, and settings. Zero cloud latency. |
| **16.2** | **Difficulty Progression** | **Progressive Mechanics & Quick Wins**. Levels 1–50 feature simple L→R / T→B words to give players instant satisfaction & high dopamine. Diagonal and Reverse words unlock gradually in later worlds. |
| **16.3** | **Cloud Backend** | **No Cloud Backend for v1.0**. 100% offline-first architecture. Eliminates server costs and complex authentication flows. |
| **16.4** | **Social & Leaderboards** | **Single-Player Engagement Focus**. No online leaderboards. Retention is driven by personal achievement badges, level map progress, and 7-day login rewards. |
| **16.5** | **Mascot Animation Tech** | **Rive / Lottie / Interactive Canvas**. Vector-animated Owl mascot delivers rich emotional reactions (blinking, cheering, winking) for maximum player visual delight. |
| **16.6** | **Level Content Delivery** | **Pre-compiled Bundled JSON Assets**. All 500 levels stored as static JSON files in `assets/levels/`. Optimal for single developer maintainability and instant level loading. |
| **16.7** | **Localization** | **English Only** for v1.0 launch. Text strings centralized in `app_strings.dart` for simple future translation if needed. |
| **16.8** | **Ad Strategy & ADX Integration** | **No Active Ads at Launch, but ADX Placeholders Built-in**. Dedicated UI containers and `AdsService` methods pre-wired so Google Ads Manager (ADX) can be activated cleanly with a single config flag later. |

---

*This PRD represents the complete, locked specification for Word Puzzle Match v1.1.0.*
