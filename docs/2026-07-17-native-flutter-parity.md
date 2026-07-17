# Native ↔ Flutter Feature Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring Android and iOS to full feature parity with Flutter CourtSide (same nav, screens, flows; real Auth + Sessions API; mock elsewhere).

**Architecture:** Feature-based Clean Architecture on both natives. Flutter `platform/lib` is the source of truth. Work in vertical slices with Android + iOS in parallel each task. Expand `ServiceLocator`; do not introduce Hilt/Koin/Alamofire unless blocked.

**Tech Stack:**
- Flutter reference: Dio, GetIt, Cubit, GoRouter
- Android: Kotlin, Jetpack Compose, Navigation Compose, Retrofit + OkHttp + kotlinx.serialization, DataStore/SharedPreferences
- iOS: SwiftUI, URLSession `APIClient`, Combine/`@Published` ViewModels
- API base: `http://localhost:8000/api/v1`

**Spec:** `docs/superpowers/specs/2026-07-17-native-flutter-parity-design.md`

**Repo root for commits:** `BAD_Mobile/` (git branch `dev_phuc`)

---

## File map (create / modify)

### Android (`android/app/src/main/`)

| Path | Role |
|------|------|
| `kotlin/.../theme/Color.kt` | CourtSide palette |
| `kotlin/.../theme/Theme.kt` | Apply primary `#006C49` |
| `kotlin/.../NavigationKeys.kt` | All routes |
| `kotlin/.../Navigation.kt` | Nav graph + auth gate |
| `kotlin/.../ui/main/MainScreen.kt` | 5-tab shell |
| `kotlin/.../core/network/*` | TokenStore, ApiClient, interceptor, SessionExpiredBus |
| `kotlin/.../core/di/ServiceLocator.kt` | Wire network + repos |
| `AndroidManifest.xml` | INTERNET (+ later POST_NOTIFICATIONS) |
| `app/build.gradle` | Retrofit/OkHttp deps |
| `features/auth/**` | Real API impl, User fields |
| `features/sessions/**` | Real API impl, Session fields |
| `features/match/**` | Matchmaking, Result, enriched entities |
| `features/profile/**` | Player domain + 3 screens |
| `features/community/**` | Chat, admin, navigation |
| Dashboard / profile screens | Shortcuts, greeting, skill bars |

### iOS (`ios/Runner/`)

| Path | Role |
|------|------|
| `theme/Theme.swift` | CourtSide palette |
| `MainNavigation.swift` | Auth gate + routes |
| `MainScreen.swift` | 5-tab shell |
| `core/network/APIClient.swift` | Single-flight refresh, session expired |
| `core/di/ServiceLocator.swift` | playerRepository |
| `features/auth/**` | logout, getMe, fullName, User fields |
| `features/sessions/**` | paymentStatus, host/level |
| `features/match/**` | Matchmaking, Result, entities |
| `features/profile/**` | Player domain + 3 screens |
| Community / Dashboard screens | Parity polish |

### Flutter (read-only reference)

Mirror behavior from:
- `platform/lib/app/router/app_router.dart`
- `platform/lib/core/network/auth_interceptor.dart`
- `platform/lib/features/auth/**`
- `platform/lib/features/sessions/**`
- `platform/lib/features/match/**`
- `platform/lib/features/profile/**`
- `platform/lib/features/community/presentation/pages/community_page.dart`
- `platform/lib/features/home/presentation/pages/dashboard_page.dart`
- `platform/lib/core/theme/app_colors.dart`

---

## Slice 0 — Shell (nav + theme)

### Task 1: Android theme CourtSide tokens

**Files:**
- Modify: `android/app/src/main/kotlin/com/maxton/bad_android/theme/Color.kt`
- Modify: `android/app/src/main/kotlin/com/maxton/bad_android/theme/Theme.kt`
- Modify: `android/app/src/main/AndroidManifest.xml` (app label if present)
- Modify: strings / activity label as needed for **CourtSide**

- [ ] **Step 1: Replace Color.kt with Flutter-aligned tokens**

