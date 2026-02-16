# GameHub for iPhone 16 Pro (JIT)

GameHub-style app to run PC/Windows games in **BoxedWine-style containers** on iPhone 16 Pro, with **JIT enabled** (via StikJIT sideload) and an optimized Wine + GPU stack (DXVK → MoltenVK → Metal).

## What’s in this repo

- **PORT_PLAN.md** – Port plan and recommended stack: Wine, MoltenVK, DXVK, BoxedWine, JIT (StikJIT) for iPhone 16 Pro.
- **GameHub/** – SwiftUI app:
  - **Games** tab: list and launch installed games (from containers).
  - **Containers** tab: import `boxedwine.zip` (or compatible container); path is stored for the future BoxedWine iOS runner.
  - **Settings** tab: JIT/StikJIT instructions and links (BoxedWine, MoltenVK).
- **BOXEDWINE_INTEGRATION.md** – How to plug in your `boxedwine.zip` and the BoxedWine iOS port when ready.

## Target device

- **iPhone 16 Pro** (A18 Pro, Metal).
- **JIT:** Use **StikJIT** with a **sideloaded** build (not App Store) for full speed.  
  See: [stikjit.github.io](https://stikjit.github.io).  
  Supported iOS versions (as of writing): 17.4–18.7.4 (check StikJIT for latest).

## Build and run (Xcode)

1. Open Xcode and create a new **App** project:
   - Product Name: **GameHub**
   - Team: your Apple ID
   - Organization Identifier: e.g. `com.yourname`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum deployment: **iOS 17.0** (to align with StikJIT-supported versions)

2. Add the existing **GameHub** source files to the app target:
   - `GameHubApp.swift`
   - `Views/` (MainTabView, GameLibraryView, ContainerListView, SettingsView)
   - `Models/` (GameEntry, GameContainer)
   - `Services/ContainerManager.swift`

3. Enable **File sharing** and **iCloud / Documents** if you want container files to be visible in Files:
   - Target → **Signing & Capabilities** → add **iCloud** or use **File sharing** (UIFileSharingEnabled, LSSupportsOpeningDocumentsInPlace in Info.plist if needed).

4. Build and run on a device (recommended: iPhone 16 Pro with JIT enabled via StikJIT).

## Sideload and JIT (StikJIT)

- Install the app via **sideload** (AltStore, SideStore, or Xcode dev install).
- Use **StikJIT** to enable JIT for the GameHub process so that when the BoxedWine iOS port runs, its x86 recompiler can use JIT for best speed.
- App Store builds **cannot** use JIT; they will run without it (slower).

## Container format (boxedwine.zip)

- You can **share your boxedwine.zip** and import it in GameHub via **Containers → Import**.
- The app **copies** the selected file into its Documents/Containers folder and stores the path. When the **BoxedWine iOS port** is integrated, the runner will receive:
  - Container path (e.g. the copied `boxedwine.zip` or extracted folder),
  - Selected .exe path (e.g. `imgtool.exe`),
  and run Wine + your .exe inside that environment.

See **BOXEDWINE_INTEGRATION.md** for where to hook the runner and how the container path is passed.

## Optimized stack (summary)

| Layer        | Choice for iPhone 16 Pro |
|-------------|---------------------------|
| Windows API | Wine (32-bit in BoxedWine; later 64-bit if needed) |
| D3D → GPU   | DXVK (D3D9/10/11 → Vulkan) |
| Vulkan → GPU| MoltenVK (Vulkan → Metal) |
| JIT         | StikJIT (sideload only)   |

Details and port steps: **PORT_PLAN.md**.

## Status

- **Done:** App UI, container import (copy `boxedwine.zip`), game list placeholder, Settings with JIT/StikJIT and stack links, port plan and integration notes.
- **Next:** Port BoxedWine to iOS (SDL2 + Metal/OpenGL ES), then in GameHub call the native runner with container path + exe path and enable JIT via StikJIT.
