# Icône de l'application XScore

Ce dossier attend un fichier `icon.png` (1024×1024, fond plein — pas de
transparence pour l'icône principale) que tu fournis toi-même : je n'ai pas
d'outil de génération d'image dans cet environnement, donc je ne peux pas
dessiner l'icône à ta place.

## 1. Place ton image ici
`assets/icon/icon.png` (1024x1024px, PNG)

Optionnel — icône adaptative Android (fond + premier plan séparés,
recommandé pour un rendu propre sur tous les launchers Android) :
`assets/icon/icon_foreground.png` (transparent, sujet centré dans le tiers
central du canevas — Android recadre en cercle/carré/goutte selon le launcher)

## 2. Ajoute la dépendance dans pubspec.yaml

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#107C10"   # vert Xbox, ou une autre couleur unie
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  min_sdk_android: 21
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
  macos:
    generate: true
    image_path: "assets/icon/icon.png"
```

## 3. Génère les icônes

```bash
flutter pub get
dart run flutter_launcher_icons
```

Ça remplace automatiquement les icônes par défaut Flutter dans
`android/`, `ios/`, `windows/`, `macos/` pour toutes les résolutions.
