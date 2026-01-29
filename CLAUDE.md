# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
npm install          # Install dependencies
npm run build        # Clean and compile (runs bslint via bsc plugin)
```

There is no separate lint command — linting runs as part of `npm run build` via the `@rokucommunity/bslint` plugin configured in `bsconfig.json`. The build outputs to `build/staging`.

To deploy to a Roku device: open in VSCode with the BrightScript Language extension and press F5. This auto-packages and sideloads to the device. There is no automated test suite — testing is done manually on a physical Roku device.

Debug console: `telnet <roku-ip> 8085` (exit with `CTRL+]` then `quit`).

## Architecture

This is a BrighterScript (`.bs`) Roku SceneGraph application. BrighterScript compiles to BrightScript (`.brs`) — never edit files in `build/`.

### Bootstrap Flow (source/Main.bs)

`Main()` creates a `roSGScreen`, initializes globals/session/constants, creates the `BaseScene`, instantiates managers (SceneManager, QueueManager, PlaystateTask, AudioPlayer), runs `LoginFlow()`, then enters the main event loop.

### Scene Management

`components/data/SceneManager.bs` implements a scene stack. `pushScene()`/`popScene()` manage navigation. Each scene is a `JFGroup` or `JFScreen` that gets added/removed from the `BaseScene` content area. The `JFOverhang` header updates per-scene.

### Event Architecture

The main event loop in `Main.bs` dispatches to handlers in `source/MainEventHandlers.bs` (30+ event types routed by field name: `selectedItem`, `movieSelected`, `jumpTo`, etc.). Action logic lives in `source/MainActions.bs`. This is a central event bus pattern — most UI interactions flow back through these files.

### API Layer

`source/api/baserequest.bs` provides `APIRequest()` which returns a configured `roUrlTransfer` with MediaBrowser auth headers. Helper functions: `getJson()`, `postJson()`, `getVoid()`, `postVoid()`, `deleteVoid()`. The full API surface is in `source/api/sdk.bs` (~80KB auto-generated).

### Authentication

`source/api/userauth.bs` handles login via username/password or QuickConnect. Auth tokens are persisted in the Roku registry. Session state is managed through `source/utils/session.bs` with a global `m.global.session` object containing server and user info.

### Settings & Config

`source/utils/config.bs` wraps Roku's registry for persistence. Global settings use the "Jellyfin" section; user-specific settings use the user ID as section name. The settings UI tree is defined in `settings/settings.json`.

### Video Player

`components/video/VideoPlayerView.bs` (~47KB) is the largest component. It handles trickplay images, subtitle/audio track selection, chapter navigation, skip segments (intro/credits), "Next Up" episodes, and playback state reporting.

### Queue Management

`components/manager/QueueManager.bs` manages the playback queue with shuffle support, audio track preferences, and preroll (cinema mode). `components/manager/ViewCreator.bs` is the factory for creating player views.

### Async Tasks

Background work uses SceneGraph Task nodes in `components/tasks/`. Tasks communicate results back via field observers on the node.

## Code Conventions

- **Formatting**: 4-space indentation, lowercase keywords, single-quote comments (see `bsfmt.json`)
- **Enums**: Defined in `source/enums/` (31 files) — use these instead of magic strings/numbers
- **Translations**: All user-facing strings go in `locale/en_US/translations.ts`
- **Settings**: When adding settings, follow the naming conventions in `docs/DEVGUIDE.md` (imperative verb phrases, alphabetical ordering, descriptions must be complete sentences)
