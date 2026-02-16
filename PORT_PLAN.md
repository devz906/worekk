# GameHub for iPhone 16 Pro – Port Plan & Optimized Stack

**Target:** iPhone 16 Pro (A18 Pro), JIT enabled via sideload (StikJIT)  
**Goal:** GameHub-style app that runs PC/Windows games at best speed with GPU (Metal) and full driver stack, similar to Winlator on Android but for iOS.

---

## 1. iPhone 16 Pro – Why It’s Suitable

| Aspect | iPhone 16 Pro |
|--------|----------------|
| **SoC** | A18 Pro (ARM64, 6-core CPU, 6-core GPU) |
| **Graphics** | Apple GPU, Metal-only (no Vulkan) |
| **JIT** | Possible via **StikJIT** (iOS 17.4–18.7.4, no jailbreak) when app is sideloaded |
| **Limit** | iOS 18.4+ may restrict JIT to debugger; stay on 18.3 or use StikJIT where it still works |

**Recommendation:** Build and test with **JIT enabled via StikJIT** + sideload (e.g. AltStore, SideStore, or developer install). App Store builds cannot use JIT.

---

## 2. Best-Optimized Gaming Stack (What to Port / Reuse)

### 2.1 High-level stack (Winlator-style, adapted for iOS)

```
[Windows .exe] → Wine (Windows API) → DXVK/D3D → Vulkan → MoltenVK → Metal (A18 GPU)
                     ↑
              x86/x64 code → Box64/FEX-style JIT (if we need x86 emu on ARM)
```

On **iPhone we don’t have** Box64/FEX (they target Linux/Android). So we have two paths:

- **Path A – Native ARM Wine (preferred):**  
  Wine built for **ARM64** (like Hangover on Linux). No x86 emulator; only ARM64 Wine + translation layers. Works only if the game has an ARM build or we use something like ARM64EC-style mix (not standard on iOS).

- **Path B – x86 emulation + Wine (BoxedWine-style):**  
  Emulate x86 (or x86_64) CPU, run unmodified Wine + Windows .exe inside that. This is what **BoxedWine** does (emulates Linux + Wine in C++). Slower but runs any .exe.

For **maximum compatibility with random .exe** (like your imgtool.exe), **Path B (BoxedWine-style)** is the one that matches your “container” idea. For **best speed** when we have ARM builds or narrow set of games, Path A would be better later.

### 2.2 Components to use / port

| Component | Role | Best choice for iPhone 16 Pro |
|-----------|------|------------------------------|
| **Wine** | Windows API → POSIX | Wine 9.x ARM64 build, or Wine inside BoxedWine’s emulated env |
| **Graphics (D3D → GPU)** | DirectX → Metal | **MoltenVK** (Vulkan → Metal) + **DXVK** (D3D9/10/11 → Vulkan). No native Vulkan on iOS, so MoltenVK is required. |
| **Optional: D3DMetal** | D3D → Metal directly | Apple’s D3DMetal is in **Game Porting Toolkit (macOS only)**. Not on iOS; use DXVK+MoltenVK. |
| **x86 emulation (if needed)** | Run x86 .exe on ARM | **BoxedWine** (C++ x86 emu + Wine) – no iOS port yet; **or** UTM’s core (heavy). Porting BoxedWine to iOS gives a single “container” (boxedwine.zip) runner. |
| **JIT** | Speed for emu/translation | Enable via **StikJIT** for the sideloaded app; ensure the app’s JIT is allowed (no App Store for full JIT). |

### 2.3 Drivers / GPU

