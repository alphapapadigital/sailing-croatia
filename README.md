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
- **Eingebettete Google Maps** der Region Mittel-Dalmatien
- **Monas Spot-Liste** prominent verlinkt (30 Spots, alle dürfen bearbeiten)
- **Crew an Bord** Sektion: jede:r trägt eigene An-Bord-Daten + Pre/Post-Trip Pläne ein
- Tag-für-Tag ausklappbare Karten (Distanz · Segelzeit · Liegeplatz)
- Foodie / Insta-Sunset / Hidden-Gems pro Stop
- Vor-Programm Trogir + Nach-Programm Split
- Food-Planung Bord (Inputs, lokal gespeichert)
- Crew-Voting (mit Crew-Namen, lokal getrackt)

## Caveat: Local-only (für jetzt)
Crew-Liste, Voting und Food-Planung werden via `localStorage` **pro Gerät** gespeichert.
Jeder sieht seine eigenen Eingaben, Crew-weiter Sync braucht ein Backend.

## Setup
- **Passwort ändern:** in `index.html` → suche `const PW = 'sailingcroatia'` → ersetzen
- **Default-Crew anpassen:** in `index.html` → `DEFAULT_CREW = [...]`
- **Map zentrieren:** im iframe-`src` die `ll=43.25,16.4&z=9` Werte anpassen

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
v2 · 10.05.2026 — Login, Maps, Monas Liste, Crew-an-Bord ergänzt
