# Troubleshooting Guide

Solutions to common problems when using the Rmotly mobile app.

## Table of Contents

- [Connection Issues](#connection-issues)
- [Authentication Issues](#authentication-issues)
- [Control Issues](#control-issues)
- [Notification Issues](#notification-issues)
- [Offline Mode](#offline-mode)
- [Performance Issues](#performance-issues)
- [Data Sync Issues](#data-sync-issues)
- [Getting Help](#getting-help)

## Connection Issues

### Cannot Connect to Server

**Symptoms:**
- "Unable to connect to server" error
- Connection timeout
- App stuck on connecting screen

**Possible Causes & Solutions:**

#### 1. Incorrect Server URL

**Check:**
- Server URL includes protocol (`https://` or `http://`)
- No trailing slash: `https://api.example.com` (not `https://api.example.com/`)
- No typos in domain name
- Correct port if using non-standard port

**Test:**
```bash
# Try accessing server URL in a browser
https://your-server-url.com
```

**Fix:**
1. Go to **Settings** → **Server**
2. Tap **Edit Server URL**
3. Correct the URL
4. Tap **Test Connection**
5. Save if successful

#### 2. Server is Down or Unreachable

**Check:**
- Ask your administrator if server is running
- Check server status page if available
- Try accessing from another device

**Test:**
```bash
# Ping the server
ping api.example.com

# Check if port is open
telnet api.example.com 443
```

**Fix:**
- Wait for server to come back online
- Contact your administrator
- Check server logs (if you're the admin)

#### 3. Network Connection Problem

**Check:**
- Device has internet access
- Wi-Fi or cellular data is enabled
- Can access other websites/apps

**Test:**
1. Open web browser
2. Visit any website (e.g., google.com)
3. If it doesn't load, network issue is with your device

**Fix:**
- Enable Wi-Fi or cellular data
- Restart your device
- Forget and reconnect to Wi-Fi
- Check airplane mode is off

#### 4. Firewall or VPN Blocking

**Check:**
- Corporate VPN may block access
- Firewall rules may prevent connection
- Proxy settings may interfere

**Test:**
- Disable VPN temporarily
- Try from different network (cellular vs Wi-Fi)
- Try from outside corporate network

**Fix:**
- Add server to VPN whitelist
- Configure proxy settings in app
- Request firewall rule from IT

#### 5. SSL Certificate Issues

**Symptoms:**
- "SSL certificate error"
- "Certificate verification failed"
- Connection fails with HTTPS but works with HTTP

**Fix for self-signed certificates:**
1. **Option A:** Install certificate on device
   - Get certificate from administrator
   - Go to Settings → Security → Install certificate
   - Select the certificate file

2. **Option B:** Use HTTP (testing only)
   - Change URL to `http://` instead of `https://`
   - ⚠️ **Not recommended for production**

3. **Option C:** Get valid SSL certificate
   - Use Let's Encrypt for free certificates
   - Contact administrator to set up proper SSL

### Connection Drops Frequently

**Symptoms:**
- Connected then disconnects
- Must reconnect constantly
- WebSocket connection unstable

**Solutions:**

#### 1. Enable Keep-Alive

1. Go to **Settings** → **Advanced** → **Network**
2. Enable **Connection Keep-Alive**
3. Set interval to 30 seconds

#### 2. Switch Connection Type

1. Go to **Settings** → **Advanced** → **Network**
2. Change **Connection Type**:
   - Try **WebSocket** (default, best)
   - Try **SSE** if WebSocket blocked
   - Try **Polling** as last resort

#### 3. Check Network Stability

- Use Wi-Fi instead of cellular if unstable
- Move closer to router
- Restart router
- Contact ISP if persistent

#### 4. Battery Optimization

Android may kill connections to save battery:

1. Go to device **Settings** → **Battery**
2. Find **Battery Optimization**
3. Search for **Rmotly**
4. Select **Don't optimize** or **Unrestricted**

### Slow Connection

**Symptoms:**
- Controls respond slowly
- Notifications delayed
- Dashboard takes long to load

**Solutions:**

#### 1. Check Network Speed

**Test your connection:**
- Run speed test (Speedtest.net)
- Need at least 1 Mbps for basic functionality
- Higher speed recommended for images

**Fix:**
- Switch to faster network
- Move closer to Wi-Fi router
- Use cellular if Wi-Fi is slow

#### 2. Clear App Cache

1. Go to **Settings** → **Data** → **Cache**
2. Tap **Clear Cache**
3. Restart app

#### 3. Reduce Timeout

1. Go to **Settings** → **Advanced** → **Network**
2. Reduce **Request Timeout** to 10 seconds
3. Faster failure detection

#### 4. Check Server Load

- Server may be overloaded
- Contact administrator
- Check server logs/metrics

## Authentication Issues

### Cannot Login

**Symptoms:**
- "Invalid credentials" error
- Login button does nothing
- Stuck on login screen

**Solutions:**

#### 1. Incorrect Email or Password

**Check:**
- Email address is correct (no typos)
- Password is correct (check caps lock)
- Remember passwords are case-sensitive

**Fix:**
1. Double-check email and password
2. Try typing slowly and carefully
3. Use "Show password" toggle to verify

#### 2. Account Not Verified

**Symptoms:**
- "Please verify your email" message
- Login fails after registration

**Fix:**
1. Check your email inbox for verification
2. Check spam/junk folder
3. Tap **Resend Verification Email**
4. Enter verification code in app

#### 3. Account Locked or Disabled

**Symptoms:**
- "Account locked" message
- "Account disabled" message

**Fix:**
- Contact your administrator
- May be locked after too many failed attempts
- Wait 15-30 minutes and try again

#### 4. Password Forgotten

**To reset password:**

1. On login screen, tap **Forgot Password?**
2. Enter your email address
3. Tap **Send Reset Link**
4. Check email for reset link
5. Click link and create new password
6. Return to app and login with new password

**If reset email doesn't arrive:**
- Check spam/junk folder
- Verify email address is correct
- Contact administrator if still not received

### Session Expired

**Symptoms:**
- "Session expired" message
- Forced to login again
- Actions fail with auth error

**Solutions:**

#### 1. Normal Session Expiry

Sessions expire after period of inactivity.

**Fix:**
1. Login again with credentials
2. Session will be renewed

**To extend session time:**
1. Go to **Settings** → **Security**
2. Enable **Remember Me**
3. Session lasts longer

#### 2. Server Restarted

Server restart invalidates all sessions.

**Fix:**
1. Simply login again
2. Contact admin if happens frequently

#### 3. Clock Skew

Device time significantly different from server time.

**Fix:**
1. Go to device **Settings** → **Date & Time**
2. Enable **Automatic date & time**
3. Restart app

### Cannot Create Account

**Symptoms:**
- "Registration failed" error
- Verification code never arrives
- Error during sign-up

**Solutions:**

#### 1. Email Already Used

**Symptoms:**
- "Email already registered" message

**Fix:**
- Use different email address
- Or login with existing account
- Or reset password if you forgot

#### 2. Username Taken

**Symptoms:**
- "Username unavailable" message

**Fix:**
- Choose different username
- Try adding numbers: `john123` instead of `john`

#### 3. Password Requirements Not Met

**Requirements:**
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

**Fix:**
- Create stronger password
- Example: `MyPass@2024`

#### 4. Verification Email Not Arriving

**Check:**
- Email address is correct
- Check spam/junk folder
- Check email filters/rules

**Fix:**
1. Tap **Resend Verification**
2. Wait 5-10 minutes
3. If still not received:
   - Try different email provider
   - Contact administrator
   - Check server email configuration (admin)

## Control Issues

### Control Not Responding

**Symptoms:**
- Tap control, nothing happens
- Control appears grayed out
- No visual feedback

**Solutions:**

#### 1. Control is Disabled

**Check:**
- Control appears faded/grayed
- "Disabled" label visible

**Fix:**
1. Long-press the control
2. Select **Enable**

#### 2. Network Connection Lost

**Check:**
- Connection indicator in app
- Try other controls

**Fix:**
- Check network connection
- Reconnect to server
- See [Connection Issues](#connection-issues)

#### 3. Action Configuration Error

**Check:**
1. Long-press control
2. Select **Edit**
3. Verify action is selected

**Fix:**
1. Select or create a valid action
2. Test action separately
3. Save control

#### 4. Control in Cooldown

**Symptoms:**
- Button shows countdown
- "Wait X seconds" message

**Fix:**
- Wait for cooldown to expire
- Cooldown prevents rapid repeated actions

### Action Execution Fails

**Symptoms:**
- Control triggers but shows error
- "Action failed" message
- Red X indicator

**Solutions:**

#### 1. View Error Details

**To see what went wrong:**
1. Long-press the control
2. Select **View Last Result**
3. Read error message and status code

#### 2. Common HTTP Status Codes

| Code | Meaning | Solution |
|------|---------|----------|
| **400** | Bad Request | Check request body/parameters |
| **401** | Unauthorized | Check API key/token |
| **403** | Forbidden | Insufficient permissions |
| **404** | Not Found | Check URL is correct |
| **422** | Unprocessable | Check JSON format |
| **429** | Rate Limited | Wait and try again |
| **500** | Server Error | Check external service |
| **503** | Service Unavailable | Service is down |
| **Timeout** | Request timed out | Check network, increase timeout |

#### 3. Check Action Configuration

**Common issues:**

**Missing Parameters:**
- Action requires variable that's not provided
- Add required parameters to action

**Invalid URL:**
```
❌ api.example.com/endpoint
✅ https://api.example.com/endpoint
```
Always include protocol!

**Malformed JSON:**
```
❌ {name: {{value}}}
✅ {"name": "{{value}}"}
```
Use proper quotes!

**Wrong Headers:**
```
❌ Authorization: {{token}}
✅ Authorization: Bearer {{token}}
```
Check header format!

#### 4. Test Action Separately

**To isolate the problem:**

1. Go to **Menu** → **Actions**
2. Find the action
3. Tap **Test** icon
4. Fill in test parameters
5. Run test
6. Check results

If test fails, problem is with action configuration.
If test succeeds but control fails, problem is with control.

#### 5. Network Issues

**Symptoms:**
- Timeout errors
- Connection refused
- DNS resolution failed

**Fix:**
- Check target service is accessible
- Try URL in browser or curl
- Check firewall/VPN settings
- Verify DNS resolves correctly

**Test with curl:**
```bash
curl -X POST https://api.example.com/endpoint \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

### Variable Substitution Not Working

**Symptoms:**
- `{{variable}}` appears literally in request
- "Variable not found" error
- Unexpected values

**Solutions:**

#### 1. Variable Name Mismatch

**Check:**
- Variable name in template matches parameter name exactly
- Names are case-sensitive: `{{Value}}` ≠ `{{value}}`

**Example:**
```yaml
Parameter name: deviceId
Template: {{deviceId}}  ✅
Template: {{deviceID}}  ❌ (wrong case)
Template: {{device_id}} ❌ (wrong name)
```

#### 2. Variable Not Defined

**Check:**
- Variable is defined in action parameters
- Variable has default value if required

**Fix:**
1. Edit action
2. Go to **Parameters**
3. Add missing parameter
4. Save action

#### 3. Wrong Variable Location

**Check:**
- Variables in URL work only if parameter location is "URL"
- Variables in headers work only if location is "Header"
- Variables in body work only if location is "Body"

**Fix:**
1. Edit action parameter
2. Set correct **Location**
3. Save action

#### 4. JSON Quoting Issues

**For strings, use quotes:**
```json
{"name": "{{deviceName}}"}  ✅
{"name": {{deviceName}}}    ❌ (breaks JSON if value is string)
```

**For numbers, don't quote:**
```json
{"value": {{brightness}}}   ✅
{"value": "{{brightness}}"} ❌ (becomes string, not number)
```

### Control Value Not Passed Correctly

**Symptoms:**
- Slider sends wrong value
- Toggle sends opposite state
- Input sends empty string

**Solutions:**

#### 1. Check Control Value Variable

Use `{{controlValue}}` to pass control's value:

```yaml
Button: {{controlValue}} = true (when pressed)
Toggle: {{controlValue}} = true (on) or false (off)
Slider: {{controlValue}} = 0-100 (current slider value)
Input: {{controlValue}} = "entered text"
Dropdown: {{controlValue}} = "selected_option"
```

#### 2. Slider Value Mapping

**If slider sends wrong range:**

Check slider configuration:
- Min value
- Max value
- Step size

**Example:**
```
Slider: 0-100
But API expects: 0.0-1.0

Solution: Use value mapping
Output = {{controlValue}} / 100
```

This requires server-side transformation or custom action logic.

#### 3. Toggle State Confusion

**If toggle actions reversed:**

Check action configuration:
- Verify "On Action" is correct
- Verify "Off Action" is correct
- May be swapped

**Fix:**
1. Edit control
2. Swap On and Off actions
3. Save control

## Notification Issues

### Not Receiving Notifications

**Symptoms:**
- Webhooks send successfully but no notification appears
- No notifications when app is closed
- Notifications work when app is open but not in background

**Solutions:**

#### 1. Check Notification Permissions

**Android:**
1. Device **Settings** → **Apps** → **Rmotly**
2. Tap **Notifications**
3. Ensure **Notifications** are enabled
4. Check all notification categories are enabled

**If blocked:**
1. Enable notifications
2. Restart app
3. Test notification

#### 2. Check Topic is Enabled

1. Open **Notification Topics**
2. Find your topic
3. Ensure toggle is **ON**
4. If off, tap to enable

#### 3. Test Webhook Delivery

**Verify webhook reaches server:**

```bash
curl -v -X POST https://api.example.com/api/notify/topic_abc123 \
  -H "X-API-Key: rmt_key_xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test",
    "message": "Testing webhook delivery"
  }'
```

**Check response:**
- `200 OK` = Webhook received
- `401 Unauthorized` = API key wrong
- `404 Not Found` = Topic ID wrong

**If webhook fails:**
- Verify topic ID in URL
- Verify API key is correct
- Check server is reachable

#### 4. Configure Push Notifications

For notifications when app is closed:

1. Go to **Settings** → **Notifications**
2. Tap **Configure Push Notifications**
3. Select distributor (ntfy, FCM)
4. Complete setup wizard
5. Send test push

**If test push doesn't arrive:**
- Check distributor is running
- Verify device has internet
- Check battery optimization settings

#### 5. Battery Optimization Blocking

Android may block background notifications to save battery:

**Fix:**
1. Device **Settings** → **Battery**
2. Tap **Battery Optimization**
3. Find **Rmotly**
4. Select **Don't optimize**
5. Restart app

**For distributor app (e.g., ntfy):**
- Apply same optimization exemption
- Both apps must be unrestricted

#### 6. Do Not Disturb Mode

**Check:**
- Device is not in Do Not Disturb mode
- Or notification priority is set to override DND

**Fix DND blocking:**
1. Disable Do Not Disturb temporarily
2. Or set notification priority to **Urgent** in topic settings
3. Or add Rmotly to DND exceptions

### Notifications Delayed

**Symptoms:**
- Notifications arrive minutes late
- Only receive when opening app
- Batch of notifications arrive at once

**Solutions:**

#### 1. Background Data Restricted

**Check:**
1. Device **Settings** → **Apps** → **Rmotly**
2. Tap **Data usage**
3. Ensure **Background data** is enabled

**Fix:**
- Enable background data
- Ensure not in data saver mode

#### 2. Doze Mode

Android Doze delays background tasks to save battery:

**Fix:**
1. Device **Settings** → **Battery**
2. Find **Battery optimization**
3. Exclude Rmotly from optimization

**Or request user exemption:**
- App can request to be whitelisted from Doze
- User must approve in settings

#### 3. Push Distributor Delays

**ntfy:**
- Self-hosted may have delays
- Check ntfy server is responsive
- Increase priority in notification settings

**FCM:**
- Google services may batch notifications
- Delays up to 15-30 minutes possible with low priority
- Set priority to **high** for faster delivery

**Fix:**
1. Edit notification topic
2. Set **Priority** to **High** or **Urgent**
3. Save topic

#### 4. Network Connection Slow

**Check:**
- Wi-Fi or cellular signal strength
- Speed test (minimum 1 Mbps)

**Fix:**
- Move closer to router
- Switch to different network
- Use cellular if Wi-Fi is slow

### Duplicate Notifications

**Symptoms:**
- Receive same notification twice
- Multiple notifications for single webhook
- Notifications from old webhooks still arriving

**Solutions:**

#### 1. Multiple Topics Configured

**Check:**
- Multiple topics pointing to same webhook
- External service sending to multiple endpoints

**Fix:**
- Delete duplicate topics
- Update external service to use single endpoint

#### 2. Multiple Distributors Active

**Check:**
- Both ntfy and FCM configured
- Each delivers notification

**Fix:**
1. Go to **Settings** → **Notifications**
2. Choose one distributor
3. Disable others

#### 3. Notification Not Dismissed

Some persistent notifications reappear:

**Fix:**
- Swipe notification away
- Clear all notifications
- Check app notification channels

### Cannot Configure Push Notifications

**Symptoms:**
- Push setup wizard fails
- "Distributor not found" error
- Cannot register endpoint

**Solutions:**

#### 1. Distributor App Not Installed

**For ntfy:**
1. Install ntfy from F-Droid or Google Play
2. Return to Rmotly
3. Try setup again

**For FCM:**
- Requires Google Play Services
- Check Play Services is installed and updated

#### 2. Server-Side Push Not Configured

**Check with administrator:**
- Server has push notification support enabled
- ntfy server is running (if self-hosted)
- VAPID keys configured

**Test:**
```bash
# Check if push endpoint is accessible
curl https://api.example.com/api/push/register
```

#### 3. Network Restrictions

Corporate networks may block push:

**Try:**
- Use cellular data for setup
- Try from different network
- Contact IT about UnifiedPush

## Offline Mode

### What Works Offline

When disconnected from server:

**Available:**
- View dashboard
- See control names and layout
- View cached data
- Read documentation

**Not Available:**
- Execute controls (requires server)
- Receive notifications
- Sync changes
- Create/edit controls
- Create/edit actions

### Sync Issues After Reconnection

**Symptoms:**
- Changes made offline not syncing
- Conflicts with server data
- "Sync failed" error

**Solutions:**

#### 1. Force Sync

1. Pull down on dashboard (pull-to-refresh)
2. Or go to **Settings** → **Data** → **Sync**
3. Tap **Sync Now**

#### 2. Clear Sync Conflicts

**If there are conflicts:**

1. App shows conflict resolution dialog
2. Choose:
   - **Keep Server Version** - Discard local changes
   - **Keep Local Version** - Overwrite server
   - **Review Changes** - See differences and choose

#### 3. Clear Local Cache

If sync persistently fails:

1. Go to **Settings** → **Data**
2. Tap **Clear Cache** (keeps settings)
3. Or **Reset App Data** (clears everything)
4. ⚠️ Backup configuration first!

### Cannot Work Offline

**App requires connection for basic functions:**

**This is by design** - Rmotly is a remote control app that sends commands to external services. Without server connection, controls cannot function.

**Workaround:**
- Some actions might support offline queueing (future feature)
- For now, connection is required for all operations

## Performance Issues

### App is Slow or Laggy

**Symptoms:**
- UI stutters or freezes
- Slow scrolling
- Controls respond slowly
- Navigation is sluggish

**Solutions:**

#### 1. Too Many Controls

**Problem:**
- Dashboard with 50+ controls can slow rendering

**Fix:**
1. **Delete unused controls**
2. **Use compact view:**
   - Settings → Appearance → Control Size → Small
3. **Create multiple dashboards** (future feature)

#### 2. Clear App Cache

1. Go to **Settings** → **Data**
2. Tap **Clear Cache**
3. Restart app

#### 3. Reduce Animations

1. Go to **Settings** → **Appearance**
2. Toggle **Control Animations** off
3. Faster but less smooth

#### 4. Restart App

Simple restart often fixes sluggishness:

1. Close app completely (recent apps → swipe away)
2. Wait 5 seconds
3. Reopen app

#### 5. Update App

Old versions may have performance issues:

1. Check for updates in Play Store
2. Or **Settings** → **About** → **Check for Updates**
3. Install latest version

#### 6. Clear Device Cache

If entire device is slow:

1. Device **Settings** → **Storage**
2. Tap **Clear Cache** (system-wide)
3. Restart device

### High Battery Usage

**Symptoms:**
- Rmotly draining battery quickly
- Device gets warm
- Battery drain even when not using app

**Solutions:**

#### 1. Disable Constant Syncing

1. Go to **Settings** → **Data** → **Sync**
2. Increase **Sync Interval** (15 or 30 minutes)
3. Or disable **Auto-sync**

#### 2. Reduce Network Polling

1. Go to **Settings** → **Advanced** → **Network**
2. Increase **Polling Interval**
3. Or switch to **Push Only**

#### 3. Close Unused WebSocket Connections

1. Go to **Settings** → **Advanced** → **Network**
2. Enable **Close Connection When Idle**
3. Saves battery when app in background

#### 4. Reduce Notifications

Frequent notifications wake device:

1. Disable or mute noisy topics
2. Reduce notification priority
3. Enable quiet hours

#### 5. Disable Background Sync

For maximum battery savings:

1. **Settings** → **Data** → **Sync**
2. Enable **Sync on Wi-Fi Only**
3. Disable **Background Sync**

**Note:** Limits functionality but saves significant battery

### App Crashes

**Symptoms:**
- App suddenly closes
- "Rmotly has stopped" message
- App restarts on its own

**Solutions:**

#### 1. Update App

Crashes often fixed in updates:

1. Check Play Store for updates
2. Install latest version
3. Restart app

#### 2. Clear App Data

**Warning:** This deletes all local data. Backup first!

1. Device **Settings** → **Apps** → **Rmotly**
2. Tap **Storage**
3. Tap **Clear Data**
4. Reopen app and login again

#### 3. Check Available Storage

Low storage can cause crashes:

1. Device **Settings** → **Storage**
2. Ensure at least 500MB free
3. Delete unnecessary files/apps
4. Clear app caches

#### 4. Report Crash

If crashes persist:

1. Go to **Settings** → **Advanced** → **Logging**
2. Enable **Crash Reporting**
3. Reproduce crash
4. Send report to developers

#### 5. Reinstall App

Last resort:

1. Backup configuration (export controls)
2. Uninstall Rmotly
3. Restart device
4. Reinstall from Play Store
5. Restore configuration (import controls)

## Data Sync Issues

### Changes Not Syncing

**Symptoms:**
- Create control on device A, doesn't appear on device B
- Edit action but changes not reflected
- Deleted items reappear

**Solutions:**

#### 1. Manual Sync

1. Pull down on dashboard (pull-to-refresh)
2. Or **Settings** → **Data** → **Sync** → **Sync Now**

#### 2. Check Auto-Sync

1. Go to **Settings** → **Data** → **Sync**
2. Ensure **Auto-sync** is enabled
3. Check **Sync Interval** is reasonable (5-15 minutes)

#### 3. Network Connection

Sync requires active connection:

**Check:**
- Device has internet access
- Server is reachable
- Not in offline mode

#### 4. Conflicts

If changes conflict:

1. App shows conflict resolution
2. Choose server or local version
3. Resolve conflicts manually

### Data Loss

**Symptoms:**
- Controls disappeared
- Actions deleted
- Settings reset

**Prevention:**

#### 1. Regular Backups

**Automatic:**
1. **Settings** → **Data** → **Backup**
2. Enable **Auto-backup**
3. Set frequency (daily, weekly)

**Manual:**
1. **Settings** → **Data** → **Export**
2. Export controls to file
3. Save file to cloud storage

#### 2. Enable Sync

With sync enabled, data stored on server:

1. **Settings** → **Data** → **Sync**
2. Enable **Auto-sync**
3. Data safe even if device lost

**Recovery:**

If data lost:

1. **Settings** → **Data** → **Import**
2. Select backup file
3. Import configuration

Or reinstall app and login - server data will sync down.

## Getting Help

### In-App Help

- Tap **?** icon on any screen
- Long-press labels for tooltips
- Check **Settings** → **Help & Support**

### Documentation

- **[Getting Started Guide](GETTING_STARTED.md)** - Setup and basics
- **[User Guide](USER_GUIDE.md)** - Complete feature documentation  
- **[Controls Guide](CONTROLS_GUIDE.md)** - Detailed control types
- **[API Documentation](API.md)** - Technical API reference

### Debug Logging

Enable detailed logging for troubleshooting:

1. Go to **Settings** → **Advanced** → **Logging**
2. Enable **Debug Logs**
3. Reproduce the issue
4. Tap **Export Logs**
5. Send logs to support

**Logs include:**
- Network requests/responses
- Error messages
- Timestamps
- Device information

**Privacy note:** Logs may contain API keys and credentials. Review before sharing.

### Contact Support

**For app issues:**
1. Export debug logs
2. Include steps to reproduce
3. Mention device model and Android version
4. Contact through project repository

**For server issues:**
- Contact your server administrator
- Check server status page
- Review server logs

### Submit Bug Report

When reporting bugs, include:

1. **Device information:**
   - Device model
   - Android version
   - App version

2. **Steps to reproduce:**
   - What you did
   - What you expected
   - What actually happened

3. **Screenshots/videos:**
   - Visual evidence helps debugging

4. **Debug logs:**
   - Export from Settings → Advanced → Logging

5. **Network details:**
   - Server URL (without credentials)
   - Connection type (Wi-Fi, cellular)

### Common Error Codes Reference

| Error | Meaning | Action |
|-------|---------|--------|
| `ERR_NETWORK` | Network error | Check connection |
| `ERR_TIMEOUT` | Request timeout | Check network speed |
| `ERR_AUTH` | Authentication failed | Re-login |
| `ERR_NOTFOUND` | Resource not found | Check configuration |
| `ERR_VALIDATION` | Invalid data | Fix input data |
| `ERR_RATELIMIT` | Too many requests | Wait and retry |
| `ERR_SERVER` | Server error | Contact admin |
| `ERR_UNKNOWN` | Unknown error | Check logs |

---

## Quick Troubleshooting Checklist

Before asking for help, try:

- [ ] Restart the app
- [ ] Check internet connection
- [ ] Verify server is reachable
- [ ] Check notification permissions
- [ ] Clear app cache
- [ ] Update to latest version
- [ ] Review error messages
- [ ] Check debug logs
- [ ] Test with different network
- [ ] Check device date/time is correct

## Emergency Recovery

**If app is completely broken:**

1. **Export data** (if possible)
   - Settings → Data → Export Controls

2. **Clear app data**
   - Device Settings → Apps → Rmotly → Clear Data

3. **Reinstall app**
   - Uninstall and reinstall from Play Store

4. **Login and restore**
   - Login with credentials
   - Data syncs from server
   - Or import exported controls

**If you're completely locked out:**

1. **Contact administrator**
   - Request account reset
   - Verify server is functioning

2. **Try web interface** (if available)
   - Some servers have web admin panel
   - Can reset account or configure controls

3. **Create new account** (last resort)
   - Create new account if allowed
   - Reconfigure controls manually

---

**Still having issues?** Check the [User Guide](USER_GUIDE.md) for detailed feature documentation, or contact your server administrator for server-specific problems.
