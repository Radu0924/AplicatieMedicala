# MedGuard — Proof of Concept v1.0

**MedGuard Go** este o platformă digitală de monitorizare și conformitate pentru transportul plasma medicală cu dispozitive CryoSafe PTU (Portable Temperature Unit). Sistemul asigură că temperatura plasmei rămâne strict între **2°C și 8°C** în conform itate cu standardul medical **MED-THERM-2026**.

---

## 📋 Cuprins

1. [Viziune și Context](#viziune-și-context)
2. [Arhitectura Sistemului](#arhitectura-sistemului)
3. [Starea Curentă a Implementării](#starea-curentă-a-implementării)
4. [Structura Proiectului](#structura-proiectului)
5. [Ghid de Setup și Development](#ghid-de-setup-și-development)
6. [Caracteristici Principale](#caracteristici-principale)
7. [Stack Tehnologic](#stack-tehnologic)
8. [Planul de Dezvoltare](#planul-de-dezvoltare)
9. [Documentație și Resurse](#documentație-și-resurse)

---

## Viziune și Context

### De ce MedGuard Go?

Dispozitivele CryoSafe PTU transport plasmă medicală care trebuie menținută strict între **2°C și 8°C**. Orice abatere de temperatură reprezintă un risc medical real pentru pacienți.

**MedGuard Go** este o soluție software cu două componente:

- **📱 Aplicația mobilă** — destinată transportatorilor
  - Interfață simplă și vizuală
  - Stare în timp real (OK / ATENȚIE / CRITICĂ)
  - Alertări instantanee
  - Funcționează parțial offline
  
- **🖥️ Platforma web admin** — destinată administratorilor
  - Acces complet la toate datele flotei
  - Rapoarte de conformitate automată
  - Gestionare dispozitive și transportatori
  - Analiză statistică și predicții AI

Ambele soluții partajează o **bază de date comună** și respectă în totalitate standardul de reglementare **MED-THERM-2026**.

---

## Arhitectura Sistemului

```
┌──────────────────────────────────────────────────────────┐
│            BAZA DE DATE COMUNĂ (PostgreSQL)              │
│     • users  • devices  • transports                     │
│     • readings  • alarms  • events  • notifications      │
└──────────────────────┬──────────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
┌─────────────────────┐   ┌──────────────────────────┐
│  APLICAȚIE MOBILĂ   │   │   PLATFORMĂ WEB ADMIN    │
│  Flutter (PoC)      │   │   (Next.js recomandat)   │
│  • Home (stare)     │   │   • Dashboard            │
│  • Detaliu          │   │   • Dispozitive          │
│  • Alertă critică   │   │   • Transportatori       │
│  • Istoric          │   │   • Rapoarte             │
│  • Profil           │   │   • Conformitate         │
└─────────────────────┘   └──────────────────────────┘
          │                         │
          └────────────┬────────────┘
                       │
                       ▼
              ┌──────────────────┐
              │   API BACKEND    │
              │   (REST / MQTT)  │
              └──────────────────┘
                       │
                       ▼
              ┌──────────────────┐
              │  DISPOZITIV      │
              │  CryoSafe PTU    │
              │  (Senzori)       │
              └──────────────────┘
```

### Reguli de Acces

| Funcție | Transportator | Administrator |
|---------|:-------------:|:-------------:|
| Temperatură live | ✅ (propriul dispozitiv) | ✅ (toate) |
| Istoricul transporturilor | ✅ | ✅ |
| Log tehnic complet | ❌ | ✅ |
| Configurare dispozitiv | ❌ | ✅ |
| Rapoarte de conformitate | ❌ | ✅ |
| Export date CSV | ❌ | ✅ |

---

## Starea Curentă a Implementării

### ✅ Completat (Faza 0-1)

**Aplicație mobilă Flutter — PoC funcțional**

- [x] Design system complet (culori, tipografie, spacing)
- [x] 10 ecrane implementate și testate
- [x] Sistem de navigare (go_router)
- [x] Mock repository cu date telemetrice reale
- [x] Tema light/dark
- [x] Bottom navigation (Acasă, Notificări, Istoric, Profil)
- [x] Logica de stare (OK / ATENȚIE / CRITICĂ)
- [x] Grafice temperatură (fl_chart)
- [x] Alertele critice (modal full-screen)
- [x] Sistem de notificări (UI ready)
- [x] Data models și mock data

**Documentație**

- [x] MedTrace_Go_Development_Plan.md (83 pagini)
- [x] PoC — Medical Device Regulatory Constraints
- [x] Dataset medical_device_logs_1000.txt (1000+ înregistrări reale)

### 🚧 În Dezvoltare

- [ ] Backend API (Node.js / Supabase)
- [ ] Baza de date și schema
- [ ] Autentificare și JWT
- [ ] WebSocket pentru telemetrie live
- [ ] Sistem de notificări push (FCM/APNs)
- [ ] Platforma web admin (Next.js)
- [ ] Engine de conformitate (MED-THERM-2026)

---

## Structura Proiectului

```
D:\Proiecte\AplicatieMedicala
├── medguard/                          # Aplicație Flutter (PoC)
│   ├── lib/
│   │   ├── main.dart                  # Entry point
│   │   ├── router.dart                # Navigare go_router
│   │   ├── models/
│   │   │   └── models.dart            # Data models (Device, Transport, etc.)
│   │   ├── screens/
│   │   │   ├── splash_screen.dart     # Ecran 1: Splash
│   │   │   ├── login_screen.dart      # Ecran 2: Login
│   │   │   ├── home_screen.dart       # Ecran 3: Home
│   │   │   ├── detail_transport_screen.dart  # Ecran 4: Detaliu
│   │   │   ├── alert_screen.dart      # Ecran 5: Alertă
│   │   │   ├── report_issue_screen.dart      # Ecran 6: Raportare
│   │   │   ├── history_screen.dart    # Ecran 7: Istoric
│   │   │   ├── past_transport_detail_screen.dart  # Ecran 8: Detaliu anterior
│   │   │   ├── notifications_screen.dart    # Ecran 9: Notificări
│   │   │   ├── profile_screen.dart    # Ecran 10: Profil
│   │   │   ├── compliance_screen.dart
│   │   │   └── admin_dashboard_screen.dart
│   │   ├── widgets/
│   │   │   ├── status_badge.dart      # Badge status (OK/ATENȚIE/CRITICĂ)
│   │   │   ├── alert_banner.dart      # Banner alertă critică
│   │   │   ├── info_card.dart         # Card info
│   │   │   ├── primary_button.dart    # Buton principal
│   │   │   ├── bottom_nav.dart        # Bottom navigation
│   │   │   ├── app_top_bar.dart       # Top bar
│   │   │   ├── global_alert_handler.dart
│   │   │   └── status_badge.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart        # Paleta culori
│   │   │   ├── app_typography.dart    # Tipografie
│   │   │   ├── app_spacing.dart       # Spațiere
│   │   │   ├── app_gradients.dart     # Gradienți
│   │   │   ├── app_shadows.dart       # Umbrele
│   │   │   ├── app_theme.dart         # Teme (light/dark)
│   │   │   └── theme_notifier.dart    # State tema
│   │   ├── data/
│   │   │   ├── mock_repository.dart   # Mock data și stream
│   │   │   └── medical_device_logs_1000.txt
│   │   └── test/
│   │       └── widget_test.dart
│   ├── pubspec.yaml                   # Dependențe Flutter
│   ├── android/                       # Configurare Android
│   ├── web/                           # Assets web
│   └── README.md
│
├── PoC- Medical Device Regulatory Constraints/
│   ├── Medical Device Regulatory Constraints.md
│   ├── Complex Enterprise-Level Client Request.txt
│   ├── Super Basic & Generic Client Request.txt
│   ├── compliant_temperature_profile.png
│   ├── noncompliant_temperature_profile.png
│   └── medical_device_logs_1000.txt
│
└── medguard/MedTrace_Go_Development_Plan.md  # Documentație completă (83 pagini)
```

### Descrieri Fișiere Cheie

| Fișier | Scop |
|--------|------|
| `medguard/MedTrace_Go_Development_Plan.md` | Planul complet de dezvoltare (design, cerințe, API, DB, faze) |
| `medguard/pubspec.yaml` | Dependențe: go_router, fl_chart, google_fonts, image_picker |
| `lib/models/models.dart` | Data models: Device, Transport, Transporter, AlertType |
| `lib/screens/home_screen.dart` | Ecranul principal (stare in tempo real, stream telemetrie) |
| `lib/theme/app_colors.dart` | Paleta MD3: primary (#000000), secondary (#0051D5), status colors |
| `lib/data/mock_repository.dart` | Mock data și telemetry stream pentru PoC |

---

## Ghid de Setup și Development

### Cerințe Preliminare

- **Flutter SDK** 3.10.4 sau mai nou: https://flutter.dev/docs/get-started/install
- **Dart 3.10+**
- **Android Studio** + Android SDK (pentru Android)
- **Git**

### Setup Local

```bash
# 1. Clonează repository-ul
git clone https://github.com/your-org/medguard.git
cd medguard

# 2. Intră în directorul Flutter
cd medguard

# 3. Obține dependențele
flutter pub get

# 4. Rulează aplicația pe emulator/device
flutter run

# 5. (Opțional) Compilare release
flutter build apk --release
flutter build ios --release
```

### Dezvoltare

**Structura unui nou ecran:**

```dart
// lib/screens/my_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_top_bar.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          children: [
            // UI here
          ],
        ),
      ),
    );
  }
}
```

**Adaugă ruta în router.dart:**

```dart
GoRoute(
  path: '/my-screen',
  builder: (context, state) => const MyScreen(),
),
```

### Rulare teste

```bash
# Widget tests
flutter test

# Coverage
flutter test --coverage
```

---

## Caracteristici Principale

### 📱 Aplicația Mobilă (Flutter)

#### 10 Ecrane Implementate

| # | Ecran | Descriere |
|---|-------|-----------|
| 1 | **Splash** | Tranziție la deschidere, verificare sesiune |
| 2 | **Login** | Autentificare transportator |
| 3 | **Home** | Stare curentă transport, temperatura live |
| 4 | **Detaliu Transport Activ** | Grafic 30 min, status senzori, baterie |
| 5 | **Alertă Critică** | Modal full-screen cu buton appel dispecerat |
| 6 | **Raportare Manuală** | Selector tip eveniment + text opțional |
| 7 | **Istoric Transporturi** | Listă transporturi anterioare cu filtre |
| 8 | **Detaliu Transport Anterior** | Read-only, grafic complet, listă evenimente |
| 9 | **Notificări** | Istoric notificări push cu marcare citit |
| 10 | **Profil și Setări** | Schimbare parolă, preferințe notificări |

#### Principii UX Core

✅ **O singură informație principală** — utilizatorul înțelege starea dintr-o privire
✅ **Maxim 3 cuvinte pentru stare** — OK / ATENȚIE / CRITICĂ
✅ **Fără terminologie tehnică** — niciun cod intern expus (REG-TEMP-1, Z-Score, etc.)
✅ **Touch target ≥48px** — ușor de apăsat, inclusiv cu mănuși
✅ **Contrast WCAG AA** — toți textele respectă ratio ≥4.5:1

#### Design System

- **Culori:** Material Design 3 (MD3)
  - Primary: #000000 (negru)
  - Secondary: #0051D5 (albastru)
  - Status-OK: #10B981 (verde)
  - Status-Warning: #F59E0B (galben)
  - Status-Critical: #EF4444 (roșu)

- **Tipografie:** Inter 400, 500, 600, 700
  - Display (temp): 64px bold
  - Headline: 24px bold
  - Body: 16px regular
  - Label: 12px medium

- **Spațiere:** 1.25rem = 20px
  - Container margin
  - Stack gap: 1rem
  - Section padding: 1.5rem

### 🖥️ Platforma Web Admin (Planificat)

Recomandare: **Next.js 14 + shadcn/ui + Recharts**

Secțiuni principale:
- **Dashboard** — overview flotă, grafice agregate
- **Dispozitive** — management, configurare praguri
- **Transportatori** — CRUD conturi, atribuire dispozitive
- **Transporturi** — istoricul complet, filtre, export
- **Alarme** — activare/dezactivare, log
- **Rapoarte de Conformitate** — MED-THERM-2026 automată
- **Setări** — configurare globală, backup, MQTT

---

## Stack Tehnologic

### Curent (PoC)

| Domeniu | Stack |
|---------|-------|
| **Mobile** | Flutter 3.10.4, Dart 3.10+ |
| **Navigation** | go_router 17.1.0 |
| **UI Components** | Flutter Material 3 |
| **Grafice** | fl_chart 0.70.1 |
| **Tipografie** | google_fonts 6.3.2 |
| **Iconuri** | material_symbols_icons 4.2.1077 |
| **Imagini** | image_picker 1.1.2 |
| **Localizare** | intl 0.20.2 |

### Recomandat (Producție)

| Domeniu | Stack |
|---------|-------|
| **Backend** | Node.js + Supabase / PostgreSQL |
| **API** | REST (Express.js) + MQTT (telemetrie) |
| **Real-time** | WebSocket / Supabase Realtime |
| **Auth** | JWT + Refresh Tokens |
| **Push Notif** | Firebase Cloud Messaging (FCM) + APNs |
| **Web Admin** | Next.js 14 + shadcn/ui + Tailwind |
| **Grafice** | Recharts / Tremor |
| **DevOps** | GitHub Actions CI/CD |
| **Monitoring** | Sentry (errors) + Logflare (logs) |

---

## Planul de Dezvoltare

### 📅 Faze (6-7 săptămâni estimat)

#### Faza 0: Pregătire ✅ (Completat)
- [x] Design system și componentele UI
- [x] 10 ecrane Flutter implementate
- [x] Mock data și telemetry stream
- [x] Documentația planului de dezvoltare

#### Faza 1: Backend și API 🔄 (În curs)
- [ ] Schema PostgreSQL (users, devices, transports, readings, etc.)
- [ ] Row Level Security (RLS) per tip user
- [ ] Endpoint-uri CRUD
- [ ] Ingestie telemetrie (POST /readings)
- [ ] Logica stare (OK / ATENȚIE / CRITICĂ)
- [ ] Job detector alarme
- [ ] Sistem push notifications

#### Faza 2: Integrare Mobilă (Planificat)
- [ ] Conectare la API real (în loc de mock)
- [ ] JWT + refresh tokens
- [ ] WebSocket pentru date live
- [ ] Push notifications (FCM/APNs)
- [ ] Comportament offline
- [ ] Sincronizare locală

#### Faza 3: Web Admin (Planificat)
- [ ] Layout și autentificare admin
- [ ] Dashboard overview flotă
- [ ] Gestionare dispozitive, transportatori
- [ ] Lista și export transporturi
- [ ] Management alarme

#### Faza 4: Conformitate (Planificat)
- [ ] Engine MED-THERM-2026 (11 reglementări)
- [ ] Rapoarte PDF/CSV
- [ ] Analiză statistică (Z-Score, EMA)
- [ ] Detecție anomalii

#### Faza 5: Testare și PoC Finalizare
- [ ] Simulare date dispozitiv
- [ ] Testare scenarii alarme
- [ ] Review UX cu utilizatori reali
- [ ] Demo și documentație finală

---

## Cerințe de Conformitate — MED-THERM-2026

Sistemul trebuie să monitorizeze și să raporteze automat conformitatea cu 11 reglementări:

### 🌡️ Cerințe Termice

| Reg | Cerință | Implementare |
|-----|---------|--------------|
| REG-TEMP-1 | 2°C ≤ T ≤ 8°C în orice moment | Monitorizare continuă, alertă critică |
| REG-TEMP-2 | Max 5 min/excursie; 10 min/24h | Timer per excursie + acumulator |
| REG-TEMP-3 | Stabilizare ≤3 min după ușă | Cronometru revenire în interval |
| REG-TEMP-4 | Sampling ≤30 sec | Configurat 15 sec, alertă dacă gap > 90 sec |

### 📡 Senzori și Redundanță

| Reg | Cerință |
|-----|---------|
| REG-SENS-1 | Senzor primar + secundar obligatoriu |
| REG-SENS-3 | \|T1-T2\| ≤ 0.5°C |

### 🔔 Sistem de Alarmare

| Reg | Cerință |
|-----|---------|
| REG-ALARM-1 | Alarma la ≥2 min în afara interval |
| REG-ALARM-2 | Notificare în ≤10 sec |

### 💾 Integritate și Logging

| Reg | Cerință |
|-----|---------|
| REG-DATA-1 | Log imutabil (append-only) |
| REG-DATA-2 | Gap telemetrie ≤90 sec |
| REG-DATA-3 | Retenție locală ≥72 ore |

### 🔋 Putere și Operații

| Reg | Cerință |
|-----|---------|
| REG-POWER-1 | Backup baterie ≥4 ore |
| REG-OPS-2 | Alertă dacă > 10 deschideri/oră |

---

## Documentație și Resurse

### 📄 Fișiere în Proiect

1. **MedTrace_Go_Development_Plan.md** (83 pagini)
   - Planul complet, arhitectură, ecrane detaliate
   - Schema bazei de date
   - Toate reglementările MED-THERM-2026
   - Stack tehnologic recomandat

2. **Medical Device Regulatory Constraints.md**
   - Contextul reglementării medicale
   - Analiza riscurilor
   - Cerinții de conformitate

3. **medical_device_logs_1000.txt**
   - 1000+ înregistrări reale de telemetrie
   - Utilizate pentru mock data și testare

4. **Screenshots și Assets** (`screenshots/`)
   - Imagini din PoC
   - Referință design

### 🔗 Referințe Externe

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Supabase PostgreSQL](https://supabase.com/)

---

## 🤝 Contribuire

Codul urmează convenții strict:

- **Naming:** `camelCase` pentru variabile/funcții, `PascalCase` pentru clase
- **Widgets:** Componente mici, reutilizabile
- **Spacing/Colors:** Doar din `app_colors.dart`, `app_spacing.dart`, etc.
- **Niciun magic value:** Toate constantele în theme/
- **Comentarii:** Doar unde logica nu e evidentă

**Code style:**

```bash
# Format código
dart format lib/

# Analiza statică
dart analyze

# Lint
flutter analyze
```

---

## 📊 Status la Data 13 Mai 2026

| Artefact | Stare | Progres |
|----------|:-----:|--------:|
| Design System | ✅ Complet | 100% |
| 10 Ecrane Flutter | ✅ Complet | 100% |
| Mock Data | ✅ Complet | 100% |
| Documentație Plan | ✅ Complet | 100% |
| Backend API | 🚧 Nu a inceput | 0% |
| Baza de Date | 🚧 Nu a inceput | 0% |
| Platforma Web | 🚧 Nu a inceput | 0% |
| **PoC Global** | 🚧 50% | **50%** |

---

## 📝 Licență

MedGuard PoC — Proprietate Internă. Utilizare exclusivă pentru evaluare și dezvoltare.

---

## 👤 Contact

**Project Owner:** rdiaconu91@yahoo.com  
**Repository:** [GitHub Link]  
**Last Updated:** 14 Mai 2026

---

## 🎯 Pași Următori

1. **Backend (Săptămâna 1-2)**
   - [ ] Setup Supabase + PostgreSQL
   - [ ] Schema bază de date
   - [ ] API endpoints de bază
   - [ ] RLS per tip user

2. **Integrare Mobilă (Săptămâna 2-3)**
   - [ ] Conectare API real
   - [ ] JWT și refresh tokens
   - [ ] WebSocket telemetrie
   - [ ] Push notifications

3. **Web Admin (Săptămâna 3-4)**
   - [ ] Setup Next.js
   - [ ] Dashboard și overview
   - [ ] Management dispozitive/transportatori

4. **Rapoarte de Conformitate (Săptămâna 4-5)**
   - [ ] Engine MED-THERM-2026
   - [ ] Export PDF/CSV
   - [ ] Analiză statistică

5. **Testare și Lansare (Săptămâna 5-7)**
   - [ ] Simulare date dispozitiv
   - [ ] Testare scenarii
   - [ ] Demo și finalizare

---

**Happy Coding! 🚀**
