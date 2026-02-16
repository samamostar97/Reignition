# Reignition — UI Design Rules (CLAUDE-UI.md)

> **Ovaj fajl se čita ZAJEDNO sa `CLAUDE.md`.** Agent MORA pročitati ovaj fajl prije bilo kakvog UI rada — novi screen, widget, forma, dizajn promjena.

---

## 📋 Design Decisions (SOURCE OF TRUTH)

> **Ova sekcija je prazna dok korisnik ne donese odluke. Kad se popuni, agent NIKAD više ne pita ista pitanja.**

| Odluka | Vrijednost |
|---|---|
| **Primary boja** | `#0F766E` |
| **Secondary boja** | `#F59E0B` |
| **Accent boja** | `#F59E0B` |
| **Error boja** | `#EF4444` |
| **Success boja** | `#22C55E` |
| **Warning boja** | `#F59E0B` |
| **Stil** | dashboard-heavy (Stripe) |
| **Globalna referenca** | Stripe Dashboard za desktop |
| **Dark mode** | ne |
| **Font** | Inter |
| **Icon set** | Lucide |
| **Border radius** | 8px kartice, 6px inputi, 4px badge |

---

## 🎨 UI Design Direction

### Kako Agent Koristi Design Decisions

**Ako je sekcija iznad POPUNJENA (nema `______` placeholder-a):**
- Koristi te odluke za svaki screen. NE pitaj ponovo.
- Za svaki novi screen, pogledaj **Design Reference** tabelu ispod i navedi koju referencu koristiš — ne traži dozvolu za to.
- Ako korisnik za specifičan screen kaže "hoću drugačiji pristup" — poštuj to samo za taj screen, NE mijenjaj globalne odluke.

**Ako je sekcija iznad PRAZNA (ima `______` placeholder-e):**
1. **Paleta boja** — predloži 2-3 opcije bazirane na tipu projekta. NIKAD ne biraj sam.
2. **Stil** — pitaj: minimalistički, dashboard-heavy, content-first, data-dense?
3. **Referenca** — pitaj: koji app kao polazna tačka?
4. **Dark mode** — pitaj: da li je potreban od početka?
5. **Font i ikone** — predloži default (Inter + Lucide), pitaj da li odgovara.
6. **Nakon što korisnik odgovori** — predloži da se popuni Design Decisions sekcija i ponudi konkretan popunjen sadržaj za copy-paste.

**Nikad ne biraj boje sam. Nikad ne pretpostavljaj stil bez popunjene sekcije.**

### Per-Screen UI Mini-Plan (OBAVEZNO)

**Prije nego počneš kodirati bilo koji screen, napiši kratki plan i čekaj OK.** Ovo se dešava u Fazi 4 (vidjeti `CLAUDE.md`). Plan pokriva odluke koje globalna Design Decisions tabela NE pokriva:

```
{Entity}ListScreen plan:
- Kolone: Code, Customer, Status (badge), Total, CreatedAt
- Layout: tabela, Stripe stil
- Filteri: chips iznad (status, date range)
- Akcije: row click → detail modal, ne nova stranica
- Forma: Mercury stil, side-panel dialog
- Empty state: ikona + "Nema narudžbi" + CTA "Kreiraj prvu"
OK?
```

**Šta plan MORA pokriti:**
- Koje kolone/polja od dostupnih u Response (agent NE bira sam svih 15 polja)
- Layout tip (tabela, kartice, lista, grid)
- Akcije (row click → modal vs navigacija, inline vs forma)
- Koja referenca iz Design Reference tabele
- Empty state poruka

**Šta plan NE treba pokrivati** (već je u Design Decisions):
- Boje, font, spacing, border radius, icon set

---

## 🎯 Estetski Principi — Ultra Modern, Zero AI-Giveaway

UI mora izgledati kao da ga je dizajnirao senior product designer, NE AI. **Moderan, čist, profesionalan.**

