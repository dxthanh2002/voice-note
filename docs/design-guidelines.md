# Design Guidelines

## 1. Visual Identity

RecapIt uses a professional, high-contrast dark theme designed for productivity and clarity.

### 1.1. Color Palette

| Category | Color | Hex | Usage |
| :--- | :--- | :--- | :--- |
| **Primary** | Blue | `#137FEC` | Buttons, Active states, Branding |
| **Background** | Dark Blue | `#101922` | Scaffold background |
| **Surface** | Card Dark | `#1A2632` | Cards, Bottom sheets, Modals |
| **Text Primary** | White | `#FFFFFF` | Headings, Main content |
| **Text Secondary** | Muted Blue | `#92ADC9` | Descriptions, Secondary info |
| **Status Error** | Red | `#EF4444` | Delete actions, Errors |

### 1.2. Typography

- **Font Family**: `Inter` (Sans-serif)
- **Hierarchy**:
    - `headlineLarge`: 32pt, Bold (Onboarding titles)
    - `headlineMedium`: 24pt, Bold (Section headers)
    - `titleMedium`: 16pt, Semi-bold (Card titles)
    - `bodyLarge`: 16pt, Regular (Standard text)
    - `bodySmall`: 12pt, Regular (Muted timestamps, labels)

## 2. Component Patterns

### 2.1. Buttons
- **Primary**: Elevated, full-width, `#137FEC` background with 12px rounded corners.
- **Outlined**: Transparent background, `dividerDark` border, used for secondary actions.

### 2.2. Cards
- **Style**: No elevation, background color `#1A2632`, 12px border radius.
- **Usage**: Recording list items, settings groups.

### 2.3. Input Fields
- **Dark Mode**: Dark background with subtle borders.
- **Active State**: Primary blue border on focus.

## 3. Dark Mode Optimization

The app is **dark-first**. When implementing new screens:
- Use `AppColors.backgroundDark` for the root scaffold.
- Avoid pure black (`#000000`) for surfaces; use `AppColors.cardDark` to create depth.
- Ensure text contrast ratios follow WCAG AA standards (minimum 4.5:1).

## 4. UI Icons
- Use `CupertinoIcons` for a sleek, iOS-inspired look on both platforms.
- Active tab icons should use `AppColors.primary`.
- Inactive tab icons should use `AppColors.textMuted`.

## 5. Spacing
- Standardized spacing scale: 4, 8, 12, 16, 24, 32 pixels.
- Horizontal screen padding: **16px** (standard) or **24px** (spacious).
