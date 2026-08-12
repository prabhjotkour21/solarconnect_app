# Real-time Socket Testing Guide

## Goal

This guide explains how to test the Flutter app’s live dashboard and inverter data flow with the backend Socket.IO gateway.

## What is already implemented

The app now connects to the backend namespace `/energy`, subscribes to live energy events, listens for inverter status updates, and responds to server heartbeat pings for connection health.

## Prerequisites

- Backend server running locally on `http://localhost:5000`
- A valid user login token
- A valid inverter ID for inverter-specific live status testing
- Flutter app running in debug mode

## 1. Start backend

1. Open the backend project.
2. Run the NestJS app.
3. Confirm the server is available at:
   - `http://localhost:5000`
   - WebSocket namespace: `ws://localhost:5000/energy`

## 2. Login and get access token

Use the auth API and save the returned access token.

Example:

- POST `/api/v1/auth/login`
- Body:
  ```json
  {
    "email": "your-email@example.com",
    "password": "your-password"
  }
  ```

Save the returned `accessToken`.

## 3. Connect the Flutter app

The app automatically connects when the Overview screen is loaded and the saved auth token exists.

Expected behavior:

- Socket connects to the `/energy` namespace
- `energy:connected` event is received
- `subscribe:energy` is sent automatically
- `heartbeat:pong` is sent to server after `heartbeat:ping`

## 4. Verify live energy data

Open the app dashboard and observe the overview cards.

Expected results:

- Energy values update without manual refresh
- Values change after the backend emits `energy:live`
- The overview reading refreshes with the latest solar, grid, battery, and consumption values

Test event name:

- `energy:live`

Sample payload:

```json
{
  "solarPowerW": 3200,
  "consumptionW": 1800,
  "batteryPercent": 76,
  "gridStatus": "off",
  "inverterStatus": "active",
  "timestamp": "2026-08-12T12:00:00.000Z"
}
```

## 5. Verify inverter-specific live updates

Use a valid inverter ID and test the room subscription.

Client event to send:

```js
socket.emit("subscribe:inverter", { inverterId: "YOUR_INVERTER_ID" });
```

Expected ACK:

```json
{
  "event": "subscribe:inverter:ack",
  "data": {
    "status": "subscribed",
    "inverterId": "YOUR_INVERTER_ID"
  }
}
```

Expected live event:

- `inverter:live-status`

Sample payload:

```json
{
  "inverterId": "YOUR_INVERTER_ID",
  "status": "active",
  "isWifiConnected": true,
  "lastSyncAt": "2026-08-12T12:00:00.000Z",
  "firmwareVersion": "v2.1.4",
  "model": "Hybrid 5KVA"
}
```

## 6. Verify heartbeat and reconnection

The backend sends a heartbeat ping periodically.

Expected behavior:

- `heartbeat:ping` arrives every 30 seconds
- Client responds with `heartbeat:pong`
- If the socket disconnects, the app should reconnect automatically
- UI should remain stable while reconnecting

## 7. Test manual socket debug in browser or Node script

A simple Socket.IO test can be executed in a browser console or Node script:

```js
const socket = io("http://localhost:5000/energy?token=YOUR_JWT_TOKEN");

socket.on("connect", () => console.log("connected"));
socket.on("energy:connected", (d) => console.log("energy:connected", d));
socket.on("energy:live", (d) => console.log("energy:live", d));
socket.on("inverter:live-status", (d) =>
  console.log("inverter:live-status", d),
);
socket.on("heartbeat:ping", () => {
  console.log("heartbeat ping received");
  socket.emit("heartbeat:pong", {});
});

socket.emit("subscribe:energy", {});
socket.emit("subscribe:inverter", { inverterId: "YOUR_INVERTER_ID" });
```

## 8. What to check in Flutter

- Overview screen shows live values without page refresh
- There are no silent socket disconnects
- The app does not crash on `heartbeat:ping`
- Inverter status update changes UI state correctly
- Reconnection does not duplicate listeners

## 9. Failure checklist

If the live data does not appear, verify:

- JWT token is valid
- Backend is running on port 5000
- Socket namespace is `/energy`
- App is connected to the correct backend URL
- `subscribe:energy` and `subscribe:inverter` are being emitted
- Client is listening for the right event names

## 10. Final validation

The feature is considered working when:

- `energy:connected` fires on connect
- `energy:live` updates dashboard values
- `inverter:live-status` updates inverter UI state
- `heartbeat:ping` receives a valid `heartbeat:pong` reply
- Reconnection works without manual app restart
