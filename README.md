# 🌳 Family Tree App — Flutter

A beautiful, feature-rich family tree application built with Flutter.

## ✨ Features

### Tree Management
- **Add Person** — Add family members with name, gender, birth/death dates, and notes
- **Add Child** — Add a new child to any selected person
- **Add Wife/Spouse** — Add a new spouse or link an existing person as spouse
- **Link** — Link any two people as parent-child
- **Unlink** — Remove parent-child or spouse relationships

### Selection & Focus Mode
- **Click a person once** → selects them and shows only them + their immediate relatives (parents, spouse, siblings, children)
- **Click again** → opens the detail panel
- **Show All** button → reveals the full tree

### Layout Templates (4 options)
| Template | Description |
|---|---|
| 🔼 Vertical Tree | Classic top-down genealogy tree |
| ↔️ Horizontal Tree | Left-to-right flow |
| 📜 Genealogy List | Card-based list view |
| 🫧 Radial View | Organic centered layout |

### Import / Export
- **Import**: Load `.json` or `.ftree` family tree files
- **Export**: Save your tree as JSON, shareable across devices

### Other Features
- Interactive pan & zoom with `InteractiveViewer`
- Stats panel (total members, generations, living count)
- Spouse connections shown in pink with ♥
- Deceased members marked with ⭐
- Sample data loader for quick demo

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+

### Installation

```bash
cd family_tree_app
flutter pub get
flutter run
```

Supports: **Android, iOS, macOS, Windows, Linux, Web**

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── person.dart              # Person & FamilyTree data models
├── providers/
│   └── family_tree_provider.dart # State management (ChangeNotifier)
├── screens/
│   └── home_screen.dart         # Main screen with tree canvas
├── widgets/
│   ├── person_card.dart          # Individual person node card
│   ├── person_detail_panel.dart  # Bottom sheet detail + action buttons
│   ├── tree_painter.dart         # CustomPainter for connecting lines + layout algorithms
│   └── dialogs.dart             # Add/Edit person dialogs, link dialog
└── utils/
    └── import_export.dart        # File import/export logic
```

---

## 🎮 Usage Guide

### Adding Your First Person
1. Launch the app (empty state with "Add Person" prompt)
2. Click **"Add Person"** in the top bar
3. Fill in the name, gender, and optional birth year
4. Click **"Add"**

### Building the Tree
- Select a person → tap **"Add Child"** in the detail panel
- Tap **"Add/Link Spouse"** → choose to add new or link existing
- Tap **"Link as Child of..."** to attach someone to a parent

### Navigating
- **Pinch/scroll** to zoom
- **Drag** to pan
- **+/-** buttons bottom-right to zoom in/out
- **⊙** button to reset view

### Saving Your Work
- Tap **Export** in the sidebar → saves as JSON
- To restore: tap **Import** and select your JSON file

---

## 📦 Dependencies

```yaml
provider: ^6.1.1         # State management
uuid: ^4.3.3             # Unique IDs for persons
file_picker: ^8.0.0+1    # Import files
share_plus: ^9.0.0       # Share/export on mobile
path_provider: ^2.1.2    # File paths
```

---

## 🎨 Design

- Dark theme with forest green (`#2C6E49`) and cream accents
- Male nodes: deep navy blue
- Female nodes: deep rose/plum
- Selected nodes: glowing emerald green
- Connections: warm brown lines for parent-child, pink for spouses
- Background: subtle grid pattern
# seiph