```kotlin
package com.maxton.bad_android.theme

import androidx.compose.ui.graphics.Color

// Flutter AppColors parity
val Primary = Color(0xFF006C49)
val PrimaryContainer = Color(0xFF10B981) // was KineticGreen
val Accent = Color(0xFFFF7E2D)
val Tertiary = Color(0xFF9D4300)
val Background = Color(0xFFF8F9FF)
val Surface = Color(0xFFF8F9FF)
val SurfaceContainer = Color(0xFFE5EEFF)
val OnBackground = Color(0xFF0B1C30)
val OnSurface = Color(0xFF0B1C30)
val OnSurfaceVariant = Color(0xFF3C4A42)
val Outline = Color(0xFF6C7A71)
val OutlineVariant = Color(0xFFBBCABF)
val Error = Color(0xFFBA1A1A)
val ErrorContainer = Color(0xFFFFDAD6)
val OnPrimary = Color(0xFFFFFFFF)

// Back-compat aliases (update call sites gradually)
val KineticGreen = PrimaryContainer
val PremiumDark = OnBackground
val SoftGray = Background
val OutlineGray = OutlineVariant
val ErrorRed = Error
val SecondaryGreen = Color(0xFF059669)
```

- [ ] **Step 2: Point Theme.kt light colorScheme primary to `Primary` (`#006C49`), background/surface to `Background`**

Use `MaterialTheme.colorScheme` so NavigationBar selected colors pick up brand primary.

- [ ] **Step 3: Set app display name to CourtSide**

In `AndroidManifest.xml` / `res/values/strings.xml`, label = `CourtSide`.

- [ ] **Step 4: Compile check**

Run from `android/`:
```bash
./gradlew :app:compileDebugKotlin
```
Expected: BUILD SUCCESSFUL (fix any broken color refs).

- [ ] **Step 5: Commit**

```bash
cd /Users/nguyenthucphuc/project/badminton/BAD_Mobile
git add android/app/src/main/kotlin/com/maxton/bad_android/theme android/app/src/main/AndroidManifest.xml android/app/src/main/res
git commit -m "feat(android): align CourtSide theme tokens with Flutter"
```

---

### Task 2: iOS theme CourtSide tokens

**Files:**
- Modify: `ios/Runner/theme/Theme.swift`

- [ ] **Step 1: Expand AppTheme**

```swift
import SwiftUI

struct AppTheme {
    // Flutter AppColors parity
    static let primary = Color(red: 0/255, green: 108/255, blue: 73/255)      // #006C49
    static let primaryContainer = Color(red: 16/255, green: 185/255, blue: 129/255) // #10B981
    static let accent = Color(red: 255/255, green: 126/255, blue: 45/255)     // #FF7E2D
    static let tertiary = Color(red: 157/255, green: 67/255, blue: 0/255)     // #9D4300
    static let background = Color(red: 248/255, green: 249/255, blue: 255/255) // #F8F9FF
    static let surface = background
    static let onBackground = Color(red: 11/255, green: 28/255, blue: 48/255) // #0B1C30
    static let onSurface = onBackground
    static let outline = Color(red: 108/255, green: 122/255, blue: 113/255)
    static let error = Color(red: 186/255, green: 26/255, blue: 26/255)       // #BA1A1A

    // Back-compat aliases
    static let KineticGreen = primaryContainer
    static let SecondaryGreen = Color(red: 5/255, green: 150/255, blue: 105/255)
    static let PremiumDark = onBackground
    static let SoftGray = background
    static let OutlineGray = Color(red: 229/255, green: 231/255, blue: 235/255)
    static let ErrorRed = error

    static let spaceSm: CGFloat = 8
    static let spaceMd: CGFloat = 16
    static let spaceLg: CGFloat = 24
    static let radiusMd: CGFloat = 12
    static let radiusLg: CGFloat = 16
}
```

- [ ] **Step 2: Prefer `AppTheme.primary` for TabView accent in MainScreen**

Change `.accentColor(AppTheme.KineticGreen)` → `.tint(AppTheme.primary)` (or `.accentColor(AppTheme.primary)`).

- [ ] **Step 3: Commit**

```bash
git add ios/Runner/theme/Theme.swift ios/Runner/MainScreen.swift
git commit -m "feat(ios): align CourtSide theme tokens with Flutter"
```

---

### Task 3: Android routes + 5-tab MainScreen

**Files:**
- Modify: `android/.../NavigationKeys.kt`
- Modify: `android/.../Navigation.kt`
- Modify: `android/.../ui/main/MainScreen.kt`
- Create placeholder screens under `features/match/presentation/` and `features/profile/presentation/` as needed

- [ ] **Step 1: Expand Routes**

