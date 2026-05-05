# Haskell CLI & GUI Applications

This repository contains four separate programs written in Haskell:

- **2Dgame** – A 2D side-scrolling platformer with coins and camera scrolling
- **Crud_cli** – CRUD operations on an in-memory list
- **Hangman** – Terminal word guessing game
- **Num_guessing_game** – Number guessing game

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
└── Num_guessing_game/
    └── Main.hs
```

---

## Requirements

- **GHC** (Glasgow Haskell Compiler) — https://www.haskell.org/ghc/
- **Cabal** (for the 2Dgame project) — https://www.haskell.org/cabal/
- **Gloss** (graphics library, installed automatically via Cabal for 2Dgame)

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

## Notes

- All CLI programs (`Crud_cli`, `Hangman`, `Num_guessing_game`) run in the terminal and require only GHC
- `2Dgame` opens a graphical window and requires Cabal + the Gloss library
- No data persistence across sessions (in-memory only)
- Some inputs are not fully validated and may cause runtime errors