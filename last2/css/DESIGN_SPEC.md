# Cookify Global - CSS Design Specification

## 1. Color Palette

### Primary Colors
- **Brand Primary**: `#D4AF37` (Gold/Amber) - Premium, luxury feel
- **Brand Secondary**: `#1a1a1a` (Near Black) - Sophisticated, professional
- **Accent**: `#E8D5B7` (Light Gold) - Highlights, hover states

### Background Colors
- **Page Background**: `#ffffff` (White) - Clean, minimal
- **Section Background**: `#f9f8f5` (Off-white/Cream) - Subtle contrast
- **Card Background**: `#ffffff` (White)
- **Footer Background**: `#1a1a1a` (Dark Grey/Black)

### Text Colors
- **Primary Text**: `#1a1a1a` (Near Black) - High contrast
- **Secondary Text**: `#666666` (Mid Grey) - Supporting content
- **Light Text**: `#ffffff` (White) - On dark backgrounds
- **Muted Text**: `#999999` (Light Grey) - Disabled/inactive states

### Status/Alert Colors
- **Sale/Discount**: `#e74c3c` (Red) - Attention, urgency
- **Rating Stars**: `#ffc107` (Bright Yellow) - Positive feedback
- **Success**: `#27ae60` (Green) - Confirmations
- **Info**: `#3498db` (Blue) - Information
- **Hover State**: `#D4AF37` with 0.9 opacity - Subtle elevation

---

## 2. Typography

### Font Families
- **Headings**: Poppins, Montserrat, or system sans-serif (modern, bold)
- **Body Text**: Inter, Segoe UI, or system sans-serif (clean, readable)
- **Fallback**: -apple-system, BlinkMacSystemFont, sans-serif

### Typography Scale

#### Headings
```
h1: 48px / 3rem | Weight: 700 | Line-height: 1.2 | Letter-spacing: -0.02em
h2: 36px / 2.25rem | Weight: 600 | Line-height: 1.3 | Letter-spacing: -0.015em
h3: 28px / 1.75rem | Weight: 600 | Line-height: 1.4
h4: 24px / 1.5rem | Weight: 600 | Line-height: 1.4
h5: 20px / 1.25rem | Weight: 500 | Line-height: 1.5
h6: 16px / 1rem | Weight: 500 | Line-height: 1.5
```

#### Body Text
```
Body (Default): 16px / 1rem | Weight: 400 | Line-height: 1.6
Body (Small): 14px / 0.875rem | Weight: 400 | Line-height: 1.5
Body (Extra Small): 12px / 0.75rem | Weight: 400 | Line-height: 1.4
```

#### Special Elements
```
Button Text: 16px / 1rem | Weight: 600 | Text-transform: none
Label: 14px / 0.875rem | Weight: 500 | Letter-spacing: 0.02em
Price (Product): 24px / 1.5rem | Weight: 700 | Color: #D4AF37
Discount Price: 14px / 0.875rem | Weight: 400 | Text-decoration: line-through
Rating: 14px / 0.875rem | Weight: 500
```

---

## 3. Layout & Structure

### Header/Navigation
- **Height**: 70px (desktop), 60px (mobile)
- **Position**: Sticky/fixed at top
- **Logo**: 40px height, padding: 15px 20px
- **Logo Font**: 24px, weight 700, color #1a1a1a
- **Navigation Links**: 
  - Desktop: Horizontal flex row, gap: 40px, padding: 20px 0
  - Mobile: Hamburger menu, vertical stack
- **Link Styling**: 16px, weight 500, color #1a1a1a, hover color #D4AF37
- **Cart Icon**: 24px size, position: absolute right 20px
- **Login Link**: 16px, weight 500, margin-right: 30px