- **Čisti prostori** — obilno whitespace. Sadržaj diše, ništa nagurano.
- **Suptilna dubina** — tanak `BoxShadow` ili `Border`, jedan nivo dubine.
- **Neutralna baza** — 90% UI-a je neutral/white/slate. Boja strateški — CTA, status, aktivni elementi.
- **Tipografija nosi dizajn** — jasna hijerarhija. Font weight i size, ne boje.
- **Mikro-interakcije** — subtle hover states, smooth transitions (150-200ms). Ne flashy animacije.
- **Ikonografija** — konzistentan icon set. Nikad mix iz različitih setova.

---

## ❌ AI-Giveaway Patterns — APSOLUTNO ZABRANJENO

**Ako vidiš ovo u svom kodu, OBRIŠI:**

- Gradijenti na dugmadima (purple-to-blue, any gradient button)
- Gradient hero sekcije, gradient pozadine
- Border radius 24px+ (bubbly look) — koristiti 6-8px za kartice, 4-6px za inpute
- Neon glow efekti (`boxShadow` sa bright color i `blurRadius: 20`)
- "Welcome to {App}" gigantski hero tekst
- Šarene kartice — svaka drugačija boja
- Drop shadows na svemu (Material 2 stil sa elevation: 4+)
- Rounded avatar sa gradient border
- Card sa icon + title + subtitle + button layout koji svi AI generišu identično
- Pretjerano korištenje primary boje — 90% UI-a je NEUTRALNO

```dart
// ✅ Subtle, professional card
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    border: Border.all(color: Theme.of(context).dividerColor),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: Offset(0, 1))],
  ),
)

// ✅ Flat button, NO gradient, NO glow
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  ),
)
```

---

## 🖼️ Design Reference — Per-Screen (AUTOMATSKI)

**Agent MORA za svaki novi screen pogledati ovu tabelu i navesti koju referencu koristi.** Ovo ne zahtijeva korisnikovu dozvolu — agent samo kaže _"Radim tabelu narudžbi, koristim Stripe stil"_ i nastavlja. Korisnik može override-ovati ako želi drugačiji pristup za specifičan screen.

**Prije nego kreneš raditi UI na nekom screen-u, pogledaj 1-2 reference za taj tip screen-a.**

### Dashboard / Admin (Desktop)

| App | Šta uzeti | Pogledaj za |
|---|---|---|
| **Linear.app** | Najčišći UI. Keyboard-first, monochrome + jedna accent boja | Sidebar navigacija, liste, task kartice |
| **Vercel Dashboard** | Crno-bijelo, data-dense bez cluttera | Tabele, deployment kartice, minimalna boja |
| **Stripe Dashboard** | Gold standard za admin panele | Tabele, filteri, kartice, forme, data prikaz |
| **Supabase Dashboard** | Developer tool sa odličnim tabelama | Table design, forme, SQL editor layout |

### Mobile

| App | Šta uzeti | Pogledaj za |
|---|---|---|
| **Revolut** | Clean finance, odličan card design, smooth transitions | Kartice, liste, transaction prikaz |
| **Airbnb** | Content-first, photography-driven, minimalan chrome | Search, listing kartice, detalji |
| **Monzo** | Banking sa personality, odlični empty states | Onboarding, empty states, feedback UI |

### Specifični Elementi — Koji Stil Za Šta

| Element | Referenca | Ključno |
|---|---|---|
| **Tabele** | Stripe | Header sa light bg, subtle row dividers, no cell borders |
| **Forme** | Mercury banking | Wide inputi, jasni labeli, inline validation |
| **Kartice** | Linear | 1px border, 0 elevation, hover = subtle bg change |
| **Navigacija** | Vercel | Sidebar sa ikonama, clean hierarchy, accent active state |
| **Empty states** | Notion | Ilustracija + kratka poruka + CTA dugme |
| **Loading** | Stripe | Skeleton screens umjesto spinnera (za liste) |
| **Snackbari** | Vercel | Toast notification, minimalan, auto-dismiss |

