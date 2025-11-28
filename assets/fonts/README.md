# Fonts

This folder is for custom fonts. 

## Recommended Fonts

For a tower stacking game, consider using:
- **Bold, blocky fonts** for scores and titles
- **Clean sans-serif fonts** for UI text

## Free Font Resources
- [Google Fonts](https://fonts.google.com)
- [Font Squirrel](https://www.fontsquirrel.com)
- [DaFont](https://www.dafont.com)

## How to Use Custom Fonts in Godot

1. Download a .ttf or .otf font file
2. Place it in this folder
3. In your scene, select a Label node
4. In the Inspector, go to Theme Overrides > Fonts
5. Load your font file

## Example
```
assets/fonts/
├── title_font.ttf      # For game title
├── score_font.ttf      # For score display
└── ui_font.ttf         # For buttons and labels
```

The game uses Godot's default font if no custom fonts are added.