### Hero Section
- **Height**: 500px (desktop), 300px (mobile)
- **Background**: High-quality product image, background-size: cover, background-position: center
- **Overlay**: Optional semi-transparent black (rgba(26, 26, 26, 0.3))
- **Content Alignment**: Center or bottom-left
- **Text Overlay**:
  - Main heading: h1 (48px), color white or #1a1a1a
  - Subheading: h3 (28px), color #D4AF37
  - Padding: 80px 40px (desktop), 40px 20px (mobile)

### Feature Strip (3 Layer Coating, PFOA Free, etc.)
- **Layout**: Horizontal scrolling carousel or grid
- **Item**: Center text, width 100%, padding 20px
- **Text**: 16px weight 600, color #1a1a1a, centered
- **Animation**: Marquee/scroll loop (infinite)
- **Height**: 60px
- **Background**: #f9f8f5 or white
- **Border**: 1px solid #e0d5c7

### Product Grid
- **Container Padding**: 40px (desktop), 20px (mobile), 20px (tablet)
- **Grid Layout**:
  - Desktop (1200px+): 4 columns, gap 24px
  - Tablet (768px-1199px): 2-3 columns, gap 20px
  - Mobile (<768px): 1-2 columns, gap 16px
- **Product Card Width**: Responsive (100% of column)
- **Section Margin**: 60px top/bottom (desktop), 40px (mobile)
- **Section Padding**: 0 40px (desktop), 0 20px (mobile)

### Product Cards
- **Height**: Auto (flexible based on content)
- **Background**: White
- **Border**: None
- **Shadow**: 0 2px 8px rgba(0,0,0,0.1)
- **Border Radius**: 4px
- **Padding**: 0 (no internal padding, image full width)
- **Hover Effect**: 
  - Box-shadow: 0 8px 16px rgba(0,0,0,0.15)
  - Transform: translateY(-4px)
  - Transition: all 0.3s ease
- **Image Container**:
  - Height: 240px (desktop), 180px (mobile)
  - Background: #f9f8f5
  - Overflow: hidden
  - Border-radius: 4px 4px 0 0
- **Content Area**:
  - Padding: 16px
- **Product Title**: 16px, weight 500, line-height 1.4, color #1a1a1a, max-lines 2
- **Rating Stars**: 14px, color #ffc107, margin 8px 0
- **Review Count**: 12px, weight 400, color #999999
- **Price Section**:
  - Original Price: 14px, text-decoration line-through, color #999999
  - Sale Price: 24px, weight 700, color #D4AF37
  - Discount Badge: "Sale" label, position absolute top-right, background #e74c3c, color white, padding 6px 12px, border-radius 4px

### Footer
- **Background**: #1a1a1a
- **Text Color**: #ffffff
- **Layout**: Grid, responsive
  - Desktop: 4 columns, gap 40px
  - Mobile: 1 column, gap 20px
- **Padding**: 60px 40px 30px (desktop), 40px 20px (mobile)
- **Sections**: Company Info, Quick Links, Policies, Social
- **Link Styling**: 14px, weight 400, color rgba(255,255,255,0.8), hover color #D4AF37
- **Social Icons**: 24px, horizontal flex, gap 15px, margin-top 15px
- **Bottom Border**: 1px solid rgba(255,255,255,0.1)
- **Copyright Text**: 12px, weight 400, color rgba(255,255,255,0.6), padding-top 30px, text-align center

---

## 4. Buttons & UI Components

### Primary Button
```
.btn-primary {
  background-color: #D4AF37;
  color: #1a1a1a;
  padding: 12px 32px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  text-transform: none;
  transition: all 0.3s ease;
}

.btn-primary:hover {
  background-color: #c49d2e;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(212, 175, 55, 0.3);
}

.btn-primary:active {
  transform: translateY(0);
  box-shadow: 0 2px 6px rgba(212, 175, 55, 0.2);
}
```

### Secondary Button
```
.btn-secondary {
  background-color: transparent;
  color: #1a1a1a;
  border: 2px solid #1a1a1a;
  padding: 10px 30px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background-color: #1a1a1a;
  color: #ffffff;
  border-color: #1a1a1a;
}
```

