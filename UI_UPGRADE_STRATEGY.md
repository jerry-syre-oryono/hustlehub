# HustleHub UI Upgrade Strategy

## 1. Theme Architecture
* **Centralized Logic**: Move theme definitions to `lib/app/theme/` with sub-files:
    * `app_colors.dart`: Define brand palette.
    * `app_typography.dart`: Define text styles using Google Fonts (Plus Jakarta Sans).
    * `app_theme.dart`: Assemble `ThemeData` for light/dark modes.
* **Material 3**: Fully leverage Material 3 features (ColorSchemes, TextTheme names).

## 2. Color Palette (Premium Purple & White)
### Light Mode:
* **Primary**: `#7C3AED` (Modern Royal Purple)
* **Secondary**: `#F472B6` (Soft Pink/Accent)
* **Background**: `#FFFFFF` (Pure White)
* **Surface**: `#FAFAFA` (Soft Light Gray)
* **Text**: `#111827` (Deep Slate)

### Dark Mode:
* **Primary**: `#A78BFA` (Vibrant Lavender)
* **Background**: `#0F0A1F` (Midnight Purple)
* **Surface**: `#1A142D` (Elevated Deep Purple)
* **Text**: `#F9FAFB` (Off-white)

## 3. Typography System (Plus Jakarta Sans)
* **Display/Heading**: Semi-Bold to Bold, tight letter spacing.
* **Body**: Medium weight for readability.
* **Buttons**: Semi-Bold, uppercase/title case for prominence.

## 4. Component Styling
* **Cards**: 20px border radius, soft multi-layered shadows (`BoxShadow`), subtle border in dark mode.
* **Buttons**: 16px radius, subtle gradients for primary buttons, scale animation on press.
* **Inputs**: 12px radius, light filled background, active glow border.
* **Bottom Nav**: Custom floating style or modern fixed with active indicator.
* **AppBar**: Minimalist, high contrast, matching surface color.

## 5. Motion & UX
* **Page Transitions**: Smooth horizontal/vertical slides.
* **Loading**: Modern shimmer effects for list items.
* **List Animation**: Staggered fade/slide-in for jobs and gigs.

## 6. Stability Strategy
* **System Tokens**: Use `context.colorScheme` and `context.textTheme` exclusively.
* **Contrast Check**: Ensure WCAG AA compliance for all text/background pairs.
* **Theme Switching**: Ensure seamless transition without UI "flicker".

---
👉 **Do you approve this UI upgrade strategy before implementation?**
