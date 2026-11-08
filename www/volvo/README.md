# VolvoConnect OAuth 2.0 Redirect Handler

This directory contains the OAuth 2.0 redirect handler for VolvoConnect authentication.

## Files

- **oauth-redirect.pl** — HTTP request handler that processes the OAuth authorization code callback

## Configuration

### 1. In FHEM

Configure your VolvoConnect device with a redirect URI that points to this handler:

```
attr <devicename> redirect_uri http://your-fhem-host/volvo/oauth-redirect.pl
```

**Examples:**
- Local development: `http://localhost/volvo/oauth-redirect.pl`
- Home network: `http://fhem.fritz.box/volvo/oauth-redirect.pl`
- External access: `https://your-domain.com/fhem/volvo/oauth-redirect.pl` (requires HTTPS and proper DNS)

### 2. In Volvo Developer Portal

1. Go to [https://developer.volvocars.com](https://developer.volvocars.com)
2. Create/Edit your OAuth application
3. Under **Redirect URIs**, add your FHEM redirect URL
4. Save the configuration

**Important:** The redirect URI must match EXACTLY (including protocol, domain, path, and filename).

### 3. OAuth Flow

1. User initiates authentication by accessing the login URL (printed in FHEM logs)
2. User logs in at Volvo's OAuth server
3. Volvo redirects back to this handler with an authorization code
4. Handler displays the authorization code in a user-friendly interface
5. User copies the code and sets it on the device:
   ```
   attr <devicename> authCode <authorization-code>
   ```
6. VolvoConnect module automatically exchanges the code for access tokens

## How It Works

**oauth-redirect.pl** performs these tasks:

### Request Processing
- Extracts URL query parameters (code, state, error, error_description)
- URL-decodes parameters properly
- Validates incoming OAuth callback data

### Response Handling

#### Success (Authorization Code Received)
- Displays the authorization code in a copyable format
- Shows the state parameter for verification
- Provides instructions for setting the authCode attribute
- Includes a "Copy Code" button for convenience

#### Error (OAuth Server Returned Error)
- Displays the error code and description
- Shows troubleshooting hints
- Allows user to retry the authorization flow

#### Invalid Request
- Handles malformed or missing parameters
- Shows expected parameter format

### User Interface

The handler provides a modern, responsive HTML interface with:

- Clean Material Design-inspired layout
- Status indicators (processing, success, error)
- Mobile-responsive design
- Clipboard copy functionality
- Detailed troubleshooting instructions
- Step-by-step guidance for setting the authCode

## Security Considerations

⚠️ **Important Security Notes:**

1. **Redirect URI must match exactly** — Any mismatch will cause OAuth to fail
2. **HTTPS recommended** — For external/public access, Volvo requires HTTPS
3. **HTTP allowed locally** — `http://localhost` is allowed for local development
4. **No code storage** — The handler doesn't store the code; it's displayed for manual entry
5. **One-time use** — Authorization codes expire quickly; users should set authCode immediately

## Troubleshooting

### "Invalid redirect_uri"
- Check that your `redirect_uri` attribute exactly matches the URI registered in Volvo Developer Portal
- Verify protocol (http/https), domain, path, and filename all match
- No extra query parameters or anchors are allowed

### "Authorization code not working"
- Code expires after ~10 minutes; get a fresh one
- Verify the `authCode` attribute is set immediately after receiving it
- Check FHEM logs for token exchange errors

### Handler not responding
- Ensure www/volvo/oauth-redirect.pl is in your FHEM www directory
- Verify FHEM's web server is running
- Check browser console for network errors
- Try accessing directly: `http://fhem-host/volvo/oauth-redirect.pl`

## Legacy vs. Keycloak

This handler works with both OAuth services:

- **Legacy (keycloakService=0):** Uses Volvo ID Service (deprecated after Jan 31, 2027)
- **Keycloak (keycloakService=1):** Uses Volvo's new Keycloak-based IAM

Configuration is identical; only the `keycloakService` attribute differs.

## Example Setup

```perl
# Define device
define VolvoXC90 VolvoConnect

# Configure OAuth
attr VolvoXC90 keycloakService 1
attr VolvoXC90 client_id YOUR_CLIENT_ID
attr VolvoXC90 client_secret YOUR_CLIENT_SECRET
attr VolvoXC90 redirect_uri http://fhem.fritz.box/volvo/oauth-redirect.pl
attr VolvoXC90 vin YOUR_VIN
attr VolvoXC90 vcc_api_key YOUR_VCC_API_KEY

# Start authentication (check logs for login URL)
```

## References

- [VolvoConnect Module Documentation](../docs/volvo/DOKUMENTATION.md)
- [Volvo Developer Portal](https://developer.volvocars.com)
- [OAuth 2.0 Specification](https://tools.ietf.org/html/rfc6749)
- [PKCE (RFC 7636)](https://tools.ietf.org/html/rfc7636)
