# Notification, Power Cut, and Wi-Fi Integration Summary

## Backend APIs covered

- `GET /notifications` — fetch user notifications
- `GET /notifications/unread-count` — fetch unread notification total
- `PUT /notifications/:id/read` — mark a notification as read
- `PUT /notifications/mark-all-read` — mark all user notifications read
- `DELETE /notifications/:id` — soft-delete notifications
- `POST /notifications/preferences` — update notification preference toggle
- `GET /inverters/:id/power-cuts` — fetch power cut history for an inverter
- `POST /inverters/:id/power-cuts` — create a new power cut event
- `POST /inverters/:id/wifi-config` — send Wi-Fi credentials to an inverter

## Frontend work completed

- Added `NotificationService`, `PowerCutService`, and `WifiConfigService`.
- Registered new services in `service_locator.dart`.
- Wired `NotificationsScreen` to backend notification endpoints.
- Wired `PowerCutScreen` to actual inverter power cut history endpoint.
- Wired `WifiConfigScreen` to send SSID/password to the backend.
- Added backend response parsing for notification and power cut models.

## Validation and behavior

- Notifications screen now loads real data and supports:
  - mark-as-read per notification
  - mark-all-read
  - delete notification
  - refresh
- Power cut screen now loads the first paired inverter and fetches its power cut history.
- Wi-Fi screen now sends selected SSID + password to backend using the first paired inverter.

## Remaining gaps

- No explicit inverter-selection UI on the Wi-Fi and power cut screens; both currently use the first paired inverter.
- Power cut event payloads rely on backend `duration`, `reason`, and `startTime` fields; `consumedPowerKw` / `solarPowerKw` remain defaulted when unavailable.
- Notification preference toggle UI is not yet wired to `POST /notifications/preferences`.

## Notes for next cycle

- Add a dedicated inverter picker for power cut and Wi-Fi flows.
- Add backend-driven network scan results instead of hardcoded SSIDs.
- Add notification preference toggle in settings with real backend persistence.
