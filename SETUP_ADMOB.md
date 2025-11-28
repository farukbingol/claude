# AdMob Setup Guide 📱💰

This guide will help you set up AdMob ads in your Tower Stacking game.

## Prerequisites

- Google AdMob account
- Godot AdMob plugin
- Android export configured

## Step 1: Create AdMob Account

1. Go to [AdMob](https://admob.google.com/)
2. Sign in with your Google account
3. Accept the Terms of Service
4. Complete the account setup

## Step 2: Create an App in AdMob

1. In AdMob Console, go to **Apps > Add App**
2. Select **Android**
3. Choose "No" if your app is not on Google Play yet
4. Enter your app name: "Tower Stacking"
5. Click **Add App**
6. Note your **App ID** (format: `ca-app-pub-XXXXXXXX~XXXXXXXXXX`)

## Step 3: Create Ad Units

### Banner Ad
1. Go to **Apps > Tower Stacking > Ad units**
2. Click **Add ad unit**
3. Select **Banner**
4. Name it: "Banner - Game Screen"
5. Click **Create ad unit**
6. Copy the **Ad unit ID**

### Interstitial Ad
1. Click **Add ad unit** again
2. Select **Interstitial**
3. Name it: "Interstitial - Game Over"
4. Click **Create ad unit**
5. Copy the **Ad unit ID**

### Rewarded Ad
1. Click **Add ad unit** again
2. Select **Rewarded**
3. Name it: "Rewarded - Continue Game"
4. Set reward: Amount = 1, Type = "continue"
5. Click **Create ad unit**
6. Copy the **Ad unit ID**

## Step 4: Install Godot AdMob Plugin

### Option A: From Asset Library
1. Open Godot Editor
2. Go to **AssetLib** tab
3. Search for "AdMob"
4. Download and install "Godot AdMob Android"
5. Enable the plugin in **Project > Project Settings > Plugins**

### Option B: Manual Installation
1. Download from [GitHub - Poing-Studios/godot-admob-android](https://github.com/poing-studios/godot-admob-android)
2. Copy the `addons/admob` folder to your project
3. Copy the Android plugin files to `android/plugins`
4. Enable the plugin in Project Settings

## Step 5: Configure Ad Unit IDs

Open `config/ads_config.gd` and replace the test IDs with your real Ad Unit IDs:

```gdscript
# Set to false for production
const IS_TEST_MODE: bool = false

# Replace with your AdMob App ID
const ADMOB_APP_ID: String = "ca-app-pub-XXXXXXXX~XXXXXXXXXX"

# Replace with your Ad Unit IDs
const BANNER_AD_ID: String = "ca-app-pub-XXXXXXXX/XXXXXXXXXX"
const INTERSTITIAL_AD_ID: String = "ca-app-pub-XXXXXXXX/XXXXXXXXXX"
const REWARDED_AD_ID: String = "ca-app-pub-XXXXXXXX/XXXXXXXXXX"
```

## Step 6: Update Android Manifest

If using manual plugin installation, add to `android/build/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXX~XXXXXXXXXX"/>
    </application>
</manifest>
```

## Step 7: Test Ads

### Use Test Mode During Development
Keep `IS_TEST_MODE = true` in `ads_config.gd` during development. This ensures you don't violate AdMob policies by clicking on real ads.

### Test Ad Unit IDs (for development)
These are Google's official test IDs that always show test ads:

```gdscript
# Test IDs (already included in the project)
const BANNER_AD_ID: String = "ca-app-pub-3940256099942544/6300978111"
const INTERSTITIAL_AD_ID: String = "ca-app-pub-3940256099942544/1033173712"
const REWARDED_AD_ID: String = "ca-app-pub-3940256099942544/5224354917"
```

### Testing on Real Device
1. Build and install the APK on your Android device
2. Ads should show as "Test Ad" banners
3. Verify all ad types work correctly

## Step 8: Go Live

When ready for production:

1. Set `IS_TEST_MODE = false` in `ads_config.gd`
2. Replace all test Ad Unit IDs with your production IDs
3. Build a release version of your app
4. Submit to Google Play Store

## Troubleshooting

### Ads Not Showing
- Check internet connection
- Verify Ad Unit IDs are correct
- Check AdMob console for issues
- Wait 1-2 hours for new ad units to activate

### "Test Ad" Banner Showing in Production
- Ensure `IS_TEST_MODE = false`
- Verify you're using production Ad Unit IDs
- Rebuild the app

### App Crashes on Ad Load
- Check plugin installation
- Verify Android manifest configuration
- Check logcat for errors

## AdMob Policies

⚠️ **Important**: Follow AdMob policies to avoid account suspension:

1. **Never click your own ads**
2. **Don't encourage users to click ads**
3. **Don't place ads in confusing locations**
4. **Show ads only when appropriate**
5. **Implement proper ad frequency capping**

## Resources

- [AdMob Help Center](https://support.google.com/admob/)
- [Godot AdMob Plugin Docs](https://github.com/poing-studios/godot-admob-android)
- [AdMob Policies](https://support.google.com/admob/answer/6128543)

---

Need help? Open an issue on GitHub!