```kotlin
object Routes {
    const val ONBOARDING = "onboarding"
    const val WELCOME = "welcome"
    const val LOGIN = "login"
    const val REGISTER = "register"
    const val MAIN = "main"
    const val SESSION_DETAILS = "session_details/{sessionId}"
    const val DEVICE_SESSIONS = "device_sessions"
    const val NOTIFICATIONS = "notifications"
    const val MEMBER_MANAGEMENT = "member_management"
    const val JOIN_REQUESTS = "join_requests"
    const val MATCHMAKING = "matchmaking"
    const val MATCH_CREATOR = "match_creator?opponentId={opponentId}"
    const val MATCH_SCORE_ENTRY = "match_score_entry/{matchId}"
    const val MATCH_RESULT = "match_result/{matchId}"
    const val PLAYER_PROFILE = "player_profile/{playerId}"
    const val RATE_PLAYER = "rate_player/{playerId}"
    const val LEADERBOARD = "leaderboard"

    fun sessionDetails(sessionId: String) = "session_details/$sessionId"
    fun matchScoreEntry(matchId: String) = "match_score_entry/$matchId"
    fun matchResult(matchId: String) = "match_result/$matchId"
    fun matchCreator(opponentId: String? = null) =
        if (opponentId.isNullOrBlank()) "match_creator"
        else "match_creator?opponentId=$opponentId"
    fun playerProfile(playerId: String) = "player_profile/$playerId"
    fun ratePlayer(playerId: String) = "rate_player/$playerId"
}
```

Note: For Navigation Compose query args, use optional navArgument `opponentId` default `""` and route pattern `match_creator?opponentId={opponentId}` or separate optional path — match existing NavHost style in `Navigation.kt`.

- [ ] **Step 2: Rewrite MainScreen bottom bar to Flutter IA**

Tabs (indices):
0 Dashboard · 1 Sessions · 2 Payments · 3 Community · 4 Profile

Remove Matches from `NavigationBar`. Profile content at index 4 (not 5).

```kotlin
// selectedTab mapping
0 -> DashboardScreen(..., onNavigateToProfile = { selectedTab = 4 }, ...)
1 -> SessionsScreen(...)
2 -> PaymentsScreen(...)
3 -> CommunityScreen(...)
4 -> PlayerProfileScreen(...)
```

Pass new callbacks from MainScreen for matchmaking / leaderboard / player profile (wired in Task 3 Step 3 via Navigation).

- [ ] **Step 3: Register placeholder composables in Navigation.kt**

For each new route, show a simple Scaffold with title text until later slices implement real UI:

```kotlin
composable(Routes.MATCHMAKING) {
    PlaceholderScreen(title = "Matchmaking")
}
composable(Routes.MATCH_RESULT) { /* matchId */ }
composable(Routes.PLAYER_PROFILE) { /* playerId */ }
composable(Routes.RATE_PLAYER) { /* playerId */ }
composable(Routes.LEADERBOARD) {
    PlaceholderScreen(title = "Leaderboard")
}
```

Wire MainScreen callbacks:
- `onMatchmakingClick` → `navController.navigate(Routes.MATCHMAKING)`
- `onCreateMatchClick` → `navigate(Routes.matchCreator())`
- `onLeaderboardClick` → `LEADERBOARD`
- etc.

- [ ] **Step 4: Compile**

```bash
./gradlew :app:compileDebugKotlin
```
Expected: SUCCESS

- [ ] **Step 5: Commit**

```bash
git add android/app/src/main/kotlin/com/maxton/bad_android
git commit -m "feat(android): 5-tab shell and stack routes matching Flutter IA"
```

---

### Task 4: iOS routes + 5-tab MainScreen

**Files:**
- Modify: `ios/Runner/MainScreen.swift`
- Modify: `ios/Runner/MainNavigation.swift`
- Create: placeholder views if needed (`MatchmakingScreen.swift`, `MatchResultScreen.swift`, `PlayerProfileDetailScreen.swift`, `RatePlayerScreen.swift`, `LeaderboardScreen.swift`) as minimal stubs

- [ ] **Step 1: Change TabView to 5 tabs**

Order: Dashboard, Sessions, Payments, Community, Profile (with `.tabItem` on Profile).

Remove Matches tab from TabView. Keep `MatchesScreen` file but do not attach as tab (optional later entry).

Profile tag = 4. Fix `onNavigateToProfile = { selectedTab = 4 }`.

- [ ] **Step 2: Add navigation destinations in MainNavigation**

```swift
// String routes (same names as Android)
// matchmaking, match_result/{id}, player_profile/{id}, rate_player/{id}, leaderboard
// match_creator?opponentId=...
```

Add `navigationDestination` / path handling consistent with existing string-route pattern in `MainNavigation.swift`.

Stub screens:

```swift
struct PlaceholderScreen: View {
    let title: String
    var body: some View {
        Text(title).font(.title).padding()
    }
}
```

- [ ] **Step 3: Thread callbacks from MainScreen → MainNavigation for new routes**