### Add to Cart Button
```
.btn-add-to-cart {
  background-color: #1a1a1a;
  color: #ffffff;
  width: 100%;
  padding: 14px 20px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s ease;
  margin-top: 12px;
}

.btn-add-to-cart:hover {
  background-color: #333333;
}

.btn-add-to-cart:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
  opacity: 0.6;
}
```

### Product Card
- **Box Shadow**: `0 2px 8px rgba(0,0,0,0.1)`
- **Hover Shadow**: `0 8px 16px rgba(0,0,0,0.15)`
- **Transition**: `all 0.3s cubic-bezier(0.4, 0, 0.2, 1)`
- **Border Radius**: 4px
- **Hover Transform**: `translateY(-4px)`

---

## 5. Spacing / Design System

### Spacing Scale
```
0: 0px
2: 2px
4: 4px
6: 6px
8: 8px
12: 12px
16: 16px
20: 20px
24: 24px
28: 28px
32: 32px
40: 40px
48: 48px
60: 60px
80: 80px
100: 100px
```

### Component Spacing
- **Page Margin**: 40px (desktop), 20px (mobile), 24px (tablet)
- **Section Padding**: 60px 40px (desktop), 40px 20px (mobile)
- **Card Padding**: 16px (inside), 24px (section margin)
- **Element Gap (Grid)**: 24px (desktop), 16px (mobile), 20px (tablet)
- **Form Input Spacing**: 16px gap between fields
- **Button Horizontal Padding**: 20-32px
- **Button Vertical Padding**: 10-14px
- **Button-to-Button Gap**: 12px

---

## 6. Effects

### Box Shadows
```
Light: 0 2px 4px rgba(0, 0, 0, 0.08)
Medium: 0 2px 8px rgba(0, 0, 0, 0.1)
Card Hover: 0 8px 16px rgba(0, 0, 0, 0.15)
Button Hover: 0 4px 12px rgba(212, 175, 55, 0.3)
Elevated: 0 8px 24px rgba(0, 0, 0, 0.12)
```

### Border Radius
```
None: 0px
Small: 2px
Default: 4px
Medium: 6px
Large: 8px
Full: 9999px (for pills)
```

### Transitions & Animations
```
Fast: 0.15s ease
Standard: 0.3s ease
Slow: 0.6s ease
Easing: cubic-bezier(0.4, 0, 0.2, 1) (smooth, material-inspired)
```

### Specific Effects
- **Link Hover**: Color change to #D4AF37, underline appears (optional)
- **Button Hover**: Slight shadow increase, subtle scale (1.02x)
- **Card Hover**: Lift effect with box-shadow, subtle translateY
- **Image Hover**: Slight zoom (1.05x), smooth transition
- **Scroll Animation**: Fade-in for cards entering viewport (optional, modern)

---

## 7. Responsive Design

### Breakpoints
```
Mobile: 320px - 479px
Small Mobile: 480px - 639px
Tablet: 640px - 1023px (up to 768px traditionally)
Desktop: 1024px+ (1200px+)
Large Desktop: 1440px+
```

### Responsive Adjustments

#### Typography
```
Desktop (1024px+):
- h1: 48px
- h2: 36px
- h3: 28px
- Body: 16px

Tablet (640px-1023px):
- h1: 40px
- h2: 32px
- h3: 24px
- Body: 15px

Mobile (<640px):
- h1: 32px
- h2: 28px
- h3: 20px
- Body: 14px
```

#### Layout
```
Desktop (1024px+):
- Grid: 4 columns for products
- Padding: 40px sides
- Margin: 60px sections
- Header Height: 70px

Tablet (640px-1023px):
- Grid: 2-3 columns
- Padding: 24px sides
- Margin: 40px sections
- Header Height: 60px

Mobile (<640px):
- Grid: 1-2 columns (stacked)
- Padding: 16px sides
- Margin: 24px sections
- Header Height: 56px
- Nav: Hamburger menu
```

