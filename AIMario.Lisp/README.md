# CYBER MARIO // SECTOR 1-1 - Common Lisp Port

## Prerequisites

### 1. Install SBCL

Download and install Steel Bank Common Lisp from https://www.sbcl.org/platform-table.html

### 2. Install Quicklisp

From the SBCL REPL:

```lisp
(load "quicklisp.lisp")
(quicklisp-quickstart:install)
(ql:add-to-init-file)
```

The `quicklisp.lisp` bootstrap file is included in this directory. The last command makes Quicklisp load automatically in future SBCL sessions.

### 3. Install SDL2

- **Windows**: Download SDL2 runtime DLL from https://github.com/libsdl-org/SDL/releases and place `SDL2.dll` on your PATH
- **macOS**: `brew install sdl2`
- **Linux**: `sudo apt install libsdl2-dev` (or equivalent for your distro)

## Running

Start SBCL from the `AIMario.Lisp/` directory, then:

```lisp
;; First time only - install Lisp dependencies:
(ql:quickload '(:sdl2 :alexandria :static-vectors))

;; Register project and load:
(push (truename ".") asdf:*central-registry*)
(asdf:load-system :aimario :force t)

;; Run the game:
(aimario:run-game)
```

On subsequent runs you can skip the `ql:quickload` step — the dependencies stay installed.

## Controls

- **Arrow keys** - Move / Duck
- **Z / Space** - Jump
- **X / Shift** - Run / Throw fireball
- **Enter** - Start
- **Escape** - Quit
