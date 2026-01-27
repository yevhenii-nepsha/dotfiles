// Firefox user.js - Custom preferences
// These settings are applied on Firefox startup

// ============================================================================
// PRIVACY & SECURITY
// ============================================================================

// Disable telemetry
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);

// Enable tracking protection
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.trackingprotection.emailtracking.enabled", true);

// Enable fingerprinting protection
user_pref("privacy.fingerprintingProtection", true);

// Strip tracking parameters from URLs
user_pref("privacy.query_stripping.enabled", true);
user_pref("privacy.query_stripping.enabled.pbmode", true);

// Bounce tracking protection
user_pref("privacy.bounceTrackingProtection.mode", 1);

// ============================================================================
// CONTAINERS
// ============================================================================

// Enable containers
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);

// ============================================================================
// UI CUSTOMIZATION
// ============================================================================

// Enable userChrome.css customization
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Startup - restore previous session
user_pref("browser.startup.page", 3);

// Blank new tab
user_pref("browser.startup.homepage", "chrome://browser/content/blanktab.html");

// ============================================================================
// DISABLE ANNOYANCES
// ============================================================================

// Disable Pocket
user_pref("extensions.pocket.enabled", false);

// Disable sponsored content
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
