# ratatui-ptk

A prompt_toolkit-style input line for ratatui: multi-line editing, history, completion and highlighting.
It renders into a ratatui `Buffer` and leaves the terminal and the event loop to the caller.
It knows nothing about any input language; anything language-specific plugs in through the `Completer` and `Lexer` traits.

## Architecture

Laid out like prompt_toolkit: state and behavior in one place, widgets that only draw it.

- **PromptState** (`src/state.rs`): the model, like prompt_toolkit's `Buffer`. Holds the `TextBuffer` (`src/buffer.rs`: multi-line text, cursor, undo/redo), history, completion and search state, and the kill ring, and handles keys. `handle_key` returns `Outcome::{Handled, Submit, Ignored}`; `Ignored` keys (Ctrl-C, Ctrl-D on empty input, ...) are the caller's to act on.
- **Prompt** (`src/prompt.rs`): `StatefulWidget` that draws the prompt string, the highlighted text and the history auto-suggestion, or the Ctrl-R search line while searching. `cursor_position` tells the caller where the terminal cursor goes.
- **CompletionMenu** (`src/menu.rs`): `StatefulWidget` for the popup list, like prompt_toolkit's `CompletionsMenu` in a `Float`. `area` places it at the word being completed, above the cursor when it fits; the caller renders it last, over other widgets.
- **Completion** (`src/completion.rs`): the `Completer` trait. Selecting a candidate previews it in the text; Esc restores what was typed, any other key keeps the candidate, and one menu session is one undo step. While typing, the menu follows with nothing selected, so Enter still submits; Tab selects. `complete_in_thread` runs the completer on a thread per request, like prompt_toolkit's `ThreadedCompleter`: a wake callback tells the caller to `poll_completions`, and answers to input that has changed since are dropped.
- **Key bindings** (`src/keys.rs`): maps keys to built-in `Command`s. Only an Emacs set ships; the map exists so a Vi set can be added later. Callers can bind more keys through `bindings_mut`, but not to their own handlers.
- **Highlighting** (`src/lexer.rs`): the `Lexer` trait tags byte ranges with token classes (`"keyword"`, ...); `Prompt::syntax` maps classes to styles.
- **History** (`src/history.rs`): in-memory or file-backed, one escaped entry per line. Backs Up/Down navigation, Ctrl-R reverse incremental search and the auto-suggestion.
- **Accept handler**: a hook that decides whether Enter submits or inserts a newline.
- **Styles**: widgets take every style through builder methods. The defaults are plain ANSI colors; there is no theme in the library.

Simplifications with a known limit are marked `shortcut:` in the code.

## Nix

Based on numtide/blueprint's `treefmt-and-git-hooks` template (`prefix = "nix"`).

- `nix/crane.nix`: crane setup shared by the checks (mold on Linux, one dependency build).
- `nix/devshell.nix`: Rust toolchain, rust-analyzer, mold, sccache. Sets `RUSTC_WRAPPER=sccache` and the mold linker. sccache is devshell-only; it cannot help inside the Nix sandbox.
- `nix/treefmt.nix`: nixfmt, rustfmt.
- `nix/checks/`: clippy (`-D warnings`), tests, and pre-commit (nil, statix, treefmt) via git-hooks.nix.

There is no package output; this is a library.

## Commands

```
nix develop                 # or direnv
cargo build
cargo test
cargo clippy --all-targets -- -D warnings
nix fmt
nix flake check
```

## Testing

Plain unit tests in `src/tests.rs`. They drive `PromptState` with key events and check the text, the `Outcome`, or the screen rendered into a `Buffer`.