#### Spacing
```
Desktop: 40px gaps, 60px margins
Tablet: 24px gaps, 40px margins
Mobile: 16px gaps, 24px margins
```

### Mobile-First Approach
- Start with mobile styles
- Use `@media (min-width: 768px)` for tablet+
- Use `@media (min-width: 1024px)` for desktop+

---

## 8. CSS Variables / Design Tokens

```css
:root {
  /* Colors - Primary */
  --color-primary: #D4AF37;
  --color-primary-dark: #c49d2e;
  --color-primary-light: #E8D5B7;
  
  /* Colors - Neutral */
  --color-dark: #1a1a1a;
  --color-dark-secondary: #333333;
  --color-light: #ffffff;
  --color-gray-100: #f9f8f5;
  --color-gray-200: #ebebeb;
  --color-gray-300: #cccccc;
  --color-gray-400: #999999;
  --color-gray-500: #666666;
  
  /* Colors - Status */
  --color-error: #e74c3c;
  --color-success: #27ae60;
  --color-warning: #f39c12;
  --color-info: #3498db;
  --color-rating: #ffc107;
  
  /* Typography */
  --font-family-heading: "Poppins", "Montserrat", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --font-family-body: "Inter", "Segoe UI", -apple-system, BlinkMacSystemFont, sans-serif;
  
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-size-2xl: 1.5rem;
  --font-size-3xl: 1.75rem;
  --font-size-4xl: 2.25rem;
  --font-size-5xl: 3rem;
  
  --font-weight-light: 300;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
  
  --line-height-tight: 1.2;
  --line-height-normal: 1.4;
  --line-height-relaxed: 1.6;
  
  /* Spacing */
  --spacing-0: 0;
  --spacing-2: 0.125rem;
  --spacing-4: 0.25rem;
  --spacing-6: 0.375rem;
  --spacing-8: 0.5rem;
  --spacing-12: 0.75rem;
  --spacing-16: 1rem;
  --spacing-20: 1.25rem;
  --spacing-24: 1.5rem;
  --spacing-32: 2rem;
  --spacing-40: 2.5rem;
  --spacing-48: 3rem;
  --spacing-60: 3.75rem;
  --spacing-80: 5rem;
  
  /* Border Radius */
  --radius-none: 0;
  --radius-sm: 0.125rem;
  --radius-base: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-full: 9999px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.08);
  --shadow-base: 0 2px 8px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.12);
  --shadow-lg: 0 8px 16px rgba(0, 0, 0, 0.15);
  --shadow-xl: 0 8px 24px rgba(0, 0, 0, 0.12);
  
  /* Transitions */
  --transition-fast: 0.15s ease;
  --transition-base: 0.3s ease;
  --transition-slow: 0.6s ease;
  --transition-cubic: cubic-bezier(0.4, 0, 0.2, 1);
}
```

---

## 9. Sample CSS Implementation

