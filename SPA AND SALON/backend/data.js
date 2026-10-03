// Seed data — in the real project this lives in MySQL, served via Spring Boot/Node.
// Kept in-memory here so the API is self-contained and easy to run for a demo.

const services = [
  { id: "hair-balayage", category: "Hair", name: "Balayage & Gloss", desc: "Hand-painted color with a glossing treatment for shine.", duration: 90, price: 3200 },
  { id: "hair-touchup", category: "Hair", name: "Root Touch-Up", desc: "Single-process color refresh for regrowth at the root.", duration: 45, price: 1500 },
  { id: "hair-cut", category: "Hair", name: "Precision Haircut", desc: "Consultation, wash, cut, and blow-dry finish.", duration: 40, price: 900 },
  { id: "hair-keratin", category: "Hair", name: "Keratin Smoothening", desc: "Frizz-control treatment for smoother, manageable hair.", duration: 120, price: 4500 },
  { id: "skin-facial", category: "Skin", name: "Signature Facial", desc: "Deep cleanse, extraction, and hydration for all skin types.", duration: 50, price: 1800 },
  { id: "skin-gold", category: "Skin", name: "Gold Radiance Facial", desc: "Brightening treatment with 24k gold-infused serum.", duration: 60, price: 2600 },
  { id: "skin-wax", category: "Skin", name: "Full Body Waxing", desc: "Smooth, salon-grade wax for arms, legs, and back.", duration: 90, price: 2200 },
  { id: "body-deeptissue", category: "Massage & Body", name: "Deep Tissue Massage", desc: "Firm-pressure therapy targeting chronic muscle tension.", duration: 60, price: 2100 },
  { id: "body-aroma", category: "Massage & Body", name: "Aromatherapy Massage", desc: "Full-body relaxation massage with essential oil blends.", duration: 75, price: 2400 },
  { id: "body-hotstone", category: "Massage & Body", name: "Hot Stone Therapy", desc: "Heated basalt stones to ease deep muscle tension.", duration: 80, price: 2900 },
  { id: "nails-manipedi", category: "Nails", name: "Classic Manicure & Pedicure", desc: "Shape, cuticle care, and polish for hands and feet.", duration: 75, price: 1400 },
  { id: "nails-gel", category: "Nails", name: "Gel Polish Add-On", desc: "Long-wear gel finish, added to any mani-pedi.", duration: 20, price: 500 },
  { id: "occ-bridal", category: "Occasions", name: "Bridal Makeup", desc: "HD makeup application with pre-bridal trial included.", duration: 150, price: 8500 }
];

const stylists = [
  { id: "aanya", name: "Aanya", role: "Senior Colorist", specialties: ["hair-balayage", "hair-touchup", "hair-keratin"] },
  { id: "rehan", name: "Rehan", role: "Massage Therapist", specialties: ["body-deeptissue", "body-aroma", "body-hotstone"] },
  { id: "meher", name: "Meher", role: "Skin Specialist", specialties: ["skin-facial", "skin-gold", "skin-wax"] },
  { id: "sana", name: "Sana", role: "Nail Artist", specialties: ["nails-manipedi", "nails-gel"] }
];

// Fixed daily working slots — a real system would derive this from stylist shift rules.
const dailySlotTemplate = ["09:30", "10:30", "11:15", "13:00", "14:30", "15:45", "17:00", "18:15"];

module.exports = { services, stylists, dailySlotTemplate };
