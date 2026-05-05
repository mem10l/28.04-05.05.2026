# Haskell CLI, GUI & Web Applications

This repository contains five separate programs written in Haskell:

- **2Dgame** – A 2D side-scrolling platformer with coins and camera scrolling
- **Crud_cli** – CRUD operations on an in-memory list
- **Hangman** – Terminal word guessing game
- **Num_guessing_game** – Number guessing game
- **web** – A Yesod web application backed by SQLite

Each project is self-contained in its own folder.

---

## Project Structure

```text
forfun/
├── 2Dgame/
│   ├── Main.hs
│   ├── 2Dgame.cabal
│   ├── src/
│   │   └── MyLib.hs
│   └── test/
├── Crud_cli/
│   └── Main.hs
├── Hangman/
│   ├── Main.hs
│   └── word.txt
├── Num_guessing_game/
│   └── Main.hs
└── web/
    ├── app/
    ├── src/
    ├── templates/
    ├── static/
    ├── config/
    ├── test/
    ├── package.yaml
    ├── stack.yaml
    ├── stack.yaml.lock
    ├── web.cabal
    └── web.sqlite3
```

---

## Requirements

- **GHC** (Glasgow Haskell Compiler) — https://www.haskell.org/ghc/
- **Cabal** (for the 2Dgame project) — https://www.haskell.org/cabal/
- **Stack** (for the web project) — https://docs.haskellstack.org/
- **Gloss** (graphics library, installed automatically via Cabal for 2Dgame)
- **Yesod** + **SQLite** (installed automatically via Stack for the web project)

---

## How to Run

Each project must be compiled and run separately.

---

### Run 2D Platformer

The 2Dgame project uses Cabal and the [Gloss](https://hackage.haskell.org/package/gloss) graphics library.

```bash
cd 2Dgame
cabal run
```

#### Features

- Side-scrolling platformer with a camera that follows the player
- Collectible coins with spin animation (+10 points each)
- Multiple platforms across a wide level
- Physics: gravity, jumping, friction, head-bump detection
- Death pit — fall below the level to trigger Game Over
- Night sky background with stars

#### Controls

| Key | Action |
|-----|--------|
| `A` / `←` | Move left |
| `D` / `→` | Move right |
| `W` / `↑` / `Space` | Jump |
| `R` | Restart |

---

### Run CRUD CLI

```bash
cd Crud_cli
ghc Main.hs -o crud
./crud
```

#### Features

- `create` – add an item
- `read` – list all items
- `update` – modify an item by index
- `delete` – remove an item by index
- `quit` – exit

---

### Run Hangman

```bash
cd Hangman
ghc Main.hs -o hangman
./hangman
```

> **Note:** `word.txt` must be present in the `Hangman/` directory. The game reads words from this file — one word per line.

#### Features

- ASCII hangman art that builds with each wrong guess
- 6 wrong attempts allowed
- Letter-by-letter guessing
- Replay option after win or loss
- Type `quit` at any time to exit

---

### Run Number Guessing Game

```bash
cd Num_guessing_game
ghc Main.hs -o guess
./guess
```

#### Features

- Random number between 1 and 100
- Feedback: too high / too low
- Runs until the correct number is guessed

---

### Run Yesod Web App

The `web` project uses [Stack](https://docs.haskellstack.org/) and the [Yesod](https://www.yesodweb.com/) framework with a SQLite database.

#### First-time setup

```bash
cd web

# Install Stack if not already installed
curl -sSL https://get.haskellstack.org/ | sh

# Build the project and fetch all dependencies (takes a while on first run)
stack build
```

#### Run in development mode

```bash
stack exec -- yesod devel
```

The app will be available at `http://localhost:3000`. Yesod will automatically recompile and reload on file changes.

#### Run in production mode

```bash
stack build
stack exec web
```

#### Database

The app uses SQLite. The database file (`web.sqlite3`) is created automatically in the `web/` directory on first run. No manual setup is required.

#### Features

- Full-stack Haskell web application
- Type-safe routing via Yesod
- Persistent SQLite storage via Persistent library
- Server-side HTML rendering with Hamlet templates
- Static file serving from the `static/` directory

---

## Notes

- All CLI programs (`Crud_cli`, `Hangman`, `Num_guessing_game`) run in the terminal and require only GHC
- `2Dgame` opens a graphical window and requires Cabal + the Gloss library
- `web` requires Stack and runs a local HTTP server; the SQLite database persists between sessions
- CLI projects have no data persistence (in-memory only)
- Some inputs are not fully validated and may cause runtime errors