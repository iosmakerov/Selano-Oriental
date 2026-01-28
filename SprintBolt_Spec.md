# SprintBolt — Technical Specification

## App Store Metadata

- **App Name:** SprintBolt
- **Subtitle:** Interval & Sprint Timer
- **Category:** Health & Fitness
- **Age Rating:** 4+
- **Bundle ID:** com.sprintbolt.app

---

## 1. App Summary

### Target Audience
- Runners and athletes focused on speed training
- HIIT enthusiasts who need structured interval timers
- Track & field athletes practicing sprint drills
- Fitness enthusiasts seeking explosive workout timing
- Coaches planning interval sessions for clients

### Problem Statement
Generic timer apps lack sport-specific features for interval training. Athletes need a dedicated tool that understands work/rest phases, provides motivational cues, and tracks sprint performance over time.

### Core Value Proposition
SprintBolt is a specialized interval training timer with an energetic, premium design. It provides customizable work/rest intervals, audio/haptic cues, and session history — all wrapped in a high-energy visual experience that motivates peak performance.

### Design Philosophy
Inspired by premium sports aesthetics: dark backgrounds, vibrant red accents (#FF1000), lightning bolt motifs symbolizing speed and explosive power. Clean typography, high contrast, and dynamic visual feedback during active sessions.

---

## 2. Feature List

### MVP Features (v1.0)
1. **Quick Start Timer** — Instant access to common interval presets
2. **Custom Workout Builder** — Create personalized interval sequences
3. **Active Session Screen** — Full-screen timer with phase indicators
4. **Audio & Haptic Cues** — Sound/vibration alerts for phase transitions
5. **Session History** — Log of completed workouts with basic stats
6. **Preset Library** — Pre-built interval templates (Tabata, HIIT, Sprint Drills)
7. **Onboarding Flow** — 4-screen introduction collecting user preferences

### Optional Features (v1.1+)
- Custom audio selection for cues
- Heart rate zone integration (HealthKit)
- Workout sharing/export
- Apple Watch companion
- Siri Shortcuts integration

---

## 3. Screen Map & Navigation Flow

```
App Launch
    │
    ▼
┌─────────────────┐
│   Onboarding    │ (if not completed)
│   (4 screens)   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│              Main Tab Bar                   │
├─────────────┬─────────────┬─────────────────┤
│   ⚡ Quick   │  📋 Workouts │   📊 History   │
│   Start     │             │                 │
└─────────────┴─────────────┴─────────────────┘
         │           │              │
         ▼           ▼              ▼
┌─────────────┐ ┌──────────┐ ┌─────────────┐
│ Preset Grid │ │ Workout  │ │ Session     │
│             │ │ List     │ │ List        │
└──────┬──────┘ └────┬─────┘ └──────┬──────┘
       │             │              │
       ▼             ▼              ▼
┌─────────────┐ ┌──────────┐ ┌─────────────┐
│  Active     │ │ Workout  │ │  Session    │
│  Session    │ │ Editor   │ │  Detail     │
│  (Modal)    │ │ (Sheet)  │ │  (Sheet)    │
└─────────────┘ └──────────┘ └─────────────┘
```

### Navigation Structure
- **Root:** `TabView` with 3 tabs
- **Modals:** Active session presented as full-screen modal
- **Sheets:** Workout editor and session details as `.sheet` presentations
- **Settings:** Accessible via toolbar button on any tab

---

## 4. Detailed Screen Specifications

### 4.1 Onboarding Flow

#### Screen 1: Welcome
- **Layout:**
  - Large lightning bolt illustration (centered, top 40%)
  - App name "SprintBolt" in H1
  - Tagline: "Unleash Your Speed"
  - Continue button (primary style)
- **Background:** Gradient from Dark Navy to Navy with subtle red glow

#### Screen 2: Training Focus
- **Purpose:** Collect user's primary training type
- **Layout:**
  - H2: "What's Your Focus?"
  - Selection grid (2x2):
    - ⚡ Sprint Training
    - 🔥 HIIT Workouts
    - 🏃 Interval Running
    - 💪 General Fitness
  - Single selection, highlighted with red border
  - Continue button

#### Screen 3: Experience Level
- **Purpose:** Calibrate default presets
- **Layout:**
  - H2: "Your Experience"
  - Vertical selection list:
    - Beginner (just starting)
    - Intermediate (regular training)
    - Advanced (competitive athlete)
  - Selected item gets red checkmark
  - Continue button

#### Screen 4: Notification Permission
- **Layout:**
  - Illustration of notification bell with lightning
  - H2: "Stay on Track"
  - Body: "Get audio cues during workouts even when screen is off"
  - Enable Notifications button (primary)
  - "Maybe Later" text button
- **Action:** Request notification permission if user taps Enable

#### Onboarding Data Storage
```swift
UserDefaults Keys:
- "onboarding_completed": Bool
- "user_training_focus": String (sprint/hiit/interval/general)
- "user_experience_level": String (beginner/intermediate/advanced)
- "notifications_enabled": Bool
```

---

### 4.2 Quick Start Tab

#### Layout Blocks
1. **Header Section**
   - H1: "Quick Start"
   - Subtitle: "Tap to begin"

2. **Featured Preset Card**
   - Large card (full width, 180pt height)
   - Background: Gradient red (#FF1000 → #D40D00)
   - Lightning bolt decorative element
   - Preset name: "Classic Tabata"
   - Duration badge: "4 min"
   - Tap to start immediately

3. **Preset Grid**
   - 2-column grid of preset cards
   - Each card shows:
     - Icon (SF Symbol)
     - Name
     - Duration
     - Interval count badge
   - Cards: Dark Grey background (#21262D)

#### Presets Included
| Name | Work | Rest | Rounds | Total |
|------|------|------|--------|-------|
| Classic Tabata | 20s | 10s | 8 | 4:00 |
| Sprint Intervals | 30s | 60s | 6 | 9:00 |
| HIIT Burner | 45s | 15s | 10 | 10:00 |
| Beginner Pace | 20s | 40s | 6 | 6:00 |
| Pro Sprints | 15s | 45s | 12 | 12:00 |
| Endurance Build | 60s | 30s | 8 | 12:00 |

#### States
- **Default:** All presets visible
- **Loading:** Skeleton cards while loading user data (rare)

#### User Actions
- Tap preset card → Launch Active Session with preset
- Long-press preset → Show quick info popover

---

### 4.3 Workouts Tab

#### Layout Blocks
1. **Header Section**
   - H1: "My Workouts"
   - "+" button in toolbar (creates new workout)

2. **Empty State** (if no custom workouts)
   - Illustration: Lightning bolt with plus sign
   - H3: "No Custom Workouts Yet"
   - Body: "Create your first interval sequence"
   - "Create Workout" button (primary)

3. **Workout List**
   - Vertical list of workout cards
   - Each card shows:
     - Custom name
     - Total duration
     - Interval summary (e.g., "8 rounds • 20s/10s")
     - Last used date (if any)
   - Swipe-to-delete enabled

#### User Actions
- Tap "+" → Open Workout Editor (new)
- Tap workout card → Open Workout Editor (edit) or Start options
- Swipe left → Delete with confirmation
- Long-press → Context menu (Edit, Duplicate, Delete)

---

### 4.4 Workout Editor (Sheet)

#### Layout Blocks
1. **Header**
   - Title: "New Workout" or "Edit Workout"
   - Cancel button (left)
   - Save button (right, disabled until valid)

2. **Name Field**
   - Text input with placeholder "Workout Name"
   - Max 30 characters
   - Validation: Required, non-empty

3. **Interval Configuration**
   - **Work Duration Stepper**
     - Label: "Work"
     - Duration picker (5s - 300s, 5s increments)
     - Red accent color
   - **Rest Duration Stepper**
     - Label: "Rest"
     - Duration picker (5s - 300s, 5s increments)
     - Grey/muted color
   - **Rounds Stepper**
     - Label: "Rounds"
     - Number picker (1-50)

4. **Preview Section**
   - Total duration calculated and displayed
   - Visual timeline preview (colored bars)

5. **Advanced Options** (collapsed by default)
   - Warm-up duration (0-60s)
   - Cool-down duration (0-60s)
   - Countdown before start (3s/5s/10s)

#### Validation Rules
- Name: 1-30 characters, required
- Work: 5-300 seconds
- Rest: 5-300 seconds
- Rounds: 1-50
- Total duration must not exceed 60 minutes

#### User Actions
- Adjust steppers → Live preview updates
- Tap Save → Validate and save to UserDefaults
- Tap Cancel → Dismiss with unsaved changes warning if dirty

---

### 4.5 Active Session Screen (Full-Screen Modal)

#### Layout Blocks
1. **Status Bar Area**
   - Pause button (top-left)
   - Current round indicator: "Round 3/8"
   - Stop button (top-right)

2. **Main Timer Display** (center, dominant)
   - Large circular progress ring
   - Current phase time remaining (giant numerals)
   - Phase label below: "WORK" or "REST"
   - Ring color: Red for work, grey/green for rest

3. **Phase Indicator Strip**
   - Horizontal bar showing all phases
   - Current phase highlighted
   - Completed phases filled
   - Upcoming phases outlined

4. **Next Up Preview**
   - Small text: "Next: REST 10s" or "Next: WORK 20s"
   - Helps user prepare mentally

5. **Control Bar** (bottom)
   - Large Pause/Resume button (centered)
   - Skip Phase button (small, right)

#### Visual States

**Work Phase:**
- Background: Pulsing dark red gradient
- Ring: Bright red (#FF1000)
- Large "WORK" label
- Optional: Subtle screen flash at phase start

**Rest Phase:**
- Background: Calm dark navy
- Ring: Green (#2EA44F) or grey
- Large "REST" label

**Paused:**
- Overlay with blur
- "PAUSED" text
- Resume and End Workout buttons

**Completed:**
- Celebration animation (lightning bolts)
- Session summary card
- "Great Work!" message
- Save & Close button

#### Audio/Haptic Cues
- 3-2-1 countdown beeps before phase change
- Distinct sound for Work start vs Rest start
- Haptic feedback: Heavy impact at phase change
- Optional voice cue: "Work!" / "Rest!"

#### User Actions
- Tap Pause → Pause timer, show overlay
- Tap Resume → Continue timer
- Tap Stop → Confirmation dialog, then end session
- Tap Skip → Skip to next phase
- Device lock → Timer continues with audio cues

---

### 4.6 History Tab

#### Layout Blocks
1. **Header Section**
   - H1: "History"
   - Filter/sort button (optional v1.1)

2. **Stats Summary Card**
   - This week's stats:
     - Total sessions
     - Total active time
     - Longest streak
   - Background: Gradient card

3. **Empty State** (if no sessions)
   - Illustration: Lightning bolt with clock
   - H3: "No Sessions Yet"
   - Body: "Complete your first workout to see it here"

4. **Session List**
   - Grouped by date (Today, Yesterday, This Week, Earlier)
   - Each item shows:
     - Workout name
     - Duration completed
     - Completion percentage
     - Time/date
   - Red accent for 100% completed sessions

#### User Actions
- Tap session → Open Session Detail sheet
- Swipe to delete (with confirmation)

---

### 4.7 Session Detail (Sheet)

#### Layout Blocks
1. **Header**
   - Workout name
   - Close button (X)

2. **Completion Badge**
   - Large percentage ring
   - "100% Complete" or "75% Complete"
   - Color based on completion (green for 100%, yellow for partial)

3. **Stats Grid**
   - Date & time
   - Total duration
   - Rounds completed
   - Work time total
   - Rest time total

4. **Timeline View** (optional)
   - Visual representation of phases completed

5. **Actions**
   - "Repeat Workout" button
   - "Delete" text button

---

### 4.8 Settings Screen

#### Access
- Gear icon in navigation bar (any tab)

#### Sections

**Sound & Haptics**
- Sound Effects toggle
- Haptic Feedback toggle
- Voice Cues toggle (v1.1)

**Timer Preferences**
- Default countdown (3s/5s/10s picker)
- Screen always on during workout toggle
- Background audio mode toggle

**About**
- App version
- Rate on App Store link
- Privacy Policy link
- Terms of Service link

**Data**
- Clear History button (with confirmation)
- Reset to Defaults button

---

## 5. Data Model

### Entities

#### Workout
```swift
struct Workout: Codable, Identifiable {
    let id: UUID
    var name: String
    var workDuration: Int // seconds
    var restDuration: Int // seconds
    var rounds: Int
    var warmupDuration: Int // seconds, default 0
    var cooldownDuration: Int // seconds, default 0
    var countdownDuration: Int // seconds, default 3
    let createdAt: Date
    var lastUsedAt: Date?
    var isPreset: Bool // true for built-in presets
}
```

#### Session
```swift
struct Session: Codable, Identifiable {
    let id: UUID
    let workoutId: UUID
    let workoutName: String
    let startedAt: Date
    let completedAt: Date?
    let totalDuration: Int // seconds actually elapsed
    let roundsCompleted: Int
    let roundsTotal: Int
    let workTimeTotal: Int // seconds
    let restTimeTotal: Int // seconds
    var completionPercentage: Double // 0.0 - 1.0
}
```

#### UserPreferences
```swift
struct UserPreferences: Codable {
    var trainingFocus: String // sprint/hiit/interval/general
    var experienceLevel: String // beginner/intermediate/advanced
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var voiceCuesEnabled: Bool
    var defaultCountdown: Int // 3, 5, or 10
    var keepScreenOn: Bool
    var backgroundAudioEnabled: Bool
}
```

### Field Constraints
- `Workout.name`: 1-30 characters
- `Workout.workDuration`: 5-300 seconds
- `Workout.restDuration`: 5-300 seconds
- `Workout.rounds`: 1-50
- `Session.completionPercentage`: 0.0-1.0

### Example Data
```json
{
  "workout": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Morning Sprints",
    "workDuration": 30,
    "restDuration": 60,
    "rounds": 8,
    "warmupDuration": 0,
    "cooldownDuration": 0,
    "countdownDuration": 5,
    "createdAt": "2025-01-15T08:00:00Z",
    "lastUsedAt": "2025-01-20T07:30:00Z",
    "isPreset": false
  }
}
```

---

## 6. Local Persistence

### UserDefaults Keys

| Key | Type | Description |
|-----|------|-------------|
| `onboarding_completed` | Bool | Onboarding completion flag |
| `user_preferences` | Data (JSON) | UserPreferences struct |
| `custom_workouts` | Data (JSON) | Array of Workout |
| `session_history` | Data (JSON) | Array of Session |
| `app_launch_count` | Int | For potential future rating prompts |

### Encoding/Decoding Approach
```swift
// Save
func saveWorkouts(_ workouts: [Workout]) {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    if let data = try? encoder.encode(workouts) {
        UserDefaults.standard.set(data, forKey: "custom_workouts")
    }
}

// Load
func loadWorkouts() -> [Workout] {
    guard let data = UserDefaults.standard.data(forKey: "custom_workouts") else {
        return []
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return (try? decoder.decode([Workout].self, from: data)) ?? []
}
```

### Migration Strategy
- v1.0 → v1.1: Add new optional fields with defaults
- Store schema version in UserDefaults: `data_schema_version`
- On app launch, check version and migrate if needed
- Migration example: Add missing fields to existing structs

---

## 7. UI Design System

### Color Palette (AppColors.swift)

```swift
enum AppColors {
    // Primary Brand
    static let boltRed = Color(hex: "#FF1000")
    static let boltRedDark = Color(hex: "#D40D00")
    static let boltRedLight = Color(hex: "#FF3D30")
    
    // Backgrounds
    static let backgroundPrimary = Color(hex: "#0D1117")
    static let backgroundSecondary = Color(hex: "#161B22")
    static let backgroundCard = Color(hex: "#21262D")
    static let backgroundElevated = Color(hex: "#30363D")
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#8B949E")
    static let textMuted = Color(hex: "#6E7681")
    
    // Semantic
    static let success = Color(hex: "#2EA44F")
    static let warning = Color(hex: "#F9A825")
    static let error = Color(hex: "#F85149")
    
    // Phase Colors
    static let workPhase = boltRed
    static let restPhase = Color(hex: "#2EA44F")
}
```

### Typography (AppFonts.swift)

```swift
enum AppFonts {
    // Using SF Pro (system font)
    static let timerDisplay = Font.system(size: 96, weight: .bold, design: .rounded)
    static let h1 = Font.system(size: 28, weight: .bold)
    static let h2 = Font.system(size: 22, weight: .semibold)
    static let h3 = Font.system(size: 18, weight: .semibold)
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let body = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium)
    static let button = Font.system(size: 16, weight: .semibold)
    static let phaseLabel = Font.system(size: 24, weight: .heavy)
}
```

### Spacing (AppSpacing.swift)

```swift
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### Corner Radii (AppCorners.swift)

```swift
enum AppCorners {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let pill: CGFloat = 999
}
```

### Component Styles

**Primary Button**
- Background: boltRed
- Text: white, button font
- Corner radius: medium (12)
- Height: 52pt
- Pressed state: boltRedDark

**Secondary Button**
- Background: backgroundCard
- Border: 1.5pt boltRed
- Text: boltRed
- Corner radius: medium

**Card**
- Background: backgroundCard
- Corner radius: large (16)
- Optional border: 1pt backgroundElevated

**Preset Card**
- Height: 100pt
- Icon: 32pt SF Symbol
- Subtle gradient overlay

---

## 8. Accessibility Checklist

### Dynamic Type
- [ ] All text uses scalable fonts
- [ ] Minimum touch targets: 44x44pt
- [ ] Layout adapts to larger text sizes
- [ ] Timer display remains readable at all sizes

### VoiceOver
- [ ] All buttons have accessibility labels
- [ ] Timer announces phase changes
- [ ] Custom rotors for workout navigation (v1.1)
- [ ] Session completion announced

### Visual
- [ ] Contrast ratio ≥ 4.5:1 for all text
- [ ] Color not sole indicator (icons + labels)
- [ ] Reduce Motion support for animations
- [ ] Dark/Light mode support (primarily dark, light mode secondary)

### Audio
- [ ] Visual alternatives for all audio cues
- [ ] Closed captions for voice cues (v1.1)

### Required Labels
```swift
// Example
Button(action: startWorkout) {
    Text("Start")
}
.accessibilityLabel("Start workout")
.accessibilityHint("Begins the interval timer")
```

---

## 9. App Store Compliance

### Privacy
- **Data Collection:** None. All data stored locally.
- **Privacy Policy:** Required. Simple policy stating no data collection.
- **Tracking:** None. No analytics SDKs.

### Permissions Required
| Permission | Usage | Purpose String |
|------------|-------|----------------|
| Notifications | Audio cues when backgrounded | "SprintBolt uses notifications to alert you during workouts when the app is in the background." |

### Content Rating
- No objectionable content
- No user-generated content
- No external links except privacy policy
- Age rating: 4+

### Review Guidelines Compliance
- ✅ Provides genuine utility (interval timer)
- ✅ No gambling mechanics or visuals
- ✅ No deceptive patterns
- ✅ Meaningful empty states
- ✅ Polished, complete flows
- ✅ No placeholder content
- ✅ Free, no monetization

### Required Disclaimers
- Settings screen: "Consult a physician before starting any exercise program."

---

## 10. Acceptance Criteria

### Onboarding
- [ ] User can complete 4-screen onboarding
- [ ] Preferences are saved to UserDefaults
- [ ] Onboarding only shows on first launch
- [ ] User can skip notification permission

### Quick Start
- [ ] 6 presets displayed in grid
- [ ] Tapping preset launches active session
- [ ] Featured card visually distinct

### Custom Workouts
- [ ] User can create workout with name, work, rest, rounds
- [ ] Validation prevents invalid inputs
- [ ] Workouts persist across app launches
- [ ] User can edit existing workouts
- [ ] User can delete workouts with confirmation

### Active Session
- [ ] Timer counts down accurately
- [ ] Phase transitions trigger audio/haptic
- [ ] Work/Rest phases visually distinct
- [ ] User can pause/resume
- [ ] User can stop with confirmation
- [ ] Session continues in background
- [ ] Completion screen shows summary

### History
- [ ] Completed sessions appear in list
- [ ] Sessions grouped by date
- [ ] User can view session details
- [ ] User can delete sessions
- [ ] Stats summary shows weekly totals

### Settings
- [ ] Sound toggle works
- [ ] Haptic toggle works
- [ ] Clear history works with confirmation
- [ ] About section shows version

### Accessibility
- [ ] VoiceOver navigable throughout
- [ ] Dynamic Type supported
- [ ] Sufficient color contrast
- [ ] 44pt minimum touch targets

---

## 11. Technical Notes

### Timer Implementation
- Use `Timer.publish` for UI updates
- Use `AVAudioSession` for background audio
- Request `.playback` category for background execution
- Store session state for resume after termination

### Background Execution
```swift
// Enable background audio
try AVAudioSession.sharedInstance().setCategory(
    .playback,
    mode: .default,
    options: [.mixWithOthers]
)
try AVAudioSession.sharedInstance().setActive(true)
```

### Haptic Feedback
```swift
// Phase change
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)

// Countdown tick
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()
```

### State Preservation
- Save active session state on `scenePhase` change to `.background`
- Restore session on app relaunch if within reasonable time (< 4 hours)

---

## Appendix: File Structure

```
SprintBolt/
├── App/
│   ├── SprintBoltApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── OnboardingPageView.swift
│   ├── QuickStart/
│   │   ├── QuickStartView.swift
│   │   └── PresetCardView.swift
│   ├── Workouts/
│   │   ├── WorkoutsView.swift
│   │   ├── WorkoutEditorView.swift
│   │   └── WorkoutCardView.swift
│   ├── ActiveSession/
│   │   ├── ActiveSessionView.swift
│   │   ├── TimerRingView.swift
│   │   └── SessionViewModel.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── SessionDetailView.swift
│   │   └── StatsCardView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Core/
│   ├── Models/
│   │   ├── Workout.swift
│   │   ├── Session.swift
│   │   └── UserPreferences.swift
│   ├── Services/
│   │   ├── StorageService.swift
│   │   ├── AudioService.swift
│   │   └── HapticService.swift
│   └── Extensions/
│       └── Color+Hex.swift
├── Design/
│   ├── AppColors.swift
│   ├── AppFonts.swift
│   ├── AppSpacing.swift
│   └── AppCorners.swift
└── Resources/
    ├── Assets.xcassets/
    └── Sounds/
```

---

*SprintBolt Technical Specification v1.0*
*Target: iOS 16+ / iPhone*
