# SolarConnect - Pending Work & Phase 2 Roadmap

**Document Date**: June 10, 2026  
**Current Status**: 81% Complete - Ready for Phase 2 Planning

---

## 🚨 CRITICAL PENDING ITEMS (Must Complete Before Production)

### 1. API Integration ❌ CRITICAL

**Priority**: HIGHEST | **Est. Time**: 8 hours | **Blocker**: Real data

#### What's Needed

```
Backend API Endpoints Required:
├── GET /api/v1/energy/current
│   ├── Returns: Current power values (W)
│   ├── Fields: solarPowerW, consumptionPowerW, batteryPowerW, gridPowerW
│   └── Update frequency: Real-time (WebSocket) or every 5 seconds
│
├── GET /api/v1/energy/today
│   ├── Returns: Daily totals (kWh)
│   ├── Fields: solarTodayKwh, consumptionTodayKwh, gridExportKwh, gridImportKwh
│   └── Cached: Once per day
│
├── GET /api/v1/battery/status
│   ├── Returns: Battery state
│   ├── Fields: batteryPercent, batteryCharging, batteryPowerW
│   └── Update frequency: Real-time
│
├── GET /api/v1/articles?category=:category
│   ├── Returns: List of articles
│   ├── Fields: id, title, subtitle, category, readTime, imageUrl
│   └── Pagination: Support offset/limit
│
└── GET /api/v1/user/profile
    ├── Returns: User data
    └── Fields: name, email, userId, systemId, systemName
```

#### Implementation Tasks

```
[ ] Dio/http package integration
[ ] API service class (lib/services/api_service.dart)
[ ] Authentication token management
[ ] Error handling & retry logic
[ ] Loading state management
[ ] Offline caching with shared_preferences
[ ] Replace EnergyReading.demo() with real API calls
[ ] Replace ExploreArticle.demoArticles with API
[ ] Replace hardcoded user data with real user API
```

### 2. Authentication ❌ CRITICAL

**Priority**: HIGHEST | **Est. Time**: 4 hours

#### What's Needed

```
Firebase Setup:
[ ] Firebase project creation
[ ] Firebase Authentication enabled
[ ] Google Sign-in configured
[ ] Apple Sign-in configured (iOS)
[ ] Facebook Sign-in configured (iOS/Android)

Implementation:
[ ] Firebase plugins: firebase_core, firebase_auth
[ ] Auth service class (lib/services/auth_service.dart)
[ ] Login/Sign up screens
[ ] Session persistence
[ ] Token refresh logic
[ ] Sign out functionality
[ ] Password reset flow
```

### 3. Error Handling & Offline Mode ❌ CRITICAL

**Priority**: HIGH | **Est. Time**: 4 hours

#### What's Needed

```
[ ] Try-catch blocks on all API calls
[ ] User-friendly error messages
[ ] Network connectivity detection
[ ] Offline mode (show cached data)
[ ] Retry buttons for failed requests
[ ] Error logging & reporting
[ ] Crash analytics integration
```

---

## ⚠️ IMPORTANT PENDING ITEMS (Phase 3 - Next Sprint)

### 1. Missing Detail Screens ❌

**Priority**: HIGH | **Est. Time**: 4 hours

#### Article Detail Screen

```
New File: lib/screens/explore/article_detail_screen.dart

Features Needed:
[ ] Full article content from API
[ ] Read time estimate
[ ] Share button (share to WhatsApp, Twitter, etc.)
[ ] Bookmark/Save for later
[ ] Related articles section
[ ] Navigation from ArticleCard
```

#### System Details Screen

```
New File: lib/screens/overview/system_details_screen.dart

Features Needed:
[ ] System info: Model, Brand, Installation date
[ ] System specifications: Panel count, battery capacity, inverter rating
[ ] Performance metrics: Lifetime generation, efficiency
[ ] Warranty info
[ ] Installation location map
```

#### Settings Screens

```
New Files:
├── lib/screens/settings/notifications_settings.dart
├── lib/screens/settings/appearance_settings.dart
├── lib/screens/settings/language_settings.dart
└── lib/screens/settings/privacy_settings.dart

Features Needed:
[ ] Toggle notifications for alerts
[ ] Dark/Light theme toggle
[ ] Language selection (i18n)
[ ] Privacy policy links
[ ] Data deletion options
[ ] Permissions management
```

