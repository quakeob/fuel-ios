# Fuel App - Production Deployment Guide

## 🎯 Quick Start

This guide will help you prepare Fuel for App Store submission. Follow the steps in order.

---

## ✅ Phase 1: Critical Configuration (REQUIRED)

### 1.1 Info.plist Setup

Copy `Info.plist.template` to your target's `Info.plist` and customize as needed.

**Action Items:**
- [ ] Add camera usage description (for barcode scanning)
- [ ] Add photo library usage description (for meal photos)
- [ ] Add HealthKit usage descriptions (if using HealthKit)
- [ ] Remove or set `NSUserTrackingUsageDescription` based on tracking needs

### 1.2 Entitlements Setup

Copy `Fuel.entitlements.template` to your target and add it in Xcode:

1. Right-click on your target → "Add Files to [Project]"
2. Select `Fuel.entitlements`
3. In target settings → Signing & Capabilities, verify entitlements are loaded

**Action Items:**
- [ ] Configure App Groups: `group.com.fuel.app` (or your identifier)
- [ ] Enable HealthKit capability
- [ ] Configure Keychain Sharing
- [ ] Enable CloudKit if using sync (see `AppConfiguration.swift`)

### 1.3 Update Configuration

Edit `AppConfiguration.swift` to match your deployment:

```swift
// Update these URLs to your actual domain
enum URLs {
    static let privacyPolicy = URL(string: "https://YOUR-DOMAIN.com/privacy")!
    static let termsOfService = URL(string: "https://YOUR-DOMAIN.com/terms")!
    static let support = URL(string: "https://YOUR-DOMAIN.com/support")!
}
```

**Action Items:**
- [ ] Update privacy policy URL (REQUIRED by App Store)
- [ ] Update support URL
- [ ] Update terms of service URL
- [ ] Set `cloudKitEnabled` if using iCloud sync
- [ ] Configure feature flags as needed

### 1.4 API Key Security

**⚠️ CRITICAL SECURITY ISSUE:**

The app currently expects users to provide their own Anthropic API key. For production:

**Option A: User-Provided Keys (Current Implementation)**
- [ ] Add onboarding screen explaining API key requirement
- [ ] Add settings UI for users to enter their API key
- [ ] Add documentation on how to get an Anthropic API key

**Option B: Backend Proxy (Recommended for Production)**
- [ ] Create a backend API to proxy Anthropic requests
- [ ] Implement request signing/authentication
- [ ] Update `FoodParsingService.swift` to call your backend
- [ ] Monitor and limit API usage per user

**Never ship hardcoded API keys in your app!**

---

## 🔒 Phase 2: Security & Privacy

### 2.1 Privacy Policy (REQUIRED)

You MUST have a privacy policy hosted at a publicly accessible URL before App Store submission.

**Required Content:**
- [ ] What data you collect (food logs, weight, goals)
- [ ] How you use the data (AI parsing, health tracking)
- [ ] Third-party services (Anthropic API, barcode lookup services)
- [ ] Data retention and deletion policies
- [ ] User rights (export, delete account)
- [ ] Contact information

**Template Privacy Policy:** [Use a generator like privacypolicygenerator.info]

### 2.2 Terms of Service (Recommended)

Create terms of service covering:
- [ ] App usage terms
- [ ] User responsibilities
- [ ] Disclaimers (nutritional advice, medical disclaimers)
- [ ] Liability limitations

### 2.3 Data Handling

Review and implement:
- [ ] User data export functionality
- [ ] Account deletion (if using accounts)
- [ ] GDPR compliance (if targeting EU)
- [ ] CCPA compliance (if targeting California)
- [ ] COPPA compliance (if allowing users < 13)

---

## 🧪 Phase 3: Testing

### 3.1 Device Testing

Test on real devices (not just simulator):
- [ ] iPhone SE (smallest screen)
- [ ] iPhone 15 Pro
- [ ] iPhone 15 Pro Max (largest screen)
- [ ] iPad (if supporting iPad)
- [ ] Test on lowest supported iOS version
- [ ] Test on latest iOS version

### 3.2 Network Scenarios

- [ ] Test with no internet connection
- [ ] Test with slow/3G connection
- [ ] Test airplane mode transitions
- [ ] Test API timeout handling
- [ ] Test API error responses (401, 429, 500)

### 3.3 Data Scenarios

- [ ] First launch (no data)
- [ ] Empty states for all screens
- [ ] Large datasets (100+ food entries)
- [ ] Import/export functionality
- [ ] Data persistence after force quit
- [ ] Background/foreground transitions

### 3.4 Accessibility Testing

- [ ] VoiceOver navigation works
- [ ] Dynamic Type at all sizes
- [ ] High contrast mode
- [ ] Voice Control
- [ ] Switch Control
- [ ] Color blindness simulators

