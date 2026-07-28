# NixOS T480

Declarative NixOS and Home Manager configuration for a Lenovo ThinkPad T480.

This repository is the source of truth for the machine: system services, desktop preferences,
development tools, power management, NVIDIA PRIME offload, VPN, torrenting, and local media
sharing are all managed through Nix.

## Highlights

- NixOS flakes with a pinned `nixos-25.11` release
- Home Manager integrated into the system configuration
- GNOME desktop with declarative user preferences
- Intel-first graphics with NVIDIA PRIME offload
- ThinkPad-oriented power and suspend configuration
- Mullvad-bound qBittorrent service with safety checks
- Local SMB media sharing and a Caddy-powered web interface
- Isolated ApplyPilot job-search automation environment
- Reproducible Go, Python, and Node.js project templates
- Formatting, static analysis, Git hooks, and CI checks

## Repository Layout

```text
.
├── flake.nix            # Inputs, checks, templates, and host configuration
├── hosts/t480/          # Host-specific and hardware configuration
├── modules/             # System-level NixOS modules
├── home/                # Home Manager modules for the vova user
├── templates/           # Reusable development project flakes
├── docs/                # Operational notes and design decisions
├── treefmt.nix          # Repository formatting and static analysis
└── justfile             # Common maintenance and diagnostic commands
```

System and hardware concerns belong in `modules/`. User applications, shell configuration,
editor settings, and desktop preferences belong in `home/`.

## Common Workflow

List all available commands:

```shell
just
```

Format and validate the configuration:

```shell
just fmt
just check
```

Test a new system generation without making it the boot default:

```shell
just test
```

Activate a validated generation:

```shell
just switch
```

The direct NixOS equivalent is:

```shell
sudo nixos-rebuild switch --flake .#t480
```

## Project Templates

Create a reproducible development project from one of the bundled templates:

```shell
nix flake init -t /etc/nixos#go
nix flake init -t /etc/nixos#python
nix flake init -t /etc/nixos#node
```

Then enter its environment with `nix develop`, or run `direnv allow` when using the included
`.envrc`.

## Useful Diagnostics

The `justfile` includes commands for inspecting the laptop and its services:

```shell
just power-full
just nvidia
just vpn
just torrent-check
just browser-check
just applypilot-doctor
```

Run `just --list` for the complete command set.

## ApplyPilot

ApplyPilot runs from a private, versioned Python environment rather than the global system
environment. After activating the NixOS configuration, install the pinned Python application:

```shell
just applypilot-install
applypilot init
applypilot doctor
```

Its profile, searches, generated documents, and API configuration live in `~/.applypilot`.
ApplyPilot supports Gemini, OpenAI, and local OpenAI-compatible models. Keep API keys in
`~/.applypilot/.env`, which is outside this repository.

Before allowing automatic submission, inspect the generated material and exercise the browser
workflow without submitting:

```shell
just applypilot-dry-run
```

## Maintenance

Update flake inputs and verify the resulting system:

```shell
just update
```

This updates `flake.lock`, runs the flake checks, and creates a temporary test generation. Review
the lockfile and test results before switching.

Old generations can be inspected or collected with:

```shell
just generations
just gc
```

## Notes

- Do not change `system.stateVersion` or `home.stateVersion` during routine upgrades.
- Keep secrets outside Git. Runtime credentials are stored with `pass` or ignored `.env` files.
- Treat `hosts/t480/hardware-configuration.nix` as generated hardware state.
- See [`docs/nixos-t480-field-notes.md`](docs/nixos-t480-field-notes.md) for the reasoning behind
  the current architecture and operational setup.
