# In-App Purchase Setup Guide 💳

This guide explains how to set up Google Play In-App Purchases for the "No Ads" feature.

## Overview

The Tower Stacking game includes a "No Ads" in-app purchase that:
- Removes all banner ads from the game screen
- Removes interstitial ads after game over
- Keeps rewarded ads available (user's choice)

## Prerequisites

- Google Play Developer account ($25 one-time fee)
- App published on Google Play (at least internal testing)
- Godot Google Play Billing plugin

## Step 1: Google Play Console Setup

### Create Developer Account
1. Go to [Google Play Console](https://play.google.com/console/)
2. Pay the $25 registration fee
3. Complete account verification

### Create Your App
1. Click **Create app**
2. Fill in app details:
   - App name: Tower Stacking
   - Default language: English
   - App or game: Game
   - Free or paid: Free
3. Accept declarations and create

## Step 2: Set Up In-App Products

### Navigate to Products
1. Open your app in Play Console
2. Go to **Monetize > Products > In-app products**
3. Click **Create product**

### Create "No Ads" Product
1. **Product ID**: `no_ads` (must match `PRODUCT_NO_ADS` in `iap_manager.gd`)
2. **Name**: Remove Ads
3. **Description**: Remove all advertisements from the game permanently
4. **Default price**: Set your price (e.g., $1.99)
5. Click **Save** then **Activate**

## Step 3: Install Godot Billing Plugin

### Download Plugin
1. Go to [Godot Google Play Billing](https://github.com/nicemicro/godot-google-play-billing)
2. Download the latest release
3. Extract to your project

### Install Plugin
1. Copy `android/plugins` folder to your project's `android/` directory
2. Copy `addons/GodotGooglePlayBilling` to your `addons/` folder
3. Enable in **Project > Project Settings > Plugins**

### Configure Build
In `export_presets.cfg`, ensure Gradle build is enabled:
```ini
gradle_build/use_gradle_build=true
```

## Step 4: Configure Project

### Update iap_manager.gd
The product ID should match your Play Console:
```gdscript
const PRODUCT_NO_ADS: String = "no_ads"
```

### Test Product IDs
For testing, Google provides these reserved IDs:
```gdscript
# Test purchases (always succeed)
"android.test.purchased"

# Test cancellation
"android.test.canceled"

# Test refund
"android.test.refunded"

# Test unavailable
"android.test.item_unavailable"
```

## Step 5: Testing

### Internal Testing Track
1. In Play Console, go to **Testing > Internal testing**
2. Create a new release
3. Upload your AAB file
4. Add tester email addresses
5. Start rollout

### License Testing
1. Go to **Settings > License testing**
2. Add your test account emails
3. Test purchases won't be charged

### Testing Workflow
1. Install the app from internal testing
2. Sign in with a test account
3. Click "No Ads" button
4. Complete test purchase
5. Verify ads are disabled
6. Test restore functionality

## Step 6: Production

### Before Going Live
1. Remove any test product IDs
2. Verify `PRODUCT_NO_ADS = "no_ads"`
3. Test purchase flow completely
4. Verify purchase persistence

### Go Live Checklist
- [ ] Product created and activated in Play Console
- [ ] Correct product ID in code
- [ ] Purchase flow tested
- [ ] Restore purchases working
- [ ] Ads properly disabled after purchase

## Code Reference

### Purchase Flow (iap_manager.gd)
```gdscript
# Start purchase
func purchase_no_ads() -> void:
    purchase_started.emit()
    if billing_plugin != null:
        billing_plugin.purchase(PRODUCT_NO_ADS)

# Handle purchase completion
func _complete_no_ads_purchase() -> void:
    no_ads_purchased = true
    _save_purchase_state()
    AdManager.disable_ads()
    purchase_completed.emit(PRODUCT_NO_ADS)
```

### Checking Purchase Status
```gdscript
# In any script
if IAPManager.is_no_ads_purchased():
    # User has purchased no ads
    pass
```

### Restoring Purchases
```gdscript
# Called from settings or menu
IAPManager.restore_purchases()
```

## Troubleshooting

### Purchase Not Working
1. Verify app is published (at least internal testing)
2. Check product is activated in Play Console
3. Verify tester accounts are added
4. Check product ID matches exactly

### Purchase Not Persisting
1. Check `user://iap_data.save` exists
2. Verify save/load functions work
3. Check file permissions

### Billing Plugin Not Found
1. Verify plugin is in `android/plugins/`
2. Check Gradle build is enabled
3. Rebuild the project

## Security Considerations

⚠️ **Important Security Notes**:

1. **Server Verification**: For production, consider verifying purchases server-side
2. **Local Storage**: Current implementation uses local storage, which can be bypassed
3. **Obfuscation**: Consider obfuscating purchase checks in production

### Adding Server Verification (Optional)
```gdscript
# After purchase, verify with your server
func _verify_purchase(purchase_token: String) -> void:
    var http = HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(_on_verification_complete)
    http.request(
        "https://your-server.com/verify",
        ["Content-Type: application/json"],
        HTTPClient.METHOD_POST,
        JSON.stringify({"token": purchase_token})
    )
```

## Resources

- [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- [Godot Google Play Billing Plugin](https://github.com/nicemicro/godot-google-play-billing)
- [Play Console Help](https://support.google.com/googleplay/android-developer/)

---

Need help? Open an issue on GitHub!