---

## 🎨 Theme — Centralized Design Tokens

> **Boje ispod popuni iz Design Decisions tabele na vrhu.** Ako tabela nije popunjena, NE generiši temu — pitaj korisnika prvo.

```dart
ThemeData lightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF______),       // ← iz Design Decisions: Primary boja
    onPrimary: Colors.white,
    secondary: Color(0xFF______),     // ← iz Design Decisions: Secondary boja
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111827),
    surfaceContainerHighest: Color(0xFFF8F9FA),
    error: Color(0xFFEF4444),         // ← iz Design Decisions: Error boja
    outline: Color(0xFFE2E4E9),
    outlineVariant: Color(0xFFF0F1F3),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  ),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: Color(0xFFE2E4E9)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  ),
  dividerTheme: const DividerThemeData(thickness: 1, space: 1),
);
```

---

## 📐 Spacing — Strict Token System

```dart
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}
```

**SAMO ove vrijednosti. Nikad 13, 17, 22.** Spacing mora biti konzistentan kroz cijeli app.

### Korištenje

```dart
// ✅
Padding(padding: EdgeInsets.all(AppSpacing.md))
SizedBox(height: AppSpacing.sm)
EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md)

// ❌
Padding(padding: EdgeInsets.all(15))
SizedBox(height: 10)
```

---

## 📱 Responsiveness & Overflow Prevention (CRITICAL)

**Nijedan screen ne smije imati RenderFlex overflow. Ikad.**

### Mandatory Rules

| Situacija | ❌ Nikad | ✅ Uvijek |
|---|---|---|
| Lista u Column | `Column(children: [ListView()])` | `Column(children: [Expanded(child: ListView())])` |
| Tekst u Row | `Row(children: [Text(longText)])` | `Row(children: [Flexible(child: Text(t, overflow: TextOverflow.ellipsis))])` |
| Fiksna širina | `Container(width: 400)` | `ConstrainedBox(constraints: BoxConstraints(maxWidth: 400))` |
| Expanded u scroll | `ScrollView(Column(Expanded(...)))` | `ScrollView(Column(SizedBox(height: 300, ...)))` |
| Slika bez ograničenja | `Image.network(url)` | `Image.network(url, fit: BoxFit.cover, width/height: ..., errorBuilder: ...)` |

### Breakpoints

- **Desktop:** `LayoutBuilder` → `< 600` mobile, `< 1100` tablet, else desktop
- **Mobile:** svaki screen: `Scaffold → SafeArea → SingleChildScrollView → Content`
- **Keyboard:** forme moraju imati `SingleChildScrollView` + `viewInsets.bottom`
- **Tables:** `SingleChildScrollView(scrollDirection: Axis.horizontal)`
- **Text:** dynamic content MORA imati `overflow: TextOverflow.ellipsis` + `maxLines`

---

## 🖥️ UI Mandatory Patterns

### 1. State Triada — Loading / Error / Empty / Data (SVAKI SCREEN)

```dart
if (state.isLoading && state.items == null) → CircularProgressIndicator
if (state.error != null && state.items == null) → error + retry button
if (state.items != null && state.items!.isEmpty) → empty state (razlikuj "nema podataka" vs "nema rezultata")
else → data + LinearProgressIndicator ako refreshuje
```

**Empty state pravila:**
- Razlikuj "Nema podataka" (prvi put) vs "Nema rezultata za '{search}'" (filtrirano)
- Empty state uvijek ima: ilustracija/ikona + kratka poruka + CTA dugme (kad je primjenjivo)
- Reference: Notion empty states

### 2. Search — 400ms Debounce (OBAVEZNO)

```dart
Timer? _debounce;

void _onSearchChanged(String value) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 400), () {
    ref.read(entityListProvider.notifier).setSearch(value);
  });
}

@override
void dispose() {
  _debounce?.cancel();
  _searchController.dispose();
  super.dispose();
}
```

