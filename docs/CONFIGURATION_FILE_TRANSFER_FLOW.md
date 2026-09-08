# Configuration File Transfer Flow

## User flow

1. The configuration screen loads registered devices, parameter definitions, current values, and connection status.
2. The user edits one or more parameters. The Send button remains disabled until there is at least one valid change.
3. Send first checks that the selected device is active and online.
4. The app calls `POST /devices/:deviceId/parameters/validate`.
5. The app calls `POST /devices/:deviceId/parameters/generate` with the changed values and a 4096-byte chunk size.
6. The generated file section displays the file name, type, size, SHA-256 checksum, chunk count, and generation status.
7. The transfer section moves through waiting, transferring, and verifying. It shows bytes, percentage, current chunk, status text, and ESP32 acknowledgement text.
8. A successful checksum acknowledgement ends in Completed. Pause, Resume, and Retry remain available where applicable.

## UI states

- `Ready`: no generated file exists yet.
- `Generating`: validation and configuration generation are in progress.
- `Waiting for ESP32`: the file exists and the device header acknowledgement is pending.
- `Transferring`: chunks are being sent and acknowledged.
- `Verifying`: the ESP32 is checking the SHA-256 checksum.
- `Completed`: transfer and verification succeeded.
- `Paused`: the user paused an active transfer.
- `Failed`: the device is unavailable, generation failed, or a transfer error was reported.
- `Retry pending`: a previously generated file is being sent again.

## Edge cases

- No registered devices: show the existing empty state and retry action.
- Offline or inactive device: Send stops before generation and shows a reconnect message.
- Invalid values: Send stays disabled or displays field-level validation errors.
- No changed values: the backend response is surfaced as a generation failure message.
- Empty generated payload: the transfer is rejected instead of showing false progress.
- Transfer failure: the error detail is shown and Retry resends the generated file without regenerating it.

## Transport boundary

The backend currently provides generation and persists the generated transfer metadata. The Flutter transfer state machine keeps chunk progress and acknowledgement handling isolated in the screen so it can be connected to the ESP32 command/ack WebSocket transport when that endpoint is enabled. The UI does not report Completed until its verification step finishes.
