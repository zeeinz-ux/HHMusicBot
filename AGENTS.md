# MusicBot (HHMusic v16.0) — Agent Guide

## Quick Start

```bash
npm install                       # install deps + auto-updates yt-dlp (postinstall)
# edit .env with Discord token + client ID
npm start                         # node index.js (normal mode, <1000 servers)
node shard.js                     # sharding mode (1000+ servers)
npm test                          # node --check index.js (syntax check only, no test framework)
```

## Key Architecture

- **Entrypoints**: `index.js` (main), `shard.js` (sharding manager spawning `index.js` workers)
- **Config**: `config.js` reads from `.env` via `dotenv`
- **Commands**: `commands/` — 12 slash commands (`play`, `search`, `nowplaying`, `queue`, `skip`, `stop`, `pause`, `resume`, `shuffle`, `loop`, `language`, `help`)
- **Core engine**: `src/MusicPlayer.js` (~2000 lines), `src/PlayerStateManager.js` (crash recovery)
- **Music sources**: `src/YouTube.js`, `src/Spotify.js`, `src/SoundCloud.js`, `src/DirectLink.js`
- **Persistence**: `database/` — JSON files (`languages.json`, `playerState.json`)
- **Audio cache**: `audio_cache/` — MD5-hashed `.opus` files, cleaned on startup

## Non-Obvious Facts

- **5-second startup delay** (`index.js:127`): `commandLoader.js` is `require`d inline at line 11 but the main `Client` creation is wrapped in `setTimeout` with 5000ms to let slash commands register via REST API before connecting.
- **`commandLoader.js` side-effect import**: Required at `index.js:11` purely for its side effect (registers slash commands via Discord REST API). No exported bindings used.
- **YouTube auth priority** (`src/YouTube.js:21-33`): PO Token > Browser Cookie > Cookie File > iOS client (fallback when nothing configured). The iOS client fallback bypasses YouTube bot detection on VPS/server IPs.
- **Session recovery**: On restart, `PlayerStateManager` restores active players from `database/playerState.json`, reconnects to voice channels, and resumes playback.
- **Sharding config** (via `.env`): `TOTAL_SHARDS` (default `auto`), `SHARD_MODE` (`process`/`worker`), `SHARD_SPAWN_DELAY` (5500ms), `SHARD_SPAWN_TIMEOUT` (30000ms).
- **No `.gitignore`**: `.env` with secrets is tracked in git. Do not commit changes to `.env`.
- **No test framework, no linter, no formatter, no TypeScript** — pure CommonJS JavaScript.
- **Required Node.js**: `>=24.11.1` (enforced via `package.json` engines).
- **ffmpeg bundled** via `ffmpeg-static` — no system install needed.
- **Postinstall hook**: `scripts/update-ytdlp.js` auto-updates yt-dlp binary (critical — YouTube breaks older versions frequently).
