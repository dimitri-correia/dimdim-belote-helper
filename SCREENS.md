# Screen Mockups and Flow

## Application Flow

```
┌─────────────────────┐
│  Écran d'accueil    │
│                     │
│   🎴 Icon           │
│   "Bienvenue..."    │
│                     │
│ [Nouvelle partie]   │
│ [Règles]            │
└─────────────────────┘
           │
           ↓
┌─────────────────────┐
│  Paramètres         │
│                     │
│ Condition de fin:   │
│  ○ Points [1000]    │
│  ○ Plis [10]        │
│                     │
│ Position:           │
│  [Nord ▼]           │
│                     │
│ Rotation:           │
│  ○ Horaire          │
│  ○ Anti-horaire     │
│                     │
│ [Commencer]         │
└─────────────────────┘
           │
           ↓
┌─────────────────────┐
│  Distribution       │
│                     │
│ Sélectionnez 8      │
│ cartes (3/8)        │
│                     │
│ ♠ [7][8][9][V]...   │
│ ♥ [7][8][9][V]...   │
│ ♦ [7][8][9][V]...   │
│ ♣ [7][8][9][V]...   │
│                     │
│ [Continuer]         │
└─────────────────────┘
           │
           ↓
┌─────────────────────┐
│  Enchères          │
│                     │
│ Tour: Nord (VOUS)   │
│ ┌─────────────────┐ │
│ │ Historique:     │ │
│ │ Nord: Passe     │ │
│ │ Est: 80 ♠       │ │
│ └─────────────────┘ │
│                     │
│ [Passe]             │
│ [Contre]            │
│                     │
│ Annoncer:           │
│ Valeur    Couleur   │
│ ○ 80      ○ ♠       │
│ ○ 90      ○ ♥       │
│ ...       ...       │
│                     │
│ [Annoncer]          │
└─────────────────────┘
```

## Detailed Screen Descriptions

### 1. Écran d'accueil (Home Screen)

**Elements:**
- AppBar: "Belote Contrée Helper"
- Large icon (Cards/Style icon)
- Title: "Bienvenue dans l'assistant\nBelote Contrée"
- Subtitle: "Cette application vous aide..."
- Primary button: "Nouvelle partie" (Blue, elevated)
- Secondary button: "Règles de la Belote Contrée" (Outlined)

**Colors:**
- Primary: Blue (#0175C2)
- Background: White/Light gray
- Text: Dark gray/Black

### 2. Paramètres (Settings Screen)

**Sections:**

#### Condition de fin (Card)
- Radio buttons for Points/Plis
- Text input for value
- Default: Points = 1000
- Validation: 100-10000 for points, 1-50 for plis

#### Votre position (Card)
- Dropdown menu
- Options: Nord, Sud, Est, Ouest
- Default: Sud

#### Sens de rotation (Card)
- Radio buttons
- Options: Horaire, Anti-horaire
- Default: Horaire

#### Action Button
- "Commencer" (Full width, elevated)

### 3. Distribution (Card Selection Screen)

**Elements:**
- Info card: "Sélectionnez vos 8 cartes (X/8)"
- Counter updates in real-time
- 4 suit sections (Cards):

For each suit:
- Suit symbol (♠♥♦♣) as header
- Color: Red for ♥♦, Black for ♠♣
- 8 FilterChips (7, 8, 9, V, D, R, 10, A)
- Selected chips: Blue background, white text
- Unselected chips: White background, colored text

#### Continue Button
- "Continuer vers les enchères"
- Enabled only when exactly 8 cards selected
- Full width, elevated

### 4. Enchères (Bidding Screen)

**Header:**
- Current player indicator (Card)
- Green background if your turn
- Gray background if not your turn
- Text: "C'est votre tour (Position)" or "Tour de Position"

**Historique des enchères (Card):**
- Scrollable list
- Each entry shows:
  - Avatar with first letter of position
  - Announcement text
- Max height: 150px

**Actions:**

#### Always Available:
- "Passe" button (Gray, full width)

#### Conditional:
- "Contre" button (Orange, if opponent's bid exists)
- "Surcontré" button (Red, if contre exists)

#### Annoncer Section:
Two columns side by side:

**Valeur (Card):**
- Radio list: 80, 90, 100, 110, 120, 130, 140, 150, 160
- Only shows values >= minimum bid

**Couleur (Card):**
- Radio list:
  - ♠ Pique
  - ♥ Cœur
  - ♦ Carreau
  - ♣ Trèfle
  - SA Sans atout
  - TA Tout atout

#### Annoncer Button:
- "Annoncer" (Blue, full width)
- Enabled only when both value and color selected
- Disabled if not your turn

**AppBar Actions:**
- Refresh icon: Restart bidding

## Color Scheme

### Primary Colors
- Blue: #0175C2 (Primary actions)
- Green: Light green (#4CAF50 shade) for current turn
- Red: #F44336 for hearts/diamonds and surcontré
- Orange: #FF9800 for contre
- Gray: #9E9E9E for pass button

### Semantic Colors
- Success: Green
- Warning: Orange
- Error: Red
- Info: Blue
- Neutral: Gray

### Card Suits
- Spades (♠): Black
- Hearts (♥): Red (#E53935)
- Diamonds (♦): Red (#E53935)
- Clubs (♣): Black

## Typography

### Headers
- App title: 28pt, Bold
- Screen titles: 20pt, Regular
- Section titles: 18pt, Bold
- Card titles: 16pt, Bold

### Body Text
- Regular: 16pt
- Small: 14pt
- Tiny: 12pt

### Buttons
- Large: 18pt
- Regular: 16pt

## Spacing

### Padding
- Screen edges: 16px
- Card padding: 12-16px
- Between sections: 12-16px
- Between elements: 8px

### Card Margins
- Bottom: 12px

### Button Height
- Standard: 48px minimum
- With padding: 16px vertical

## Interaction States

### Buttons
- Default: Solid color
- Hover: Slightly darker
- Pressed: Much darker
- Disabled: Gray with 50% opacity

### Cards
- Default: White with subtle shadow
- Active: Green tint (for current turn)
- Hover: Slight elevation increase

### Chips (Cards)
- Unselected: White background, border
- Selected: Blue background, white text, checkmark
- Hover: Light blue tint
- Disabled: Gray with 50% opacity

## Responsive Behavior

### Mobile (< 600px)
- Single column layout
- Full width buttons
- Stacked value/color selection

### Tablet (600-1200px)
- Two column layout for value/color
- Wider cards
- More padding

### Desktop (> 1200px)
- Centered content (max width 800px)
- Side-by-side layouts where appropriate
- Larger text and buttons

## Accessibility

### Touch Targets
- Minimum 48x48 dp for all interactive elements
- Proper spacing between touch targets

### Colors
- Sufficient contrast ratios (WCAG AA)
- Color not the only indicator
- Text labels for all icons

### Screen Readers
- Semantic HTML/widgets
- Proper labels for all inputs
- Announcement of state changes

## Animations

### Navigation
- Slide transition between screens (300ms)
- Fade in for dialogs (200ms)

### State Changes
- Fade transition for text changes
- Scale animation for button presses
- Smooth color transitions

### List Updates
- Animated insertion for new bid entries
- Subtle highlight fade for new items

This design ensures:
- ✅ Clear visual hierarchy
- ✅ Intuitive navigation
- ✅ French language throughout
- ✅ Responsive across devices
- ✅ Accessible to all users
- ✅ Consistent with Material Design 3