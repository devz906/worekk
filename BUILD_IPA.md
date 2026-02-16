# Getting the IPA and bundled runtime (no manual Wine)

## 1. IPA from GitHub Actions

The **Build IPA** workflow runs on every push to `main` (and manually via **Actions → Build IPA → Run workflow**).  
- **If you haven’t added the 5 secrets:** the workflow still runs and only builds for simulator (no IPA, no failure).  
- **After you add the secrets:** it will build and export an IPA and you can download it from the run’s **Artifacts** (e.g. `GameHub-iPA`).

### Where to add the secrets

1. Open your repo: **https://github.com/devz906/worekk**
2. Click **Settings** (repo tabs).
3. In the left sidebar, click **Secrets and variables** → **Actions**.
4. Click **New repository secret** and add each of these (name exactly as below, value as described):

| Secret name (exact) | What to put |
|--------------------|-------------|
| `DEVELOPER_TEAM_ID` | Your Apple Team ID (10 chars), e.g. from https://developer.apple.com/account → Membership details. |
| `CODE_SIGNING_IDENTITY` | Full name of your cert in Keychain, e.g. `Apple Development: your@email.com (TEAMID)`. |
| `P12_BASE64` | Single-line base64 of your .p12 file: `openssl base64 -A -in YourCert.p12` (see “Fixing P12” below). |
| `P12_PASSWORD` | The password you set when exporting the .p12. |
| `MOBILEPROVISION_BASE64` | Single-line base64 of your .mobileprovision: `openssl base64 -A -in GameHub.mobileprovision`. |

After all five are saved, run **Actions → Build IPA → Run workflow** again; the run will produce the **GameHub-iPA** artifact.

### Required secrets (code signing)

To build an IPA for a real device, add these in **GitHub → repo → Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `DEVELOPER_TEAM_ID` | Apple Developer Team ID (10 characters, e.g. `ABCD123456`). Find it in [Apple Developer](https://developer.apple.com/account) → Membership. |
| `CODE_SIGNING_IDENTITY` | Exact name of your iOS Distribution or Development certificate in Keychain, e.g. `"Apple Development: you@email.com (TEAM_ID)"` or `"iOS Distribution"`. |
| `P12_BASE64` | Your signing certificate + private key as `.p12`, then Base64 **single line (no newlines)**. See “Fixing P12” below. |
| `P12_PASSWORD` | Password you set when exporting the .p12. |
| `MOBILEPROVISION_BASE64` | Your **iOS App Development** (or Ad Hoc) profile, Base64 **single line**. See below. |

- **Development** profile: install on devices registered in your Apple Developer account (sideload, AltStore, StikJIT).
- **Ad Hoc**: same but for TestFlight-style distribution to registered devices.

After saving the secrets, run the workflow. When it finishes, open the run → **Artifacts** → download **GameHub-iPA** (contains `GameHub.ipa`).

---

### Fixing “P12 keys missing or in the wrong format”

The action needs base64 **with no newlines** (one long line). If you used `base64 -i file` or `openssl base64 -in file` without `-A`, the string has line breaks and will fail.

**1. Export .p12 from Mac:** Keychain Access → your **Apple Development** (or iOS Distribution) cert + its **private key** → right‑click → **Export 2 items** → save as `.p12` and set a password (`P12_PASSWORD`).

**2. Encode as one line:**

- **macOS/Linux:** `openssl base64 -A -in YourCert.p12`  
  (The **`-A`** is required.)
- **Windows PowerShell:**  
  `[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\YourCert.p12"))`

Copy the **entire** output.

**3. GitHub secret:** Settings → Secrets → **P12_BASE64** → paste the full string. No leading/trailing spaces or newlines, no quotes.

**4. Provisioning profile (same idea):**  
- **macOS/Linux:** `openssl base64 -A -in GameHub.mobileprovision`  
- **Windows:** `[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\GameHub.mobileprovision"))`  
Create **MOBILEPROVISION_BASE64** and paste the full single-line output.

---

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
