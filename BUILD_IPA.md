# Getting the IPA and bundled runtime (no manual Wine)

## 1. IPA from GitHub Actions

The **Build IPA** workflow runs on every push to `main` (and manually via **Actions → Build IPA → Run workflow**). It produces an IPA you can download from the run’s **Artifacts** (e.g. `GameHub-iPA`).

### Required secrets (code signing)

To build an IPA for a real device, add these in **GitHub → repo → Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `DEVELOPER_TEAM_ID` | Apple Developer Team ID (10 characters, e.g. `ABCD123456`). Find it in [Apple Developer](https://developer.apple.com/account) → Membership. |
| `CODE_SIGNING_IDENTITY` | Exact name of your iOS Distribution or Development certificate in Keychain, e.g. `"Apple Development: you@email.com (TEAM_ID)"` or `"iOS Distribution"`. |
| `P12_BASE64` | Your signing certificate + private key exported as a `.p12` file, then Base64-encoded (no newlines): `openssl base64 -A -in Certificates.p12` |
| `P12_PASSWORD` | Password you set when exporting the .p12. |
| `MOBILEPROVISION_BASE64` | Your **iOS App Development** (or Ad Hoc) provisioning profile, Base64-encoded: `openssl base64 -A -in GameHub.mobileprovision` |

- **Development** profile: install on devices registered in your Apple Developer account (sideload, AltStore, StikJIT).
- **Ad Hoc**: same but for TestFlight-style distribution to registered devices.

After saving the secrets, run the workflow. When it finishes, open the run → **Artifacts** → download **GameHub-iPA** (contains `GameHub.ipa`).

### If you don’t set secrets

The workflow will fail at the “Build and export IPA” step with a signing error. To only **build** (no IPA) on your Mac: open `GameHub.xcodeproj` in Xcode, set your Team under Signing & Capabilities, then **Product → Archive** and **Distribute App** to export an IPA locally.

---

## 2. Wine / BoxedWine: you do **not** install it manually

Like **GamePiisii**, the goal is to **bundle a ready-made BoxedWine environment** (a ~200MB zip with Wine + minimal “PC” runtime) so the app can run .exe without the user installing Wine.

- **GamePiisii:** ships (or downloads) a ~200MB boxedwine zip with the whole runtime and runs actual .exe inside it.
- **GameHub (this repo):**  
  - The app already **imports** a `boxedwine.zip` (Containers tab) and will pass it to the **BoxedWine iOS runner** when that’s integrated.  
  - Next step: **bundle a default runtime** so the user doesn’t have to provide one:
    - Either **embed** a ~200MB BoxedWine zip in the app (or in a first-run download), or  
    - **Pre-package** one and host it; the app downloads it on first launch if no container is present.

So: **no manual Wine install**. The app will use a bundled/pre-downloaded BoxedWine zip (same idea as GamePiisii). Your existing `boxedwine.zip` that runs `imgtool.exe` is the kind of container we’ll ship or download by default once the BoxedWine iOS port is in place.

Summary:

- **IPA:** from the GitHub Actions workflow (after adding the secrets above) or from Xcode Archive on your Mac.  
- **Wine:** not installed by the user; the app will use a bundled BoxedWine-style runtime (e.g. a ~200MB zip) like GamePiisii.
