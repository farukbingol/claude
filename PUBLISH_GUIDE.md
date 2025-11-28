# Google Play Publishing Guide 🚀

Complete guide to publishing Tower Stacking on Google Play Store.

## Prerequisites

- [ ] Google Play Developer account ($25 one-time fee)
- [ ] Finished and tested game
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (minimum 2)
- [ ] Privacy policy URL
- [ ] Signed release build

## Step 1: Prepare Assets

### App Icon
- Size: 512 x 512 pixels
- Format: 32-bit PNG
- No transparency
- No rounded corners (Google adds them)

### Feature Graphic
- Size: 1024 x 500 pixels
- Format: JPEG or PNG
- Used in Play Store header

### Screenshots
- Minimum: 2 screenshots
- Recommended: 8 screenshots
- Phone: 16:9 aspect ratio (1920x1080 or similar)
- Show key game features:
  1. Main menu
  2. Gameplay
  3. Perfect placement
  4. Game over screen
  5. High score
  6. Settings

### Short Description
Max 80 characters:
```
Stack blocks perfectly and build the tallest tower! How high can you go?
```

### Full Description
Max 4000 characters:
```
🏗️ TOWER STACKING - The Ultimate Block Stacking Challenge!

Test your timing and precision in this addictive arcade game. Stack blocks as high as you can and compete for the highest score!

🎮 HOW TO PLAY
• Tap to drop the moving block
• Align it perfectly on the tower
• Build higher and score more points
• Miss and it's game over!

✨ FEATURES
• Simple one-tap controls
• Progressive difficulty - speed increases as you stack
• Perfect placement bonuses
• Local high score tracking
• Colorful rainbow blocks
• Smooth animations
• Sound effects and music

🏆 COMPETE
• Beat your high score
• Challenge friends
• Become the ultimate tower builder

📱 OPTIMIZED
• Works on all Android devices
• Portrait mode gameplay
• Responsive touch controls

Download now and start stacking! 🎯
```

## Step 2: Create Signed Release Build

### Generate Keystore
```bash
keytool -genkey -v \
  -keystore tower-stacking-release.keystore \
  -alias tower-stacking \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

**⚠️ IMPORTANT**: 
- Save your keystore file securely
- Remember your passwords
- You cannot update your app without this keystore

### Configure Export in Godot
1. Open **Project > Export**
2. Select Android preset
3. Fill in keystore details:
   - **Release Keystore**: Path to your .keystore file
   - **Release User**: Your alias (tower-stacking)
   - **Release Password**: Your keystore password
4. Set version:
   - **Version Code**: 1 (increment for each update)
   - **Version Name**: 1.0.0

### Export AAB (Recommended for Play Store)
1. In Export dialog, change format to AAB
2. Click **Export Project**
3. Save as `tower-stacking.aab`

### Export APK (For testing)
1. Keep format as APK
2. Click **Export Project**
3. Save as `tower-stacking.apk`

## Step 3: Create App in Play Console

### Basic Setup
1. Go to [Play Console](https://play.google.com/console/)
2. Click **Create app**
3. Fill in:
   - **App name**: Tower Stacking
   - **Default language**: English (US)
   - **App or game**: Game
   - **Free or paid**: Free

### App Details
1. Go to **Grow > Store presence > Main store listing**
2. Fill in:
   - Short description
   - Full description
   - App icon
   - Feature graphic
   - Screenshots

### Content Rating
1. Go to **Policy > App content > Content rating**
2. Start questionnaire
3. Answer questions honestly
4. Get your rating (likely Everyone or Everyone 10+)

### Privacy Policy
1. Create a privacy policy (required)
2. Host it online (GitHub Pages, your website, etc.)
3. Add URL in **Policy > App content > Privacy policy**

Example privacy policy for simple games:
```
Privacy Policy for Tower Stacking

This game:
- Does not collect personal information
- Uses advertising (AdMob) which may collect anonymous data
- Stores high scores locally on your device

For AdMob's privacy policy, visit:
https://policies.google.com/privacy

Contact: your-email@example.com
```

### Target Audience
1. Go to **Policy > App content > Target audience**
2. Select appropriate age group
3. Answer questions about content

### Ads Declaration
1. Go to **Policy > App content > Ads**
2. Confirm your app contains ads
3. Declare ad networks used (AdMob)

## Step 4: Release Your App

### Internal Testing (Recommended First)
1. Go to **Testing > Internal testing**
2. Click **Create new release**
3. Upload your AAB file
4. Add release notes
5. Click **Save** then **Review release**
6. Click **Start rollout to Internal testing**

### Closed Testing
1. Go to **Testing > Closed testing**
2. Create a track
3. Add testers by email
4. Upload AAB and release

### Open Testing
1. Go to **Testing > Open testing**
2. Create release
3. Anyone can join testing

### Production Release
1. Go to **Production**
2. Click **Create new release**
3. Upload your signed AAB
4. Add release notes:
   ```
   Version 1.0.0
   - Initial release
   - Stack blocks and build towers!
   - Perfect placement bonuses
   - High score tracking
   ```
5. Click **Save** then **Review release**
6. Click **Start rollout to Production**

## Step 5: Post-Launch

### Monitor Performance
- Check crash reports in Play Console
- Monitor ratings and reviews
- Track download statistics

### Respond to Reviews
- Thank positive reviewers
- Address issues from negative reviews
- Be professional and helpful

### Plan Updates
- Fix bugs promptly
- Add new features
- Increase version code for each update

## Common Rejection Reasons

### Policy Violations
1. **Missing privacy policy**: Add one before submitting
2. **Misleading ads**: Don't disguise ads as game content
3. **Inappropriate content**: Keep it family-friendly

### Technical Issues
1. **Crashes**: Test thoroughly on multiple devices
2. **ANR (App Not Responding)**: Optimize performance
3. **Permission abuse**: Only request necessary permissions

### Metadata Issues
1. **Keyword stuffing**: Don't spam keywords in description
2. **Misleading screenshots**: Show actual gameplay
3. **Copyright infringement**: Use only your own assets

## Updating Your App

### Version Numbers
```
Version Code: 2, 3, 4... (must always increase)
Version Name: 1.0.1, 1.1.0, 2.0.0...
```

### Update Process
1. Make changes in Godot
2. Increment version code in export settings
3. Export new AAB
4. Upload to Production track
5. Write release notes
6. Roll out

## Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Play Console Policy Center](https://play.google.com/about/developer-content-policy/)
- [App Quality Guidelines](https://developer.android.com/docs/quality-guidelines/)
- [Launch Checklist](https://developer.android.com/distribute/best-practices/launch/launch-checklist)

---

Congratulations on publishing your game! 🎉

Need help? Open an issue on GitHub!