Clear button (X) u search polju. `dispose()` MORA cancelovati timer i controller.

### 3. Delete Confirmation (OBAVEZNO)

```dart
Future<bool> showDeleteConfirmation(BuildContext context, String itemName) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Potvrda brisanja'),
      content: Text('Da li ste sigurni da želite obrisati "$itemName"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Obriši'),
        ),
      ],
    ),
  );
  return result ?? false;  // dismiss = cancel
}
```

### 4. Unified Feedback — Animirani Success / Error (SVAKA MUTACIJA)

**Svaka mutacija (create, update, delete) MORA imati animirani feedback.** Projekt koristi JEDINSTVEN feedback sistem — isti izgled i ponašanje svugdje, desktop i mobile.

#### Princip

- **Jedna `AppSnackbars` klasa** za cijeli projekat — nikad ručni `ScaffoldMessenger` pozivi u widgetima
- **Animirana ikona** — success ✓ sa scale-in animacijom, error ✕ sa shake animacijom
- **Opisna poruka** — nikad generička "Greška" ili "Uspjeh". Uvijek konkretno šta se desilo:
  - ✅ `"Narudžba uspješno kreirana."` · `"Kategorija ažurirana."` · `"Korisnik obrisan."`
  - ❌ `"Kategorija sa ovim imenom već postoji."` · `"Ne možete obrisati jer ima povezane stavke."`
- **Error poruke dolaze sa backenda** — nikad hardkodirane na frontendu (osim za network/timeout errore)

#### AppSnackbars — Jedinstvena Klasa

```dart
// widgets/shared/app_snackbars.dart
abstract class AppSnackbars {
  /// Success — zelena ikona sa scale animacijom, 3s auto-dismiss
  static void success(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.success);
  }

  /// Error — crvena ikona sa shake animacijom, 5s + dismiss button
  static void error(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.error);
  }

  /// Warning — amber ikona, 4s auto-dismiss
  static void warning(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.warning);
  }

  /// Info — plava ikona, 3s auto-dismiss
  static void info(BuildContext context, String message) {
    _show(context, message: message, type: _SnackbarType.info);
  }

  static void _show(BuildContext context, {
    required String message,
    required _SnackbarType type,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();  // UVIJEK sakrij prethodni

    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: type.backgroundColor,
      duration: type.duration,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: type == _SnackbarType.error
          ? SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {})
          : null,
      content: Row(
        children: [
          _AnimatedIcon(type: type),  // Animirana ikona
          SizedBox(width: AppSpacing.sm),
          Flexible(child: Text(message, style: TextStyle(color: Colors.white))),
        ],
      ),
    ));
  }
}

enum _SnackbarType {
  success(Color(0xFF22C55E), Duration(seconds: 3), Icons.check_circle_rounded),
  error(Color(0xFFEF4444), Duration(seconds: 5), Icons.error_rounded),
  warning(Color(0xFFF59E0B), Duration(seconds: 4), Icons.warning_rounded),
  info(Color(0xFF3B82F6), Duration(seconds: 3), Icons.info_rounded);

  final Color backgroundColor;
  final Duration duration;
  final IconData icon;
  const _SnackbarType(this.backgroundColor, this.duration, this.icon);
}
```

#### Animirana Ikona — Detalji

```dart
// Success: scale 0 → 1 sa elastic curve (300ms)
// Error: shake animacija — translateX oscilacija (400ms)
// Warning/Info: fade-in (200ms)
class _AnimatedIcon extends StatefulWidget {
  // Implementacija koristi AnimationController + CurvedAnimation
  // MORA biti lightweight — ne kompleksna Lottie/Rive animacija
}
```

#### Korištenje u Widgetima

