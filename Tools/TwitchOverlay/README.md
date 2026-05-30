# Twitch Overlay Suite - Clean Stable Build

This package has one active route per feature. The old overlapping legacy folders and redirect-only duplicates were removed after their code was folded into the active builder, manager, dashboard, and viewer pages.

## Start

1. Run `START_SERVER_8080.bat`.
2. Open `http://localhost:8080`.
3. Use the root menu:
   - `OverlayBuilder/OverlayTools.html`
   - `StreamManager/StreamManager.html`
   - `Dashboard/dashboard.html`
   - `ClientViewer/index.html`

## Active structure

```text
TwitchOverlay_Clean_Stable_App/
├─ index.html
├─ START_SERVER_8080.bat
├─ server.py
├─ README.md
├─ OverlayBuilder/
│  └─ OverlayTools.html
├─ StreamManager/
│  └─ StreamManager.html
├─ Dashboard/
│  └─ dashboard.html
├─ ClientViewer/
│  └─ index.html
├─ Outputs/
│  ├─ Elements/
│  ├─ OverlayFrames/
│  └─ Clients/
└─ Game Profiles/
```

## Flow

1. Use **Overlay Element Builder** to export PNG, PNG frameset ZIP, or self-contained HTML labels, buttons, and frames.
2. Put or select those exports from `Outputs/Elements` or `Outputs/OverlayFrames` when loading them in **Stream Manager**.
3. In **Stream Manager**, define the required **Game Name** and **Profile / Scene Name** before creating the stream.
4. Enter the Twitch channel and Dashboard Metrics Twitch name. The dashboard URL is built as `https://twitchtracker.com/<twitch-name>`.
5. Press **Create Stream / Export Client ZIP**.
6. The downloaded ZIP contains a GitHub Pages-ready viewer folder with root `index.html`, plus profile copies under `Game Profiles/<Game>/<Profile>/`.

## GitHub Pages viewer

Upload the generated viewer folder contents, not the entire app folder, to GitHub Pages. The generated viewer uses `location.hostname` as the Twitch embed parent by default, so it does not need localhost hard-coded.

## Important browser limits

Static browser pages cannot silently write files into local folders. The manager therefore uses downloads/ZIP export and user-selected imports. That is the stable static-site-safe version of the requested flow.

If TwitchTracker blocks iframe embedding from its own server headers, the dashboard panel still builds the correct URL and the **Open Direct** button opens the exact metrics page.

## Hotfix: baked PNG/HTML workflow, local cache, and stripped clients

This hotfix keeps the clean app structure but adds the missing production flow:

- Overlay Builder now caches exported PNG and self-contained HTML elements into localStorage so Stream Manager can reload them after refresh.
- Custom PNG label exports now bake the uploaded image, its scale, and the custom label shape/backplate toggle into the final PNG.
- Overlay Builder no longer wipes typed label fields when switching presets/layout styling. Use Quick Labels only when you intentionally want preset text.
- PNG frames now export as a `*_png_frameset.zip` instead of loose repeated downloads.
- Stream Manager accepts PNG, PNG frameset ZIP, and self-contained HTML element imports. SVG is intentionally not part of the active workflow.
- Stream Manager includes an action editor for selected elements/buttons: visual-only, URL/href open, redirect, play sound URL, invite link, or donation link.
- Stream Manager autosaves profile/config/library state locally while you work.
- Generated clients are stripped and baked as:

```text
<streamer>_StreamClient/
├─ index.html
└─ viewer/
   └─ index.html
```

The generated client does not include `Outputs/`, `Game Profiles/`, or editable config files. The root `index.html` is the GitHub Pages entry and fades in `viewer/index.html`.

## GitHub publish helpers

See `Tools/README_GITHUB_PAGES.md`.

- `Tools/Publish_StreamClient_To_GitHub.bat` copies a generated `*_StreamClient` to a public GitHub repo, creates a Pages workflow, commits, pushes, and prints the share URL.
- `Tools/End_Stream_Cleanup.bat` removes an ended stream folder from the repo under `streams/<stream-name>/`, commits the cleanup, and pushes.
