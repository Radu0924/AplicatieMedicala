# MedGuard Go — Plan Complet de Dezvoltare
## Proof of Concept · Versiunea 1.0

---

## Cuprins

1. [Viziune și Context](#1-viziune-și-context)
2. [Arhitectura Sistemului](#2-arhitectura-sistemului)
3. [Design System](#3-design-system)
4. [Aplicația Mobilă — Transportator](#4-aplicația-mobilă--transportator)
   - 4.1 Principii de design funcțional
   - 4.2 Ecrane (10 ecrane detaliate)
   - 4.3 Navigare și flow complet
   - 4.4 Comportament offline
   - 4.5 Notificări push
5. [Platforma Web — Administrator](#5-platforma-web--administrator)
   - 5.1 Structura panoului admin
   - 5.2 Secțiuni și funcționalități
   - 5.3 Rapoarte de conformitate
6. [Baza de Date Comună](#6-baza-de-date-comună)
   - 6.1 Entități principale
   - 6.2 Reguli de acces per tip user
7. [Cerințe de Conformitate Regulatorie](#7-cerințe-de-conformitate-regulatorie)
   - 7.1 Reglementări termice
   - 7.2 Senzori și redundanță
   - 7.3 Sistem de alarmare
   - 7.4 Integritate date și logging
8. [Faze de Dezvoltare](#8-faze-de-dezvoltare)
9. [Stack Tehnologic Recomandat](#9-stack-tehnologic-recomandat)

---

## 1. Viziune și Context

### Ce este MedGuard Go?

MedGuard Go este o platformă digitală de monitorizare și conformitate pentru unitățile de transport plasmatic de tip **CryoSafe PTU** (Portable Temperature Unit). Platforma este formată din două produse distincte care împart o bază de date comună:

- **Aplicația mobilă** — destinată exclusiv transportatorilor; simplă, vizuală, orientată pe stare în timp real
- **Platforma web** — destinată administratorilor; completă, cu acces la toate datele, rapoarte și configurare

### De ce există această aplicație?

Dispozitivele CryoSafe PTU transportă plasmă care trebuie menținută strict între **2°C și 8°C**. Orice abatere de temperatură reprezintă un risc medical real. Standardul de conformitate **MED-THERM-2026** impune monitorizare continuă, alarmare rapidă și auditare completă a tuturor evenimentelor.

Scopul PoC-ului este să demonstreze că un sistem software poate:
- Ingesta și valida date din senzori în timp real
- Detecta automat violări de conformitate față de reglementările MED-THERM-2026
- Prezenta starea într-un mod simplu și acționabil pentru transportatori non-tehnici
- Oferi administratorilor o vizibilitate completă și rapoarte auditabile

---

## 2. Arhitectura Sistemului

```
┌─────────────────────────────────────────────────────────────────┐
│                        BAZA DE DATE COMUNĂ                      │
│   PostgreSQL / Supabase — date partajate, acces controlat       │
│   Entități: users, devices, transports, readings, events,       │
│             alarms, notifications, reports                      │
└──────────────────────┬──────────────────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
┌─────────────────┐       ┌──────────────────────┐
│  APLICAȚIE      │       │  PLATFORMĂ WEB        │
│  MOBILĂ         │       │  ADMIN                │
│  React Native   │       │  Next.js / React      │
│  (Transportator)│       │  (Administrator)      │
│                 │       │                       │
│  Acces limitat: │       │  Acces complet:       │
│  - Propriul     │       │  - Toate dispozitivele│
│    dispozitiv   │       │  - Toți transportatorii│
│  - Transport    │       │  - Rapoarte complete  │
│    propriu      │       │  - Configurare sistem │
│  - Fără config  │       │  - Export CSV         │
│  - Fără admin   │       │  - Conformitate       │
└─────────────────┘       └──────────────────────┘
          │                         │
          └────────────┬────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │   API BACKEND   │
              │   REST / GraphQL│
              │   Node.js /     │
              │   Supabase Edge │
              └─────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  DISPOZITIV     │
              │  CryoSafe PTU   │
              │  Telemetrie IoT │
              │  MQTT / WebSocket│
              └─────────────────┘
```

### Reguli de acces

| Funcționalitate | Transportator (mobil) | Administrator (web) |
|---|---|---|
| Temperatură live | DA — propriul dispozitiv | DA — toate dispozitivele |
| Log tehnic complet | NU | DA |
| Erori senzor detaliate | NU (doar Activ/Inactiv) | DA |
| Date alți transportatori | NU | DA |
| Dezactivare alarme | NU | DA |
| Configurare dispozitiv | NU | DA |
| Creare/ștergere conturi | NU | DA |
| Rapoarte de conformitate | NU | DA |
| Export date CSV | NU | DA |
| Predicții statistice | NU | DA |
| Vizualizare flotă completă | NU | DA |

---

## 3. Design System

**Numele sistemului:** MedGuard Design System  
**Font:** Inter (400, 500, 600, 700)  
**Iconițe:** Material Symbols Outlined  
**Framework vizual:** Tailwind CSS cu token-uri personalizate

### Paleta de culori

| Token | Valoare HEX | Utilizare |
|---|---|---|
| `primary` | `#000000` | Elemente principale, texte cheie |
| `secondary` | `#0051D5` | Acțiuni, butoane CTA, link-uri |
| `secondary-container` | `#316BF3` | Butoane active, highlights |
| `background` | `#FCFFF8FA` | Fundalul general al aplicației |
| `surface-container-lowest` | `#FFFFFF` | Carduri, formulare |
| `surface-container` | `#F0EDEF` | Suprafețe secundare |
| `on-surface` | `#1B1B1D` | Text principal |
| `on-surface-variant` | `#45464D` | Text secundar, etichete |
| `outline` | `#76777D` | Borduri, separatoare |
| `status-ok` | `#10B981` | Stare normală — OK |
| `status-warning` | `#F59E0B` | Stare de avertisment — ATENȚIE |
| `status-critical` | `#EF4444` | Stare critică — ALERTĂ |
| `error` | `#BA1A1A` | Erori de formular |

### Tipografie

| Token | Dimensiune | Greutate | Utilizare |
|---|---|---|---|
| `display-temp` | 64px / 72px | 700 | Afișarea temperaturii curente |
| `headline-lg` | 24px / 32px | 700 | Titluri principale de ecran |
| `status-label` | 18px / 24px | 600 | Etichete de stare (OK/ATENȚIE/CRITICĂ) |
| `body-md` | 16px / 24px | 400 | Text curent, descrieri |
| `label-sm` | 12px / 16px | 500 | Etichete mici, metadate |

### Spațiere și raze

| Token | Valoare | Utilizare |
|---|---|---|
| `container-margin` | 1.25rem | Marginile laterale ale ecranului |
| `stack-gap` | 1rem | Spațiu între elemente verticale |
| `section-padding` | 1.5rem | Padding intern al secțiunilor |
| `touch-target` | 3rem (48px) | Dimensiunea minimă a elementelor interactive |
| `rounded-lg` | 0.5rem | Carduri, butoane |
| `rounded-xl` | 0.75rem | Containere principale |
| `rounded-full` | 9999px | Badge-uri, indicatoare circulare |

### Componente de bază

- **Status Badge** — bandă colorată cu text scurt (OK / ATENȚIE / CRITICĂ), folosind culorile `status-*`
- **Temperature Display** — număr mare cu font `display-temp`, centrat, cu unitatea °C
- **Primary Button** — fundal `secondary`, text `on-secondary`, înălțime `touch-target`, raze `rounded-lg`
- **Secondary Button** — fundal transparent, border `outline`, text `on-surface`
- **Alert Banner** — bandă persistentă roșie în partea de sus a ecranului la alertă activă
- **Info Card** — container `surface-container-lowest` cu border `border-subtle`, raze `rounded-xl`
- **Bottom Navigation Bar** — 4 tab-uri cu iconițe și etichete, fundal `surface-container-lowest`

---

## 4. Aplicația Mobilă — Transportator

### 4.1 Principii de design funcțional

Aceste principii guvernează toate deciziile de UX și trebuie respectate pe fiecare ecran:

1. **O singură informație principală pe ecran** — utilizatorul înțelege starea dintr-o privire, fără să citească text lung.
2. **Starea se exprimă în maxim trei cuvinte** — OK / ATENȚIE / CRITICĂ — niciodată terminologie tehnică.
3. **Fără termeni tehnici expuși** — nu se afișează REG-TEMP-1, Z-Score, TELEMETRY_SYNC_FAILED sau alte coduri interne.
4. **Temperatura este singura valoare numerică proeminentă** — bateria și timpul sunt informații secundare, mai mici vizual.
5. **Maximum două acțiuni disponibile pe ecran** — niciodată mai multe butoane sau opțiuni simultan.
6. **Alertele preiau controlul ecranului imediat** — o alertă critică apare automat, nu necesită navigare.
7. **Touch target minim 48px** — fiecare element interactiv trebuie să fie ușor apăsabil, inclusiv cu mănuși.
8. **Contrast ridicat** — toate textele respectă WCAG AA (contrast ≥ 4.5:1 pentru text normal).

---

### 4.2 Ecrane — Descriere detaliată

---

#### ECRAN 1 — Splash / Încărcare

**Scop:** Ecran de tranziție afișat 1–2 secunde la deschiderea aplicației, în timp ce se verifică sesiunea și se încarcă datele inițiale.

**Conținut vizual:**
- Logo MedGuard Go centrat (iconiță `medical_services` + text)
- Indicator de încărcare circular (spinner) sub logo
- Fundal `background` (#FCFFF8FA)

**Logică:**
- Dacă există sesiune validă → redirect automat la Ecranul 3 (Home)
- Dacă nu există sesiune → redirect la Ecranul 2 (Login)
- Nu există butoane sau interacțiuni pe acest ecran

---

#### ECRAN 2 — Login / Autentificare

**Scop:** Identificarea transportatorului în sistem folosind credențiale furnizate de administrator.

**Conținut vizual:**
- Logo + subtitlu „Logistics & Tracking System" centrat sus
- Card formular (`surface-container-lowest`, `rounded-xl`, `shadow-sm`):
  - Label + câmp email/telefon cu iconiță `person`
  - Label + câmp parolă (mascat) cu iconiță `lock` și buton toggle vizibilitate
  - Checkbox opțional: „Ține-mă conectat"
  - Buton principal: „Intră în cont" (full-width, fundal `secondary`)
  - Link: „Am uitat parola"

**Funcționalitate:**
- Autentificare cu credențiale create de admin (transportatorul nu își poate crea cont singur)
- La autentificare reușită → redirect la Ecranul 3
- La eroare → mesaj inline simplu: „Date incorecte. Încearcă din nou." (culoare `error`)
- După 5 încercări eșuate → blocare temporară 5 minute cu mesaj: „Contul este blocat temporar. Încearcă din nou în 5 minute."
- Flow resetare parolă: email/SMS cu cod → câmp cod → câmp parolă nouă → confirmare

**Stări de validare:**
- Câmpuri goale la submit → highlight roșu + mesaj sub câmp
- Email invalid ca format → mesaj „Format email invalid"
- Parolă sub 8 caractere → mesaj specific

---

#### ECRAN 3 — Home / Starea curentă

**Scop:** Ecranul principal al aplicației. Primul ecran văzut după login. Arată în timp real starea transportului activ.

**Conținut vizual — când există transport activ:**

```
┌─────────────────────────────────┐
│  MedGuard Go         [Notif 🔔] │
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐    │
│  │   ● OK                  │    │  ← Status badge (verde/galben/roșu)
│  │   5.4°C                 │    │  ← Temperatură (64px, bold)
│  │   Interval: 2°C – 8°C   │    │  ← Text secundar mic
│  └─────────────────────────┘    │
│                                 │
│  📍 Hunedoara → Cluj-Napoca     │  ← Traseu activ
│  ⏱  2h 14min în transport      │
│  🔋 82% baterie  ████████░░     │
│  📡 Senzor rezervă: Activ       │
│  🕐 Actualizat acum 10 sec      │
│                                 │
│  [Raportează o problemă]        │  ← Buton secundar
├─────────────────────────────────┤
│  🏠 Acasă  🔔 Notif  📋 Istoric  👤 Profil │
└─────────────────────────────────┘
```

**Conținut vizual — când nu există transport activ:**
- Text centrat: „Niciun transport activ în acest moment."
- Iconiță ilustrativă (ex: camion cu X)
- Buton: „Vezi istoricul" → Ecranul 7

**Logică de stare:**
- `OK` (verde `status-ok`) = 2°C ≤ T ≤ 8°C, senzori funcționali, telemetrie activă
- `ATENȚIE` (galben `status-warning`) = 7°C < T ≤ 8°C, SAU senzor secundar inactiv, SAU întreruperi de semnal
- `CRITICĂ` (roșu `status-critical`) = T > 8°C sau T < 2°C, SAU alarma dispozitivului este activă

**Funcționalitate:**
- Date actualizate automat la fiecare 10 secunde via WebSocket sau polling
- Tap pe cardul de stare → deschide Ecranul 4 (Detaliu transport activ)
- La apariție alertă critică → tranziție automată la Ecranul 5 (modal full-screen)
- Transportatorul nu poate modifica nicio valoare, nu poate dezactiva alarme

---

#### ECRAN 4 — Detaliu transport activ

**Scop:** Informații suplimentare față de Home, pentru transportatorii care vor să vadă mai mult. Accesat prin tap pe ecranul Home.

**Conținut vizual:**

```
┌─────────────────────────────────┐
│  ← Înapoi        Detaliu activ │
├─────────────────────────────────┤
│  ● OK    5.4°C                  │
│                                 │
│  [Grafic temperatură 30 min]    │
│   9°C ─────────────────────────│  ← Linie roșie la 8°C
│   8°C ━━━━━━━━━━━━━━━━━━━━━━━━│
│   6°C      ∿∿∿∿∿∿∿∿∿∿∿∿        │  ← Linie temperatură
│   4°C  ∿∿∿                     │
│   2°C ─────────────────────────│
│        acum-30min          acum │
│                                 │
│  🔋 Baterie: 82% · ~3h 40min   │
│  📡 Senzor principal: Activ     │
│  📡 Senzor rezervă: Activ       │
│                                 │
│  ⚠️  Alerte în sesiune: 0       │
│  🚪 Deschideri ușă: 3           │
│  🕐 Start transport: 09:45      │
│  🆔 Dispozitiv: PTU-7           │
│                                 │
│  [Raportează o problemă]        │
├─────────────────────────────────┤
│  🏠 Acasă  🔔 Notif  📋 Istoric  👤 Profil │
└─────────────────────────────────┘
```

**Logică grafic temperatură:**
- Afișează doar ultimele 30 de minute, nu întreaga sesiune
- O singură linie de temperatură (albastru `secondary`)
- O singură linie orizontală roșie la 8°C (limita maximă)
- Fără axe complexe, fără legendă elaborată, fără valori numerice pe axe (opțional o scală simplă)
- Actualizat la fiecare 30 secunde

**Logică senzori:**
- Dacă senzorul de rezervă este inactiv → avertisment clar: „Senzorul de rezervă nu funcționează. Anunță imediat dispeceratul." (text portocaliu, iconiță `warning`)
- Transportatorul nu vede valorile numerice individuale ale senzorilor — doar Activ/Inactiv

---

#### ECRAN 5 — Alertă activă (modal full-screen)

**Scop:** Ecran de urgență care preia automat controlul complet al aplicației la detecția unei stări critice.

**Declanșare automată când:**
- Temperatura depășește 8°C sau scade sub 2°C
- Alarma dispozitivului este activată
- Senzorul principal eșuează

**Conținut vizual:**

```
┌─────────────────────────────────┐
│                                 │
│     🚨  ALERTĂ CRITICĂ          │  ← Titlu mare, roșu, centrat
│                                 │
│   Temperatura a depășit         │
│   limita maximă admisă.         │  ← Maxim 2 propoziții
│   Contactează imediat           │
│   dispeceratul.                 │
│                                 │
│         9.2°C                   │  ← Temperatura curentă (mare)
│                                 │
│  ┌───────────────────────────┐  │
│  │  📞 Sună dispeceratul     │  │  ← Buton principal (roșu)
│  └───────────────────────────┘  │
│                                 │
│  [Am înțeles, continuu]         │  ← Buton secundar (text, gri)
│                                 │
└─────────────────────────────────┘
```

**Funcționalitate:**
- Notificare push trimisă automat și simultan administratorului web la apariția alertei
- Nu poate fi închis fără confirmare (butonul „Am înțeles" este obligatoriu)
- Numărul de telefon al dispeceratului este configurat de admin, nu poate fi modificat de transportator

**Logică:**
- „Am înțeles, continuu" → alerta marcată ca „văzută" în DB cu timestamp → redirect Home cu banner roșu persistent
- „Sună dispeceratul" → apel telefonic inițiat automat → evenimentul înregistrat în log
- Banner roșu persistent pe toate ecranele până când dispozitivul revine la stare normală
- La revenire în interval normal → alerta se închide automat + mesaj: „Temperatura a revenit la normal. Sesiunea continuă."

**Mesaje predefinite pe tip de alertă:**
- Temperatură ridicată: „Temperatura a depășit limita maximă admisă. Contactează imediat dispeceratul."
- Temperatură scăzută: „Temperatura a scăzut sub limita minimă admisă. Contactează imediat dispeceratul."
- Senzor principal inactiv: „Senzorul principal nu mai funcționează. Oprește-te în siguranță și anunță dispeceratul."

---

#### ECRAN 6 — Raportare eveniment manual

**Scop:** Permite transportatorului să raporteze un eveniment care nu este detectat automat de senzori.

**Conținut vizual:**

```
┌─────────────────────────────────┐
│  ← Înapoi     Ce s-a întâmplat?│
├─────────────────────────────────┤
│                                 │
│  Selectează tipul evenimentului:│
│                                 │
│  ○ Am deschis ușa dispozitivului│
│  ○ Am oprit motorul / am parcat │
│  ○ Dispozitivul face zgomot     │
│    neobișnuit                   │
│  ○ Altceva                      │
│                                 │
│  Detalii suplimentare (opțional)│
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │  (maxim 200 caractere)    │  │
│  └───────────────────────────┘  │
│                                 │
│  [Trimite raportul]             │  ← Buton principal
│  [Anulează]                     │  ← Buton secundar
│                                 │
└─────────────────────────────────┘
```

**Funcționalitate:**
- Raportul este salvat cu timestamp + ID utilizator + ID transport activ
- Administratorul vede toate rapoartele manuale în panoul web
- Offline: raportul este salvat local și trimis automat la reconectare

**Logică:**
- Selectare obligatorie a tipului (submit dezactivat fără selecție)
- La submit reușit → toast de confirmare: „Raportul a fost trimis. Mulțumim." → redirect Ecranul 3
- Câmpul text acceptă maxim 200 caractere cu contor vizibil

---

#### ECRAN 7 — Istoricul transporturilor

**Scop:** Lista tuturor transporturilor efectuate de acest transportator, în ordine cronologică inversă.

**Conținut vizual:**

```
┌─────────────────────────────────┐
│  Transporturile mele            │
│  [Această lună] [Luna trecută] [Toate] │  ← Filtre
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │ 🟢 Fără incidente         │  │  ← Badge stare finală
│  │ Hunedoara → Cluj-Napoca   │  │
│  │ 13 Mai 2026 · 09:45       │  │
│  │ Durată: 2h 30min · PTU-7  │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 🟡 Cu avertismente        │  │
│  │ Deva → Timișoara          │  │
│  │ 12 Mai 2026 · 14:20       │  │
│  │ Durată: 3h 15min · PTU-3  │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 🔴 Cu alerte critice      │  │
│  │ Sibiu → București         │  │
│  │ 10 Mai 2026 · 08:00       │  │
│  │ Durată: 5h 02min · PTU-7  │  │
│  └───────────────────────────┘  │
│  ← scroll infinit →             │
├─────────────────────────────────┤
│  🏠 Acasă  🔔 Notif  📋 Istoric  👤 Profil │
└─────────────────────────────────┘
```

**Funcționalitate:**
- Scroll vertical cu paginare automată (lazy loading la scroll)
- Tap pe card → Ecranul 8 (Detaliu transport anterior)
- Filtre: „Această lună" / „Luna trecută" / „Toate"
- Transportul activ curent apare cu eticheta specială „În desfășurare" (albastru)

**Logică:**
- Se afișează EXCLUSIV transporturile asociate contului acestui transportator
- Nu pot fi văzute transporturile altor transportatori

---

#### ECRAN 8 — Detaliu transport anterior

**Scop:** Vizualizarea unui transport finalizat în detaliu. Accesat din Ecranul 7. Read-only.

**Conținut vizual:**

```
┌─────────────────────────────────┐
│  ← Înapoi la istoric            │
├─────────────────────────────────┤
│  🔴 Cu alerte critice           │  ← Banner dacă au existat alerte
│                                 │
│  Sibiu → București              │
│  10 Mai 2026 · 08:00 – 13:02   │
│  Durată totală: 5h 02min        │
│  Dispozitiv: PTU-7              │
│                                 │
│  Temperatură sesiune:           │
│  Min: 3.1°C  |  Max: 9.4°C     │  ← Minim și maxim
│                                 │
│  [Grafic temperatură sesiune]   │
│  ──── 8°C (limita)  ────────── │  ← Linie roșie orizontală
│       ∿∿∿∿∿  ↑                 │  ← Depășire vizibilă
│                                 │
│  Alerte în sesiune: 2           │
│  Deschideri ușă: 5              │
│                                 │
│  Evenimente notabile:           │
│  • 10:32 — Alertă temp. ridicată│
│  • 11:15 — Senzor rezervă inact.│
│  • 12:07 — Ușă deschisă        │
│  • 13:02 — Transport finalizat  │
└─────────────────────────────────┘
```

**Logică:**
- Datele sunt read-only, nu pot fi modificate
- Lista de evenimente este filtrată — nu se afișează coduri tehnice (`TELEMETRY_SYNC_FAILED`, etc.), ci doar evenimente relevante pentru transportator
- Dacă au existat alerte critice → banner roșu în partea de sus

---

#### ECRAN 9 — Notificări

**Scop:** Istoricul notificărilor push primite de acest utilizator.

**Conținut vizual:**

```
┌─────────────────────────────────┐
│  Notificările mele              │
├─────────────────────────────────┤
│  ● 10:32 — ALERTĂ CRITICĂ       │  ← Punct roșu = necitit
│    „Temp. a depășit 8°C..."     │
│                                 │
│  ○ 09:45 — Informare            │  ← Cerc gol = citit
│    „Transportul a început."     │
│                                 │
│  ○ Ieri 15:20 — Avertisment     │
│    „Bateria sub 20%"            │
│                                 │
│  ○ Ieri 14:02 — Transport fin.  │
│    „Transport finalizat cu succ."│
├─────────────────────────────────┤
│  🏠 Acasă  🔔 Notif  📋 Istoric  👤 Profil │
└─────────────────────────────────┘
```

**Funcționalitate:**
- Tap pe o notificare → deschide ecranul relevant (Ecranul 5 dacă alertă activă, Ecranul 8 dacă transport finalizat)
- Marcare automată ca „citit" la deschidere
- Notificările necitite: punct colorat + text bold
- Retenție: maxim 90 de zile
- Ștergerea notificărilor nu este disponibilă transportatorului

---

#### ECRAN 10 — Profil și setări cont

**Scop:** Informații despre cont și setări minime ale aplicației.

**Conținut vizual:**

```
┌─────────────────────────────────┐
│  Profil                         │
├─────────────────────────────────┤
│  👤  Ion Popescu                │
│      ion.popescu@example.com    │
│      +40 721 234 567            │
├─────────────────────────────────┤
│  SETĂRI NOTIFICĂRI              │
│  Notificări push     [ON ●]     │
│  Vibrare la alertă   [ON ●]     │
│                                 │
│  LIMBĂ                          │
│  Română / Engleză              │
├─────────────────────────────────┤
│  [Schimbă parola]               │
│  [Deconectare]                  │
├─────────────────────────────────┤
│  MedGuard Go v1.0.0             │
└─────────────────────────────────┘
```

**Funcționalitate:**
- Transportatorul POATE schimba: parola (flow SMS + cod), preferințe notificări, limbă
- Transportatorul NU POATE schimba: numele, telefonul, emailul (doar adminul poate face asta)
- La dezactivarea notificărilor → dialog de confirmare: „Dacă dezactivezi notificările, nu vei primi alerte în caz de urgență. Ești sigur?"
- Notificările de tip CRITICĂ sunt trimise indiferent de setările utilizatorului
- Deconectare → ștergere sesiune locală → redirect Ecranul 2

---

### 4.3 Navigare și flow complet

```
[ECRAN 1 — Splash]
    │
    ├─── sesiune validă ──────────────────────────┐
    │                                             │
    └─── fără sesiune                             │
         │                                        │
         ▼                                        │
    [ECRAN 2 — Login]                             │
         │                                        │
         └─── autentificare reușită ──────────────┘
                                                  │
                                                  ▼
                              [ECRAN 3 — Home / Stare curentă]
                                    │
                    ┌───────────────┼────────────────────┐
                    │               │                     │
              tap stare      alertă apare          bottom nav
                    │         automat                     │
                    ▼               │           ┌─────────┼──────────┐
            [ECRAN 4 —             │           │         │          │
           Detaliu activ]          ▼      Notificări  Istoric    Profil
                    │        [ECRAN 5 —        │         │          │
                    │       Alertă activă]      ▼         ▼          ▼
                    │          │    │    [ECRAN 9]  [ECRAN 7 —  [ECRAN 10]
                    └──────────┘    │               Istoric]
                    │         │     │                   │
                    ▼         │     └── Apel telefon    │
               [ECRAN 6 —    │         (dispecerat)    tap card
              Raportare]  „Am înțeles"                  │
                    │         │                         ▼
                    └─────────┘                   [ECRAN 8 —
                          │                       Detaliu ant.]
                          ▼
                    [ECRAN 3 — Home]
                    (cu banner alertă)
```

### 4.4 Comportament offline

| Situație | Comportament |
|---|---|
| Pierdere conexiune | Banner persistent gri: „Fără conexiune. Datele afișate pot fi depășite." |
| Date disponibile offline | Ultimele date sincronizate, lista transporturilor anterioare stocate local |
| Date indisponibile offline | Date live, notificări noi, trimitere rapoarte |
| Raport manual offline | Salvat local → trimis automat la reconectare |
| Reconectare | Date actualizate automat, banner dispare |

### 4.5 Notificări push — logică de trimitere

| Eveniment | Tip | Text notificare | Poate fi dezactivat? |
|---|---|---|---|
| Temperatura > 8°C | CRITICĂ | „ALERTĂ: Temperatura a depășit 8°C. Verifică dispozitivul." | NU |
| Temperatura < 2°C | CRITICĂ | „ALERTĂ: Temperatura a scăzut sub 2°C. Verifică dispozitivul." | NU |
| Temperatura 7°C–8°C | AVERTISMENT | „ATENȚIE: Temperatura se apropie de limita maximă." | DA |
| Senzor principal inactiv | CRITICĂ | „ALERTĂ: Senzorul principal nu mai funcționează. Anunță dispeceratul." | NU |
| Senzor de rezervă inactiv | AVERTISMENT | „ATENȚIE: Senzorul de rezervă s-a oprit." | DA |
| Baterie sub 20% | AVERTISMENT | „ATENȚIE: Bateria dispozitivului este aproape descărcată." | DA |
| Transport finalizat | INFORMARE | „Transportul a fost finalizat cu succes." | DA |
| Alarma activată | CRITICĂ | „ALERTĂ: Alarma dispozitivului a fost declanșată." | NU |

**Reguli speciale:**
- Notificările CRITICE sunt livrate indiferent de setările utilizatorului
- Dacă dispozitivul este offline → notificarea se trimite la prima reconectare
- Administratorul primește simultan o copie a tuturor notificărilor CRITICE pe platforma web

---

## 5. Platforma Web — Administrator

Platforma web este destinată exclusiv administratorilor. Spre deosebire de aplicația mobilă, aceasta oferă acces complet la toate datele, configurare și rapoarte de conformitate.

### 5.1 Structura panoului admin

**Navigare principală (sidebar):**
- Dashboard (Overview)
- Dispozitive
- Transportatori
- Transporturi
- Alarme și Alerte
- Rapoarte de Conformitate
- Notificări
- Setări sistem
- Conturi utilizatori

---

### 5.2 Secțiuni și funcționalități

#### A. Dashboard — Overview

**Scop:** Vizualizarea stării întregii flote la un moment dat.

**Conținut:**
- Grid de carduri per dispozitiv activ, fiecare afișând:
  - ID dispozitiv (ex: PTU-7)
  - Starea curentă (OK / ATENȚIE / CRITICĂ)
  - Temperatura curentă
  - Transportator atribuit
  - Ora ultimei actualizări
- Rezumat global:
  - Număr dispozitive active
  - Număr alarme active
  - Număr dispozitive în conformitate / neconformitate
- Grafic agregat al temperaturii pentru toate dispozitivele (ultimele 24h)
- Feed în timp real de alerte (live stream)

---

#### B. Dispozitive

**Scop:** Management complet al dispozitivelor CryoSafe PTU din flotă.

**Funcționalități:**
- Lista tuturor dispozitivelor (ID, status, transportator atribuit, ultima sincronizare)
- Detaliu per dispozitiv:
  - Temperatură live + grafic 24h / 7 zile / 30 zile
  - Starea ambilor senzori cu valori numerice exacte (T1, T2, |T1-T2|)
  - Nivel baterie + prognoză descărcare
  - Log tehnic complet (TELEMETRY_SYNC_FAILED, SENSOR_TIMEOUT, etc.)
  - Număr deschideri ușă în sesiunea curentă
  - Starea alarmei (activă/inactivă)
- Configurare per dispozitiv:
  - Praguri de avertisment (ex: alertă de la 7.5°C în loc de 7°C)
  - Numărul de telefon al dispeceratului
  - Intervalul de sampling (≤30 secunde per REG-TEMP-4)
  - Activare/dezactivare alarme

---

#### C. Transportatori

**Scop:** Gestionarea conturilor utilizatorilor de tip transportator.

**Funcționalități:**
- Lista tuturor transportatorilor (nume, telefon, email, status cont)
- Creare cont nou transportator (admin furnizează credențialele)
- Editare date personale (admin poate modifica telefon, email, nume)
- Resetare parolă forțată
- Dezactivare / reactivare cont
- Vizualizarea istoricului complet al unui transportator (toate transporturile)
- Atribuire dispozitiv unui transportator

---

#### D. Transporturi

**Scop:** Vizualizarea și gestionarea tuturor transporturilor din flotă.

**Funcționalități:**
- Lista tuturor transporturilor (toate dispozitivele, toți transportatorii)
- Filtre: perioadă, transportator, dispozitiv, stare (finalizat/activ/cu alerte)
- Detaliu per transport:
  - Traseu complet
  - Date start/stop
  - Grafic temperatură complet al sesiunii
  - Log tehnic complet
  - Rapoarte manuale trimise de transportator în sesiune
  - Alerte generate + timestamp-uri
- Export CSV per transport sau per perioadă

---

#### E. Alarme și Alerte

**Scop:** Centralizarea tuturor alarmelor active și istorice.

**Funcționalități:**
- Lista alarmelor active (toate dispozitivele)
- Posibilitatea dezactivării manuale a unei alarme cu motivație
- Istoricul complet al alarmelor cu:
  - Tip alertă
  - Dispozitiv și transportator implicat
  - Timestamp activare
  - Timestamp confirmare de transportator
  - Timestamp rezolvare
  - Durata totală a alertei
- Statistici: număr alerte pe tip, durată medie, frecvență per dispozitiv

---

#### F. Rapoarte de Conformitate (MED-THERM-2026)

**Scop:** Auditarea automată a conformității cu standardul de reglementare.

**Funcționalități:**
- Raport per dispozitiv / perioadă cu verificarea fiecărei reglementări:
  - REG-TEMP-1: % timp în interval 2°C–8°C
  - REG-TEMP-2: Număr excursii > 5 minute + durata cumulată
  - REG-TEMP-3: Timp mediu de stabilizare după deschidere ușă
  - REG-TEMP-4: Verificare interval de sampling (≤30 sec)
  - REG-SENS-1: Disponibilitate senzor redundant
  - REG-SENS-3: Număr evenimente |T1-T2| > 0.5°C
  - REG-ALARM-1: Verificare timp de activare alarmă (≥2 min după excursie)
  - REG-ALARM-2: Verificare latență notificare (≤10 sec)
  - REG-DATA-2: Gaps de telemetrie > 90 secunde
  - REG-DATA-3: Confirmare retenție locală ≥72 ore
  - REG-POWER-1: Verificare backup baterie ≥4 ore
  - REG-OPS-2: Număr evenimente de acces excesiv (>10 deschideri/oră)
- Clasificare severitate per violație:
  - **CRITIC** — violații ce pun în pericol produsul sau pacientul
  - **MAJOR** — abateri semnificative de la standard
  - **MINOR** — neconformități care pot fi remediate procedural
- Export raport PDF/CSV
- Predicții AI: detecție anomalii statistice în seriile de temperatură (Z-Score, EMA)

---

#### G. Setări sistem

**Funcționalități:**
- Configurare globală praguri de alertă (default pentru toate dispozitivele)
- Configurare număr dispecerat de urgență (afișat transportatorilor pe Ecranul 5)
- Configurare retenție date (minim 72 ore local per REG-DATA-3)
- Gestionare utilizatori admin
- Configurare interval de backup
- Setări integrare MQTT/IoT (endpoint, port, credențiale)

---

### 5.3 Rapoarte de conformitate — detaliu

Raportul de conformitate este documentul central al PoC-ului. Acesta mapează fiecare reglementare la datele reale din sistem:

```
RAPORT CONFORMITATE — PTU-7 — 01.05.2026 – 13.05.2026
══════════════════════════════════════════════════════

REG-TEMP-1  ✅ CONFORM     Timp în interval: 97.3%
REG-TEMP-2  ❌ NECONFORM   3 excursii > 5 min (max: 8 min)
                           Cumulat: 24 min (limita: 10 min/24h)
REG-TEMP-3  ✅ CONFORM     Timp mediu stabilizare: 2.1 min
REG-TEMP-4  ✅ CONFORM     Interval sampling: 15 sec
REG-SENS-1  ❌ NECONFORM   2 evenimente senzor redundant inactiv
REG-SENS-3  ⚠️ AVERTISMENT 1 eveniment |T1-T2| = 0.51°C
REG-ALARM-1 ✅ CONFORM     Alarme activate prompt
REG-ALARM-2 ✅ CONFORM     Latență medie notificare: 3.2 sec
REG-DATA-2  ⚠️ AVERTISMENT 2 gap-uri telemetrie: 95 sec, 120 sec
REG-DATA-3  ✅ CONFORM     Date locale: 168 ore disponibile
REG-POWER-1 ✅ CONFORM     Backup testat: 5.2 ore
REG-OPS-2   ⚠️ AVERTISMENT 1 sesiune cu 12 deschideri/oră

CONCLUZIE: NECONFORM — 2 violații critice identificate
```

---

## 6. Baza de Date Comună

### 6.1 Entități principale

```sql
-- Utilizatori (transportatori + admini)
TABLE users (
    id UUID PRIMARY KEY,
    role ENUM('admin', 'transporter'),
    full_name TEXT,
    phone TEXT,
    email TEXT,
    password_hash TEXT,
    is_active BOOLEAN,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ
)

-- Dispozitive CryoSafe PTU
TABLE devices (
    id UUID PRIMARY KEY,
    device_code TEXT UNIQUE, -- ex: PTU-7
    is_active BOOLEAN,
    assigned_transporter_id UUID REFERENCES users(id),
    temp_min_ok FLOAT DEFAULT 2.0,
    temp_max_ok FLOAT DEFAULT 8.0,
    temp_warning_threshold FLOAT DEFAULT 7.0,
    alarm_delay_seconds INT DEFAULT 120,
    dispatch_phone TEXT,
    last_sync_at TIMESTAMPTZ
)

-- Lecturi de temperatură (telemetrie)
TABLE temperature_readings (
    id UUID PRIMARY KEY,
    device_id UUID REFERENCES devices(id),
    transport_id UUID REFERENCES transports(id),
    sensor_primary_value FLOAT,
    sensor_secondary_value FLOAT,
    sensor_secondary_active BOOLEAN,
    recorded_at TIMESTAMPTZ,
    INDEX (device_id, recorded_at)
)

-- Transporturi
TABLE transports (
    id UUID PRIMARY KEY,
    device_id UUID REFERENCES devices(id),
    transporter_id UUID REFERENCES users(id),
    route_from TEXT,
    route_to TEXT,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    status ENUM('active', 'completed', 'aborted'),
    final_status ENUM('no_incidents', 'with_warnings', 'with_critical_alerts')
)

-- Alarme și alerte
TABLE alarms (
    id UUID PRIMARY KEY,
    device_id UUID REFERENCES devices(id),
    transport_id UUID REFERENCES transports(id),
    alarm_type ENUM('temp_high','temp_low','sensor_primary_fail','sensor_secondary_fail','telemetry_gap'),
    triggered_at TIMESTAMPTZ,
    acknowledged_at TIMESTAMPTZ, -- când transportatorul a apăsat „Am înțeles"
    resolved_at TIMESTAMPTZ,
    call_dispatched BOOLEAN DEFAULT FALSE
)

-- Evenimente din log
TABLE events (
    id UUID PRIMARY KEY,
    device_id UUID REFERENCES devices(id),
    transport_id UUID REFERENCES transports(id),
    user_id UUID REFERENCES users(id),
    event_type TEXT, -- DOOR_OPEN, ALARM_TRIGGERED, CONFIG_CHANGE, etc.
    event_details JSONB,
    is_technical BOOLEAN DEFAULT FALSE, -- dacă FALSE → vizibil și pe mobile
    recorded_at TIMESTAMPTZ
)

-- Notificări
TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    transport_id UUID REFERENCES transports(id),
    type ENUM('critical','warning','info'),
    title TEXT,
    body TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ -- 90 zile retenție
)

-- Rapoarte manuale (trimise de transportator)
TABLE manual_reports (
    id UUID PRIMARY KEY,
    transport_id UUID REFERENCES transports(id),
    transporter_id UUID REFERENCES users(id),
    report_type ENUM('door_open','engine_stop','unusual_noise','other'),
    details TEXT,
    submitted_offline BOOLEAN DEFAULT FALSE,
    submitted_at TIMESTAMPTZ
)
```

### 6.2 Reguli de acces per tip user

Implementate la nivel de **Row Level Security (RLS)** în baza de date sau prin middleware API:

- **Transportator** → poate accesa EXCLUSIV înregistrările unde `transporter_id = auth.user_id` sau `device.assigned_transporter_id = auth.user_id`
- **Administrator** → acces complet la toate înregistrările
- **Câmpurile tehnice** (erori senzor detaliate, coduri interne) → returnate EXCLUSIV pentru admini
- **Imutabilitate log** (REG-DATA-1) → tabelele `temperature_readings` și `events` sunt append-only; UPDATE și DELETE sunt interzise

---

## 7. Cerințe de Conformitate Regulatorie

Standardul **MED-THERM-2026** definește 8 categorii de cerințe pe care sistemul trebuie să le monitorizeze continuu.

### 7.1 Reglementări termice

| Reglementare | Cerință | Implementare sistem |
|---|---|---|
| REG-TEMP-1 | 2°C ≤ T ≤ 8°C în orice moment | Monitorizare continuă; stare CRITICĂ dacă T iese din interval |
| REG-TEMP-2 | Excursie max 5 min/eveniment; max 10 min cumulat/24h | Timer per excursie + acumulator zilnic; alertă CRITICĂ la depășire |
| REG-TEMP-3 | Stabilizare ≤3 min după deschidere ușă | Timestamp ușă deschisă + cronometru revenire în interval |
| REG-TEMP-4 | Sampling ≤30 secunde | Configurat la 15 secunde; alertă dacă gap > 30 sec |

### 7.2 Senzori și redundanță

| Reglementare | Cerință | Implementare sistem |
|---|---|---|
| REG-SENS-1 | Senzor primar + senzor secundar obligatoriu | Monitorizare status ambii senzori; alertă CRITICĂ la eșec primar sau secundar |
| REG-SENS-2 | Senzorii nu se plasează < 15 cm de fluxul de aer | Cerință fizică hardware — documentată în specificații tehnice |
| REG-SENS-3 | \|T1-T2\| ≤ 0.5°C | Calculat la fiecare lectură; alertă dacă diferența depășește pragul |

### 7.3 Sistem de alarmare

| Reglementare | Cerință | Implementare sistem |
|---|---|---|
| REG-ALARM-1 | Alarma se activează dacă T rămâne în afara intervalului ≥2 min | Timer declanșat la prima excursie; alarmă la 120 secunde |
| REG-ALARM-2 | Notificarea se livrează în ≤10 secunde | Push notification via FCM/APNs; timestamp livrat vs. generat |
| REG-ALARM-3 | Alarmă sonoră + vizuală + notificare mobilă | Buzzer dispozitiv + Ecranul 5 full-screen + push notification |

### 7.4 Integritate date și logging

| Reglementare | Cerință | Implementare sistem |
|---|---|---|
| REG-DATA-1 | Log imutabil: temperaturi, alarme, config, senzori | Tabele append-only; RLS cu UPDATE/DELETE interzis; audit trail |
| REG-DATA-2 | Gap telemetrie ≤90 secunde | Detectat automat; eveniment gap înregistrat; alertă dacă gap > 90 sec |
| REG-DATA-3 | Retenție locală ≥72 ore | Cache local pe dispozitiv; verificat și raportat |
| REG-POWER-1 | Backup baterie ≥4 ore | Monitorizare nivel baterie; alertă < 20%; test periodic |
| REG-OPS-2 | Avertisment dacă deschideri ușă > 10/oră | Contor deschideri per sesiune per oră; alertă la depășire |

---

## 8. Faze de Dezvoltare

### Faza 0 — Pregătire și infrastructură (Săptămâna 1)
- Configurare repository (monorepo: mobile + web + backend)
- Configurare bază de date (Supabase / PostgreSQL)
- Configurare autentificare (JWT + refresh tokens)
- Definitivare design system (token-uri Tailwind exportate)
- Configurare pipeline CI/CD

### Faza 1 — Backend și API de bază (Săptămânile 1–2)
- Schema completă a bazei de date (migrații)
- Row Level Security (RLS) per tip user
- Endpoint-uri CRUD: users, devices, transports
- Endpoint ingestie telemetrie (POST /readings)
- Logica de detectare stări: OK / ATENȚIE / CRITICĂ
- Sistem de notificări push (FCM + APNs)
- Job de detectare alarme (background worker)

### Faza 2 — Aplicație mobilă (Săptămânile 2–4)
- Ecran 1: Splash
- Ecran 2: Login + resetare parolă
- Ecran 3: Home cu date live (WebSocket)
- Ecran 5: Alertă activă (modal full-screen, push)
- Ecran 4: Detaliu transport + grafic temperatură
- Ecran 6: Raportare manuală eveniment
- Ecran 7: Lista istoricului
- Ecran 8: Detaliu transport anterior
- Ecran 9: Lista notificări
- Ecran 10: Profil și setări
- Comportament offline (cache local + retry)

### Faza 3 — Platformă web admin (Săptămânile 3–5)
- Layout de bază + autentificare admin
- Dashboard overview flotă
- Detaliu dispozitiv + grafice
- Gestionare transportatori (CRUD)
- Lista transporturi cu filtre și export
- Gestionare alarme (activare/dezactivare)
- Raport de conformitate MED-THERM-2026 (toate reglementările)

### Faza 4 — Conformitate și rapoarte AI (Săptămânile 5–6)
- Engine de conformitate automată (verificare toate REG-*)
- Clasificare severitate violații (CRITIC / MAJOR / MINOR)
- Analiză statistică serii temporale (Z-Score, EMA)
- Detecție anomalii și predicții
- Export PDF / CSV rapoarte de conformitate
- Dashboard sinteză conformitate per flotă

### Faza 5 — Testare și PoC finalizare (Săptămâna 6–7)
- Simulare date dispozitiv (mock MQTT producer)
- Testare scenarii de alertă (excursii termice, eșecuri senzori)
- Testare comportament offline
- Review UX cu utilizator non-tehnic
- Documentație finală și demo PoC

---

## 9. Stack Tehnologic Recomandat

### Aplicație mobilă
- **Framework:** React Native (Expo)
- **Navigare:** React Navigation v6
- **State management:** Zustand sau React Query
- **Grafice:** Victory Native sau React Native Charts Kit
- **Notificări push:** Expo Notifications (FCM + APNs)
- **Cache offline:** AsyncStorage + React Query offline

### Platformă web admin
- **Framework:** Next.js 14 (App Router)
- **UI Components:** shadcn/ui + Tailwind CSS
- **Grafice:** Recharts sau Tremor
- **State:** React Query (server state) + Zustand (UI state)
- **Export PDF:** React PDF / puppeteer
- **Tabele de date:** TanStack Table

### Backend & Infrastructură
- **BaaS:** Supabase (PostgreSQL + Auth + Realtime + Edge Functions)
- **Real-time telemetrie:** MQTT (Mosquitto) → WebSocket Bridge
- **Job queue:** Supabase Edge Functions sau BullMQ
- **Push notifications:** Firebase Cloud Messaging (FCM) + Apple Push Notification Service (APNs)
- **Hosting:** Vercel (web) + EAS (mobile) + Supabase Cloud

### DevOps
- **CI/CD:** GitHub Actions
- **Testing:** Jest + React Testing Library + Detox (E2E mobile)
- **Monitoring:** Sentry (erori) + Logflare (logs)

---

*Document generat pe baza:*
- *MedGuard Design System (DESIGN.md)*
- *Ecrane de design implementate în Stitch (10 ecrane)*
- *CryoSafe PTU — Compliance Standard MED-THERM-2026*
- *Complex Enterprise-Level Client Request (PoC)*

*Versiune: 1.0 · Data: Mai 2026*