### 3.5 Edge Cases

- [ ] Invalid user input (negative numbers, special characters)
- [ ] Extremely long text inputs
- [ ] Date edge cases (leap years, time zones)
- [ ] Low storage scenarios
- [ ] Background app termination
- [ ] System permission denials

---

## 📱 Phase 4: App Store Preparation

### 4.1 Build Configuration

1. **Select Release Configuration:**
   - Product → Scheme → Edit Scheme
   - Archive: Change Build Configuration to "Release"

2. **Optimization Settings (should already be set for Release):**
   - Swift Compiler - Code Generation → Optimization Level: `-O`
   - Build Options → Debug Information Format: `DWARF with dSYM File`
   - Deployment → Strip Debug Symbols During Copy: `Yes`
   - Deployment → Strip Swift Symbols: `Yes`
   - Build Settings → Enable Testability: `No` (for Release)

3. **Version & Build Number:**
   - Set version to `1.0.0` (or your desired version)
   - Set build number to `1`
   - Plan versioning strategy for updates

### 4.2 App Store Connect Setup

1. **Create App Record:**
   - [ ] Log in to App Store Connect
   - [ ] Create new app
   - [ ] Select bundle identifier
   - [ ] Choose primary language

2. **App Information:**
   - [ ] App name (30 characters max)
   - [ ] Subtitle (30 characters max)
   - [ ] Primary category: Health & Fitness
   - [ ] Secondary category (optional)

3. **Pricing & Availability:**
   - [ ] Set pricing (Free or Paid)
   - [ ] Select availability territories
   - [ ] Set availability date

### 4.3 App Store Metadata

**App Description (4000 characters):**

Write compelling description highlighting:
- AI-powered food parsing
- Macro tracking (protein, carbs, fats)
- Weight tracking
- HealthKit integration
- Offline mode
- Privacy-focused

**Keywords (100 characters):**
Examples: `nutrition,macro,calories,diet,fitness,health,food,tracker,weight,protein`

**Promotional Text (170 characters):**
Can be updated without app review - use for announcements

**What's New (4000 characters):**
For version 1.0.0: "Welcome to Fuel! Track your nutrition with AI-powered food logging..."

### 4.4 Screenshots

**Required Sizes:**
- [ ] iPhone 6.7" Display (iPhone 15 Pro Max): 1290 x 2796 pixels
- [ ] iPhone 6.5" Display (iPhone 11 Pro Max): 1242 x 2688 pixels
- [ ] iPad Pro (6th Gen) 12.9": 2048 x 2732 pixels (if supporting iPad)

**Tips:**
- Show key features: Dashboard, AI parsing, macro breakdown
- Add captions/annotations highlighting features
- Use consistent styling
- Show the app on a device mockup

**Tools:**
- Screenshots.pro
- Previewed.app
- RocketSim (for Xcode)

### 4.5 App Preview Videos (Optional but Recommended)

- [ ] 15-30 second video showcasing key features
- [ ] Same sizes as screenshots
- [ ] No audio required but recommended
- [ ] Show actual app footage

### 4.6 App Review Information

**Demo Account:**
If your app requires login:
- [ ] Create demo account
- [ ] Provide credentials to reviewers
- [ ] Ensure account has sample data

**Notes for Reviewer:**
Explain:
- [ ] How to test AI parsing (requires API key - provide test key)
- [ ] Special permissions needed
- [ ] Any beta features to ignore

**Contact Information:**
- [ ] First name, Last name
- [ ] Phone number
- [ ] Email address

---

## 🚀 Phase 5: Submission

### 5.1 Archive & Upload

1. **Archive the App:**
   ```
   Product → Archive (in Xcode)
   ```

2. **Validate Archive:**
   - Click "Validate App" in Organizer
   - Fix any validation errors
   - Common issues: Missing icons, entitlement errors

3. **Upload to App Store Connect:**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Follow prompts
   - Wait for processing (5-30 minutes)

### 5.2 Submit for Review

1. **Select Build:**
   - In App Store Connect, go to your app
   - Select the uploaded build

2. **Export Compliance:**
   - Answer encryption questions
   - Most apps: "No" unless doing custom encryption

3. **Advertising Identifier:**
   - If using analytics/ads: "Yes"
   - If not tracking: "No"

4. **Submit:**
   - Click "Submit for Review"
   - Review time: 24-48 hours typically

---

## 📊 Phase 6: Post-Launch Monitoring

### 6.1 Crash Monitoring

Set up crash reporting:
- [ ] Integrate Crashlytics or Sentry
- [ ] Monitor crash-free rate (target: >99%)
- [ ] Set up alerts for crash rate spikes

### 6.2 Analytics