Dashboard / Community will need: matchmaking, leaderboard, player profile, rate player (can no-op until Slice 2–3 screens are real).

- [ ] **Step 4: Manual smoke** — build in Xcode if available, or at least verify Swift files parse.

- [ ] **Step 5: Commit**

```bash
git add ios/Runner
git commit -m "feat(ios): 5-tab shell and stack routes matching Flutter IA"
```

---

## Slice 1 — Auth lifecycle + Sessions API

### Task 5: Android networking stack

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `kotlin/.../core/network/AuthTokenStore.kt`
- Create: `kotlin/.../core/network/SessionExpiredBus.kt`
- Create: `kotlin/.../core/network/ApiModule.kt` (Retrofit factory)
- Create: `kotlin/.../core/network/AuthInterceptor.kt`
- Create: `kotlin/.../core/network/ApiDtos.kt` (or per-feature DTOs)

- [ ] **Step 1: Add dependencies to app/build.gradle**

```gradle
implementation 'com.squareup.retrofit2:retrofit:2.9.0'
implementation 'com.squareup.retrofit2:converter-kotlinx-serialization:1.0.0'
implementation 'com.squareup.okhttp3:okhttp:4.12.0'
implementation 'com.squareup.okhttp3:logging-interceptor:4.12.0'
implementation 'org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0'
implementation 'androidx.datastore:datastore-preferences:1.0.0'
// if converter artifact fails, use:
// implementation 'com.jakewharton.retrofit:retrofit2-kotlinx-serialization-converter:1.0.0'
```

- [ ] **Step 2: INTERNET permission**

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

- [ ] **Step 3: AuthTokenStore**

```kotlin
// SharedPreferences keys must match conceptual Flutter: ACCESS_TOKEN / REFRESH_TOKEN
class AuthTokenStore(private val prefs: SharedPreferences) {
    fun getAccessToken(): String? = prefs.getString("ACCESS_TOKEN", null)
    fun getRefreshToken(): String? = prefs.getString("REFRESH_TOKEN", null)
    fun saveTokens(access: String, refresh: String) {
        prefs.edit()
            .putString("ACCESS_TOKEN", access)
            .putString("REFRESH_TOKEN", refresh)
            .apply()
    }
    fun clear() {
        prefs.edit().remove("ACCESS_TOKEN").remove("REFRESH_TOKEN").apply()
    }
    fun hasTokens(): Boolean = getAccessToken() != null
}
```

- [ ] **Step 4: SessionExpiredBus**

```kotlin
object SessionExpiredBus {
    private val _events = MutableSharedFlow<Unit>(extraBufferCapacity = 1)
    val events: SharedFlow<Unit> = _events.asSharedFlow()
    fun emit() { _events.tryEmit(Unit) }
}
```

- [ ] **Step 5: AuthInterceptor + single-flight refresh**

Mirror Flutter `auth_interceptor.dart`:
- Skip `/auth/login`, `/auth/register`, `/auth/refresh`
- Attach `Authorization: Bearer <access>`
- On 401: one shared refresh `POST /auth/refresh` body `{"refresh": "<token>"}`; response `access` + `refresh`
- On refresh fail: `clear()`, `SessionExpiredBus.emit()`

- [ ] **Step 6: Retrofit base**

```kotlin
// baseUrl = "http://localhost:8000/api/v1/"
// For emulator use 10.0.2.2 instead of localhost if needed — make constant configurable:
object ApiConfig {
    const val BASE_URL = "http://10.0.2.2:8000/api/v1/" // Android emulator → host
}
```

Note: Flutter uses `localhost` (iOS sim / desktop). Android emulator needs `10.0.2.2`. Document in code comment.

- [ ] **Step 7: Unit test token store + interceptor refresh lock (optional but preferred)**

```kotlin
// test: AuthTokenStore save/clear
// test: concurrent 401 only one refresh call (if testable)
```

Run: `./gradlew :app:test`

- [ ] **Step 8: Commit**

```bash
git commit -m "feat(android): add Retrofit networking and auth token infrastructure"
```

---

### Task 6: Android real AuthRepository + SessionRepository

**Files:**
- Modify: `features/auth/domain/entities/User.kt` — add `phone`, `avatarUrl`
- Modify: `features/auth/domain/entities/DeviceSession.kt` — align fields with Flutter
- Modify: `features/auth/data/repositories/AuthRepositoryImpl.kt`
- Modify: `features/sessions/domain/entities/*` — `paymentStatus`, participant `level`, `isHost`
- Modify: `features/sessions/data/repositories/SessionRepositoryImpl.kt`
- Create: Retrofit service interfaces `AuthApi`, `SessionApi`
- Modify: `ServiceLocator.kt`
- Modify: `AuthViewModel.kt` — restore session, listen SessionExpiredBus
- Modify: `Navigation.kt` — start destination based on auth

