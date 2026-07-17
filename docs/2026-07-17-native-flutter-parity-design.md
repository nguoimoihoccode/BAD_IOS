# Design: Android & iOS Feature Parity with Flutter

**Date:** 2026-07-17  
**App:** CourtSide (BAD_Mobile)  
**Status:** Approved  
**Source of truth:** Flutter `BAD_Mobile/platform/lib`

---

## 1. Goal & Scope

### Goal

Bring **Android** (`BAD_Mobile/android`) and **iOS** (`BAD_Mobile/ios`) to **full feature parity** with Flutter:

- Same information architecture (5-tab bottom nav + stack routes)
- Same screens and user flows
- Real API for **Auth** and **Sessions** (same endpoints as Flutter)
- CourtSide theme tokens aligned with Flutter
- Remaining features stay **mock** with data shapes matching Flutter

### In scope

| Area | Requirement |
|------|-------------|
| Navigation | Home · Sessions · Payments · Community · Profile |
| Auth | Login, register, logout, cold-start restore, token refresh, session-expired |
| Sessions | List, details, join/leave via real API |
| Match | Matchmaking → Creator → Score → Result |
| Player social | Profile detail, rate player, leaderboard |
| Community | Announcements, poll, chat preview, admin entry, player deep links |
| Dashboard | Personalized greeting, hero session card, Flutter shortcuts, notif badge |
| Profile (own) | Live user, skill bars, push + sound toggles, device sessions |
| Theme | Primary `#006C49`, accent `#FF7E2D`, surface `#F8F9FF` |
| Push / tablet | P2: FCM/APNs wiring, max-width 1050, sessions split |

### Out of scope (this phase)

- Real APIs for payments, community, match, admin, player (Flutter also mocks these)
- Porting Android/iOS-only extras into Flutter (e.g. Matches bottom tab as primary IA)
- Backend changes
- Dark theme (Flutter is light-only)

### Success criteria

- Android and iOS can complete the same user journeys as Flutter
- Auth + Sessions hit the same base URL and paths as Flutter
- Bottom nav and stack routes match Flutter route map
- Missing Flutter screens exist on both native platforms
- Theme tokens match Flutter `AppColors` / spacing / radius

---

## 2. Architecture

### Principle

Keep existing **feature-based Clean Architecture** on both platforms:

```
features/<name>/
  domain/          entities + repository interfaces
  data/            models, remote/local datasources, repository impl
  presentation/    ViewModels + screens (Compose / SwiftUI)

core/
  network/         API client, auth interceptor, token store, session-expired bus
  di/              ServiceLocator (or equivalent)
  theme/           CourtSide design tokens
```

### Conventions

| Concern | Rule |
|---------|------|
| Source of truth | Flutter implementations for behavior, routes, entity fields, endpoint paths |
| Domain purity | Domain has no UI or HTTP dependencies |
| Presentation | Talks only to domain repository interfaces |
| Mock features | In-memory repositories with data shapes matching Flutter mocks |
| API base | Configurable; default `http://localhost:8000/api/v1` |
| Auth tokens | Persist access + refresh; inject Bearer; single-flight refresh on 401 |
| Session expired | After failed refresh: clear tokens → force Welcome |

### Stack choices (native)

| Platform | Network | Persistence | UI |
|----------|---------|-------------|-----|
| Android | Retrofit + OkHttp + kotlinx.serialization (or Ktor if preferred during impl) | DataStore / SharedPreferences for tokens | Jetpack Compose + Material 3 |
| iOS | Existing `URLSession` `APIClient` (extend) | UserDefaults (existing token keys) | SwiftUI |

Do **not** introduce Hilt/Koin/Alamofire unless needed mid-implementation; expand `ServiceLocator` first for consistency with current code.

### Delivery model

**Vertical slices**, Android + iOS **in parallel** each slice:

```
Slice 0 Shell → 1 Auth/Sessions → 2 Match → 3 Player → 4 Community/Dashboard/Profile → 5 Push/Tablet
```

Each slice is complete on **both** platforms before starting the next (unless a platform-specific blocker is documented).

---

## 3. Navigation & Information Architecture

### Bottom navigation (match Flutter)

| Index | Tab | Destination |
|-------|-----|-------------|
| 0 | Home / Dashboard | Main root |
| 1 | Sessions | Sessions list |
| 2 | Payments | Payments |
| 3 | Community | Community |
| 4 | Profile | Own profile |

**Remove Matches from the bottom bar.** Match entry points: dashboard shortcuts + stack routes (Flutter model).

Native `MatchesScreen` (Scheduled / Results) may remain as an optional internal list, but **must not** occupy a bottom-tab slot. Prefer not blocking parity on keeping or deleting it.

### Stack / deep routes (both platforms)

