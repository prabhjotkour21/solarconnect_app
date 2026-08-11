# Settings and Real-Time Integration Test Plan

## Objective

Verify settings/profile and notification preference APIs, live inverter/dashboard updates, active device status mapping, socket auth, and frontend flows.

## 1. Settings / User Preferences

### API paths

- GET /api/v1/settings/profile
- PUT /api/v1/settings/profile
- GET /api/v1/settings/notifications
- PUT /api/v1/settings/notifications

### Test steps

1. Login and obtain valid JWT token.
2. Call GET /settings/profile with Authorization Bearer token:
   - Expected 200
   - Response contains user profile without `passwordHash`
   - `preferences.notifications` exists if set
3. Call PUT /settings/profile with one or more fields:
   - Example: `{ "firstName": "Test", "location": "Pune" }`
   - Expected 200 and updated values in response
4. Call GET /settings/notifications:
   - Expected 200
   - Response shape: `{ "notifications": true|false }`
5. Call PUT /settings/notifications with `{ "notifications": false }`:
   - Expected 200
   - Confirm returned preferences include updated value
   - Re-check GET /settings/notifications to validate persisted state

### Frontend checks

- `lib/screens/me/settings_screen.dart` loads notification setting from `settingsService.getNotificationSettings`
- The notification toggle should reflect backend state on screen load
- Toggling the switch should call `settingsService.updateNotificationSettings`
- If backend responds with error, the toggle should revert and show an error

## 2. Socket / Real-Time Updates

### Backend gateway

- `/energy` Socket.IO namespace
- Auth must be passed via query `token` or `Authorization: Bearer <token>`
- Events:
  - `energy:connected`
  - `energy:live`
  - `inverter:live-status`
  - `dashboard:update`
  - `notification:new`
  - `heartbeat:ping`

### Backend broadcast flow

- `WebsocketBroadcastService` sends:
  - energy every 5s via `emitLiveEnergyData`
  - inverter status every 15s via `emitInverterLiveStatus`
  - dashboard snapshot via `emitEvent(userId, 'dashboard:update')`
  - notifications via `emitEvent(userId, 'notification:new')`

### Test steps

1. Connect a Socket.IO test client to `ws://<host>:<port>/energy?token=<token>`
2. Confirm `energy:connected` received immediately
3. Wait up to 10 seconds for `energy:live`
4. Subscribe to a specific inverter room using `subscribe:inverter` and confirm `subscribe:inverter:ack`
5. Cause an inverter status change in the backend or simulator and confirm `inverter:live-status`
6. Verify `dashboard:update` is emitted after a metrics refresh or broadcast trigger
7. Confirm `notification:new` arrives when backend creates a new notification for the user

## 3. Device Mapping and Status Propagation

### Expected behavior

- Active ESP32 / inverter devices should map to frontend user rooms
- Backend should emit real-time energy updates to the correct `user:{userId}` room
- Inverter status should be sent to `inverter:{inverterId}` room and also user room under `inverter:live-status`

### Test steps

1. Authenticate a device with native WS if applicable.
2. Send a sensor reading so backend saves data and emits `energy:live`
3. Confirm the payload contains `deviceSerialNumber`, `inverterStatus`, and reading timestamps
4. Confirm frontend receives updates for the correct user and inverter

## 4. Notification Broadcast and UI Refresh

### Test steps

1. Use backend device or manual trigger to generate a notification event
2. Confirm a WebSocket `notification:new` event is sent to the user room
3. In the frontend, refresh the notifications screen and verify the latest item appears
4. Verify `unreadCount` updates when new notifications arrive or are marked read

## 5. Regression Test Areas

### Prioritized flows

- Settings profile and notification preference GET/PUT
- Live dashboard overview data
- Inverter status and mapping via Socket.IO
- Notification feed CRUD operations
- Auth guard behavior on protected /settings endpoints

### Quick checks

- Run backend Jest tests: `npm test`
- Validate `solarconnect_app` compiles after adding socket client dependency
- Verify the `settings_screen.dart` frontend path no longer depends on `/auth/me` for notifications

## 6. Remaining Frontend Gaps

### Known gaps

- No existing Socket.IO client use in Flutter app yet
- `settings_screen.dart` only reads notification toggles; profile edit UI not wired yet
- Live dashboard refresh currently depends on polling, not WS events
- No frontend subscription logic for `dashboard:update`, `inverter:live-status`, or `notification:new`

### Priorities for quick changes

1. Add Socket.IO client integration and event handlers in app startup or Overview screen
2. Ensure `settingsService` is used in `settings_screen.dart` for notification toggles
3. Add a dedicated profile screen and load `GET /settings/profile` once authenticated
4. Update Overview/dashboard to refresh when `dashboard:update` arrives

## 7. Handoff Notes

- Backend `/settings` endpoints are implemented and tested by guide
- Frontend now has `SettingsService` and `SocketService` stubs ready for integration
- Client-side socket support requires `socket_io_client` package and event wiring
- Use `testingDonc/SETTINGS_AND_REALTIME_INTEGRATION_TEST_PLAN.md` for verification and follow-up