**Flutter contracts:**

```
POST /auth/login     {email, password} → {access, refresh, user}
POST /auth/register  {email, username, password, full_name?} → same
POST /auth/logout    {refresh}
GET  /me
GET  /me/sessions
DELETE /me/sessions/{id}
POST /auth/refresh   {refresh} → {access, refresh}
GET  /sessions?status=upcoming|past
GET  /sessions/{id}
POST /sessions/{id}/join
POST /sessions/{id}/leave
```

User JSON (from Flutter `UserModel`): mirror snake_case keys (`short_id`, `full_name`, `avatar_url`, etc.) — read `platform/lib/features/auth/data/models/user_model.dart` when implementing.

- [ ] **Step 1: Expand User**

```kotlin
data class User(
    val id: String,
    val shortId: String,
    val email: String,
    val username: String,
    val fullName: String? = null,
    val phone: String? = null,
    val avatarUrl: String? = null,
)
```

- [ ] **Step 2: Implement AuthApi + AuthRepositoryImpl using Retrofit**

`login`/`register`: save tokens then return User.  
`logout`: POST then clear tokens (ignore network failure still clear).  
`getMe`: GET `/me`.  
`isAuthenticated`: `tokenStore.hasTokens()`.

- [ ] **Step 3: Implement SessionApi + SessionRepositoryImpl**

Map JSON → domain Session with fees, participants, `paymentStatus`.

- [ ] **Step 4: Wire ServiceLocator**

```kotlin
// provide OkHttp, Retrofit, AuthTokenStore, AuthApi, SessionApi
// authRepository = AuthRepositoryImpl(api, tokenStore)
// sessionRepository = SessionRepositoryImpl(api)
```

- [ ] **Step 5: AuthViewModel cold start**

On init:
```kotlin
viewModelScope.launch {
    if (repo.isAuthenticated()) {
        repo.getMe().onSuccess { user = it; isLoggedIn = true }
            .onFailure { repo.logout(); isLoggedIn = false }
    } else isLoggedIn = false
}
// collect SessionExpiredBus → logout UI state
```

- [ ] **Step 6: Navigation auth gate**

If `isLoggedIn` → MAIN else WELCOME (after onboarding).  
On login success → MAIN.  
On logout / session expired → WELCOME clear back stack.

- [ ] **Step 7: Manual test against backend**

Start BAD_BE if available; login with known test user.  
If backend down, compile-only + unit tests for mapping.

- [ ] **Step 8: Commit**

```bash
git commit -m "feat(android): real auth and sessions API with token lifecycle"
```

---

### Task 7: iOS auth lifecycle completeness

**Files:**
- Modify: `ios/Runner/core/network/APIClient.swift`
- Modify: `ios/Runner/features/auth/Domain/Repositories/AuthRepository.swift`
- Modify: `ios/Runner/features/auth/Data/Repositories/AuthRepositoryImpl.swift`
- Modify: `ios/Runner/features/auth/Domain/Entities/User.swift` (or path where User lives)
- Modify: `ios/Runner/features/auth/Presentation/ViewModels/AuthViewModel.swift`
- Modify: `ios/Runner/MainNavigation.swift`
- Modify: Register screen for fullName
- Modify: Session entity mapping for paymentStatus / host / level

- [ ] **Step 1: Single-flight refresh in APIClient**

```swift
private var refreshTask: Task<Result<String, Error>, Never>?

private func rotateToken() async -> Result<String, Error> {
    if let refreshTask { return await refreshTask.value }
    let task = Task { /* existing rotate body */ }
    refreshTask = task
    let result = await task.value
    refreshTask = nil
    return result
}
```

- [ ] **Step 2: Expand AuthRepository protocol**

```swift
protocol AuthRepository {
    func login(email: String, password: String) async -> Result<User, Error>
    func register(email: String, username: String, password: String, fullName: String?) async -> Result<User, Error>
    func logout() async -> Result<Void, Error>
    func getMe() async -> Result<User, Error>
    func isAuthenticated() -> Bool
    func getDeviceSessions() async -> Result<[DeviceSession], Error>
    func deleteDeviceSession(id: String) async -> Result<Void, Error>
}
```

- [ ] **Step 3: Implement logout + getMe**

