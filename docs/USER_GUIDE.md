# Rmotly User Guide

Complete guide to using all features of the Rmotly mobile app.

## Table of Contents

- [Dashboard Overview](#dashboard-overview)
- [Creating Controls](#creating-controls)
- [Managing Controls](#managing-controls)
- [Creating Actions](#creating-actions)
- [Using Actions](#using-actions)
- [OpenAPI Import](#openapi-import)
- [Notification Topics](#notification-topics)
- [Settings](#settings)

## Dashboard Overview

The dashboard is your main workspace where all your controls are displayed.

### Main Interface

```
┌─────────────────────────────────┐
│  ☰  Rmotly          🔍  ⚙️      │ ← Header
├─────────────────────────────────┤
│                                 │
│   ┌──────┐  ┌──────┐  ┌──────┐ │
│   │Light │  │ Fan  │  │ Lock │ │
│   │  💡  │  │  🌀  │  │  🔒  │ │ ← Control Cards
│   └──────┘  └──────┘  └──────┘ │
│                                 │
│   ┌──────┐  ┌──────┐           │
│   │Garage│  │Camera│           │
│   │  🚗  │  │  📷  │           │
│   └──────┘  └──────┘           │
│                                 │
├─────────────────────────────────┤
│              [+]                │ ← Add Button
└─────────────────────────────────┘
```

### Navigation

| Action | How To |
|--------|--------|
| **Open menu** | Tap the ☰ (hamburger menu) icon |
| **Search controls** | Tap the 🔍 (search) icon |
| **Open settings** | Tap the ⚙️ (settings) icon |
| **Add control** | Tap the **+** (add) button |
| **Trigger control** | Tap a control card |
| **Edit control** | Long-press a control card → **Edit** |
| **Delete control** | Long-press a control card → **Delete** |
| **Reorder controls** | Long-press and drag to new position |

### Layout Options

Switch between different dashboard layouts:

1. **Grid View** (default)
   - Controls displayed in a grid
   - 2-3 columns depending on screen size
   - Compact and organized

2. **List View**
   - Controls displayed in a vertical list
   - One control per row
   - More detailed information visible

3. **Compact View**
   - Smaller control cards
   - More controls visible at once
   - Good for dashboards with many items

**To change layout:**
1. Tap the menu icon (☰)
2. Select **View Options**
3. Choose your preferred layout
4. Tap **Apply**

### Pull to Refresh

Swipe down on the dashboard to:
- Reload controls from the server
- Refresh control states
- Sync any pending changes

## Creating Controls

Controls are the interactive elements on your dashboard that trigger actions.

### Control Creation Flow

```
1. Choose Control Type
   ↓
2. Configure Basic Settings (name, icon, color)
   ↓
3. Select or Create Action
   ↓
4. Configure Control-Specific Settings
   ↓
5. Save Control
```

### Step-by-Step: Creating Any Control

#### 1. Start Control Creation

**Option A: From Dashboard**
- Tap the **+ (add)** button at the bottom

**Option B: From Menu**
- Tap the menu icon (☰)
- Select **Add Control**

#### 2. Choose Control Type

Select the type that matches your use case:

| Control Type | Icon | When to Use |
|--------------|------|-------------|
| **Button** | 🔘 | Single action, one tap execution |
| **Toggle** | 🔄 | On/off states, switch actions |
| **Slider** | ━━◉━━ | Range values, adjustments |
| **Input** | 📝 | Text entry, custom data |
| **Dropdown** | ▼ | Multiple predefined options |

See the [Controls Guide](CONTROLS_GUIDE.md) for detailed information about each type.

#### 3. Configure Basic Settings

All controls share these common settings:

**Control Name** (required)
- Displayed on the dashboard
- Should be descriptive and concise
- Example: `Living Room Light`, `Garage Door`

**Icon** (optional)
- Visual representation of the control
- Tap icon selector to browse available icons
- Search by name (e.g., "light", "home", "music")
- Choose icons that are easily recognizable

**Color** (optional)
- Accent color for the control card
- Use colors to categorize or prioritize
- Example: Red for critical, Green for lights, Blue for climate

**Description** (optional)
- Additional information about the control
- Displayed when viewing control details
- Example: `Controls the main living room overhead light`

#### 4. Select or Create Action

Each control must be linked to an action:

**Option A: Select Existing Action**
1. Tap **Select Action**
2. Browse your saved actions
3. Tap an action to select it
4. Continue to control-specific settings

**Option B: Create New Action**
1. Tap **Create New Action**
2. Fill in action details (see [Creating Actions](#creating-actions))
3. Save the action
4. Continue to control-specific settings

**Option C: Import from OpenAPI**
1. Tap **Import from OpenAPI**
2. Follow the import wizard (see [OpenAPI Import](#openapi-import))
3. Continue to control-specific settings

#### 5. Configure Control-Specific Settings

Each control type has unique settings. See the [Controls Guide](CONTROLS_GUIDE.md) for details.

#### 6. Preview and Save

1. **Preview your control:**
   - See how it will appear on the dashboard
   - Test the interaction (tap, slide, etc.)

2. **Save the control:**
   - Tap **Save** or **Create Control**
   - The control appears on your dashboard
   - You can now use it immediately

### Quick Tips

- **Start simple:** Create basic controls first, add complexity later
- **Meaningful names:** Use clear, descriptive names for easy identification
- **Test actions:** Use the action test feature before creating controls
- **Organize thoughtfully:** Group related controls together
- **Use colors wisely:** Create a consistent color scheme

## Managing Controls

### Editing Controls

**To edit an existing control:**

1. **Long-press** the control card
2. Select **Edit** from the context menu
3. Make your changes:
   - Update name, icon, or color
   - Change the linked action
   - Modify control-specific settings
4. Tap **Save**

**Quick edit:**
- Some settings can be changed directly from long-press menu
- Example: Rename, change color, toggle enable/disable

### Reordering Controls

Organize your dashboard by dragging controls:

1. **Long-press** a control card
2. Wait for the card to lift (haptic feedback)
3. **Drag** to the desired position
4. **Release** to drop in place

The new order is automatically saved to the server.

**Tips:**
- Group related controls together (e.g., all lights, all locks)
- Put frequently-used controls at the top
- Consider creating a logical flow for common tasks

### Duplicating Controls

Create a copy of an existing control:

1. **Long-press** the control card
2. Select **Duplicate**
3. The app creates a copy with " (Copy)" appended to the name
4. Edit the duplicate to customize it

**Use cases:**
- Similar controls for different rooms
- Variations with different settings
- Testing changes without affecting the original

### Enabling/Disabling Controls

Temporarily disable controls without deleting them:

1. **Long-press** the control card
2. Select **Disable** or **Enable**
3. Disabled controls appear grayed out
4. They remain on the dashboard but cannot be triggered

**Use cases:**
- Seasonal controls (holiday lights, AC)
- Maintenance mode
- Testing without deletion

### Deleting Controls

**To delete a single control:**

1. **Long-press** the control card
2. Select **Delete**
3. Confirm deletion in the dialog
4. The control is removed permanently

**To delete multiple controls:**

1. Tap the menu icon (☰)
2. Select **Select Controls**
3. Tap controls to select them (checkmark appears)
4. Tap the **Delete** icon
5. Confirm deletion

⚠️ **Warning:** Deleting a control cannot be undone. The linked action is not deleted.

### Searching Controls

Find controls quickly using search:

1. Tap the **🔍 (search)** icon
2. Type the control name or description
3. Matching controls are filtered in real-time
4. Tap a control to dismiss search

**Search tips:**
- Search works on names and descriptions
- Partial matches are supported
- Search is case-insensitive

### Exporting and Importing

#### Export Your Configuration

Backup your controls for safekeeping or transfer:

1. Go to **Settings** → **Data**
2. Tap **Export Controls**
3. Choose export format:
   - **JSON** - Standard format, full detail
   - **YAML** - Human-readable format
4. Choose save location
5. File is saved as `rmotly-controls-[date].json` (or `.yaml`)

#### Import Configuration

Restore or transfer controls:

1. Go to **Settings** → **Data**
2. Tap **Import Controls**
3. Select the exported file
4. Choose import mode:
   - **Merge** - Add to existing controls
   - **Replace** - Delete existing and import
5. Tap **Import**
6. Review import summary

⚠️ **Note:** Actions referenced by controls must exist or be imported separately.

## Creating Actions

Actions define HTTP requests executed when controls are triggered.

### Action Creation Basics

```
Action Components:
├── Name & Description
├── HTTP Method (GET, POST, PUT, DELETE, PATCH)
├── URL (with optional template variables)
├── Headers (optional)
├── Request Body (optional, for POST/PUT/PATCH)
└── Parameters (variable definitions)
```

### Step-by-Step: Manual Action Creation

#### 1. Open Action Editor

**Option A: From Actions Screen**
1. Tap menu icon (☰)
2. Select **Actions**
3. Tap **+ (add)** button

**Option B: From Control Editor**
1. While creating/editing a control
2. Tap **Create New Action**

#### 2. Basic Information

**Action Name** (required)
- Descriptive name for the action
- Example: `Toggle Living Room Light`, `Send Alert`

**Description** (optional)
- Explains what the action does
- Example: `Toggles the main living room light using Home Assistant API`

#### 3. Configure HTTP Request

**HTTP Method**

Select the appropriate method:

| Method | Use Case | Has Body |
|--------|----------|----------|
| **GET** | Retrieve data, query status | No |
| **POST** | Create resources, submit data | Yes |
| **PUT** | Update/replace entire resource | Yes |
| **PATCH** | Partial update of resource | Yes |
| **DELETE** | Remove resource | No |

**URL**

Enter the full URL of the endpoint:

```
https://homeassistant.local/api/services/light/toggle
```

**With variables:**
```
https://api.example.com/devices/{{deviceId}}/state
```

**Tips:**
- Include protocol (`https://` or `http://`)
- Use template variables for dynamic values: `{{variableName}}`
- Test URLs in browser or curl first

#### 4. Headers (Optional)

Add HTTP headers as key-value pairs:

**Common headers:**

| Header | Purpose | Example |
|--------|---------|---------|
| `Authorization` | Authentication | `Bearer {{apiToken}}` |
| `Content-Type` | Body format | `application/json` |
| `Accept` | Response format | `application/json` |
| `User-Agent` | Client identification | `Rmotly/1.0` |
| `X-API-Key` | API key auth | `{{apiKey}}` |

**To add a header:**
1. Tap **Add Header**
2. Enter header name (e.g., `Authorization`)
3. Enter header value (e.g., `Bearer my_token`)
4. Repeat for additional headers

**Example header configuration:**
```
Authorization: Bearer {{homeAssistantToken}}
Content-Type: application/json
Accept: application/json
```

#### 5. Request Body (POST/PUT/PATCH)

For methods that accept a body, define the payload:

**JSON Format (most common):**
```json
{
  "entity_id": "light.living_room",
  "brightness": {{brightness}}
}
```

**Form Data:**
```
field1=value1&field2={{value2}}
```

**Raw Text:**
```
Any plain text content
```

**Tips:**
- Use proper JSON syntax (check with a validator)
- Use template variables for dynamic content: `{{variable}}`
- Format JSON for readability (the app will minify it)

#### 6. Define Parameters

Parameters are variables used in URLs, headers, or body.

**To add a parameter:**
1. Tap **Add Parameter**
2. Fill in parameter details:

**Parameter Name** (required)
- Variable name used in templates
- Example: `deviceId`, `brightness`, `apiToken`

**Type**
- **String** - Text values
- **Number** - Numeric values
- **Boolean** - true/false
- **Control Value** - Value from the control itself

**Default Value** (optional)
- Used when no value is provided
- Example: `100` for brightness, `device_123` for deviceId

**Location**
- **URL** - Substituted in URL template
- **Header** - Substituted in header value
- **Body** - Substituted in request body

**Required**
- Enable if parameter must have a value
- Validation fails if missing

**Example parameter configuration:**
```
Name: apiToken
Type: String
Default: (leave empty)
Location: Header
Required: Yes
Description: Home Assistant Long-Lived Access Token
```

#### 7. Test Your Action

Before saving, test the action:

1. Tap **Test Action**
2. Fill in test values for parameters
3. Tap **Execute Test**
4. Review results:
   - **Status code** (200 = success)
   - **Response headers**
   - **Response body**
   - **Execution time**

**Interpreting status codes:**

| Code | Meaning |
|------|---------|
| **200-299** | Success |
| **400-499** | Client error (check request) |
| **500-599** | Server error |

**Common issues:**
- **401 Unauthorized** - Check authentication headers
- **404 Not Found** - Verify URL is correct
- **422 Unprocessable** - Check body format
- **Timeout** - Increase timeout or check server

#### 8. Save Action

1. Review all settings
2. Tap **Save Action**
3. Action is added to your action library
4. Now available for use in controls

### Complete Example: Home Assistant Light Control

```yaml
Action Configuration:
  Name: Toggle Living Room Light
  Description: Controls the main living room overhead light
  
  HTTP Method: POST
  URL: https://homeassistant.local/api/services/light/toggle
  
  Headers:
    Authorization: Bearer {{haToken}}
    Content-Type: application/json
  
  Body:
    {
      "entity_id": "light.living_room"
    }
  
  Parameters:
    - Name: haToken
      Type: String
      Location: Header
      Required: Yes
      Description: Home Assistant API token
```

## Using Actions

### Built-in Variables

Rmotly provides several built-in variables available in all actions:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `{{controlValue}}` | Current value from control | `true`, `75`, `"hello"` |
| `{{controlId}}` | ID of triggering control | `ctrl_abc123` |
| `{{controlName}}` | Name of triggering control | `Living Room Light` |
| `{{timestamp}}` | ISO 8601 timestamp | `2025-01-14T10:30:00Z` |
| `{{timestampMs}}` | Unix timestamp (ms) | `1705227000000` |
| `{{userId}}` | Current user ID | `user_xyz789` |

### Template Variable Syntax

Use double curly braces for variable substitution:

**In URLs:**
```
https://api.example.com/devices/{{deviceId}}/control
```

**In headers:**
```
Authorization: Bearer {{apiToken}}
X-Request-ID: {{timestamp}}
```

**In JSON body:**
```json
{
  "device": "{{deviceId}}",
  "value": {{controlValue}},
  "user": "{{userId}}"
}
```

### Variable Substitution Rules

1. **String values** are quoted in JSON:
   ```json
   "name": "{{deviceName}}"  →  "name": "Living Room"
   ```

2. **Numeric values** are unquoted:
   ```json
   "value": {{brightness}}  →  "value": 75
   ```

3. **Boolean values** are unquoted:
   ```json
   "enabled": {{isEnabled}}  →  "enabled": true
   ```

4. **Missing variables** cause execution to fail

### Conditional Logic

Use control-specific logic for conditional behavior:

**Example: Toggle-based conditional**
```json
{
  "state": "{{controlValue}}",
  "action": "{{controlValue ? 'turn_on' : 'turn_off'}}"
}
```

Note: Advanced conditionals may require server-side implementation.

### Advanced Templating

#### Nested Object Access

Access nested properties with dot notation:

```
{{device.id}}
{{user.settings.theme}}
```

#### Array Access

Access array elements by index:

```
{{items[0]}}
{{devices[2].name}}
```

#### Default Values

Provide fallback values:

```
{{brightness || 100}}
{{deviceId || 'default_device'}}
```

### Testing Actions

#### Test from Actions Screen

1. Go to **Menu** → **Actions**
2. Find your action in the list
3. Tap the **test icon** (▶️)
4. Fill in parameter values
5. Tap **Run Test**
6. View results

#### Test from Control

1. Long-press the control
2. Select **Test Action**
3. Results appear in a dialog

#### View Action History

See recent action executions:

1. Go to **Menu** → **Actions**
2. Tap an action
3. Select **History** tab
4. View:
   - Timestamp of execution
   - Status code and result
   - Parameter values used
   - Response time

### Debugging Failed Actions

When an action fails:

1. **Check the error message:**
   - Displayed in the control's response
   - May indicate specific problem

2. **View detailed logs:**
   - Long-press control → **View Last Result**
   - Shows full request and response

3. **Common issues:**

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| **Network error** | No internet or server unreachable | Check connectivity |
| **401 Unauthorized** | Invalid credentials | Verify API token/key |
| **404 Not Found** | Wrong URL | Check endpoint spelling |
| **422 Validation** | Invalid body format | Validate JSON syntax |
| **Timeout** | Slow or unresponsive server | Increase timeout setting |

4. **Test externally:**
   - Use curl or Postman
   - Verify request works outside Rmotly
   - Compare request format

## OpenAPI Import

Import API endpoints from OpenAPI (Swagger) specifications automatically.

### What is OpenAPI Import?

OpenAPI Import lets you:
- Automatically create actions from API documentation
- Import entire API specifications at once
- Pre-fill URLs, methods, and parameters
- Save time on manual configuration

### Supported Formats

- **OpenAPI 3.0+** (recommended)
- **OpenAPI 2.0** (Swagger)
- JSON or YAML format
- Accessible via URL or file

### Step-by-Step: Import from OpenAPI

#### 1. Start Import Wizard

**Option A: From Actions Screen**
1. Tap menu (☰) → **Actions**
2. Tap the **import icon** (⬇️)
3. Select **Import from OpenAPI**

**Option B: From Control Editor**
1. While creating a control
2. Tap **Import from OpenAPI**

#### 2. Provide OpenAPI Specification

**Option A: Enter URL**
1. Select **URL** tab
2. Enter the spec URL:
   ```
   https://api.example.com/openapi.json
   ```
   or
   ```
   https://api.example.com/docs/swagger.yaml
   ```
3. Tap **Load Specification**

**Option B: Upload File**
1. Select **File** tab
2. Tap **Choose File**
3. Navigate to your OpenAPI file
4. Select the file
5. Tap **Load Specification**

**Option C: Paste Content**
1. Select **Paste** tab
2. Paste the OpenAPI specification (JSON or YAML)
3. Tap **Parse Specification**

#### 3. Browse Available Operations

The app displays all API operations found:

```
┌────────────────────────────────────┐
│ API: Example API v1.0              │
├────────────────────────────────────┤
│ 🟢 GET    /users                   │
│     List all users                 │
│                                    │
│ 🟢 GET    /users/{id}              │
│     Get user by ID                 │
│                                    │
│ 🟡 POST   /users                   │
│     Create new user                │
│                                    │
│ 🟠 PUT    /users/{id}              │
│     Update user                    │
│                                    │
│ 🔴 DELETE /users/{id}              │
│     Delete user                    │
└────────────────────────────────────┘
```

**Filter operations:**
- Search by path or description
- Filter by HTTP method
- Filter by tag/category

#### 4. Select Operations to Import

**Single operation:**
1. Tap an operation to select it
2. Proceed to configuration

**Multiple operations:**
1. Tap **Select Multiple**
2. Tap operations to select (checkmark appears)
3. Tap **Import Selected**
4. Actions are created for all selections

#### 5. Configure Action

For each operation, customize the action:

**Action Name**
- Pre-filled from operation summary
- Edit to make it descriptive
- Example: `List All Users` → `Get Users`

**Server URL**
- Pre-filled from spec's servers
- Select if multiple servers available
- Can be overridden

**Parameters**
- All parameters are automatically detected
- Set default values for path parameters
- Configure required vs. optional parameters

**Authentication**
- Pre-filled if spec includes security schemes
- Options: API key, Bearer token, Basic auth
- Enter credentials or use variables

**Example configuration:**
```
Operation: GET /users/{id}
↓
Action Name: Get User Details
Server: https://api.example.com
Parameters:
  - id: (required, path parameter)
  - apiKey: (required, header: X-API-Key)
Headers:
  - Authorization: Bearer {{apiToken}}
```

#### 6. Test Imported Action

Before saving:

1. Tap **Test Action**
2. Enter test values:
   - Path parameters (e.g., `id: 123`)
   - Authentication credentials
3. Tap **Run Test**
4. Verify response is correct

#### 7. Save Imported Action

1. Review configuration
2. Tap **Save Action**
3. Action is added to your library
4. Create a control to use it

### Tips for OpenAPI Import

1. **Check spec quality:**
   - Well-documented specs import more cleanly
   - Missing descriptions require manual naming

2. **Server selection:**
   - Choose production server for live use
   - Choose staging/dev for testing

3. **Authentication:**
   - Store credentials securely in Settings
   - Use variables instead of hardcoding tokens

4. **Batch import:**
   - Import all related operations at once
   - Easier to manage related actions together

5. **Review imported actions:**
   - Check parameter defaults make sense
   - Test thoroughly before creating controls

### Troubleshooting OpenAPI Import

| Issue | Solution |
|-------|----------|
| **Cannot load spec** | Check URL is accessible, CORS enabled |
| **Parse error** | Verify spec is valid OpenAPI/Swagger format |
| **Missing operations** | Check spec version (3.0+ recommended) |
| **No servers listed** | Add server URL manually |
| **Auth not working** | Verify security scheme is supported |

## Notification Topics

Receive notifications from external systems via webhooks.

### What are Notification Topics?

Topics are channels for receiving notifications:
- Each topic has a unique webhook URL
- External systems POST notifications to this URL
- Notifications are delivered to your device in real-time
- Supports multiple notification formats automatically

### Creating Topics

#### Step 1: Open Topics Screen

1. Tap menu (☰)
2. Select **Notification Topics**
3. Tap **+ (add)** button

#### Step 2: Configure Topic

**Topic Name** (required)
- Descriptive name for the topic
- Example: `Server Alerts`, `Order Notifications`

**Description** (optional)
- Explains what this topic is for
- Example: `Critical alerts from production servers`

**Icon** (optional)
- Visual identifier for notifications
- Used in notification display

**Channel Settings:**

**Priority**
- **Low** - Silent, no sound or vibration
- **Normal** - Default notification sound
- **High** - Priority sound, prominent display
- **Urgent** - Bypass Do Not Disturb

**Sound**
- Choose notification sound
- Options: default, alert, chime, custom

**Vibration**
- Enable/disable vibration
- Vibration pattern (for supported devices)

#### Step 3: Template Configuration (Optional)

Customize how webhook data is displayed:

**Title Template**
```
{{title}}
```
or
```
Alert: {{severity}} - {{message}}
```

**Body Template**
```
{{body}}
```
or
```
{{message}} from {{source}} at {{timestamp}}
```

Templates use JSONPath-like syntax to extract fields from webhook payloads.

#### Step 4: Save Topic

1. Review settings
2. Tap **Create Topic**
3. Topic is created with webhook credentials

### Using Webhook URLs

After creating a topic, you'll see:

#### Webhook URL
```
https://api.yourdomain.com/api/notify/topic_abc123
```

#### API Key
```
rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx
```

### Sending Notifications

Send notifications using HTTP POST:

#### Basic Notification

```bash
curl -X POST https://api.yourdomain.com/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Server Alert",
    "message": "CPU usage exceeded 90%"
  }'
```

#### With Priority

```bash
curl -X POST https://api.yourdomain.com/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Critical Alert",
    "message": "Database connection lost",
    "priority": "urgent"
  }'
```

#### With Image

```bash
curl -X POST https://api.yourdomain.com/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Motion Detected",
    "message": "Front door camera triggered",
    "image": "https://camera.example.com/snapshot.jpg"
  }'
```

#### With Action URL

```bash
curl -X POST https://api.yourdomain.com/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Order",
    "message": "Order #12345 received",
    "url": "app://orders/12345"
  }'
```

### Supported Formats

Rmotly automatically detects these notification formats:

1. **Generic/Standard**
   ```json
   {"title": "...", "message": "..."}
   ```

2. **Firebase Cloud Messaging**
   ```json
   {"notification": {"title": "...", "body": "..."}}
   ```

3. **Pushover**
   ```json
   {"title": "...", "message": "...", "priority": 1}
   ```

4. **ntfy**
   ```json
   {"topic": "...", "title": "...", "message": "..."}
   ```

5. **Gotify**
   ```json
   {"title": "...", "message": "...", "extras": {...}}
   ```

6. **Home Assistant**
   ```json
   {"title": "...", "message": "...", "data": {...}}
   ```

See the [API Documentation](API.md#webhooks) for complete format specifications.

### Managing Topics

#### Edit Topic

1. Tap a topic in the list
2. Modify settings
3. Tap **Save**

**Note:** Editing does not change webhook URL or API key.

#### Regenerate API Key

If your API key is compromised:

1. Tap a topic
2. Select **Regenerate API Key**
3. Confirm regeneration
4. **Update external services** with new key
5. Old key stops working immediately

#### Disable Topic

Temporarily stop receiving notifications:

1. Tap a topic
2. Toggle **Enabled** off
3. Webhook still accepts requests but notifications are not delivered

#### Delete Topic

Permanently remove a topic:

1. Long-press a topic
2. Select **Delete**
3. Confirm deletion
4. Webhook URL stops working

⚠️ **Warning:** Deletion cannot be undone. External services will get 404 errors.

### Push Notification Setup

For notifications when the app is closed, configure push notifications.

#### Three-Tier Notification Delivery

Rmotly uses a layered approach:

1. **Tier 1: WebSocket (Live)**
   - Active when app is open
   - Real-time, instant delivery
   - No configuration needed

2. **Tier 2: UnifiedPush (Background)**
   - Active when app is closed
   - Battery-efficient
   - Requires distributor setup

3. **Tier 3: SSE Fallback**
   - Active in restricted networks
   - Polling-based
   - Automatic fallback

#### Configure UnifiedPush

**Step 1: Install a Distributor**

Choose a push notification distributor:

- **ntfy** (recommended for privacy)
  - Self-hosted option available
  - Free public server: ntfy.sh
  - No Google services required

- **FCM** (Google Firebase)
  - Uses Google's infrastructure
  - Requires Google Play Services
  - Opt-in only

- **Other UnifiedPush distributors**
  - NextPush (Nextcloud)
  - UP-FCM (UnifiedPush via FCM)

**Step 2: Configure in Rmotly**

1. Go to **Settings** → **Notifications**
2. Tap **Configure Push Notifications**
3. Select your distributor
4. Follow distributor-specific setup
5. Grant notification permissions
6. Test push notifications

**Step 3: Test Push**

1. In **Settings** → **Notifications**
2. Tap **Send Test Notification**
3. Close the app completely
4. You should receive a test notification

#### Self-Hosted Push (ntfy)

If your server includes ntfy:

1. Your admin provides the ntfy server URL
2. In Rmotly settings, select **ntfy (Self-Hosted)**
3. Enter server URL: `https://push.yourdomain.com`
4. Tap **Connect**
5. Push is configured!

**Benefits:**
- Complete privacy
- No third-party dependencies
- Included in Rmotly docker-compose stack

### Notification Preferences

Configure how notifications appear:

1. Go to **Settings** → **Notifications**

**General Settings:**
- Enable/disable all notifications
- Notification sound
- Vibration
- LED color (supported devices)

**Do Not Disturb:**
- Quiet hours (e.g., 10 PM - 7 AM)
- Urgent notifications override
- Weekend mode

**Per-Topic Settings:**
- Override sound per topic
- Override priority per topic
- Mute specific topics

**Badges:**
- Show unread count on app icon
- Clear badge on open
- Auto-clear after time

### Troubleshooting Notifications

#### Not Receiving Notifications

1. **Check topic is enabled:**
   - Go to **Notification Topics**
   - Verify topic toggle is ON

2. **Check notification permissions:**
   - Go to device Settings → Apps → Rmotly → Notifications
   - Ensure notifications are allowed

3. **Test webhook:**
   - Use curl to send test notification
   - Check app displays it when open

4. **Check push setup:**
   - Go to Settings → Notifications
   - Verify push distributor is connected
   - Send test push notification

5. **Check Do Not Disturb:**
   - Verify device is not in DND mode
   - Or configure urgent priority to override

#### Notifications Delayed

1. **Check device battery settings:**
   - Remove Rmotly from battery optimization
   - Settings → Battery → Battery optimization → Rmotly → Don't optimize

2. **Check push distributor:**
   - ntfy and other distributors may have delays
   - FCM is generally fastest

3. **Check network:**
   - Poor connection causes delays
   - Switch to Wi-Fi if on cellular

#### Duplicate Notifications

1. **Check multiple topic subscriptions:**
   - Webhook may be configured in multiple places
   - Each delivers a notification

2. **Check distributor configuration:**
   - Ensure only one distributor is active
   - Multiple can cause duplicates

## Settings

Configure app preferences and account settings.

### Account Settings

#### View Profile

1. Go to **Settings** → **Account**
2. View your account information:
   - Username
   - Email
   - Account created date
   - Server URL

#### Change Password

1. Go to **Settings** → **Account** → **Change Password**
2. Enter current password
3. Enter new password
4. Confirm new password
5. Tap **Update Password**

**Password requirements:**
- Minimum 8 characters
- Mix of uppercase and lowercase
- At least one number
- At least one special character

#### Update Email

1. Go to **Settings** → **Account** → **Update Email**
2. Enter new email address
3. Tap **Send Verification**
4. Check your new email inbox
5. Enter verification code
6. Tap **Verify and Update**

#### Logout

1. Go to **Settings** → **Account**
2. Tap **Logout**
3. Confirm logout
4. You return to login screen

**Note:** Logging out does not delete your data from the server.

#### Delete Account

⚠️ **Permanent action - cannot be undone**

1. Go to **Settings** → **Account** → **Delete Account**
2. Read the warning carefully
3. Enter your password to confirm
4. Tap **Delete My Account**
5. All your data is permanently removed

### Appearance Settings

#### Theme

1. Go to **Settings** → **Appearance** → **Theme**
2. Choose:
   - **Light** - Light theme always
   - **Dark** - Dark theme always
   - **System** - Follow device theme
   - **Auto** - Light during day, dark at night

#### Control Size

1. Go to **Settings** → **Appearance** → **Control Size**
2. Choose:
   - **Small** - Compact controls, more per screen
   - **Medium** - Balanced (default)
   - **Large** - Larger, easier to tap

#### Dashboard Layout

1. Go to **Settings** → **Appearance** → **Dashboard Layout**
2. Choose:
   - **Grid** - Multi-column grid (default)
   - **List** - Single-column list
   - **Compact** - Dense grid

#### Control Animations

1. Go to **Settings** → **Appearance**
2. Toggle **Control Animations**
   - ON: Smooth transitions and feedback
   - OFF: Instant, no animations (saves battery)

### Notification Settings

See [Notification Topics - Notification Preferences](#notification-preferences) for details.

### Security Settings

#### Action Credentials

Store API keys and tokens securely:

1. Go to **Settings** → **Security** → **Credentials**
2. Tap **Add Credential**
3. Enter:
   - **Name**: Variable name (e.g., `haToken`)
   - **Value**: The actual token/key
   - **Type**: API Key, Bearer Token, or Custom
4. Tap **Save**

Use credentials in actions:
```
Authorization: Bearer {{haToken}}
```

**Security features:**
- Encrypted storage (AES-256)
- Never logged or exposed
- Synced securely to server

#### Biometric Lock

Require fingerprint/face to open app:

1. Go to **Settings** → **Security** → **App Lock**
2. Toggle **Biometric Lock** ON
3. Configure timeout:
   - **Immediate** - Lock when leaving app
   - **1 minute** - Lock after 1 minute
   - **5 minutes** - Lock after 5 minutes
   - **Never** - Only lock when device locks

**Note:** Requires biometric authentication set up on device.

#### Auto-Lock Controls

Prevent accidental control triggers:

1. Go to **Settings** → **Security** → **Control Protection**
2. Enable options:
   - **Confirmation for critical** - Confirm before executing critical actions
   - **Lock controls when locked** - Disable controls when app is locked
   - **Require password for delete** - Password required to delete controls

### Data Settings

#### Sync Settings

1. Go to **Settings** → **Data** → **Sync**
2. Configure:
   - **Auto-sync** - Sync changes automatically
   - **Sync interval** - How often to sync (1/5/15 minutes)
   - **Sync on Wi-Fi only** - Save mobile data

#### Cache Settings

1. Go to **Settings** → **Data** → **Cache**
2. Options:
   - **Clear cache** - Remove cached data
   - **Cache size limit** - Maximum cache storage
   - **Cache images** - Cache notification images

#### Export Data

See [Managing Controls - Exporting and Importing](#exporting-and-importing)

#### Import Data

See [Managing Controls - Exporting and Importing](#exporting-and-importing)

### Advanced Settings

#### Network

1. Go to **Settings** → **Advanced** → **Network**
2. Configure:
   - **Timeout** - Request timeout (5-60 seconds)
   - **Retry attempts** - Failed request retries (0-5)
   - **Connection type** - WebSocket, SSE, or Auto

#### Logging

1. Go to **Settings** → **Advanced** → **Logging**
2. Options:
   - **Enable debug logs** - Detailed logging for troubleshooting
   - **Export logs** - Save logs for support
   - **Clear logs** - Remove all logs

#### Developer Options

1. Go to **Settings** → **Advanced** → **Developer**
2. Options:
   - **Show action IDs** - Display internal IDs
   - **API inspector** - View raw API requests/responses
   - **Test mode** - Enable testing features

### About

View app information:

1. Go to **Settings** → **About**
2. See:
   - App version
   - Server version
   - License information
   - Privacy policy
   - Terms of service
   - Open source licenses

**Check for Updates:**
- Tap **Check for Updates**
- Follow prompts if update available

---

## Getting Help

### In-App Help

- Tap **?** icon on any screen for contextual help
- Long-press labels for tooltips
- Check Settings → Help & Support

### Documentation

- **[Getting Started Guide](GETTING_STARTED.md)** - First-time setup
- **[Controls Guide](CONTROLS_GUIDE.md)** - Detailed control documentation
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Common issues and solutions
- **[API Documentation](API.md)** - Technical API reference

### Support

- Contact your server administrator for server-related issues
- Check the project repository for updates and known issues
- Submit bug reports with debug logs (Settings → Advanced → Export Logs)

---

**Continue learning:** See the [Controls Guide](CONTROLS_GUIDE.md) for detailed information about each control type.
