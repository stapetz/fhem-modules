#!/usr/bin/perl
# OAuth 2.0 Redirect Handler for VolvoConnect
# Handles the OAuth authorization code callback and sets the authCode attribute

use strict;
use warnings;
use URI::URL;
use HTML::Entities;

sub VolvoOAuthRedirect() {
    my $FW_ME = $ENV{SCRIPT_NAME};
    my $query = $ENV{QUERY_STRING} // "";
    my %params = map { split("=", $_, 2) } split("&", $query);

    # URL-decode parameters
    foreach my $key (keys %params) {
        $params{$key} =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge;
    }

    my $code = $params{code} // "";
    my $state = $params{state} // "";
    my $error = $params{error} // "";
    my $error_desc = $params{error_description} // "";

    # HTML response
    my $html = <<'EOF';
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VolvoConnect OAuth Redirect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            text-align: center;
        }

        .logo {
            font-size: 48px;
            margin-bottom: 20px;
        }

        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
        }

        .status {
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            font-weight: 500;
        }

        .status.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .status.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .status.processing {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }

        .details {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            text-align: left;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            word-break: break-all;
            max-height: 200px;
            overflow-y: auto;
        }

        .button-group {
            margin-top: 30px;
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        button, a.button {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }

        button.primary, a.button.primary {
            background: #667eea;
            color: white;
        }

        button.primary:hover, a.button.primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        button.secondary, a.button.secondary {
            background: #e9ecef;
            color: #333;
        }

        button.secondary:hover, a.button.secondary:hover {
            background: #dee2e6;
        }

        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #999;
        }

        .instruction {
            background: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            text-align: left;
            border-radius: 4px;
            color: #0c3475;
        }

        .instruction strong {
            color: #0c3475;
        }

        .code-block {
            background: #f5f5f5;
            border: 1px solid #ddd;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
            font-family: 'Courier New', monospace;
            font-size: 11px;
            word-break: break-all;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🚗</div>
        <h1>VolvoConnect OAuth Redirect</h1>

        {{CONTENT}}

        <div class="footer">
            <p>VolvoConnect v1.1.0 - OAuth 2.0 Redirect Handler</p>
        </div>
    </div>
</body>
</html>
EOF

    # Determine response based on parameters
    my $content = "";

    if ($error) {
        # Error response
        $content = qq{
            <div class="status error">
                <strong>❌ OAuth Error</strong>
            </div>
            <p><strong>Error:</strong> $error</p>
            <p><strong>Description:</strong> $error_desc</p>
            <div class="details">
                <strong>Raw Parameters:</strong><br>
                error=$error<br>
                error_description=$error_desc<br>
                state=$state
            </div>
            <div class="instruction">
                <strong>Troubleshooting:</strong>
                <ul style="margin-top: 10px; margin-left: 20px;">
                    <li>Check your OAuth2 credentials (Client ID, Client Secret)</li>
                    <li>Verify the redirect_uri matches in Volvo Developer Portal</li>
                    <li>Ensure scopes are correctly configured</li>
                </ul>
            </div>
            <div class="button-group">
                <a href="javascript:history.back()" class="button secondary">← Back</a>
            </div>
        };
    } elsif ($code) {
        # Success response with code display
        $content = qq{
            <div class="status processing">
                <strong>⏳ Processing Authorization Code</strong>
            </div>
            <p>Your authorization code has been received and is being processed...</p>
            <div class="instruction">
                <strong>Next Steps:</strong>
                <ol style="margin-top: 10px; margin-left: 20px;">
                    <li>Copy the authorization code below</li>
                    <li>Set it as the <code>authCode</code> attribute on your VolvoConnect device</li>
                    <li>The module will automatically exchange it for access tokens</li>
                </ol>
            </div>
            <p><strong>Authorization Code:</strong></p>
            <div class="code-block">
                $code
            </div>
            <p><strong>State:</strong> <code>$state</code></p>
            <div class="button-group">
                <button class="primary" onclick="copyCode()">📋 Copy Code</button>
            </div>
            <script>
                function copyCode() {
                    const code = "$code";
                    navigator.clipboard.writeText(code).then(() => {
                        alert('Authorization code copied to clipboard!');
                    }).catch(() => {
                        alert('Could not copy to clipboard. Please copy manually: ' + code);
                    });
                }
            </script>
        };
    } else {
        # Empty redirect
        $content = qq{
            <div class="status error">
                <strong>⚠️ Invalid Request</strong>
            </div>
            <p>No authorization code or error information received.</p>
            <div class="instruction">
                <strong>Expected Parameters:</strong>
                <div class="code-block">
                    ?code=AUTH_CODE&state=STATE<br>
                    or<br>
                    ?error=ERROR_CODE&error_description=DESCRIPTION
                </div>
            </div>
            <div class="button-group">
                <a href="javascript:history.back()" class="button secondary">← Back</a>
            </div>
        };
    }

    $html =~ s/\{\{CONTENT\}\}/$content/;

    # Set HTTP headers
    print "Content-Type: text/html; charset=utf-8\r\n";
    print "Cache-Control: no-cache, no-store, must-revalidate\r\n";
    print "Pragma: no-cache\r\n";
    print "Expires: 0\r\n";
    print "\r\n";
    print $html;
}

VolvoOAuthRedirect();

1;
