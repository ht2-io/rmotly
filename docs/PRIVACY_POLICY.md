# Privacy Policy

**Last Updated: January 2025**

## Overview

Rmotly ("we", "our", or "the app") is a self-hosted remote control and notification application. This privacy policy explains how we handle your data.

## Data Collection

### What We Collect

When you use Rmotly, the following data is stored on **your self-hosted server**:

- **Account Information**: Email address and hashed password for authentication
- **Controls**: Custom dashboard controls you create (names, configurations)
- **Actions**: HTTP action templates (URLs, headers, body templates)
- **Topics**: Notification topic configurations
- **Events**: Logs of control interactions and their results
- **Push Subscriptions**: Device endpoints for push notification delivery

### What We Don't Collect

- We do not collect analytics or telemetry
- We do not track your location
- We do not access your contacts, photos, or other device data
- We do not sell or share your data with third parties

## Data Storage

All data is stored on infrastructure you control:

- **Self-hosted server**: Your Serverpod instance stores all user data
- **Local device**: Minimal caching for offline functionality
- **No cloud sync**: Data never leaves your server unless you configure external integrations

## Third-Party Services

### Optional Integrations

Rmotly may interact with third-party services only when you explicitly configure them:

- **External APIs**: Actions you create may call external services (Home Assistant, IFTTT, etc.)
- **Webhook Sources**: External services can send notifications to your topics

### Push Notification Providers

For push notifications, Rmotly supports:

- **Self-hosted ntfy**: Recommended, no third-party involvement
- **UnifiedPush distributors**: You choose your provider
- **No Firebase/Google services required**

## Data Security

We implement security measures including:

- **Encryption at Rest**: Sensitive data encrypted with AES-256-GCM
- **Secure Authentication**: Password hashing with modern algorithms
- **API Key Security**: Webhook endpoints protected with unique API keys
- **Rate Limiting**: Protection against abuse
- **HTTPS**: All communications encrypted in transit (when properly configured)

## Your Rights

Since all data is stored on your infrastructure:

- **Access**: You have direct database access to all your data
- **Export**: Use the app's export feature or query the database directly
- **Deletion**: Delete your account and all associated data at any time
- **Portability**: Export your configuration as JSON

## Data Retention

- **Events**: Configurable retention period (default: 30 days)
- **Account data**: Retained until you delete your account
- **Backups**: According to your backup configuration

## Children's Privacy

Rmotly is not intended for children under 13. We do not knowingly collect data from children.

## Changes to This Policy

We may update this policy to reflect changes in our practices. We will notify users of significant changes.

## Open Source

Rmotly is open source. You can review exactly what data is collected and how it's handled by examining the source code at [github.com/yourusername/rmotly](https://github.com/yourusername/rmotly).

## Contact

For privacy questions, please open an issue on our GitHub repository.

---

## Summary

**Your data stays on your server.** Rmotly is designed for privacy-conscious users who want full control over their data. We don't collect, process, or store any of your data on our servers because we don't have any central servers - it's all self-hosted.