```dart
// SVAKA mutacija — UVIJEK provjeri mounted
Future<void> _createOrder(CreateOrderRequest request) async {
  try {
    await ref.read(orderListProvider.notifier).create(request);
    if (mounted) {
      Navigator.pop(context);
      AppSnackbars.success(context, 'Narudžba uspješno kreirana.');
    }
  } on ApiException catch (e) {
    // Backend poruka — NIKAD hardkodirana
    if (mounted) AppSnackbars.error(context, e.message);
  }
}

// Delete — nakon potvrde
Future<void> _deleteOrder(int id, String code) async {
  final confirmed = await showDeleteConfirmation(context, code);
  if (!confirmed) return;
  try {
    await ref.read(orderListProvider.notifier).delete(id);
    if (mounted) AppSnackbars.success(context, 'Narudžba $code obrisana.');
  } on ApiException catch (e) {
    if (mounted) AppSnackbars.error(context, e.message);
  }
}
```

#### Pravila

| Pravilo | Detalj |
|---|---|
| **Jedna klasa** | `AppSnackbars.success/error/warning/info` — nikad direktni `ScaffoldMessenger` |
| **hideCurrentSnackBar()** | UVIJEK prije novog — sprječava gomilanje |
| **mounted check** | OBAVEZNO prije svakog poziva nakon async |
| **Error poruke sa backenda** | `e.message` iz `ApiException` — NIKAD hardkodirane poruke za API greške |
| **Opisne success poruke** | Specifično šta je urađeno: "Kategorija 'Elektronika' kreirana." — NE "Uspješno!" |
| **Network error** | Jedini slučaj kad je poruka hardkodirana: `"Nema internet konekcije."`, `"Server nije dostupan."` |
| **Floating behavior** | Uvijek `SnackBarBehavior.floating` sa `margin` — nikad full-width stuck na dnu |
| **Isti izgled** | Desktop i mobile koriste ISTU `AppSnackbars` klasu iz core ili shared widgeta |
| **Animacija lightweight** | `AnimationController` + `Transform` — NIKAD Lottie/Rive za snackbar ikone |

### 5. Forms — Create & Edit

- **Jedan form widget** — `item` null = create, non-null = edit
- Pre-populate SVA polja za edit
- Validate on submit sa `FormValidators.compose()`
- Dispose SVE controllere
- Button tekst: "Kreiraj" vs "Sačuvaj izmjene"
- **Validacije MORAJU odgovarati backend Data Annotations** (Contract Sync)

### 6. Refresh After Mutation

Provider `create/update/delete` UVIJEK zove `load()`. Rethrow exception → widget snackbar. Formu zatvori SAMO na success.

---

## 🎯 Component Patterns

### Tabele (Desktop) — Stripe Stil

```dart
// Header
Container(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
  ),
  child: Row(children: [/* header cells */]),
)

// Rows — subtle dividers, no cell borders, hover state
InkWell(
  onTap: () => /* navigate to detail */,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
    ),
    child: Row(children: [/* cells */]),
  ),
)
```

### Kartice — Linear Stil

```dart
Container(
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    border: Border.all(color: Theme.of(context).colorScheme.outline),
    borderRadius: BorderRadius.circular(8),
  ),
  // hover: subtle bg change through InkWell or MouseRegion
)
```

