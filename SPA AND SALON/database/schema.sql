-- ============================================================
-- Verdant — Salon & Spa Client Self-Service App
-- Database schema (MySQL 8+)
-- ============================================================

CREATE DATABASE IF NOT EXISTS verdant_salon_spa;
USE verdant_salon_spa;

-- ------------------------------------------------------------
-- USERS — clients, stylists, and admins all live here.
-- Auth itself is handled by Firebase Authentication; this table
-- stores the app-side profile linked to the Firebase UID.
-- ------------------------------------------------------------
CREATE TABLE users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    firebase_uid  VARCHAR(128) NOT NULL UNIQUE,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(15),
    role          ENUM('client', 'stylist', 'admin') NOT NULL DEFAULT 'client',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- STYLISTS — extends a user with staff-only details.
-- One-to-one with users (a stylist is a user with role='stylist').
-- ------------------------------------------------------------
CREATE TABLE stylists (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL UNIQUE,
    specialty   VARCHAR(100),
    bio         TEXT,
    is_active   BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- SERVICES — the salon/spa menu.
-- ------------------------------------------------------------
CREATE TABLE services (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    category          VARCHAR(50) NOT NULL,
    name              VARCHAR(100) NOT NULL,
    description       TEXT,
    duration_minutes  INT NOT NULL,
    price             DECIMAL(10,2) NOT NULL,
    is_active         BOOLEAN DEFAULT TRUE
);

-- ------------------------------------------------------------
-- STYLIST_SERVICES — many-to-many: which stylists can perform
-- which services.
-- ------------------------------------------------------------
CREATE TABLE stylist_services (
    stylist_id  BIGINT NOT NULL,
    service_id  BIGINT NOT NULL,
    PRIMARY KEY (stylist_id, service_id),
    FOREIGN KEY (stylist_id) REFERENCES stylists(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- APPOINTMENTS — the core booking record.
-- ------------------------------------------------------------
CREATE TABLE appointments (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id         BIGINT NOT NULL,
    stylist_id        BIGINT NOT NULL,
    service_id        BIGINT NOT NULL,
    appointment_date  DATE NOT NULL,
    appointment_time  TIME NOT NULL,
    status            ENUM('confirmed', 'cancelled', 'completed', 'no_show') NOT NULL DEFAULT 'confirmed',
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id)  REFERENCES users(id)     ON DELETE CASCADE,
    FOREIGN KEY (stylist_id) REFERENCES stylists(id)  ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES services(id)  ON DELETE RESTRICT,
    UNIQUE KEY uniq_stylist_slot (stylist_id, appointment_date, appointment_time)
);

-- ------------------------------------------------------------
-- PAYMENTS — one payment per appointment, via Razorpay/Stripe.
-- ------------------------------------------------------------
CREATE TABLE payments (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    appointment_id  BIGINT NOT NULL UNIQUE,
    amount          DECIMAL(10,2) NOT NULL,
    method          ENUM('razorpay', 'stripe', 'cash') NOT NULL,
    transaction_id  VARCHAR(100),
    status          ENUM('pending', 'paid', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    paid_at         TIMESTAMP NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- REVIEWS — client feedback after a completed appointment.
-- ------------------------------------------------------------
CREATE TABLE reviews (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    appointment_id  BIGINT NOT NULL UNIQUE,
    client_id       BIGINT NOT NULL,
    rating          TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment         TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id)      REFERENCES users(id)        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- NOTIFICATIONS — log of Firebase Cloud Messaging pushes
-- (reminders, confirmations, cancellations).
-- ------------------------------------------------------------
CREATE TABLE notifications (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    appointment_id  BIGINT,
    type            VARCHAR(50) NOT NULL,
    message         VARCHAR(255) NOT NULL,
    is_read         BOOLEAN DEFAULT FALSE,
    sent_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)        REFERENCES users(id)        ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- Seed data (matches the demo backend/data.js)
-- ------------------------------------------------------------
INSERT INTO services (category, name, description, duration_minutes, price) VALUES
('Hair', 'Balayage & Gloss', 'Hand-painted color with a glossing treatment for shine.', 90, 3200.00),
('Hair', 'Root Touch-Up', 'Single-process color refresh for regrowth at the root.', 45, 1500.00),
('Hair', 'Precision Haircut', 'Consultation, wash, cut, and blow-dry finish.', 40, 900.00),
('Hair', 'Keratin Smoothening', 'Frizz-control treatment for smoother, manageable hair.', 120, 4500.00),
('Skin', 'Signature Facial', 'Deep cleanse, extraction, and hydration for all skin types.', 50, 1800.00),
('Skin', 'Gold Radiance Facial', 'Brightening treatment with 24k gold-infused serum.', 60, 2600.00),
('Skin', 'Full Body Waxing', 'Smooth, salon-grade wax for arms, legs, and back.', 90, 2200.00),
('Massage & Body', 'Deep Tissue Massage', 'Firm-pressure therapy targeting chronic muscle tension.', 60, 2100.00),
('Massage & Body', 'Aromatherapy Massage', 'Full-body relaxation massage with essential oil blends.', 75, 2400.00),
('Massage & Body', 'Hot Stone Therapy', 'Heated basalt stones to ease deep muscle tension.', 80, 2900.00),
('Nails', 'Classic Manicure & Pedicure', 'Shape, cuticle care, and polish for hands and feet.', 75, 1400.00),
('Nails', 'Gel Polish Add-On', 'Long-wear gel finish, added to any mani-pedi.', 20, 500.00),
('Occasions', 'Bridal Makeup', 'HD makeup application with pre-bridal trial included.', 150, 8500.00);
