# Controls Guide

Detailed guide for all control types in Rmotly.

## Table of Contents

- [Overview](#overview)
- [Button Control](#button-control)
- [Toggle Control](#toggle-control)
- [Slider Control](#slider-control)
- [Input Control](#input-control)
- [Dropdown Control](#dropdown-control)
- [Control Best Practices](#control-best-practices)

## Overview

Controls are interactive UI elements on your dashboard that trigger actions. Each control type is designed for specific use cases and interaction patterns.

### Control Type Selection Guide

| Control Type | Interaction | State | Best For |
|--------------|-------------|-------|----------|
| **Button** | Single tap | Stateless | Triggering one-time actions |
| **Toggle** | Tap to switch | On/Off | Binary state controls |
| **Slider** | Drag to adjust | Range value | Adjusting continuous values |
| **Input** | Type and submit | Text value | Sending custom text/data |
| **Dropdown** | Select option | Selected value | Choosing from predefined options |

### Common Control Properties

All controls share these base properties:

**Name** (required)
- Displayed on the control card
- Should be clear and concise
- Example: `Living Room Light`, `Garage Door`

**Icon** (optional)
- Visual representation
- Helps with quick identification
- Choose recognizable icons

**Color** (optional)
- Accent color for the card
- Use for categorization or priority
- Example: Red for security, Blue for climate

**Description** (optional)
- Additional context
- Visible in control details
- Example: `Controls the overhead light in the living room`

**Action** (required)
- HTTP action to execute
- Can be shared across controls
- See [User Guide - Creating Actions](USER_GUIDE.md#creating-actions)

**Position** (automatic)
- Order on the dashboard
- Drag to rearrange
- Saved automatically

## Button Control

Single-tap trigger for one-time actions.

### Visual Appearance

```
┌─────────────────┐
│    Lights On    │  ← Name
│                 │
│       💡        │  ← Icon
│                 │
│   [  Tap Me  ]  │  ← Button Label
└─────────────────┘
```

### When to Use

- **Triggering actions** - Send a command, start a process
- **One-time events** - No persistent state needed
- **Quick actions** - Fast, single-tap execution

**Good use cases:**
- Turn on/off a device
- Send a notification
- Trigger a webhook
- Start/stop a service
- Execute a command
- Open a door (momentary action)

**Not ideal for:**
- On/off switches with state tracking (use Toggle)
- Adjusting values (use Slider)
- Entering custom data (use Input)
- Selecting from options (use Dropdown)

### Configuration Options

#### Button Label

Text displayed on the button itself.

**Default:** Control name
**Example:** `Turn On`, `Execute`, `Send`

**Tips:**
- Keep it short (1-2 words ideal)
- Use action verbs
- Clear indication of what happens

#### Icon

Visual representation on the button.

**Common choices:**
- 💡 Lightbulb - Lights
- 🔌 Power - Power controls
- 🚪 Door - Door controls
- 🔔 Bell - Alerts/notifications
- ▶️ Play - Start/execute actions
- 🔄 Refresh - Reload/sync actions

#### Confirmation Dialog

Require confirmation before executing.

**When to use:**
- Critical actions (delete, shutdown)
- Expensive operations (API costs)
- Irreversible actions
- Actions with significant impact

**Configuration:**
- Toggle **Require Confirmation** ON
- Customize confirmation message
- Set button text (e.g., "Yes, Delete", "Confirm")

**Example:**
```
Control: Delete User
Confirmation: ON
Message: "Are you sure you want to delete this user? This cannot be undone."
Confirm Button: "Yes, Delete"
Cancel Button: "Cancel"
```

#### Cooldown Period

Prevent rapid repeated presses.

**When to use:**
- Rate-limited APIs
- Prevent accidental double-taps
- Protect against rapid-fire actions

**Configuration:**
- Set cooldown duration (1-60 seconds)
- Button disabled during cooldown
- Countdown displayed on button

**Example:**
```
Control: Send Alert
Cooldown: 10 seconds
Behavior: After press, button shows "Wait 10s..." then "Wait 9s..." etc.
```

#### Haptic Feedback

Vibration feedback on press.

**Options:**
- **None** - No vibration
- **Light** - Subtle tap
- **Medium** - Noticeable vibration
- **Heavy** - Strong feedback

**Best practices:**
- Light for frequent actions
- Medium for standard actions
- Heavy for critical actions

#### Success/Error Indicators

Visual feedback after execution.

**Success:**
- ✓ Checkmark appears briefly
- Green flash/pulse
- Success message toast

**Error:**
- ✗ X mark appears briefly
- Red flash
- Error message with details

**Configuration:**
- Toggle **Show Result Indicator** ON/OFF
- Set display duration (1-5 seconds)
- Customize success/error messages

### Complete Example: Home Assistant Light

```yaml
Control Configuration:
  Type: Button
  Name: Living Room Light
  
  Appearance:
    Icon: lightbulb
    Color: Gold (#FFD700)
    Button Label: Turn On
  
  Behavior:
    Confirmation: No
    Cooldown: 0 seconds
    Haptic: Light
    Show Result: Yes
  
  Action: Toggle Living Room Light
    Method: POST
    URL: https://homeassistant.local/api/services/light/toggle
    Headers:
      Authorization: Bearer {{haToken}}
    Body:
      {
        "entity_id": "light.living_room"
      }
```

### Button Use Cases

#### 1. Smart Home Device Control

```yaml
Control: Bedroom Light On
Type: Button
Label: Turn On
Action: POST to Home Assistant
Use Case: Turn on bedroom light
```

#### 2. API Webhook Trigger

```yaml
Control: Deploy Website
Type: Button
Label: Deploy
Confirmation: Yes
Cooldown: 60 seconds
Action: POST to CI/CD webhook
Use Case: Trigger deployment pipeline
```

#### 3. Notification Sender

```yaml
Control: Send "I'm Home"
Type: Button
Label: Send
Action: POST to notification service
Use Case: Quick status update
```

#### 4. Device Reboot

```yaml
Control: Reboot Server
Type: Button
Label: Reboot
Confirmation: Yes
Message: "Reboot production server?"
Action: POST to server API
Use Case: Remote server restart
```

### Button Tips

1. **Clear labels:** Use action verbs that describe what will happen
2. **Appropriate icons:** Choose icons that are immediately recognizable
3. **Confirmation for critical:** Always confirm destructive or expensive actions
4. **Cooldowns for rate limits:** Prevent API rate limit violations
5. **Visual feedback:** Enable success/error indicators for reassurance

## Toggle Control

On/off switch with persistent state display.

### Visual Appearance

```
┌─────────────────┐
│  Security Alarm │  ← Name
│                 │
│    ⚠️  [●    ]  │  ← Icon + Switch (Off)
│       Disarmed  │  ← Status Label
└─────────────────┘

┌─────────────────┐
│  Security Alarm │
│                 │
│    ⚠️  [    ●]  │  ← Switch (On)
│       Armed     │  ← Status Label
└─────────────────┘
```

### When to Use

- **Binary states** - On/off, enabled/disabled, armed/disarmed
- **State tracking** - Show current state visually
- **Toggle actions** - Single action switches between states

**Good use cases:**
- Light on/off with state
- Enable/disable services
- Arm/disarm systems
- Lock/unlock doors
- Mute/unmute devices
- Show/hide elements

**Not ideal for:**
- One-time triggers without state (use Button)
- Multiple states (use Dropdown)
- Value ranges (use Slider)

### Configuration Options

#### State Labels

Custom text for each state.

**On State Label**
- Default: "On"
- Example: "Armed", "Enabled", "Locked", "Active"

**Off State Label**
- Default: "Off"
- Example: "Disarmed", "Disabled", "Unlocked", "Inactive"

**Example:**
```
Control: Office AC
On Label: Cooling
Off Label: Off
```

#### State Colors

Visual color coding for each state.

**On State Color**
- Default: Green (#4CAF50)
- Common: Green (active), Red (alert), Blue (cool)

**Off State Color**
- Default: Gray (#757575)
- Common: Gray (inactive), Black (off)

**Example:**
```
Control: Security Alarm
On Color: Red (#F44336) - "Alert/Armed"
Off Color: Green (#4CAF50) - "Safe/Disarmed"
```

#### Switch Style

Visual style of the toggle switch.

**Material (default)**
- Modern Material Design switch
- Smooth animation
- Clear on/off position

**iOS Style**
- Apple-style toggle
- Rounded switch with slide
- Familiar to iOS users

**Checkbox**
- Simple checkbox
- Minimal design
- Space-efficient

#### Initial State

Default state when control is created.

**Options:**
- **Off** (default) - Starts in off position
- **On** - Starts in on position
- **Last Known** - Remembers last state (requires state API)

**Note:** This is display-only. Actual device state depends on the connected system.

#### Confirmation

Require confirmation before toggling.

**When to use:**
- Critical systems (security, safety)
- Expensive state changes
- Actions with significant impact

**Example:**
```
Control: Main Power
Confirmation: Yes
Message: "Toggle main power?"
```

#### State Sync

Automatically update switch to match device state.

**Configuration:**
- Enable **Sync with Device**
- Provide status check endpoint (GET request)
- Set polling interval (5-60 seconds)

**Example:**
```
Control: Living Room Light
Sync: Yes
Status URL: GET https://homeassistant.local/api/states/light.living_room
Polling: 10 seconds
State Path: state (returns "on" or "off")
```

**Without sync:** Switch shows last user action, not actual device state
**With sync:** Switch always shows current device state

### Complete Example: Smart Lock

```yaml
Control Configuration:
  Type: Toggle
  Name: Front Door Lock
  
  Appearance:
    Icon: lock
    Color: Blue (#2196F3)
    On Label: Locked
    Off Label: Unlocked
    On Color: Green (#4CAF50)
    Off Color: Red (#F44336)
  
  Behavior:
    Switch Style: Material
    Initial State: Off
    Confirmation: Yes
    Confirmation Message: "Toggle door lock?"
  
  State Sync:
    Enabled: Yes
    Status URL: GET https://smartlock.local/api/status
    Polling Interval: 15 seconds
    State Field: locked (boolean)
  
  Actions:
    On Action: Lock Door
      Method: POST
      URL: https://smartlock.local/api/lock
      Body: {"action": "lock"}
    
    Off Action: Unlock Door
      Method: POST
      URL: https://smartlock.local/api/unlock
      Body: {"action": "unlock"}
```

### Toggle Use Cases

#### 1. Smart Light Switch

```yaml
Control: Bedroom Light
Type: Toggle
On Label: On
Off Label: Off
On Color: Yellow
State Sync: Yes (poll every 10s)
Use Case: Light control with state display
```

#### 2. Service Enable/Disable

```yaml
Control: Backup Service
Type: Toggle
On Label: Enabled
Off Label: Disabled
Confirmation: Yes
Use Case: Enable/disable automated backups
```

#### 3. Security System

```yaml
Control: Home Alarm
Type: Toggle
On Label: Armed
Off Label: Disarmed
On Color: Red
Off Color: Green
Confirmation: Yes
Use Case: Arm/disarm security system
```

#### 4. Device Power

```yaml
Control: Living Room TV
Type: Toggle
On Label: On
Off Label: Off
State Sync: Yes
Use Case: TV power with state tracking
```

### Toggle Actions

Toggles can use two different approaches:

#### Approach 1: Two Separate Actions

Define different actions for On and Off states:

```yaml
On Action: Turn Light On
  POST /api/light/on
  
Off Action: Turn Light Off
  POST /api/light/off
```

**When to use:**
- Different endpoints for on/off
- Different request methods
- Different payloads

#### Approach 2: Single Toggle Action

Single action with control value:

```yaml
Toggle Action: Set Light State
  POST /api/light/state
  Body: {"state": {{controlValue}}}
```

**When to use:**
- Same endpoint for both states
- State passed as parameter
- Simpler configuration

### Toggle Tips

1. **Meaningful labels:** Use descriptive state names, not just "On/Off"
2. **Color coding:** Use colors that match expectations (red=danger/armed)
3. **State sync:** Enable for accurate state display
4. **Confirmation for critical:** Always confirm security or safety toggles
5. **Test both directions:** Verify both on→off and off→on work correctly

## Slider Control

Drag to adjust a continuous value within a range.

### Visual Appearance

```
┌─────────────────────────┐
│   Living Room Brightness│  ← Name
│                         │
│   ☀️                    │  ← Icon
│                         │
│   [━━━━━◉━━━━━]   75%  │  ← Slider + Value
│                         │
│   Min: 0       Max: 100 │  ← Range Labels
└─────────────────────────┘
```

### When to Use

- **Continuous values** - Brightness, volume, temperature
- **Range adjustments** - Any value between min and max
- **Fine control** - Precise value selection

**Good use cases:**
- Light brightness (0-100%)
- Volume control (0-100)
- Temperature setting (60-85°F)
- Speed control (0-10)
- Opacity/transparency (0-100%)
- Zoom level (1-10x)

**Not ideal for:**
- Binary states (use Toggle)
- Discrete options (use Dropdown)
- Large ranges with specific values (use Input)
- One-time triggers (use Button)

### Configuration Options

#### Range Settings

Define the value range.

**Minimum Value** (required)
- Lowest possible value
- Default: 0
- Example: 0, 60 (for temperature in °F)

**Maximum Value** (required)
- Highest possible value
- Default: 100
- Example: 100, 10, 255

**Step Size**
- Increment between values
- Default: 1
- Example: 1, 5, 0.1

**Example:**
```
Control: Room Temperature
Min: 60
Max: 85
Step: 0.5
Range: 60, 60.5, 61, 61.5 ... 85
```

#### Display Options

How the slider is presented.

**Show Current Value**
- Display numeric value next to slider
- Toggle ON/OFF
- Position: right, below, or inside slider

**Value Format**
- Decimal places (0-2)
- Prefix (e.g., "$", "#")
- Suffix (e.g., "%", "°F", "ms")

**Example:**
```
Control: Light Brightness
Show Value: Yes
Format: "{{value}}%"
Display: "75%" (when value is 75)
```

**Range Labels**
- Show min/max values below slider
- Toggle ON/OFF
- Helps users understand range

**Tick Marks**
- Visual marks at intervals
- Show major steps
- Toggle ON/OFF

#### Value Mapping

Map slider values to different output values.

**Linear (default)**
- Direct mapping
- Example: Slider 0-100 → Output 0-100

**Exponential**
- Non-linear curve
- Example: Slider 0-100 → Output 0-1000 (exponential)
- Good for volume, brightness perception

**Custom**
- Define specific value mappings
- Example: Slider 1-5 → Output ["Low", "Med-Low", "Med", "Med-High", "High"]

**Example:**
```
Control: Volume
Slider: 0-100 (linear)
Mapping: Exponential
Formula: output = (slider / 100) ^ 2 * 100
Result: More granular control at lower values
```

#### Update Behavior

When to send the action.

**On Release (default)**
- Action sent when user releases slider
- Reduces API calls
- Smooth interaction

**On Drag**
- Action sent continuously while dragging
- Real-time updates
- More API calls

**Debounced**
- Action sent after user stops moving for X ms
- Balance between real-time and efficiency
- Configurable delay (100-1000ms)

**On Commit**
- Show value but don't send until user taps "Apply"
- Explicit confirmation
- Best for expensive operations

**Example:**
```
Control: Light Brightness
Update: On Release
Behavior: Drag slider, release to set brightness
```

#### Initial Value

Starting position of the slider.

**Options:**
- **Minimum** - Starts at min value
- **Maximum** - Starts at max value
- **Middle** - Starts at midpoint
- **Custom** - Specific value
- **Last Known** - Remembers last setting (requires state sync)

#### Haptic Feedback

Vibration while sliding.

**Options:**
- **None** - No feedback
- **Tick** - Vibrate at each step
- **Light** - Subtle continuous vibration
- **Heavy** - Strong continuous vibration

**Best practices:**
- Tick for discrete steps (e.g., 1-10)
- Light for continuous ranges (e.g., 0-100)
- None for very fine adjustments

### Complete Example: Thermostat Control

```yaml
Control Configuration:
  Type: Slider
  Name: Living Room Temperature
  
  Appearance:
    Icon: thermometer
    Color: Orange (#FF5722)
  
  Range:
    Minimum: 60
    Maximum: 85
    Step: 0.5
    Initial: 72
  
  Display:
    Show Value: Yes
    Format: "{{value}}°F"
    Show Range Labels: Yes
    Tick Marks: Yes (every 5°F)
  
  Behavior:
    Update: Debounced (500ms)
    Haptic: Light
  
  Action: Set Thermostat
    Method: POST
    URL: https://thermostat.local/api/temperature
    Body:
      {
        "target_temp": {{controlValue}},
        "unit": "fahrenheit"
      }
```

### Slider Use Cases

#### 1. Light Brightness

```yaml
Control: Kitchen Brightness
Type: Slider
Range: 0-100
Step: 5
Format: "{{value}}%"
Update: On Release
Use Case: Adjust kitchen light brightness
```

#### 2. Volume Control

```yaml
Control: Speaker Volume
Type: Slider
Range: 0-100
Step: 1
Mapping: Exponential
Format: "{{value}}%"
Update: Debounced (300ms)
Use Case: Fine-grained volume control
```

#### 3. Temperature Setting

```yaml
Control: AC Temperature
Type: Slider
Range: 60-85
Step: 1
Format: "{{value}}°F"
Update: On Release
Use Case: Set desired room temperature
```

#### 4. Speed Control

```yaml
Control: Fan Speed
Type: Slider
Range: 0-5
Step: 1
Labels: ["Off", "Low", "Med-Low", "Med", "Med-High", "High"]
Tick Marks: Yes
Update: On Release
Use Case: Select fan speed level
```

#### 5. RGB Color Component

```yaml
Control: Red Channel
Type: Slider
Range: 0-255
Step: 1
Format: "R: {{value}}"
Update: Debounced (100ms)
Use Case: Adjust red component of RGB light
```

### Slider Tips

1. **Appropriate ranges:** Match range to actual device capabilities
2. **Logical steps:** Use steps that make sense for the value (whole degrees, 5% increments)
3. **Format clearly:** Include units in the display (%, °F, dB)
4. **Update strategy:** Balance real-time feedback with API efficiency
5. **Tick marks for discrete:** Use ticks when specific values are meaningful
6. **Haptic for steps:** Tick feedback helps users feel discrete steps

## Input Control

Text entry field with submit button for custom data.

### Visual Appearance

```
┌─────────────────────────┐
│   Send Message          │  ← Name
│                         │
│   💬                    │  ← Icon
│                         │
│   [Enter message...   ] │  ← Input Field
│                   [Send]│  ← Submit Button
└─────────────────────────┘
```

### When to Use

- **Custom text** - User-provided strings
- **Dynamic data** - Data that changes each time
- **Search/query** - Search terms, API queries
- **Variable input** - Cannot be predefined

**Good use cases:**
- Send custom messages
- Search queries
- User IDs or codes
- Custom commands
- File paths
- URLs

**Not ideal for:**
- Fixed actions (use Button)
- On/off states (use Toggle)
- Predefined options (use Dropdown)
- Numeric ranges (use Slider)

### Configuration Options

#### Input Type

Type of data being entered.

**Text (default)**
- Plain text input
- Multiline optional
- No restrictions

**Number**
- Numeric keyboard
- Integer or decimal
- Min/max validation

**Email**
- Email keyboard with @ and .
- Email format validation
- Example: user@example.com

**URL**
- URL keyboard with / and .
- URL format validation
- Example: https://example.com

**Password**
- Obscured input (●●●●)
- Show/hide toggle
- No autocorrect

**Phone**
- Phone number keyboard
- Format validation
- Example: (555) 123-4567

**Example:**
```
Control: Send Email
Input Type: Email
Validation: Email format
```

#### Placeholder Text

Hint text shown when input is empty.

**Purpose:**
- Guide user on what to enter
- Show format examples
- Provide context

**Examples:**
- "Enter your message here..."
- "example@email.com"
- "https://example.com"
- "Search for users..."

#### Default Value

Pre-filled text in the input field.

**When to use:**
- Common values
- Templates for users to modify
- Last used value (with memory)

**Example:**
```
Control: Deploy Branch
Input Type: Text
Default: "main"
Placeholder: "Enter branch name"
```

#### Validation Rules

Enforce input requirements.

**Required**
- Input cannot be empty
- Submit disabled until filled

**Minimum Length**
- Minimum characters required
- Example: Min 3 for search queries

**Maximum Length**
- Maximum characters allowed
- Example: Max 280 for tweets

**Pattern (Regex)**
- Custom format validation
- Example: `^[A-Z]{2,3}-[0-9]{3}$` for codes like "ABC-123"

**Custom Validator**
- URL endpoint that validates input
- Returns true/false
- Example: Check if username is available

**Example:**
```
Control: Enter Promo Code
Validation:
  Required: Yes
  Pattern: ^[A-Z0-9]{6}$
  Message: "Code must be 6 uppercase letters or numbers"
```

#### Submit Behavior

How submission works.

**Submit Button**
- Show explicit submit button
- Label customizable (e.g., "Send", "Search", "Submit")
- Disabled until validation passes

**Enter Key Action**
- **Submit** - Enter key submits (default)
- **New Line** - Enter adds line break (multiline)
- **Nothing** - Enter key disabled

**Auto-Submit**
- Submit automatically after delay
- Useful for search queries
- Configurable delay (500-3000ms)

**Example:**
```
Control: Search Users
Submit: Auto (1000ms after typing stops)
```

#### Keyboard Options

Control keyboard behavior.

**Auto-focus**
- Automatically focus input when control opens
- Keyboard appears immediately
- Good for primary input controls

**Autocorrect**
- Enable/disable autocorrect
- Disable for codes, technical input
- Enable for messages, notes

**Autocapitalization**
- **None** - No capitalization
- **Sentences** - First word of sentences
- **Words** - First letter of each word
- **Characters** - All uppercase

**Suggestions**
- Show word suggestions
- Enable/disable per control

#### Input Actions

**Clear Button**
- Show X button to clear input
- Appears when text entered
- Quick way to start over

**Copy Last**
- Button to copy last submitted value
- Useful for repeated submissions
- Shows last N submissions

**History**
- Dropdown of previous submissions
- Tap to reuse
- Configurable history size (5-20)

### Complete Example: Send Notification Message

```yaml
Control Configuration:
  Type: Input
  Name: Send Alert
  
  Appearance:
    Icon: notification
    Color: Red (#F44336)
  
  Input Settings:
    Type: Text
    Multiline: Yes (max 3 lines)
    Placeholder: "Enter alert message..."
    Default: ""
  
  Validation:
    Required: Yes
    Min Length: 5
    Max Length: 200
    Message: "Message must be 5-200 characters"
  
  Keyboard:
    Auto-focus: Yes
    Autocorrect: Yes
    Autocapitalization: Sentences
  
  Submit:
    Button Label: "Send"
    Enter Key: Submit
    Show Clear: Yes
  
  Action: Send Alert Notification
    Method: POST
    URL: https://api.example.com/alerts
    Headers:
      Authorization: Bearer {{apiToken}}
      Content-Type: application/json
    Body:
      {
        "message": "{{controlValue}}",
        "priority": "high",
        "timestamp": "{{timestamp}}"
      }
```

### Input Use Cases

#### 1. Search Users

```yaml
Control: Search
Type: Input
Input Type: Text
Placeholder: "Enter username..."
Submit: Auto (1000ms delay)
Action: GET /api/users/search?q={{controlValue}}
Use Case: Search database for users
```

#### 2. Send Custom Message

```yaml
Control: Broadcast Message
Type: Input
Input Type: Text (Multiline)
Placeholder: "Message to all users..."
Validation: Required, Max 500 chars
Submit: Button "Send"
Action: POST message to broadcast API
Use Case: Admin broadcast to users
```

#### 3. Execute Command

```yaml
Control: Run Command
Type: Input
Input Type: Text
Placeholder: "Enter command..."
Autocorrect: No
History: Last 10 commands
Action: POST to command execution API
Use Case: Remote command execution
```

#### 4. Set URL

```yaml
Control: Configure Webhook
Type: Input
Input Type: URL
Placeholder: "https://example.com/webhook"
Validation: Valid URL format
Action: POST to save webhook URL
Use Case: Configure integration webhook
```

#### 5. Enter Verification Code

```yaml
Control: Verify Code
Type: Input
Input Type: Number
Placeholder: "123456"
Max Length: 6
Pattern: ^\d{6}$
Autocapitalization: None
Action: POST code to verification API
Use Case: 2FA verification
```

### Input Tips

1. **Clear placeholders:** Show exactly what format is expected
2. **Appropriate validation:** Don't over-validate, but ensure data quality
3. **Good defaults:** Pre-fill common values when possible
4. **Submit feedback:** Clear success/error messages after submission
5. **History for repetition:** Enable history for frequently repeated inputs
6. **Keyboard type:** Match keyboard to input type (email, URL, number)
7. **Multiline when needed:** Enable for longer text like messages

## Dropdown Control

Select from a predefined list of options.

### Visual Appearance

```
┌─────────────────────────┐
│   Scene Selection       │  ← Name
│                         │
│   🎬                    │  ← Icon
│                         │
│   [ Movie Night      ▼] │  ← Selected Option
└─────────────────────────┘

When tapped:
┌─────────────────────────┐
│   Select Scene:         │
├─────────────────────────┤
│   ○ Bright              │
│   ● Movie Night         │  ← Selected
│   ○ Romantic            │
│   ○ Party               │
│   ○ Sleep               │
└─────────────────────────┘
```

### When to Use

- **Fixed options** - Known set of choices
- **Mutually exclusive** - Only one can be selected
- **More than 2-3 options** - Too many for buttons

**Good use cases:**
- Scene selection (movie, party, sleep)
- Mode selection (auto, manual, eco)
- Device selection (from list)
- Preset selection (presets 1-10)
- Profile selection (user profiles)
- Input source (HDMI 1, HDMI 2, etc.)

**Not ideal for:**
- Binary choice (use Toggle)
- Continuous ranges (use Slider)
- Custom values (use Input)
- Single actions (use Button)

### Configuration Options

#### Options List

Define the selectable options.

**Option Configuration:**

Each option has:
- **Label** - Displayed text
- **Value** - Sent to action
- **Icon** (optional) - Visual identifier
- **Description** (optional) - Additional info

**Example:**
```yaml
Options:
  - Label: "Movie Night"
    Value: "movie"
    Icon: movie
    Description: "Dim lights, close curtains"
  
  - Label: "Bright"
    Value: "bright"
    Icon: wb_sunny
    Description: "Full brightness"
  
  - Label: "Romantic"
    Value: "romantic"
    Icon: favorite
    Description: "Warm dim lighting"
```

**Adding options:**
1. Tap **Add Option**
2. Enter label and value
3. Optionally add icon and description
4. Repeat for all options
5. Drag to reorder

#### Display Style

How the dropdown appears.

**Dropdown (default)**
- Standard dropdown menu
- Taps to expand
- Good for 3-10 options

**Radio List**
- Always expanded list
- Radio button selection
- Good for 2-5 options

**Modal Dialog**
- Full-screen selection
- Searchable
- Good for many options (10+)

**Bottom Sheet**
- Sheet slides up from bottom
- Swipe to dismiss
- Good for 5-15 options

**Segmented Control**
- Horizontal button row
- All visible at once
- Good for 2-4 options

**Example:**
```
Control: Input Source (2 options)
Style: Segmented Control
Display: [HDMI 1][HDMI 2]

Control: Scene (8 options)
Style: Dropdown
Display: [Movie Night ▼]

Control: Device (50 options)
Style: Modal Dialog with search
Display: [Select Device... ▼]
```

#### Selection Behavior

**Single Select (default)**
- Only one option selected at a time
- Selecting new option deselects previous

**Multi-Select**
- Multiple options can be selected
- Checkboxes instead of radio buttons
- Value is array of selected values

**Example multi-select:**
```yaml
Control: Notify Users
Options: [Admin, Moderators, Users, Guests]
Multi-Select: Yes
Selected: [Admin, Moderators]
Value Sent: ["admin", "moderators"]
```

#### Default Selection

Initial selected option.

**Options:**
- **None** - Nothing selected initially
- **First** - First option selected
- **Specific** - Particular option selected
- **Last Used** - Remember previous selection

**Example:**
```
Control: Scene
Default: First option ("Bright")
```

#### Search/Filter

Enable searching in large lists.

**Configuration:**
- Enable **Searchable** option
- Search searches labels and descriptions
- Real-time filtering

**When to use:**
- 10+ options
- Users know what they're looking for
- Long option names

**Example:**
```
Control: Select Device (50 options)
Searchable: Yes
Placeholder: "Search devices..."
```

#### Grouping

Organize options into categories.

**Example:**
```yaml
Control: Smart Home Scene

Groups:
  Lighting:
    - Bright
    - Dim
    - Night Light
  
  Entertainment:
    - Movie Night
    - Party Mode
    - Gaming
  
  Sleep:
    - Bedtime
    - Good Morning
```

Display:
```
┌─────────────────────────┐
│ Select Scene:           │
├─────────────────────────┤
│ LIGHTING                │
│   ○ Bright              │
│   ○ Dim                 │
│   ○ Night Light         │
├─────────────────────────┤
│ ENTERTAINMENT           │
│   ● Movie Night         │
│   ○ Party Mode          │
│   ○ Gaming              │
├─────────────────────────┤
│ SLEEP                   │
│   ○ Bedtime             │
│   ○ Good Morning        │
└─────────────────────────┘
```

#### Confirmation

Require confirmation before applying selection.

**When to use:**
- Selections with significant impact
- Expensive operations
- Irreversible changes

**Example:**
```
Control: Server Mode
Confirmation: Yes
Message: "Switch to {{selectedValue}} mode?"
```

### Complete Example: Home Scene Selection

```yaml
Control Configuration:
  Type: Dropdown
  Name: Living Room Scene
  
  Appearance:
    Icon: lightbulb_group
    Color: Purple (#9C27B0)
  
  Options:
    - Label: "Bright"
      Value: "bright"
      Icon: wb_sunny
      Description: "100% brightness, cool white"
    
    - Label: "Movie Night"
      Value: "movie"
      Icon: movie
      Description: "10% brightness, warm white"
    
    - Label: "Romantic"
      Value: "romantic"
      Icon: favorite
      Description: "25% brightness, warm amber"
    
    - Label: "Party"
      Value: "party"
      Icon: celebration
      Description: "Multi-color animation"
    
    - Label: "Reading"
      Value: "reading"
      Icon: book
      Description: "75% brightness, focused"
  
  Display:
    Style: Dropdown
    Searchable: No
    Show Icons: Yes
  
  Behavior:
    Default: "bright"
    Confirmation: No
  
  Action: Set Home Assistant Scene
    Method: POST
    URL: https://homeassistant.local/api/services/scene/turn_on
    Headers:
      Authorization: Bearer {{haToken}}
    Body:
      {
        "entity_id": "scene.living_room_{{controlValue}}"
      }
```

### Dropdown Use Cases

#### 1. Scene Selection

```yaml
Control: Bedroom Scene
Type: Dropdown
Options: Bright, Dim, Sleep, Wake
Default: Bright
Style: Radio List
Use Case: Quick scene changes
```

#### 2. Input Source

```yaml
Control: TV Input
Type: Dropdown
Options: HDMI 1, HDMI 2, HDMI 3, Chromecast, Cable
Style: Segmented (2 rows)
Use Case: Switch TV input source
```

#### 3. Device Selection

```yaml
Control: Control Device
Type: Dropdown
Options: [List of 30 smart devices]
Searchable: Yes
Style: Modal Dialog
Use Case: Select device to control
```

#### 4. Preset Selection

```yaml
Control: Camera Preset
Type: Dropdown
Options: Preset 1-10
Grouped: Outdoor, Indoor, Special
Style: Dropdown
Use Case: Camera position presets
```

#### 5. Mode Selection

```yaml
Control: Thermostat Mode
Type: Dropdown
Options: Heat, Cool, Auto, Off
Style: Segmented Control
Confirmation: Yes (for "Off")
Use Case: HVAC mode selection
```

#### 6. Multi-Select Notification Recipients

```yaml
Control: Send To
Type: Dropdown
Multi-Select: Yes
Options: Admins, Moderators, Users, All
Default: None
Style: Bottom Sheet (checkboxes)
Use Case: Select notification recipients
```

### Dropdown Tips

1. **Clear labels:** Make option names obvious and distinct
2. **Logical order:** Alphabetical or by frequency of use
3. **Appropriate style:** Match style to number of options
4. **Icons for clarity:** Visual icons help quick identification
5. **Search for many:** Enable search for 10+ options
6. **Group related:** Use groups for logical organization
7. **Descriptions for complex:** Add descriptions when options need explanation
8. **Default selection:** Start with the most common option

## Control Best Practices

### General Principles

1. **One Control, One Purpose**
   - Each control should do one thing well
   - Don't overload controls with multiple actions
   - Create separate controls for distinct functions

2. **Descriptive Naming**
   - Names should be self-explanatory
   - Include location/context if needed
   - Avoid technical jargon

3. **Visual Consistency**
   - Use consistent colors for categories
   - Use recognizable icons
   - Maintain consistent sizing

4. **Logical Organization**
   - Group related controls together
   - Put frequently-used controls at top
   - Create a flow for common tasks

5. **Test Thoroughly**
   - Test actions before creating controls
   - Verify all edge cases
   - Test error handling

### Choosing the Right Control Type

| If you need to... | Use... |
|-------------------|--------|
| Trigger a one-time action | Button |
| Switch between two states | Toggle |
| Adjust a value in a range | Slider |
| Enter custom text or data | Input |
| Choose from predefined options | Dropdown |
| Choose from many options | Dropdown (searchable) |
| Adjust multiple RGB values | 3 Sliders (R, G, B) |
| Send different commands | Multiple Buttons or Dropdown |

### Common Mistakes to Avoid

1. **Using Button for State**
   - ❌ Button named "Light" that toggles
   - ✅ Toggle control showing on/off state

2. **Slider for Discrete Options**
   - ❌ Slider with 5 preset positions
   - ✅ Dropdown with 5 named options

3. **Dropdown with 2 Options**
   - ❌ Dropdown: [On, Off]
   - ✅ Toggle control

4. **Input for Fixed Options**
   - ❌ Input field for "Mode" (3 fixed modes)
   - ✅ Dropdown with 3 options

5. **Vague Naming**
   - ❌ "Control 1", "Button", "Thing"
   - ✅ "Living Room Light", "Garage Door", "AC Temperature"

### Performance Considerations

1. **Limit Dashboard Controls**
   - Keep dashboard under 30-40 controls
   - Create multiple dashboards if needed
   - Use search for large collections

2. **Debounce Sliders**
   - Don't send on every drag pixel
   - Use "On Release" or debouncing
   - Reduces API calls

3. **Cache When Possible**
   - Enable state caching for toggles
   - Reduces server requests
   - Improves perceived speed

4. **Optimize Images**
   - Use small icons (24-48px)
   - Compress notification images
   - Avoid large embedded images

### Accessibility

1. **Clear Labels**
   - All controls should have descriptive names
   - Labels should be readable at small sizes

2. **Color is Secondary**
   - Don't rely solely on color to convey information
   - Use icons and text labels

3. **Touch Target Size**
   - Ensure controls are large enough to tap
   - Minimum 44x44 pixels
   - Add padding if needed

4. **Screen Reader Support**
   - Controls include semantic labels
   - State changes are announced

### Security Best Practices

1. **Confirmation for Critical Actions**
   - Always confirm destructive actions
   - Confirm expensive operations
   - Confirm security/safety changes

2. **Secure Credentials**
   - Store API keys in Settings, not hardcoded
   - Use variables: `{{apiKey}}`
   - Never expose keys in logs

3. **Limit Permissions**
   - Only give controls necessary permissions
   - Separate admin controls
   - Use different API keys per function

4. **Validate Inputs**
   - Always validate input controls
   - Set reasonable ranges on sliders
   - Sanitize text inputs server-side

---

## Quick Reference

### Control Type Matrix

| Feature | Button | Toggle | Slider | Input | Dropdown |
|---------|--------|--------|--------|-------|----------|
| **Interaction** | Tap | Tap | Drag | Type | Select |
| **State** | None | Binary | Range | Custom | Selected |
| **Best For** | Actions | On/Off | Ranges | Custom Data | Options |
| **Confirmation** | Yes | Yes | No* | Optional | Optional |
| **Variables** | No | Current State | Value | Text | Selected Value |

*Not typically needed for sliders

### Icon Suggestions

| Use Case | Icon | Unicode |
|----------|------|---------|
| **Lights** | 💡 lightbulb | U+1F4A1 |
| **Power** | ⚡ power | U+26A1 |
| **Lock** | 🔒 lock | U+1F512 |
| **Temperature** | 🌡️ thermometer | U+1F321 |
| **Volume** | 🔊 volume | U+1F50A |
| **Camera** | 📷 camera | U+1F4F7 |
| **Notification** | 🔔 bell | U+1F514 |
| **Home** | 🏠 home | U+1F3E0 |
| **Settings** | ⚙️ gear | U+2699 |

### Common Patterns

**Light Control:**
- Toggle for on/off
- Slider for brightness (0-100%)
- Dropdown for scenes

**Climate Control:**
- Toggle for on/off
- Slider for temperature (60-85°F)
- Dropdown for mode (heat/cool/auto)

**Media Control:**
- Button for play/pause
- Slider for volume (0-100)
- Dropdown for input source

**Security:**
- Toggle for arm/disarm (with confirmation)
- Button for panic (with confirmation)
- Dropdown for mode (home/away/night)

---

**Continue exploring:** See the [User Guide](USER_GUIDE.md) for complete feature documentation and the [Troubleshooting Guide](TROUBLESHOOTING.md) for solving common issues.