### 2. Charts & Data Visualization ❌

**Priority**: HIGH | **Est. Time**: 6 hours

#### Historical Data Charts

```
New Files:
├── lib/widgets/overview/daily_chart.dart (Line chart - today)
├── lib/widgets/overview/monthly_chart.dart (Line chart - month)
└── lib/widgets/overview/yearly_chart.dart (Bar chart - year)

Features Needed:
[ ] Line chart: Energy generation over time (today)
[ ] Line chart: Energy consumption over time (today)
[ ] Bar chart: Daily comparison (last 7 days)
[ ] Bar chart: Monthly comparison (last 12 months)
[ ] Pie chart: Energy source breakdown
[ ] Interactive tooltips
[ ] Zoom & pan gestures

Data Required from API:
[ ] GET /api/v1/energy/history/daily?date=YYYY-MM-DD
[ ] GET /api/v1/energy/history/monthly?month=YYYY-MM
[ ] GET /api/v1/energy/history/yearly?year=YYYY
```

### 3. Loading Skeletons ❌

**Priority**: MEDIUM | **Est. Time**: 2 hours

#### Current Issue

```
shimmer package imported but not used
```

#### What's Needed

```
New Files:
├── lib/widgets/skeletons/overview_skeleton.dart
├── lib/widgets/skeletons/article_list_skeleton.dart
└── lib/widgets/skeletons/profile_skeleton.dart

Implementation:
[ ] Create shimmer placeholder widgets
[ ] Replace hard-coded data with skeletons while loading
[ ] Animate shimmer effect
[ ] Apply to Overview screen (stats)
[ ] Apply to Explore screen (articles)
[ ] Apply to Me screen (user info)
```

---

## 📋 MEDIUM PRIORITY PENDING ITEMS

### 1. Light Theme Implementation ⚠️

**Priority**: MEDIUM | **Est. Time**: 1 hour

#### What's Needed

```
File: lib/theme/app_theme.dart - Add light() ThemeData

Steps:
[ ] Create light ColorScheme
[ ] Create light textTheme
[ ] Create light component themes
[ ] Update AppColors for light theme readiness
[ ] Test on all screens
[ ] Add theme toggle in settings

Note: Light theme colors already defined in app_colors.dart
      Just need to add them to AppTheme.light()
```

### 2. Notifications System ⚠️

**Priority**: MEDIUM | **Est. Time**: 4 hours

#### What's Needed

```
Packages:
[ ] firebase_messaging: ^15.0.0 (Push notifications)
[ ] flutter_local_notifications: ^14.0.0 (Local notifications)

Features:
[ ] Setup Firebase Cloud Messaging
[ ] Local notification permissions
[ ] Alert notifications (low battery, grid issues)
[ ] Notification settings screen
[ ] Notification history/logs
[ ] Rich notifications with images
```

### 3. Settings Persistence ⚠️

**Priority**: MEDIUM | **Est. Time**: 2 hours

#### What's Needed

```
Already have: shared_preferences imported

Implementation:
[ ] Create lib/services/settings_service.dart
[ ] Save user preferences:
    - Theme selection
    - Language
    - Notification settings
    - Unit system (kW vs W, etc.)
    - Default view
[ ] Load saved preferences on app startup
[ ] Apply settings dynamically
```

---

## 📊 TESTING GAPS (Need 10-15 Tests Minimum)

### Critical Tests Needed ❌

#### 1. Widget Tests (5-7 tests)

```
[ ] test_overview_screen.dart - 2-3 tests
    [ ] Overview screen renders without errors
    [ ] Energy stats display correctly
    [ ] Battery card shows correct percentage

[ ] test_explore_screen.dart - 2-3 tests
    [ ] Category filtering works
    [ ] Articles display correctly
    [ ] Tap on article triggers onTap

[ ] test_shell_screen.dart - 1 test
    [ ] Tab switching works

[ ] test_theme.dart - 1 test
    [ ] Dark theme applies correctly
```

#### 2. Integration Tests (3-5 tests)

```
[ ] User taps tab → screen changes
[ ] User filters articles → list updates
[ ] User scrolls Overview → SliverAppBar collapses
[ ] User taps article card → navigates to detail
[ ] App handles network errors gracefully
```

