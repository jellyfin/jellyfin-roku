# Background Overlay Style Examples

This document provides examples of different overlay configurations you can use to customize the appearance of your random movie backgrounds.

## Default Style
- **Opacity**: 0.94 (94% opacity)
- **Color**: 0x000000 (Pure black)
- **Effect**: Strong overlay that provides excellent text readability with noticeable background image ambiance

## Complete Overlay Style
- **Opacity**: 1.0 (100% opacity)
- **Color**: 0x000000 (Pure black)
- **Effect**: Complete overlay with no background image visibility, pure black background

## High Contrast Style
- **Opacity**: 0.9 (90% opacity)
- **Color**: 0x000000 (Pure black)
- **Effect**: Very strong darkening for excellent text readability, minimal background image visibility

## Medium Style
- **Opacity**: 0.6 (60% opacity)
- **Color**: 0x000000 (Pure black)
- **Effect**: Moderate darkening that balances image visibility with text readability

## Subtle Style
- **Opacity**: 0.4 (40% opacity)
- **Color**: 0x000000 (Pure black)
- **Effect**: Light darkening that preserves most of the original image brightness while providing text contrast

## Blue Tint Style
- **Opacity**: 0.3 (30% opacity)
- **Color**: 0x001133 (Dark blue)
- **Effect**: Adds a cinematic blue tint while maintaining readability

## Warm Style
- **Opacity**: 0.3 (30% opacity)
- **Color**: 0x221100 (Dark orange/brown)
- **Effect**: Adds a warm, cozy feeling with slight sepia tones

## No Overlay Style
- **Opacity**: 0.0 (0% opacity)
- **Color**: Any (not visible)
- **Effect**: Shows the original movie backdrop without any overlay

## Configuration Examples

To apply these styles, set the following user settings:

### Default (Recommended)
```
backgroundOverlayOpacity: 0.94
backgroundOverlayColor: "0x000000"
```

### Complete Overlay
```
backgroundOverlayOpacity: 1.0
backgroundOverlayColor: "0x000000"
```

### High Contrast
```
backgroundOverlayOpacity: 0.9
backgroundOverlayColor: "0x000000"
```

### Medium
```
backgroundOverlayOpacity: 0.6
backgroundOverlayColor: "0x000000"
```

### Subtle
```
backgroundOverlayOpacity: 0.4
backgroundOverlayColor: "0x000000"
```

### Blue Tint
```
backgroundOverlayOpacity: 0.3
backgroundOverlayColor: "0x001133"
```

### Warm
```
backgroundOverlayOpacity: 0.3
backgroundOverlayColor: "0x221100"
```

### No Overlay
```
backgroundOverlayOpacity: 0.0
backgroundOverlayColor: "0x000000"
```

## Tips

1. **Text Readability**: Higher opacity values (0.8-1.0) work better for ensuring UI text is readable over busy backgrounds
2. **Image Preservation**: Lower opacity values (0.2-0.6) preserve more of the original movie backdrop's visual impact
3. **Color Choice**: Dark colors work best for overlays; avoid bright colors that might clash with the UI
4. **Testing**: Try different settings with various movie backdrops to find your preferred balance
5. **Strong Coverage**: 92% opacity provides excellent readability while allowing more noticeable background image details to enhance the visual experience