- **iOS only exposes Metal.** No Vulkan, no OpenGL (only legacy GL via Metal).
- **Stack:** DXVK (D3D → Vulkan) → **MoltenVK** (Vulkan → Metal).
- **MoltenVK:** [The-Wineskin-Project/MoltenVK](https://github.com/The-Wineskin-Project/MoltenVK) – Vulkan 1.x on Metal, works on **iOS and macOS**. Use this in the Wine/DXVK build for iPhone.
- **Turnip / VirGL / Vortek:** Those are **Android** GPU drivers (Vulkan). Not applicable on iOS; on iPhone the “driver” is Metal + MoltenVK.

So: **best “driver” setup for iPhone 16 Pro = Metal + MoltenVK + DXVK + Wine.**

---

## 3. Port Strategy: BoxedWine to iOS

BoxedWine currently supports: Windows, macOS, Linux, Emscripten. **No official iOS port.**

### 3.1 Why BoxedWine fits your “container” idea

- Runs an **unmodified 32-bit Wine** inside an emulated Linux environment.
- Can load filesystem from a **zip** (e.g. your **boxedwine.zip**).
- Single C++ codebase with SDL2; SDL2 has **official iOS support**.
- So: one app (GameHub) can ship or load a “container” (boxedwine.zip) and run .exe inside it.

### 3.2 What to port

1. **BoxedWine core (C++)**  
   - Platform layer: add **SDL2 iOS** target (SDL already supports iOS).  
   - Replace Emscripten-specific code with iOS (Metal/OpenGL ES) where needed.  
   - Use **JIT** for the x86 recompiler: on iOS, JIT is only allowed when the process is being debugged or with tricks (e.g. StikJIT); the app **must** be sideloaded and JIT-enabled.

2. **Build system**  
   - CMake or Xcode project; link SDL2 for iOS, and optionally **MoltenVK** if we add a Vulkan path inside the emulator later.  
   - First goal: get BoxedWine running on iOS with **interpreted or simple JIT** x86 execution, then optimize with full JIT where StikJIT allows.

3. **Container format**  
   - Keep **boxedwine.zip** as the format: Wine prefix + Windows FS + your .exe (e.g. imgtool.exe).  
   - GameHub app: “Install container” = copy/extract boxedwine.zip to app container, then launch BoxedWine with that path.

4. **GPU**  
   - BoxedWine’s current GPU path is often OpenGL or software. For “max speed” and “drivers”:  
   - Long-term: integrate **DXVK + MoltenVK** in the Wine build used inside BoxedWine (complex).  
   - Short-term: get BoxedWine on iOS running with existing Wine GPU (OpenGL → Metal via MetalKit/OpenGL ES), then iterate.

### 3.3 GamePiisii-style limitation (“only lower exe”)

- “Lower exe” likely means **32-bit** .exe.  
- BoxedWine uses **32-bit Wine**; Box64 is for **64-bit** on ARM.  
- So: BoxedWine = 32-bit Windows apps; if we later add 64-bit (e.g. Box64 or similar) we’d need an x86_64 emulator.  
- For your **imgtool.exe** (32-bit), BoxedWine in a zip is a good match; the port keeps that use case.

---

## 4. Recommended order of work

1. **GameHub iOS app (Swift/SwiftUI)**  
   - Game library UI, “containers” (e.g. list of boxedwine.zip imports).  
   - Document: “Use StikJIT for full speed (sideload only).”  
   - Placeholder to launch “runner” (BoxedWine when ported, or external UTM if you want a fallback).

2. **BoxedWine iOS port (C++ / SDL2)**  
   - New target in BoxedWine: **iOS** (iPhone 16 Pro, ARM64).  
   - SDL2 iOS + Metal or OpenGL ES for display.  
   - Load **boxedwine.zip** from app container; start Wine and run selected .exe.

3. **JIT**  
   - Ensure the app is **sideloaded** and **StikJIT-enabled** so the x86 recompiler in BoxedWine can use JIT.  
   - Test on iOS 17.4–18.3 (or current StikJIT-supported versions).

4. **GPU and “drivers”**  
   - First: get BoxedWine’s current Wine/OpenGL path rendering on Metal (via MetalKit or GL ES).  
   - Then: explore DXVK + MoltenVK in the Wine used inside BoxedWine for better 3D and “max speed.”

---

## 5. Summary: “Best optimized gaming Wine and drivers” for iPhone 16 Pro

- **Wine:** Wine 9.x (32-bit for BoxedWine; later 64-bit if we add x64 emu).  
- **GPU “drivers”:** **MoltenVK** (Vulkan on Metal) + **DXVK** (D3D → Vulkan).  
- **Container:** **BoxedWine** (boxedwine.zip) with Wine + your .exe; port BoxedWine to iOS.  
- **JIT:** **StikJIT** + sideload (no App Store for this build).  
- **Platform:** iPhone 16 Pro (A18 Pro), Metal-only; no Vulkan, so MoltenVK is mandatory for a Vulkan-based stack.

If you share your **boxedwine.zip** layout (or a list of what’s inside), the next step is to wire GameHub to that format and then implement the BoxedWine iOS target so your imgtool.exe (and other 32-bit .exe) run inside GameHub with JIT and, over time, the best possible Metal/DXVK path.
