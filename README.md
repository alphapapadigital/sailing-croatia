# Sailing Croatia · 30.05 – 06.06.2026

Mobile-first interaktive Crew-Itinerary-Page (Single-File HTML).

## Lokal öffnen
Einfach `index.html` doppelklicken – läuft self-contained, keine Build-Tools nötig.

## GitHub Pages Deployment
1. Repo anlegen, z.B. `sailing-croatia-2026`
2. `index.html` (und gerne `README.md`) committen
3. Repo → **Settings** → **Pages** → Source: `Deploy from branch`, Branch: `main` / `/root`
4. Nach ~1 min unter `https://<username>.github.io/sailing-croatia-2026/` erreichbar
5. QR-Code für die Crew generieren und in den WhatsApp-Chat posten

## Was schon drin ist
- **Boots-Card** Lagoon 46 „Coolway" — Hero-Foto, Spec-Grid, Equipment-Chips, klickbare Foto-Galerie (Lightbox), CTA zu Boataround
- **Crew-Login** (Name + Passwort `sailingcroatia`) — sweet Gimmick, Name wird für Voting genutzt
- Hero + Routen-Übersicht (Sa→Sa, ~115 NM)
- **Leaflet Map** der Region Mittel-Dalmatien · Route + Monas Spots
- **Monas Spot-Liste** prominent verlinkt (30 Spots, alle dürfen bearbeiten)
- **Crew an Bord** Sektion: jede:r trägt eigene An-Bord-Daten + Pre/Post-Trip Pläne ein
- Tag-für-Tag ausklappbare Karten (Distanz · Segelzeit · Liegeplatz)
- Foodie / Insta-Sunset / Hidden-Gems pro Stop
- Vor-Programm Trogir + Nach-Programm Split
- Food-Planung Bord
- **Crew-Voting** — cross-device live über Supabase
- **Crew-Vorschläge** — Crew kann neue Voting-Optionen / Fragen einreichen
- **Feedback-Button** — Kabinen-/Diät-/Sonderwünsche direkt an Andre
- **Admin-Inbox** (nur für „Andre" sichtbar) — alle Vorschläge & Feedback an einem Ort, mit Status (Offen / In Arbeit / Erledigt / Abgelehnt), Quick-Action „Poll-Snippet" zum Reinkopieren

## Backend
Cross-device-Daten (Voting, Vorschläge, Feedback, Tickets) liegen in Supabase.
- Projekt: `xcalfhpllpyzfycgpxtr.supabase.co` (EU-West-1)
- Tabellen: `sc_votes`, `sc_suggestions`, `sc_feedback`, `sc_tickets`
- Schema: [`db/setup.sql`](db/setup.sql) — einmal im Supabase SQL Editor ausführen, Public-RLS-Policies inkl.
- Trust-Boundary: das Login-Passwort. Daten sind über den `publishable` Key öffentlich CRUD-bar — OK für eine Crew-only-App.

## Setup
- **Passwort ändern:** in `index.html` → suche `const PW = 'sailingcroatia'` → ersetzen
- **Default-Crew anpassen:** in `index.html` → `DEFAULT_CREW = [...]`
- **Admin festlegen:** in `index.html` → `function isAdmin()` — aktuell Name = `Andre` (Akzente werden normalisiert)
- **Polls bearbeiten:** in `index.html` → `const polls = [...]` (Admin kann via Snippet-Button im Inbox automatisch passende Einträge generieren lassen)
- **Supabase URL/Key:** in `index.html` → `SUPA_URL`, `SUPA_KEY` (publishable key ist OK im Frontend)

## GitHub Pages Deployment
1. Repo anlegen, z.B. `sailing-croatia-2026`
2. `index.html` (und gerne `README.md`) committen
3. Repo → **Settings** → **Pages** → Source: `Deploy from branch`, Branch: `main` / `/root`
4. Nach ~1 min unter `https://<username>.github.io/sailing-croatia-2026/` erreichbar
5. QR-Code für die Crew generieren und in den WhatsApp-Chat posten

## Was später kommen kann
- **Echtes Backend** für crew-weiten Sync — empfohlen: Google Sheet via Apps-Script-Webhook (kein Build-Tool, gratis), Alternative: Supabase oder Firebase
- Wetter-Widget (Windguru iframes pro Stop)
- Ankerbuchten-GPX / Custom Google MyMaps-Layer mit der echten Route
- Foto-Upload pro Tag (Firebase Storage)
- Reservierungs-Status pro Restaurant (✅/⏳/❌) mit Owner

## Inhaltsstand
v3 · 11.05.2026 — Supabase-Backend, Crew-Vorschläge, Feedback, Admin-Inbox