```swift
// logout: POST /auth/logout with refresh; always APIClient.shared.clearTokens()
// getMe: GET /me
// isAuthenticated: APIClient.shared.hasTokens()
// register body includes full_name
```

- [ ] **Step 4: User fields**

```swift
struct User: Identifiable, Codable, Equatable {
    let id: String
    let shortId: String
    let email: String
    let username: String
    let fullName: String?
    let phone: String?
    let avatarUrl: String?
}
```

Map CodingKeys snake_case.

- [ ] **Step 5: AuthViewModel**

```swift
func restoreSession() async {
    guard repository.isAuthenticated() else { currentUser = nil; return }
    switch await repository.getMe() {
    case .success(let user): currentUser = user
    case .failure: _ = await repository.logout(); currentUser = nil
    }
}

func logout() async {
    _ = await repository.logout()
    currentUser = nil
}
```

- [ ] **Step 6: MainNavigation**

On appear: `await authViewModel.restoreSession()`.  
If `currentUser != nil` → show Main; else Welcome (after first-time).  
Observe `NotificationCenter` `SessionExpired` → logout + pop to Welcome.

- [ ] **Step 7: RegisterScreen fullName field**

Add `TextField` fullName; pass to `register(..., fullName:)`.

- [ ] **Step 8: Session entity parity fields**

Add `paymentStatus: String?`, participant `level`, `isHost` from API JSON (read Flutter `session_model.dart` for keys).

- [ ] **Step 9: Commit**

```bash
git commit -m "feat(ios): complete auth lifecycle and session field parity"
```

---

## Slice 2 — Match flow

### Task 8: Android match domain + matchmaking/result screens

**Files:**
- Modify: match domain entities (OpponentCandidate, MatchItem)
- Modify: `MatchRepository` + `MatchRepositoryImpl` (mock data from Flutter)
- Modify: `MatchViewModel`
- Create: `MatchmakingScreen.kt`
- Create: `MatchResultScreen.kt`
- Modify: `MatchCreatorScreen.kt` — DatePicker/TimePicker, opponentId
- Modify: `MatchScoreEntryScreen.kt` — navigate to result
- Modify: Navigation + Dashboard shortcuts

**Flutter repository contract:**

```kotlin
interface MatchRepository {
    suspend fun findMatchmakingOpponents(): Result<List<OpponentCandidate>>
    suspend fun createMatch(opponentId: String, courtName: String, dateTime: Instant): Result<MatchItem>
    suspend fun enterMatchScore(matchId: String, setScores: List<Map<String, Int>>): Result<Unit>
    suspend fun getMatchDetail(matchId: String): Result<MatchItem>
}
```

- [ ] **Step 1: Align entities with Flutter**

```kotlin
data class OpponentCandidate(
    val id: String,
    val fullName: String,
    val username: String,
    val avatarUrl: String? = null,
    val skillLevel: String,
    val compatibilityScore: Int, // 0-100
)

data class MatchItem(
    val id: String,
    val player1Name: String,
    val player2Name: String,
    val player1Avatar: String? = null,
    val player2Avatar: String? = null,
    val setScores: List<Map<String, Int>>, // p1/p2
    val date: Long, // epoch millis
    val courtName: String,
    val isCompleted: Boolean,
)
```

- [ ] **Step 2: Port mock data from Flutter `match_repository_impl.dart`**

Same opponent ids `m1/m3/m4`, compatibility scores 98/85/60.

- [ ] **Step 3: MatchmakingScreen UI**

List opponents with compatibility %; CTA Challenge → `Routes.matchCreator(opponent.id)`.

- [ ] **Step 4: MatchResultScreen**

Load `getMatchDetail`; show winner (more sets won), set scores; button back to MAIN.

- [ ] **Step 5: Creator + Score flow**

- Creator: pick court, date, time; call `createMatch`; navigate score entry.  
- Score submit: `enterMatchScore` then `navigate(Routes.matchResult(id))` and pop score/creator.

- [ ] **Step 6: Dashboard shortcuts**

Matchmaking → MATCHMAKING; New Match → match_creator; remove wrong Leaderboard→Matches.

- [ ] **Step 7: Compile + commit**

```bash
git commit -m "feat(android): matchmaking and match result flow parity"
```

---

### Task 9: iOS match domain + matchmaking/result screens

**Files:**
- Modify: `features/match/Domain/*` entities + repository
- Modify: `MatchRepositoryImpl.swift` mock
- Modify: `MatchViewModel.swift`
- Create: `MatchmakingScreen.swift`, `MatchResultScreen.swift`
- Modify: `MatchCreatorScreen.swift`, `MatchScoreEntryScreen.swift`
- Modify: `MainNavigation.swift`, Dashboard shortcuts