| Route | Screen |
|-------|--------|
| `onboarding` | Onboarding |
| `welcome` | Welcome |
| `login` | Login |
| `register` | Register |
| `main` | Tab shell |
| `session_details/{id}` | Session details |
| `device_sessions` | Device sessions |
| `notifications` | Notifications |
| `member_management` | Admin members |
| `join_requests` | Join requests |
| `matchmaking` | Matchmaking |
| `match_creator?opponentId=` | Match creator (optional preselect) |
| `match_score_entry/{id}` | Score entry |
| `match_result/{id}` | Match result |
| `player_profile/{id}` | Player profile detail |
| `rate_player/{id}` | Rate player |
| `leaderboard` | Leaderboard |

### Auth redirect rules

1. First launch (`is_first_time`) → Onboarding → Welcome  
2. Tokens present → `GET /me` success → Main  
3. No tokens or `GET /me` fails → Welcome  
4. Authenticated user opening login/register → Main  
5. Session expired (refresh failed) → clear tokens → Welcome  

### Dashboard shortcuts (match Flutter)

- Book Court  
- Invoices  
- Community  
- **Matchmaking**  
- **New Match**  
- My Stats  

Also: greeting from `currentUser`, upcoming-session **hero** card, notification unread badge on bell.

---

## 4. Theme (CourtSide)

Align Android `Color.kt` / iOS `Theme.swift` with Flutter `app_colors.dart` / `app_theme.dart`:

| Token | Value |
|-------|--------|
| Primary | `#006C49` |
| Primary container / kinetic green | `#10B981` |
| Accent orange | `#FF7E2D` |
| Tertiary | `#9D4300` |
| Background / surface | `#F8F9FF` |
| Text dark | `#0B1C30` (or Flutter equivalent) |
| Error | `#BA1A1A` |

- App display name: **CourtSide**  
- Spacing: 4px grid; radius sm/md/lg tokens  
- Typography: Inter on Android if feasible; SF on iOS with matching scale weights/sizes  

---

## 5. Vertical slices

### Slice 0 — Shell (nav + theme)

**Android**

- Fix `MainScreen` bottom nav to 5 tabs (Home, Sessions, Payments, Community, Profile)
- Fix broken Profile tab index (`selectedTab = 5` with only 0–4 items)
- Add route keys + destinations for all stack routes (placeholder screens OK)
- Apply CourtSide color tokens; rename labels to CourtSide

**iOS**

- Align `MainScreen` TabView with same 5 tabs; Profile visible in tab bar
- Add missing `NavigationStack` routes (placeholders OK)
- Expand `Theme.swift` tokens

**DoD:** Both apps show identical tab set; all routes reachable without crash.

---

### Slice 1 — Auth lifecycle + Sessions API

#### Shared API contract (from Flutter)

| Method | Path |
|--------|------|
| Login | `POST /auth/login` |
| Register | `POST /auth/register` |
| Logout | `POST /auth/logout` |
| Me | `GET /me` |
| Device sessions | `GET /me/sessions` |
| Revoke session | `DELETE /me/sessions/{id}` |
| Refresh | `POST /auth/refresh` |
| Sessions list | `GET /sessions?status=upcoming\|past` |
| Session detail | `GET /sessions/{id}` |
| Join | `POST /sessions/{id}/join` |
| Leave | `POST /sessions/{id}/leave` |

#### Entity field parity

**User:** `id`, `shortId`, `email`, `username`, `fullName?`, `phone?`, `avatarUrl?`  
**DeviceSession:** align with Flutter (`deviceInfo` / name, `ip`, `userAgent`, `createdAt`, `expiresAt`, `isCurrent`, last active)  
**Session:** include `paymentStatus`; participants include `level`, `isHost`  
**Register body:** include `full_name` when provided  

#### Android work

1. Add network dependencies + `INTERNET` permission  
2. `AuthTokenStore` (access + refresh)  
3. Auth interceptor: Bearer header; skip auth endpoints; single-flight refresh on 401; emit session expired  
4. Real `AuthRepositoryImpl` / `SessionRepositoryImpl`  
5. Cold-start restore + auth-gated navigation  
6. Logout calls API then clears tokens  

#### iOS work

1. `AuthRepository`: `logout`, `getMe`, `isAuthenticated`  
2. Logout: API + `APIClient.clearTokens()`  
3. Single-flight token refresh in `APIClient`  
4. Observe `SessionExpired` → reset to Welcome  
5. Cold-start token gate in `MainNavigation`  
6. Register `fullName`; expand User / DeviceSession / Session fields  

**DoD:** Login persists across kill/relaunch; logout clears session; expired refresh returns to Welcome; sessions list/detail/join/leave hit real API on both platforms.

---

