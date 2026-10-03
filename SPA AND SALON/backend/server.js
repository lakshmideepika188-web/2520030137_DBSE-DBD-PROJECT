const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");
const { services, stylists, dailySlotTemplate } = require("./data");

const app = express();
const PORT = process.env.PORT || 4000;
const BOOKINGS_FILE = path.join(__dirname, "bookings.json");

app.use(cors());
app.use(express.json());

// ---- tiny JSON-file "database" for bookings ----
function readBookings() {
  if (!fs.existsSync(BOOKINGS_FILE)) return [];
  try {
    return JSON.parse(fs.readFileSync(BOOKINGS_FILE, "utf-8"));
  } catch {
    return [];
  }
}
function writeBookings(bookings) {
  fs.writeFileSync(BOOKINGS_FILE, JSON.stringify(bookings, null, 2));
}

// ---- health check ----
app.get("/api/health", (req, res) => {
  res.json({ status: "ok", service: "verdant-backend", time: new Date().toISOString() });
});

// ---- services ----
app.get("/api/services", (req, res) => {
  res.json(services);
});

// ---- stylists ----
app.get("/api/stylists", (req, res) => {
  res.json(stylists);
});

// ---- available slots for a stylist on a given date ----
// GET /api/slots?stylistId=aanya&date=2026-09-18
app.get("/api/slots", (req, res) => {
  const { stylistId, date } = req.query;
  if (!stylistId || !date) {
    return res.status(400).json({ error: "stylistId and date are required query params" });
  }
  const stylist = stylists.find((s) => s.id === stylistId);
  if (!stylist) return res.status(404).json({ error: "Stylist not found" });

  const bookings = readBookings();
  const takenTimes = bookings
    .filter((b) => b.stylistId === stylistId && b.date === date && b.status !== "cancelled")
    .map((b) => b.time);

  const slots = dailySlotTemplate.map((time) => ({
    time,
    available: !takenTimes.includes(time)
  }));

  res.json({ stylistId, date, slots });
});

// ---- create a booking ----
// POST /api/bookings { serviceId, stylistId, date, time, clientName, clientPhone }
app.post("/api/bookings", (req, res) => {
  const { serviceId, stylistId, date, time, clientName, clientPhone } = req.body || {};

  if (!serviceId || !stylistId || !date || !time || !clientName) {
    return res.status(400).json({ error: "serviceId, stylistId, date, time, and clientName are required" });
  }

  const service = services.find((s) => s.id === serviceId);
  if (!service) return res.status(404).json({ error: "Service not found" });

  const stylist = stylists.find((s) => s.id === stylistId);
  if (!stylist) return res.status(404).json({ error: "Stylist not found" });

  if (!dailySlotTemplate.includes(time)) {
    return res.status(400).json({ error: "Invalid time slot" });
  }

  const bookings = readBookings();
  const clash = bookings.find(
    (b) => b.stylistId === stylistId && b.date === date && b.time === time && b.status !== "cancelled"
  );
  if (clash) {
    return res.status(409).json({ error: "That slot was just taken. Please pick another time." });
  }

  const booking = {
    id: "bk_" + Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
    serviceId,
    serviceName: service.name,
    price: service.price,
    duration: service.duration,
    stylistId,
    stylistName: stylist.name,
    date,
    time,
    clientName,
    clientPhone: clientPhone || null,
    status: "confirmed",
    createdAt: new Date().toISOString()
  };

  bookings.push(booking);
  writeBookings(bookings);

  // In the full project this is where Firebase Cloud Messaging / Razorpay would hook in.
  console.log(`[notification] Booking confirmed for ${clientName}: ${service.name} with ${stylist.name} on ${date} ${time}`);

  res.status(201).json(booking);
});

// ---- list all bookings (e.g. for an admin/salon-staff view) ----
app.get("/api/bookings", (req, res) => {
  res.json(readBookings());
});

// ---- cancel a booking ----
app.delete("/api/bookings/:id", (req, res) => {
  const bookings = readBookings();
  const booking = bookings.find((b) => b.id === req.params.id);
  if (!booking) return res.status(404).json({ error: "Booking not found" });
  booking.status = "cancelled";
  writeBookings(bookings);
  res.json(booking);
});

app.listen(PORT, () => {
  console.log(`Verdant backend running at http://localhost:${PORT}`);
});