- [ ] **Step 1–6:** Same behavior as Task 8 steps 1–6, SwiftUI equivalents.

```swift
protocol MatchRepository {
    func findMatchmakingOpponents() async -> Result<[OpponentCandidate], Error>
    func createMatch(opponentId: String, courtName: String, date: Date) async -> Result<MatchItem, Error>
    func enterMatchScore(matchId: String, setScores: [[String: Int]]) async -> Result<Void, Error>
    func getMatchDetail(matchId: String) async -> Result<MatchItem, Error>
}
```

- [ ] **Step 7: Commit**

```bash
git commit -m "feat(ios): matchmaking and match result flow parity"
```

---

## Slice 3 — Player social

### Task 10: Android PlayerRepository + screens

**Files:**
- Create: `features/profile/domain/entities/PlayerProfile.kt`
- Create: `features/profile/domain/repositories/PlayerRepository.kt`
- Create: `features/profile/data/repositories/PlayerRepositoryImpl.kt`
- Create: `features/profile/presentation/PlayerProfileViewModel.kt`
- Create: `PlayerProfileDetailScreen.kt`, `RatePlayerScreen.kt`, `LeaderboardScreen.kt`
- Modify: `ServiceLocator.kt`
- Modify: Navigation + Community taps

**Flutter entity:**

```kotlin
data class PlayerProfile(
    val id: String,
    val fullName: String,
    val username: String,
    val avatarUrl: String? = null,
    val skillLevel: String,
    val bio: String,
    val matchesPlayed: Int,
    val wins: Int,
    val losses: Int,
    val fairPlayRating: Double,
    val skillRating: Double,
    val email: String,
    val phone: String,
)
```

- [ ] **Step 1: Copy mock profiles from Flutter `player_repository_impl.dart` (m1–m4)**

- [ ] **Step 2: Repository methods**

```kotlin
interface PlayerRepository {
    suspend fun getPlayerProfile(playerId: String): Result<PlayerProfile>
    suspend fun ratePlayer(playerId: String, skillRating: Double, fairPlayRating: Double): Result<Unit>
    suspend fun getLeaderboard(): Result<List<PlayerProfile>>
}
```

- [ ] **Step 3: Screens**

- Detail: bio, W/L, ratings, Rate button → RATE_PLAYER  
- Rate: two sliders/stars skill + fair play, submit  
- Leaderboard: sorted by wins, row → PLAYER_PROFILE  

- [ ] **Step 4: Wire Community top players / active → player profile; ranking → leaderboard**

- [ ] **Step 5: Commit**

```bash
git commit -m "feat(android): player profile, rate, and leaderboard screens"
```

---

### Task 11: iOS PlayerRepository + screens

**Files:**
- Create under `ios/Runner/features/profile/`:
  - `Domain/Entities/PlayerProfile.swift`
  - `Domain/Repositories/PlayerRepository.swift`
  - `Data/Repositories/PlayerRepositoryImpl.swift`
  - `Presentation/ViewModels/PlayerProfileViewModel.swift`
  - `PlayerProfileDetailScreen.swift`, `RatePlayerScreen.swift`, `LeaderboardScreen.swift`
- Modify: `ServiceLocator.swift`
- Modify: Community + MainNavigation

- [ ] **Steps:** Mirror Task 10.

- [ ] **Commit**

```bash
git commit -m "feat(ios): player profile, rate, and leaderboard screens"
```

---

## Slice 4 — Community + Dashboard + Profile polish

### Task 12: Android Community / Dashboard / Profile polish

**Files:**
- Modify: `CommunityScreen.kt`
- Modify: `DashboardScreen.kt` (under sessions/presentation)
- Modify: `PlayerProfileScreen.kt` (own profile)

- [ ] **Step 1: Community**

- Admin console strip → member management + join requests  
- Recent messages section from VM messages  
- Tappable active/top players → `player_profile/{id}`  
- “View full ranking” → leaderboard  
- Announcement image if URL  

- [ ] **Step 2: Dashboard**

- Greeting: `authViewModel.currentUser?.fullName ?: username`  
- Hero card for next session (gradient Primary → PrimaryContainer)  
- Shortcuts: Book Court, Invoices, Community, Matchmaking, New Match, My Stats  
- Bell unread badge if any unread notifications  

- [ ] **Step 3: Own Profile**