#### 3. Unit Tests (2-3 tests)

```
[ ] EnergyReading.demo() returns valid data
[ ] ExploreArticle filtering logic works
[ ] Constants are properly defined
```

---

## 📚 DOCUMENTATION GAPS

### Critical Documentation ❌

#### 1. README.md Update (HIGH)

```markdown
Current: Generic Flutter starter
Needed:

# SolarConnect - Solar Energy Monitoring App

## Overview

- What is it?
- Key features
- Screenshots

## Getting Started

- Prerequisites (Flutter version, SDK)
- Installation steps
- Running the app

## Project Structure

- Folder organization
- What's in each folder

## Available Scripts

- flutter run
- flutter test
- flutter build

## Features

- Overview tab
- Explore tab
- Me tab
- (Coming soon: Charts, etc.)

## Architecture

- State management approach
- API integration
- Error handling

## Contributing

- Code style guidelines
- Pull request process

## License

- License information
```

#### 2. API Documentation (MEDIUM)

```
File: API.md

Needed:
[ ] List all endpoints
[ ] Request/response formats
[ ] Authentication headers
[ ] Error codes & meanings
[ ] Rate limiting info
[ ] Example requests/responses
```

#### 3. Setup & Development Guide (MEDIUM)

```
File: SETUP.md

Needed:
[ ] System requirements
[ ] Flutter version requirements
[ ] IDE setup (VS Code, Android Studio)
[ ] Android emulator setup
[ ] iOS simulator setup
[ ] First run steps
[ ] Hot reload debugging tips
```

#### 4. Architecture Documentation (MEDIUM)

```
File: ARCHITECTURE.md

Needed:
[ ] Project structure diagram
[ ] Widget tree hierarchy
[ ] Data flow diagram
[ ] State management pattern
[ ] Folder organization rationale
```

---

## 🔧 KNOWN ISSUES & IMPROVEMENTS

### Code Quality Issues ⚠️

#### 1. State Management (Future Refactor)

```
Current: Using setState in ShellScreen & ExploreScreen

Why it's not ideal:
- Hard to scale with more complex state
- Props drilling if more screens added
- Can't easily test state logic

Recommended Solution (Phase 3):
- Use Provider or Riverpod
- Centralize state for: user, energy readings, articles
- Easier testing & debugging

Timeline: Not critical now, but plan for Phase 3+
```

#### 2. Energy Flow Painter Performance (Minor)

```
Current: EnergyFlowPainter redraws every frame

Optimization:
- Could cache painted image for static parts
- Only animate the lines
- Use RepaintBoundary for optimization

Impact: Low (runs fine on modern devices)
Timeline: Phase 4 optimization
```

#### 3. Mock Data Hardcoded

```
Current: EnergyReading.demo() and ExploreArticle.demoArticles

Issue: Not easily switchable between mock and real API

Solution:
- Create DataProvider class
- Switch between MockDataProvider and ApiDataProvider
- Easier testing

Timeline: Phase 2 (when implementing API)
```

---

## 📲 PLATFORM-SPECIFIC TASKS

### Android ❌

```
[ ] Update minSdkVersion if needed
[ ] Configure signing key
[ ] Set up app icon
[ ] Test on multiple devices
[ ] Battery optimization settings
[ ] Background location permissions (if needed)
```

### iOS ❌

```
[ ] Update iOS deployment target
[ ] Configure signing certificate
[ ] Set up app icon
[ ] Set up launch screen
[ ] Configure privacy strings (Info.plist)
[ ] Test on different devices
[ ] Submit to TestFlight
```

### Web ❌

```
[ ] Test responsive layout
[ ] Performance optimization
[ ] SEO metadata
[ ] PWA setup (optional)
[ ] Deploy to hosting
```

---

## 🎯 RECOMMENDED PHASE 2 SPRINT PLAN

**Duration**: 2-3 days (16-24 hours)  
**Focus**: Get real data flowing

### Day 1: API Integration Foundation (8 hours)

```
Completed Time: 0 hours

Tasks:
1. [ ] Setup Dio HTTP client (1 hour)
2. [ ] Create API service class (2 hours)
3. [ ] Implement EnergyReading API integration (2 hours)
4. [ ] Implement ExploreArticle API integration (2 hours)
5. [ ] Add error handling (1 hour)
```