### Status Badge

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
  decoration: BoxDecoration(
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(statusText, style: TextStyle(
    color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
)
```

### Loading — Skeleton Screens za Liste

```dart
// Za tabele i liste — skeleton umjesto spinnera
// Spinner SAMO za initial page load ili modal actions
// Skeleton = Container sa shimmer animacijom matching row layout
```

---

## 🎨 Color Usage Rules

### Semantičke Boje (kroz Theme)

| Namjena | Token | Koristi za |
|---|---|---|
| Primarna akcija | `colorScheme.primary` | CTA dugmad, aktivni tab, linkovi |
| Površina | `colorScheme.surface` | Card background, dialog bg |
| Tekst | `colorScheme.onSurface` | Primary text |
| Suptilni tekst | `colorScheme.onSurface.withOpacity(0.6)` | Secondary text, hints |
| Greška | `colorScheme.error` | Delete, error states |
| Granica | `colorScheme.outline` | Card borders, dividers |
| Suptilna granica | `colorScheme.outlineVariant` | Row dividers |
| Hover / Selected bg | `colorScheme.surfaceContainerHighest` | Table header, hover |

### Status Boje — Iz Design Decisions

```dart
// Vrijednosti iz Design Decisions tabele na vrhu ovog fajla
abstract class StatusColors {
  static const Color success = Color(0xFF22C55E);  // ← Design Decisions: Success
  static const Color warning = Color(0xFFF59E0B);  // ← Design Decisions: Warning
  static const Color error = Color(0xFFEF4444);    // ← Design Decisions: Error
  static const Color info = Color(0xFF3B82F6);
  static const Color neutral = Color(0xFF6B7280);
}
```

**Pravilo:** NIKAD hardkodirane boje u widgetima. Uvijek `Theme.of(context)` ili definisane konstante.

---

## 📐 Layout Patterns

### Desktop — Sidebar + Content

```dart
Row(
  children: [
    // Sidebar — fixed width
    SizedBox(
      width: 240,
      child: NavigationSidebar(),
    ),
    // Vertical divider
    VerticalDivider(width: 1),
    // Content — expanded
    Expanded(
      child: Column(
        children: [
          TopBar(),           // breadcrumb, user menu
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: screenContent,
            ),
          ),
        ],
      ),
    ),
  ],
)
```

### Mobile — Standard Scaffold

```dart
Scaffold(
  appBar: AppBar(title: Text('Screen Title')),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: content,
    ),
  ),
)
```

### Screen Header Pattern (Desktop)

```dart
// Svaki list screen ima: Title + Action button + Search/Filters
Row(
  children: [
    Text('Narudžbe', style: Theme.of(context).textTheme.headlineSmall),
    const Spacer(),
    ElevatedButton.icon(
      onPressed: _openCreateDialog,
      icon: Icon(Icons.add),
      label: Text('Nova narudžba'),
    ),
  ],
)
SizedBox(height: AppSpacing.md),
// Search bar + filter chips
```

---

## ✅ Pre-UI Checklist

Prije nego pustiš bilo koji UI kod:

**Design Decisions:**
- [ ] Design Decisions tabela je popunjena (nema `______` placeholder-a) — ako nije, PITAJ prvo
- [ ] Boje samo kroz `Theme.of(context)` ili `StatusColors` konstante — nikad hardkodirane
- [ ] Spacing samo `AppSpacing` — nikad magic numbers
- [ ] Border radius konzistentan sa Design Decisions (default: 6-8px)
- [ ] Ikone iz seta definisanog u Design Decisions — nikad mix

**Per-Screen Reference:**
- [ ] Pogledana referenca za tip screen-a (tabela → Stripe, forma → Mercury, itd.)
- [ ] Navedena referenca u komentaru: _"Koristim Stripe stil za tabelu"_

**Anti-AI:**
- [ ] Zero gradijenti (osim ako korisnik eksplicitno traži)
- [ ] Elevation 0 ili minimalna
- [ ] Nijedan element ne izgleda "AI-generated"
- [ ] 90% UI-a neutralno, boja samo strateški

**Funkcionalnost:**
- [ ] 4 stanja pokrivena (loading / error / empty / data)
- [ ] Empty states sa ikonom + porukom + CTA (razlikuj "nema podataka" vs "nema rezultata")
- [ ] Search ima 400ms debounce
- [ ] Delete ima potvrdu
- [ ] Snackbar nakon svake mutacije
- [ ] Typography hijerarhija jasna (max 5-6 veličina iz `textTheme`)
- [ ] Hover suptilni

**Responsiveness:**
- [ ] Zero RenderFlex overflow
- [ ] Responsive na min/max širinama
- [ ] Keyboard ne pokriva forme
- [ ] Text sa dynamic content ima ellipsis + maxLines
