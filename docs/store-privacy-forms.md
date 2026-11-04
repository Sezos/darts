# Store privacy forms for DartScore

These are the answers for App Store Connect's **App Privacy** section and Google Play's **Data safety** form, as of the release that adds ranks and friends. Update them whenever the app starts collecting something new.

Privacy policy URL: `https://darts-onoo.web.app/privacy`
Account deletion URL (required by Play): `https://darts-onoo.web.app/delete-account`

## What the app collects

| Data | Source | Linked to the user | Purpose | Shared publicly |
|---|---|---|---|---|
| Player name | Friends profile | Yes | App functionality | Yes, to anyone with the friend code |
| User ID (Firebase uid, friend code) | Friends | Yes | App functionality | Code only |
| Skill ratings, games played | Friends profile | Yes | App functionality | Yes, to anyone with the code |
| Game history (backup) | Friends | Yes | App functionality | No (owner only) |
| Friends list | Friends | Yes | App functionality | No |
| Email address | Only with Apple/Google sign-in | Yes | App functionality (account) | No |
| Usage data: screens, game events, settings | Firebase Analytics | No | Analytics | No |
| Device ID / app instance ID | Firebase Analytics, AdMob | No | Analytics, advertising | No |
| Advertising data, coarse location (IP) | AdMob | No | Third-party advertising | No |

The camera is used only on the phone, to read QR codes. Nothing is collected from it.

## App Store Connect: App Privacy

Data types to declare:
- **Contact Info → Email Address:** linked to the user, App Functionality. Only when they sign in with Apple or Google.
- **Contact Info → Name:** linked to the user, App Functionality. This is the player name on their profile.
- **Identifiers → User ID:** linked to the user, App Functionality.
- **Identifiers → Device ID:** not linked, Analytics and Third-Party Advertising (Firebase Analytics, AdMob).
- **Usage Data → Product Interaction:** not linked, Analytics.
- **Usage Data → Advertising Data:** not linked, Third-Party Advertising.
- **User Content → Gameplay Content:** linked to the user, App Functionality (ratings and game backup).
- **Location → Coarse Location:** not linked, Third-Party Advertising (AdMob, from the IP address).

**Tracking:** the app doesn't show the App Tracking Transparency prompt, so AdMob serves non-personalised ads on iOS. Check AdMob's current Apple-privacy guidance before answering "Used to track you". If the app ever adds the ATT prompt, Device ID and Advertising Data become tracking.

## Google Play: Data safety

- **Does your app collect or share any of the required user data types?** Yes.
- **Is all of the user data encrypted in transit?** Yes. Firebase and AdMob use TLS.
- **Do you provide a way for users to request that their data is deleted?** Yes: in the app (Settings → Online account) and at the deletion URL above.
- **Personal info:**
  - Name: collected, App functionality, optional (only if they open Friends).
  - Email address: collected, Account management, optional (Apple/Google sign-in).
  - User IDs: collected, App functionality.
- **App activity:**
  - App interactions: collected, Analytics.
  - Other user-generated content (game history, ratings): collected, App functionality, optional.
- **Device or other IDs:** collected and shared with Google (AdMob), Analytics and Advertising.
- **Location → Approximate location:** collected by AdMob, Advertising.
- **Sharing:** declare AdMob's ad data as "shared". Data processed by Firebase on your behalf counts as service-provider processing, not sharing.

## Still to decide

Contact email on the privacy and deletion pages: badral@mail.com.

- Abandoned anonymous accounts are never cleaned up. Either add a scheduled cleanup, or state a retention period in the policy.