Track key metrics:
- [ ] Daily Active Users (DAU)
- [ ] User retention (Day 1, 7, 30)
- [ ] Feature usage (AI parsing, manual entry, etc.)
- [ ] API costs and usage
- [ ] App Store conversion rate

### 6.3 User Feedback

Monitor:
- [ ] App Store reviews and ratings
- [ ] Support emails
- [ ] Feature requests
- [ ] Bug reports

### 6.4 Performance Monitoring

Track:
- [ ] App launch time (target: <2 seconds)
- [ ] API response times
- [ ] Memory usage
- [ ] Battery impact
- [ ] Storage usage

---

## 🔄 Phase 7: Maintenance & Updates

### 7.1 Regular Updates

Plan for:
- [ ] Bug fixes (as needed)
- [ ] Feature updates (monthly/quarterly)
- [ ] iOS compatibility updates (annually)
- [ ] Dependency updates (as needed)

### 7.2 TestFlight Beta Program

Consider:
- [ ] Set up TestFlight for beta testing
- [ ] Recruit beta testers
- [ ] Use for pre-release testing
- [ ] Gather feedback before public release

### 7.3 Version Numbering

Follow semantic versioning:
- Major (1.0.0): Major features/breaking changes
- Minor (1.1.0): New features, backwards compatible
- Patch (1.0.1): Bug fixes only

---

## 🆘 Common Issues & Solutions

### Issue: "Missing Compliance"
**Solution:** Answer export compliance questions in App Store Connect

### Issue: "Missing Privacy Manifest"
**Solution:** Ensure Info.plist has all required privacy descriptions

### Issue: "Invalid Entitlements"
**Solution:** Verify entitlements match capabilities in Developer Portal

### Issue: "Binary Rejected - Crashes"
**Solution:** Test thoroughly on real devices, check crash logs

### Issue: "Metadata Rejected"
**Solution:** Ensure screenshots match app functionality, no prohibited content

### Issue: "Missing Info.plist Keys"
**Solution:** Add all required usage descriptions (camera, photos, health)

---

## 📋 Pre-Submission Checklist

Run through this before submitting:

**Code:**
- [ ] All TODO/FIXME comments resolved
- [ ] No debug print statements (use AppLogger)
- [ ] No hardcoded API keys
- [ ] Error handling comprehensive
- [ ] Logging uses OSLog
- [ ] Configuration uses AppConfiguration

**Testing:**
- [ ] Tested on multiple devices
- [ ] Tested all user flows
- [ ] Tested offline mode
- [ ] Tested error scenarios
- [ ] Accessibility verified
- [ ] Performance acceptable

**Assets:**
- [ ] App icon all sizes
- [ ] Launch screen configured
- [ ] Screenshots prepared
- [ ] App preview video (optional)

**Metadata:**
- [ ] App name finalized
- [ ] Description written
- [ ] Keywords optimized
- [ ] Privacy policy live
- [ ] Support URL live
- [ ] Contact info provided

**Configuration:**
- [ ] Info.plist privacy descriptions
- [ ] Entitlements configured
- [ ] Signing certificates valid
- [ ] Bundle ID correct
- [ ] Version/build number set

**Legal:**
- [ ] Privacy policy hosted
- [ ] Terms of service ready
- [ ] GDPR compliance (if EU)
- [ ] COPPA compliance (if < 13)

---

## 🎓 Resources

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Tools
- [App Store Screenshot Mockup Generator](https://www.appstorescreenshot.com/)
- [Privacy Policy Generator](https://app-privacy-policy-generator.firebaseapp.com/)
- [App Store Optimization](https://www.storemaven.com/)

### Testing
- [TestFlight](https://developer.apple.com/testflight/)
- [Instruments (Performance)](https://developer.apple.com/xcode/instruments/)
- [Accessibility Inspector](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityMacOSX/OSXAXTestingApps.html)

---

## 💡 Tips for Success

1. **Start Early**: Begin App Store setup before app is complete
2. **Test Thoroughly**: Crashes = rejections
3. **Good Screenshots**: First impression matters
4. **Clear Description**: Help users understand your app
5. **Respond Quickly**: Reply to reviewer questions fast
6. **Monitor Metrics**: Watch crash reports and reviews
7. **Iterate**: Use feedback to improve
8. **Stay Updated**: iOS changes require updates

---

## 🎉 Launch Day Checklist

- [ ] Submit to App Store
- [ ] Prepare social media announcements
- [ ] Set up app support email monitoring
- [ ] Monitor crash reports closely
- [ ] Watch for critical bugs
- [ ] Respond to initial reviews
- [ ] Thank beta testers
- [ ] Celebrate! 🎊

---

**Questions or Issues?**

Check the `PRODUCTION_CHECKLIST.md` for detailed technical requirements.

Good luck with your launch! 🚀
