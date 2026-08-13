# Flutter Notification & Settings Testing Guide

This guide explains how to test the completed real-time notification flow and the user settings sync in the Flutter app.

## 1. Real-time Notification Flow

### Objective

Verify that a new notification pushed from the backend socket appears in the app without manual refresh.

### Prerequisites

- App is running on emulator/device.
- User is logged in and valid JWT token exists.
- Backend WebSocket server is running on the /energy namespace.
- Notification push event is enabled from backend through `notification:new`.

### Steps

1. Open the app and log in.
2. Navigate to the Notifications screen.
3. Trigger a backend notification event for the authenticated user.
   Example payload:
   {
   "title": "Battery Alert",
   "message": "Battery level is low. Please check your system.",
   "category": "alert",
   "timestamp": "2026-08-13T12:00:00.000Z"
   }
4. Confirm that the notifications list updates automatically without pulling to refresh.
5. Check that unread count increases and the new item appears on top.
6. Tap the item and verify it can be marked read.

### Expected Result

- `notification:new` event is received by the client.
- The app inserts the item into the list immediately.
- The UI reflect change without manual reload.

## 2. Settings: Notification Preferences

### Objective

Verify the push notification toggle saves to backend and reflects correctly.

### Steps

1. Open Settings screen.
2. Turn Push Notifications off and on.
3. Observe the snackbar and saved state.
4. Reopen the screen or refresh the screen.
5. Confirm the value persists from backend response.

### Expected Result

- `PUT /settings/notifications` is called with `notifications: true|false`.
- Toggle state stays consistent.

## 3. Settings: Appearance Preferences

### Objective

Verify dark mode and language updates are sent to the backend and applied immediately.

### Steps

1. Open Settings screen.
2. Toggle Dark Mode on/off.
3. Change Language to Hindi / English / Spanish / French / German.
4. Confirm app theme and language change immediately.
5. Reopen the settings screen and verify saved values are loaded.

### Expected Result

- `PUT /settings/appearance` is called with theme and language values.
- UI updates immediately and remains saved on the next open.

## 4. Settings: Privacy Preferences

### Objective

Verify privacy toggles save and remain consistent.

### Steps

1. Open Privacy & Security section.
2. Toggle Data Sharing and Analytics Opt-In.
3. Verify the toggle values persist after screen refresh.
4. Check that backend receives the correct booleans.

### Expected Result

- `PUT /settings/privacy` updates values.
- The screen reflects saved state.

## 5. API Validation Points

### Notifications API

- `GET /notifications`
- `GET /notifications/unread-count`
- `PUT /notifications/:id/read`
- `PUT /notifications/mark-all-read`
- `DELETE /notifications/:id`

### Settings API

- `GET /settings/notifications`
- `PUT /settings/notifications`
- `GET /settings/appearance`
- `PUT /settings/appearance`
- `GET /settings/privacy`
- `PUT /settings/privacy`

## 6. Common Issues to Check

- Socket disconnected due to expired JWT token.
- Token missing from local storage.
- Notification payload shape mismatch (`message` vs `description`, `category` vs `type`).
- Settings API returns `data` wrapper vs direct object.
- Theme/language values not mapped correctly from backend response.

## 7. Suggested Manual Test Checklist

- [ ] Login successful
- [ ] Notifications screen loads list
- [ ] Unread count appears
- [ ] New socket notification appears automatically
- [ ] Toggle notification preference saves
- [ ] Theme toggles update UI
- [ ] Language change updates UI
- [ ] Privacy toggles save correctly
- [ ] Reopen settings screen and data remains consistent

## 8. Automated Test Coverage

A basic widget/socket test has been added in:

- `test/notification_socket_and_settings_test.dart`

This validates that the socket service can be created and that the notification stream is exposed.