- Real user name/email/avatar  
- Skill bars: Smashing, Stamina, Speed, Control, Backhand (static mock levels OK, match Flutter layout)  
- Push toggle + Sound toggle (prefs)  
- Device sessions + logout  

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(android): community, dashboard, profile polish parity"
```

---

### Task 13: iOS Community / Dashboard / Profile polish

**Files:**
- Modify: `CommunityScreen.swift`, `DashboardScreen.swift`, `PlayerProfileScreen.swift`

- [ ] **Steps:** Same as Task 12.

- [ ] **Commit**

```bash
git commit -m "feat(ios): community, dashboard, profile polish parity"
```

---

## Slice 5 — Push + tablet (P2)

### Task 14: Android FCM scaffolding + responsive wrapper

**Files:**
- Modify: `app/build.gradle` (firebase messaging if google-services available; else local notification channel only)
- Create: `core/notification/NotificationHelper.kt`
- Create: `core/ui/ResponsiveWrapper.kt`
- Modify: Manifest POST_NOTIFICATIONS (API 33+)
- Sessions list: optional dual-pane when `sw >= 600dp`

- [ ] **Step 1: Local notification channel** (parity minimum without full Firebase project)

```kotlin
// CHANNEL_ID = "courtside_default"
// Create on app start
```

- [ ] **Step 2: If `google-services.json` exists, add FCM; else document TODO and skip remote**

- [ ] **Step 3: ResponsiveWrapper max width 1050.dp centered**

Wrap MainScreen content.

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(android): notification channel and tablet max-width wrapper"
```

---

### Task 15: iOS push token hook + responsive container

**Files:**
- Modify: `AppDelegate.swift` (token already stored)
- Create: `core/ui/ResponsiveContainer.swift`
- Optional: after login POST device token when backend endpoint exists — if no endpoint, leave UserDefaults only + comment

- [ ] **Step 1: ResponsiveContainer maxWidth 1050**

```swift
struct ResponsiveContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        GeometryReader { geo in
            content
                .frame(maxWidth: min(geo.size.width, 1050))
                .frame(maxWidth: .infinity)
        }
    }
}
```

Wrap MainScreen.

- [ ] **Step 2: Optional iPad sessions split** when `horizontalSizeClass == .regular`

- [ ] **Step 3: Commit**

```bash
git commit -m "feat(ios): responsive container and push token readiness"
```

---

## Final verification

### Task 16: Cross-platform parity checklist

- [ ] **Step 1: Walk Flutter routes and confirm Android + iOS each have equivalent**

Checklist:

| Journey | Android | iOS |
|---------|---------|-----|
| Onboarding → Welcome → Login → Main | | |
| Cold start with token → Main | | |
| Logout → Welcome; tokens cleared | | |
| Session list/detail join/leave | | |
| Payments tab works | | |
| Community poll + player deep link | | |
| Matchmaking → create → score → result | | |
| Leaderboard → player → rate | | |
| Profile device sessions | | |
| Admin members + join requests | | |
| 5 tabs only (no Matches tab) | | |
| Theme primary #006C49 | | |

- [ ] **Step 2: Compile both**

```bash
cd android && ./gradlew :app:compileDebugKotlin
# iOS: xcodebuild if project wired; else file-level review
```

- [ ] **Step 3: Final commit if any fixups**

```bash
git commit -m "chore: native-flutter parity verification fixes"
```

---

## Self-review (plan vs spec)

| Spec requirement | Tasks |
|------------------|-------|
| 5-tab bottom nav | 3, 4 |
| Stack routes | 3, 4 |
| Theme CourtSide | 1, 2 |
| Auth + token lifecycle | 5, 6, 7 |
| Sessions real API | 6, 7 |
| Matchmaking + result | 8, 9 |
| Player detail / rate / leaderboard | 10, 11 |
| Community + Dashboard + Profile polish | 12, 13 |
| Push + tablet | 14, 15 |
| Android + iOS parallel | Tasks paired per slice |
| Matches tab removed | 3, 4 |
| Mock remaining features | 8–13 use Flutter mock shapes |

No TBD placeholders remaining in task steps. Types (`OpponentCandidate`, `PlayerProfile`, auth methods) are consistent across tasks.

---

## Execution notes for agents

1. Always read the Flutter source file listed before porting UI.  
2. Prefer small commits per task.  
3. Do not change Flutter unless a bug blocks parity understanding.  
4. Android emulator API host: `10.0.2.2`; iOS simulator: `localhost`.  
5. If backend is offline, still complete compile + mock-path screens; mark API manual test deferred in commit message.  
6. After each slice (0–5), stop for human review before next slice if using executing-plans checkpoints.
