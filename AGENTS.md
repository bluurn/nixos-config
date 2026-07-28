# Repository Guide

## Purpose

This repository is the declarative source of truth for the `t480` NixOS workstation.
Keep changes focused, reproducible, and easy to review.

## Structure

- `flake.nix` wires inputs, formatting, checks, templates, and the `t480` configuration.
- `hosts/t480/` contains host-specific configuration and generated hardware configuration.
- `modules/` contains system-level NixOS modules.
- `home/` contains Home Manager modules for the `vova` user.
- `templates/` contains reusable project flakes.
- `docs/` contains operational knowledge and design decisions.

Put operating-system, hardware, networking, and system-service changes in `modules/`.
Put shell, editor, desktop preference, user service, and user package changes in `home/`.
Only put host-specific composition in `hosts/t480/`.

## Working Rules

- Preserve unrelated user changes in the worktree.
- Prefer small, responsibility-based modules over growing unrelated files.
- Follow the existing Nix style and let `nix fmt` perform formatting.
- Do not edit `hosts/t480/hardware-configuration.nix` unless the task is explicitly
  hardware-related.
- Do not change `system.stateVersion` or `home.stateVersion` during routine upgrades.
- Do not commit secrets, tokens, account numbers, generated credentials, or personal resume
  data. Use `pass` or ignored `.env` files for runtime secrets.
- Do not run `nixos-rebuild switch`, update the lock file, commit, or push unless explicitly
  requested.
- Document project decisions, alternatives, reasoning, and operational consequences in
  `docs/nixos-t480-field-notes.md`.
- Update `README.md` whenever a crucial change affects user-facing features, setup, activation,
  migration, validation, or next steps. Do not leave required handoff commands only in the final
  response.
- Summarize each material change and its operational effect when handing work back.

## Validation

Use the narrowest relevant validation first, then broaden when appropriate:

```shell
nix fmt
nix flake check
sudo nixos-rebuild test --flake .#t480
sudo nixos-rebuild switch --flake .#t480
```

The equivalent repository commands are:

```shell
just fmt
just check
just test
just switch
```

Formatting and flake checks are safe defaults. `test` and `switch` require sudo and should only
run when the user is ready to apply or activate system-level changes.

## Service Changes

For services, keep configuration declarative and include a practical smoke-test command in the
relevant `justfile` recipe when ongoing diagnostics would be useful. Avoid exposing services on
all interfaces by default; scope firewall openings and listeners to the intended interface.

For software with difficult or fast-moving dependencies, prefer an isolated flake/dev shell or a
rootless container over mutable global installation. Only promote software into Home Manager or
the system configuration when it is intended to be permanently available.