```css
/* ============================================
   BASE STYLES
   ============================================ */

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  font-size: 16px;
  scroll-behavior: smooth;
}

body {
  font-family: var(--font-family-body);
  color: var(--color-dark);
  background-color: var(--color-light);
  line-height: var(--line-height-relaxed);
}

/* ============================================
   TYPOGRAPHY
   ============================================ */

h1 {
  font-family: var(--font-family-heading);
  font-size: var(--font-size-5xl);
  font-weight: var(--font-weight-bold);
  line-height: var(--line-height-tight);
  letter-spacing: -0.02em;
}

h2 {
  font-family: var(--font-family-heading);
  font-size: var(--font-size-4xl);
  font-weight: var(--font-weight-semibold);
  line-height: var(--line-height-normal);
  letter-spacing: -0.015em;
}

h3 {
  font-family: var(--font-family-heading);
  font-size: var(--font-size-3xl);
  font-weight: var(--font-weight-semibold);
  line-height: 1.4;
}

h4 {
  font-family: var(--font-family-heading);
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-semibold);
  line-height: 1.4;
}

h5 {
  font-family: var(--font-family-heading);
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-medium);
}

h6 {
  font-family: var(--font-family-heading);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-medium);
}

p {
  margin-bottom: var(--spacing-16);
}

a {
  color: var(--color-dark);
  text-decoration: none;
  transition: color var(--transition-base);
}

a:hover {
  color: var(--color-primary);
}

/* ============================================
   HEADER & NAVIGATION
   ============================================ */

.header {
  height: 70px;
  background-color: var(--color-light);
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
}

.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 0 var(--spacing-40);
  max-width: 1440px;
  margin: 0 auto;
}

.logo {
  font-size: 24px;
  font-weight: var(--font-weight-bold);
  color: var(--color-dark);
  text-transform: uppercase;
  letter-spacing: 1px;
}

.nav-links {
  display: flex;
  list-style: none;
  gap: var(--spacing-40);
  align-items: center;
  flex: 1;
  margin-left: var(--spacing-60);
}

.nav-links a {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-medium);
  color: var(--color-dark);
  position: relative;
  padding-bottom: 4px;
}

.nav-links a::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 0;
  height: 2px;
  background-color: var(--color-primary);
  transition: width var(--transition-base);
}

.nav-links a:hover::after {
  width: 100%;
}

.nav-right {
  display: flex;
  gap: var(--spacing-20);
  align-items: center;
  margin-left: auto;
}

.cart-icon,
.account-link {
  font-size: var(--font-size-base);
  color: var(--color-dark);
  cursor: pointer;
  transition: color var(--transition-base);
}

.cart-icon:hover,
.account-link:hover {
  color: var(--color-primary);
}

/* Mobile Menu */
.menu-toggle {
  display: none;
  flex-direction: column;
  gap: 4px;
  cursor: pointer;
  padding: var(--spacing-8);
}

.menu-toggle span {
  width: 24px;
  height: 2px;
  background-color: var(--color-dark);
  border-radius: 2px;
  transition: all var(--transition-base);
}

/* ============================================
   HERO SECTION
   ============================================ */

.hero {
  height: 500px;
  background: linear-gradient(135deg, rgba(26, 26, 26, 0.3) 0%, rgba(26, 26, 26, 0.5) 100%), 
              url('/images/hero-bg.jpg') center/cover no-repeat;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: var(--color-light);
  margin-bottom: var(--spacing-60);
}

.hero h1 {
  font-size: var(--font-size-5xl);
  margin-bottom: var(--spacing-20);
  color: var(--color-light);
}

.hero p {
  font-size: var(--font-size-xl);
  margin-bottom: var(--spacing-32);
  color: var(--color-light);
}

/* ============================================
   FEATURE STRIP (Carousel/Marquee)
   ============================================ */

.feature-strip {
  height: 60px;
  background-color: var(--color-gray-100);
  border-top: 1px solid #e0d5c7;
  border-bottom: 1px solid #e0d5c7;
  display: flex;
  align-items: center;
  overflow: hidden;
  position: relative;
  margin-bottom: var(--spacing-60);
}

.feature-strip-content {
  display: flex;
  gap: var(--spacing-40);
  white-space: nowrap;
  animation: scroll 30s linear infinite;
  padding: 0 var(--spacing-40);
}

.feature-item {
  flex-shrink: 0;
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-dark);
}

@keyframes scroll {
  0% {
    transform: translateX(0);
  }
  100% {
    transform: translateX(-100%);
  }
}

/* ============================================
   BUTTONS
   ============================================ */

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-12) var(--spacing-32);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  border: none;
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all var(--transition-base);
  text-transform: none;
  font-family: var(--font-family-body);
}

.btn-primary {
  background-color: var(--color-primary);
  color: var(--color-dark);
}

.btn-primary:hover {
  background-color: var(--color-primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(212, 175, 55, 0.3);
}

.btn-primary:active {
  transform: translateY(0);
  box-shadow: 0 2px 6px rgba(212, 175, 55, 0.2);
}

.btn-secondary {
  background-color: transparent;
  color: var(--color-dark);
  border: 2px solid var(--color-dark);
}

.btn-secondary:hover {
  background-color: var(--color-dark);
  color: var(--color-light);
}

.btn-add-to-cart {
  width: 100%;
  background-color: var(--color-dark);
  color: var(--color-light);
  padding: var(--spacing-16) var(--spacing-20);
  margin-top: var(--spacing-12);
}

.btn-add-to-cart:hover {
  background-color: var(--color-dark-secondary);
}

.btn-add-to-cart:disabled {
  background-color: var(--color-gray-300);
  cursor: not-allowed;
  opacity: 0.6;
}

/* ============================================
   PRODUCT GRID & CARDS
   ============================================ */

.container {
  max-width: 1440px;
  margin: 0 auto;
  padding: 0 var(--spacing-40);
}

.grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--spacing-24);
  margin-bottom: var(--spacing-60);
}

.product-card {
  background-color: var(--color-light);
  border-radius: var(--radius-base);
  overflow: hidden;
  box-shadow: var(--shadow-base);
  transition: all var(--transition-base);
  display: flex;
  flex-direction: column;
}

.product-card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-4px);
}

.product-image {
  width: 100%;
  height: 240px;
  background-color: var(--color-gray-100);
  overflow: hidden;
  border-radius: var(--radius-base) var(--radius-base) 0 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--transition-base);
}

.product-card:hover .product-image img {
  transform: scale(1.05);
}

.product-content {
  padding: var(--spacing-16);
  flex: 1;
  display: flex;
  flex-direction: column;
}

.product-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-medium);
  line-height: var(--line-height-normal);
  color: var(--color-dark);
  margin-bottom: var(--spacing-8);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.product-rating {
  display: flex;
  align-items: center;
  gap: var(--spacing-8);
  margin-bottom: var(--spacing-8);
}

.stars {
  font-size: var(--font-size-sm);
  color: var(--color-rating);
}

.review-count {
  font-size: var(--font-size-sm);
  color: var(--color-gray-400);
}

.product-price {
  display: flex;
  align-items: baseline;
  gap: var(--spacing-8);
  margin-bottom: var(--spacing-12);
}

.original-price {
  font-size: var(--font-size-sm);
  color: var(--color-gray-400);
  text-decoration: line-through;
}

.sale-price {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-primary);
}

.sale-badge {
  position: absolute;
  top: var(--spacing-16);
  right: var(--spacing-16);
  background-color: var(--color-error);
  color: var(--color-light);
  padding: var(--spacing-6) var(--spacing-12);
  border-radius: var(--radius-base);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-semibold);
  z-index: 10;
}

.product-image {
  position: relative;
}

/* ============================================
   FOOTER
   ============================================ */

.footer {
  background-color: var(--color-dark);
  color: var(--color-light);
  padding: var(--spacing-60) var(--spacing-40) var(--spacing-40);
  margin-top: var(--spacing-80);
}

.footer-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--spacing-40);
  max-width: 1440px;
  margin: 0 auto;
  margin-bottom: var(--spacing-40);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: var(--spacing-40);
}

.footer-section h4 {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  margin-bottom: var(--spacing-16);
  color: var(--color-light);
}

.footer-section ul {
  list-style: none;
}

.footer-section ul li {
  margin-bottom: var(--spacing-12);
}

.footer-section a {
  font-size: var(--font-size-sm);
  color: rgba(255, 255, 255, 0.8);
  transition: color var(--transition-base);
}

.footer-section a:hover {
  color: var(--color-primary);
}

.social-icons {
  display: flex;
  gap: var(--spacing-16);
  margin-top: var(--spacing-16);
}

.social-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  color: var(--color-light);
  transition: all var(--transition-base);
}

.social-icon:hover {
  background-color: var(--color-primary);
  color: var(--color-dark);
}

.footer-bottom {
  text-align: center;
  font-size: var(--font-size-sm);
  color: rgba(255, 255, 255, 0.6);
  max-width: 1440px;
  margin: 0 auto;
}

/* ============================================
   RESPONSIVE DESIGN
   ============================================ */

@media (max-width: 1023px) {
  .navbar {
    padding: 0 var(--spacing-24);
  }
  
  .nav-links {
    gap: var(--spacing-24);
    margin-left: var(--spacing-40);
  }
  
  .grid {
    grid-template-columns: repeat(3, 1fr);
    gap: var(--spacing-20);
  }
  
  .container {
    padding: 0 var(--spacing-24);
  }
  
  .hero {
    height: 400px;
  }
  
  .hero h1 {
    font-size: var(--font-size-4xl);
  }
  
  .footer-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--spacing-24);
  }
}

@media (max-width: 767px) {
  .header {
    height: 60px;
    padding: 0 var(--spacing-16);
  }
  
  .navbar {
    padding: 0 var(--spacing-16);
  }
  
  .menu-toggle {
    display: flex;
  }
  
  .nav-links {
    display: none;
    position: fixed;
    top: 60px;
    left: 0;
    right: 0;
    flex-direction: column;
    gap: var(--spacing-16);
    background-color: var(--color-light);
    padding: var(--spacing-24);
    border-bottom: 1px solid rgba(0, 0, 0, 0.08);
    z-index: 99;
  }
  
  .nav-links.active {
    display: flex;
  }
  
  .grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--spacing-16);
    margin-bottom: var(--spacing-40);
  }
  
  .container {
    padding: 0 var(--spacing-16);
  }
  
  .hero {
    height: 300px;
    margin-bottom: var(--spacing-40);
  }
  
  .hero h1 {
    font-size: var(--font-size-3xl);
  }
  
  h2 {
    font-size: var(--font-size-2xl);
  }
  
  h3 {
    font-size: var(--font-size-xl);
  }
  
  .product-image {
    height: 180px;
  }
  
  .footer {
    padding: var(--spacing-40) var(--spacing-16) var(--spacing-24);
  }
  
  .footer-grid {
    grid-template-columns: 1fr;
    gap: var(--spacing-24);
    margin-bottom: var(--spacing-24);
  }
  
  .feature-strip-content {
    gap: var(--spacing-24);
    padding: 0 var(--spacing-16);
  }
}

@media (max-width: 479px) {
  h1 {
    font-size: var(--font-size-3xl);
  }
  
  h2 {
    font-size: var(--font-size-xl);
  }
  
  .grid {
    grid-template-columns: 1fr;
  }
  
  .hero h1 {
    font-size: var(--font-size-2xl);
  }
  
  .btn {
    width: 100%;
  }
}
```

---

## 10. Key Design Principles

1. **Premium Aesthetic**: Gold/Amber (#D4AF37) paired with near-black (#1a1a1a) conveys luxury
2. **Clean & Minimal**: Generous whitespace, simple typography hierarchy
3. **User-Focused**: Clear CTAs, easy product browsing, smooth interactions
4. **Responsive First**: Mobile-optimized at foundation, enhanced for larger screens
5. **Performance**: Efficient animations (cubic-bezier easing), minimal repaints
6. **Accessibility**: High contrast ratios, readable fonts, clear focus states
7. **Consistency**: Design tokens ensure unified look across all components
8. **Interactive Feedback**: Hover states, transitions, and visual feedback for all interactive elements

