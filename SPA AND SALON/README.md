# Verdant — Salon & Spa Client Self-Service (Demo)

A working frontend + backend demo for the Salon & Spa Client Self-Service App project.

## What's real here
- **Backend**: Node.js + Express API (`/backend`) with endpoints for services, stylists,
  slot availability, and booking creation. Data is persisted to `backend/bookings.json`
  so bookings survive a server restart.
- **Frontend**: Plain HTML/CSS/JS (`/frontend/index.html`) — the booking section on this
  page calls the real backend over `fetch()`, so picking a service/stylist/date/time and
  clicking "Confirm & pay" creates an actual booking on the server, and already-taken
  slots show as unavailable.

This is a demo, not the full production stack (no MySQL, Firebase Auth, or Razorpay yet —
those are the next steps for the real project, this proves out the booking flow end to end).

## Quick start (2 minutes)

**1. Start the backend**
```
cd backend
npm install
npm start
```
You should see: `Verdant backend running at http://localhost:4000`

**2. Open the frontend**
Just open `frontend/index.html` directly in your browser (double-click it, or drag it
into a browser tab). Scroll to the "Book a slot right here" section — it will say
"Connected to the live Verdant API" if the backend is reachable.

Keep the backend terminal window open during your presentation — closing it will make
the live booking demo fall back to showing an error message.

## API endpoints (for reference)
- `GET /api/health` — check the server is up
- `GET /api/services` — list all services
- `GET /api/stylists` — list all stylists
- `GET /api/slots?stylistId=aanya&date=2026-09-18` — available times for a stylist/day
- `POST /api/bookings` — create a booking `{ serviceId, stylistId, date, time, clientName }`
- `GET /api/bookings` — list all bookings made so far
- `DELETE /api/bookings/:id` — cancel a booking
