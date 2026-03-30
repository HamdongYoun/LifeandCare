# Premium UI Design Specification

This document defines the visual and interactive standards for the "Life & Care" platform, inspired by leading healthcare apps like Goodoc, Dr. Now, and My Doctor.

## 1. Design Philosophy
- **Trust & Clarity**: Use clean whitespace and professional colors to instill confidence.
- **Accessibility First**: High contrast, large touch targets, and readable typography for all age groups.
- **Fluid Response**: Smooth transitions and real-time feedback (animations) as requested.

## 2. Color Palette
| Name | Hex | Usage |
| :--- | :--- | :--- |
| Primary Blue | `#3B82F6` | Primary buttons, active tab icons, brand accents. |
| Emergency Red | `#EF4444` | Emergency alerts, critical warnings. |
| Background Gray | `#F9FAFB` | App background, secondary containers. |
| Pure White | `#FFFFFF` | Cards, input fields, primary text background. |
| Text Primary | `#111827` | Headings, main body text. |
| Text Secondary | `#6B7280` | Subtitles, labels, timestamps. |

## 3. Typography
- **Primary Font**: `Outfit` or `Inter` (Sans-serif).
- **Scale**:
  - H1: 24px (Bold)
  - H2: 20px (Semi-bold)
  - Body: 16px (Regular)
  - Caption: 14px (Regular)

## 4. Components

### 4.1. Navigation Bar (Bottom)
- **Position**: Fixed at the bottom.
- **Items**: Chat, Map, Health, Settings.
- **Active State**: Primary Blue icon + subtle label scale.

### 4.2. Chat Interface
- **Bubble Style**: 
  - User: Blue background, white text, top-right sharp corner.
  - AI: Light gray background, dark text, top-left sharp corner.
- **Input Area**: Pill-shaped input field with a floating "Send" button.

### 4.3. Hospital Card
- **Layout**: Image (left), Details (right).
- **Shadow**: `0 4px 6px -1px rgb(0 0 0 / 0.1)`.
- **Corner Radius**: `16px`.

## 5. Interactions
- **Tab Switching**: Cross-fade transition (300ms).
- **Message Appearance**: Slide up + Fade in (400ms).
- **Emergency Trigger**: Pulsing red overlay + 3s countdown.