### Day 2: Authentication & Testing (8 hours)

```
Tasks:
1. [ ] Firebase setup & config (2 hours)
2. [ ] Auth service implementation (2 hours)
3. [ ] Login screen UI (2 hours)
4. [ ] Integration tests (2 hours)
```

### Day 3: Polish & Documentation (8 hours)

```
Tasks:
1. [ ] Loading states & skeletons (2 hours)
2. [ ] Update README.md (1 hour)
3. [ ] Create API documentation (1 hour)
4. [ ] Bug fixes & testing (3 hours)
5. [ ] Deploy to TestFlight/Play Store internal testing (1 hour)
```

---

## 🎨 UI/UX IMPROVEMENTS (Nice-to-Have)

### Visual Refinements

```
[ ] Add app icon (currently uses Flutter default)
[ ] Add splash screen
[ ] Add onboarding screens (first launch)
[ ] Improve energy flow animation
[ ] Add micro-interactions (button press feedback)
[ ] Add haptic feedback for important actions
```

### Accessibility

```
[ ] Semantic labels for screen readers
[ ] Color contrast audit
[ ] Font size scaling tests
[ ] Keyboard navigation
[ ] Voice control testing
```

### Localization (i18n)

```
[ ] Set up intl package (already added)
[ ] Create translation files (en, es, fr, etc.)
[ ] Test on different locales
```

---

## 📊 SUCCESS METRICS

### Phase 2 Goals

```
✅ API Integration
   - [ ] 100% of data from real API
   - [ ] <2 second initial load time
   - [ ] Handles network errors gracefully
   - [ ] Works offline (cached data)

✅ Testing
   - [ ] 10+ widget tests passing
   - [ ] 3+ integration tests passing
   - [ ] 100% critical path coverage

✅ Performance
   - [ ] 60 FPS animations
   - [ ] <50MB app size
   - [ ] <100MB RAM usage
   - [ ] Runs on devices with 2GB RAM

✅ User Experience
   - [ ] App can be used with real data
   - [ ] No crashes on main flows
   - [ ] Smooth navigation
   - [ ] Clear error messages
```

---

## 🚀 DEPLOYMENT CHECKLIST

### Pre-Release (Before beta)

```
[ ] All critical issues fixed
[ ] 100% code review complete
[ ] Performance testing done
[ ] Security audit (API keys, permissions)
[ ] Beta testing group identified
[ ] Crash reporting setup (Sentry/Firebase)
```

### Release Candidate

```
[ ] Version number updated (1.0.0 → 1.0.1)
[ ] Release notes prepared
[ ] Screenshots updated
[ ] Store listings prepared
[ ] Privacy policy ready
[ ] Terms of service ready
```

### Post-Release

```
[ ] Monitor crash analytics
[ ] Monitor performance metrics
[ ] Monitor user feedback
[ ] Plan v1.1 features based on feedback
```

---

## 💡 TECHNICAL DEBT TO TRACK

```
1. State Management
   - Consider Provider/Riverpod migration in Phase 3
   - Complexity: Medium
   - Impact: High (improves testability)

2. Mock Data
   - Create proper data provider abstraction
   - Complexity: Low
   - Impact: Medium (easier testing)

3. Error Handling
   - Add comprehensive error handling
   - Complexity: Medium
   - Impact: High (reliability)

4. Logging
   - Add logging framework
   - Complexity: Low
   - Impact: Medium (debugging)

5. Analytics
   - Add user analytics tracking
   - Complexity: Medium
   - Impact: Medium (user insights)
```

---

## 📞 CONTACT & REFERENCES

**Project Manager**: [Name]  
**Lead Developer**: [Name]  
**Design Lead**: [Name]

**Documentation**:

- [Flutter Docs](https://flutter.dev)
- [Material Design 3](https://m3.material.io)
- [Firebase Docs](https://firebase.google.com/docs)

**Tools**:

- VS Code with Flutter extension
- Android Studio for AVD management
- Xcode for iOS (Mac only)

---

## 📝 CHANGE LOG

| Date       | Change                | By       |
| ---------- | --------------------- | -------- |
| 2026-06-10 | Created this document | Dev Team |

---

**Next Review Date**: After Phase 2 completion (3 days)  
**Last Updated**: June 10, 2026