### Slice 2 — Match flow

#### Screens

| Screen | Behavior |
|--------|----------|
| Matchmaking | Opponent candidates + compatibility; challenge → creator with `opponentId` |
| Match creator | Court + real date/time pickers; preselect opponent; create → score entry |
| Score entry | Enter sets; submit → **match result** (replace navigation) |
| Match result | Winner banner, set breakdown, back home |

#### Domain enrichment

- `OpponentCandidate`: `id`, `fullName`, `username`, `skillLevel`, `compatibilityScore`, `avatarUrl?`  
- `MatchRepository`: `findMatchmakingOpponents`, `createMatch(opponentId, court, dateTime)`, `enterMatchScore`, `getMatchDetail`  
- Data remains **mock** until backend exists  

#### Dashboard

- Shortcuts: Matchmaking, New Match  
- Do not misroute “Leaderboard” to Matches list  

**DoD:** Full matchmaking → result path works on Android and iOS with same steps as Flutter.

---

### Slice 3 — Player social

#### New module (both platforms)

```
features/profile (or player)/
  Domain/Entities/PlayerProfile
  Domain/Repositories/PlayerRepository
  Data/Repositories/PlayerRepositoryImpl  (mock)
  Presentation: Detail, Rate, Leaderboard screens + VMs
```

#### Methods (mock, match Flutter)

- `getPlayerProfile(id)`  
- `ratePlayer(id, skill, fairPlay)`  
- `getLeaderboard()`  

#### Wiring

- Community active/top players → player profile  
- “View full ranking” → leaderboard  
- Leaderboard row → player profile  
- Profile detail CTA → rate player  

**DoD:** All three screens exist and are reachable from Community + Dashboard on both platforms.

---

### Slice 4 — Community + Dashboard + Profile polish

#### Community

- Admin console strip → member management + join requests  
- Chat / recent messages preview (render existing mock messages)  
- Announcement image if URL present  
- Tappable members → player profile  

#### Own Profile

- Bind real `currentUser` (name, email, avatar)  
- Skill metric bars (Smashing, Stamina, Speed, Control, Backhand)  
- Push toggle + **sound** toggle  
- Device sessions + logout  

#### Dashboard

- Auth-based greeting  
- Gradient upcoming-session hero → session details  
- Flutter shortcut set  
- Notification unread badge  

**DoD:** Visual/behavioral parity for these three areas (mock data OK).

---

### Slice 5 — Push + tablet (P2)

| Platform | Work |
|----------|------|
| Android | FCM + notification channel + `POST_NOTIFICATIONS`; optional deep link |
| iOS | Keep APNs; register device token with backend when endpoint exists |
| Both | Max content width ~1050 on large screens; sessions master–detail when tablet (`shortestSide >= 600`) |

**DoD:** Push scaffolding matches Flutter capability level; tablet layouts do not break.

---

## 6. Platform-specific notes

### Android-only today (keep or demote)

- Matches list tab → demote from bottom nav  
- Community `sendChatMessage` → optional once chat UI exists  
- Dark theme scaffolding → unused for parity  

### iOS-only today

- `SessionExpired` posted but unobserved → fix in Slice 1  
- Logout does not clear tokens → fix in Slice 1  
- Always starts Welcome → cold-start restore in Slice 1  

### Flutter-only extras to mirror

- Matchmaking + Match result  
- Player detail / rate / leaderboard + `PlayerRepository`  
- Auth interceptor single-flight + AuthEventBus force logout  
- Responsive wrapper / split view  
- FCM notification service  

---

## 7. Definition of Done (global)

Parity is complete when:

1. Bottom nav IA matches Flutter on Android and iOS  
2. All Flutter stack routes have native counterparts  
3. Auth + Sessions use real API with token lifecycle  
4. Matchmaking → Result and Player social flows work end-to-end  
5. Community, Dashboard, Profile match Flutter interactions  
6. Theme tokens match CourtSide Flutter palette  
7. Slice 5 optional polish accepted or explicitly deferred  

---

## 8. Implementation order

```
0. Shell (nav + theme)
1. Auth + Sessions API
2. Match flow
3. Player social
4. Community + Dashboard + Profile polish
5. Push + tablet
```

Next step after this spec is approved: write a detailed implementation plan (`writing-plans`) and execute slice by slice with review checkpoints.

---

## 9. Decisions log

| Decision | Choice |
|----------|--------|
| Parity level | Full parity (screens, flows, nav, theme; Auth+Sessions real API) |
| Execution | Vertical slices; Android + iOS in parallel |
| Source of truth | Flutter |
| Matches bottom tab | Remove from tab bar |
| Mock features | Stay mock until backend ready |
| DI | Expand ServiceLocator first |
| Design approval | User approved 2026-07-17 |
