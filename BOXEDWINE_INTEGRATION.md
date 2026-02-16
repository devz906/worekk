# BoxedWine / boxedwine.zip integration

This doc describes how your **boxedwine.zip** and a future **BoxedWine iOS port** plug into GameHub.

## Container format you can share

- **boxedwine.zip** – A zip that BoxedWine can use as its filesystem (Wine prefix + Windows FS + your .exe, e.g. `imgtool.exe`).  
  BoxedWine supports loading the FS from a zip when built with **BOXEDWINE_ZLIB**.

GameHub does **not** unzip it. It **copies** the chosen file into:

```
Documents/Containers/<name>.zip
```

and stores that path in `ContainerManager`. When you add a “game”, you associate an .exe path (e.g. `imgtool.exe`) with that container path.

## Where the runner is called

In **GameHub/Services/ContainerManager.swift**:

```swift
func launch(game: GameEntry) {
    // TODO: Integrate BoxedWine iOS port – run container at game.containerId, exe at game.exePath
}
```

When you have the BoxedWine iOS port (or any native runner):

1. **Container path:** `game.containerId` (e.g. `.../Documents/Containers/boxedwine.zip`).
2. **Exe path:** `game.exePath` (e.g. `imgtool.exe` or `C:\...\imgtool.exe` inside the Wine prefix).

Pass these into your runner (e.g. via a C++ bridge or a subprocess API if you spawn the BoxedWine binary).

## BoxedWine iOS port – what to pass

From the BoxedWine side:

- **Root / filesystem:** Path to the .zip (or an extracted directory). BoxedWine can use a zip with the right build flags.
- **Exe to run:** The Windows path of the .exe (e.g. `imgtool.exe` or full path inside the prefix).

So the bridge from GameHub to BoxedWine should at least accept:

- `containerPath` (String) → path to `boxedwine.zip` (or folder).
- `exePath` (String) → Windows path of the .exe inside that environment.

## Adding games from a container

Right now the UI only lists “games” that are already in `installedGames`. To **add** a game (e.g. “imgtool” from your boxedwine.zip):

1. **Option A – Code:** Call `ContainerManager.shared.addGame(name: "imgtool", exePath: "imgtool.exe", containerId: "<container path>", containerName: "boxedwine")` (e.g. from a “+” flow or a container detail screen).
2. **Option B – UI:** Add a screen that lists containers, lets the user pick one, then enter “Game name” and “Exe path” and call `addGame`.

If you share the exact layout of your **boxedwine.zip** (paths to Wine and to `imgtool.exe`), we can define a small manifest (e.g. `games.json` inside the zip) so GameHub can auto-scan and add games from the container.

## Summary

- **Import:** User picks `boxedwine.zip` → app copies it to `Documents/Containers/` and saves the path.
- **Launch:** When runner is ready, `launch(game:)` passes `game.containerId` and `game.exePath` to the BoxedWine iOS port.
- **Your zip:** Share your **boxedwine.zip** when ready; the port plan and this doc stay valid for that format.
