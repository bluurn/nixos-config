# NixOS T480 Field Notes

These notes summarize the main concepts, decisions, debugging patterns, and operational commands from the ThinkPad T480 NixOS setup.

The goal is not to document every option, but to preserve the important engineering lessons behind the current configuration.

## 1. Project Goal

The machine is a Lenovo ThinkPad T480 running NixOS.

The long-term goal is to turn it into a reproducible, well-understood personal workstation:

```text
ThinkPad T480
  ├─ NixOS desktop laptop
  ├─ development workstation
  ├─ reproducible flake-based system
  ├─ Home Manager user environment
  ├─ PRIME offload gaming setup
  ├─ power-managed ThinkPad
  ├─ qBittorrent + Mullvad torrent box
  └─ SMB media share for LAN playback
```

The main philosophy:

```text
Do not configure the laptop by hand.
Describe the system declaratively in Git.
```

## 2. Repository as Source of Truth

The NixOS configuration lives in Git and should be treated as the source of truth.

Typical workflow:

```bash
cd /etc/nixos

git status
just fmt
just check
just test
just switch
```

Direct equivalents:

```bash
nix fmt
nix flake check
sudo nixos-rebuild test --flake .#t480
sudo nixos-rebuild switch --flake .#t480
```

Rule of thumb:

```text
Small change → format → check → switch/test → smoke test → commit.
```

Avoid large unrelated changes in one commit.

## 3. Configuration Structure

The configuration is split by responsibility.

System-level modules describe the operating system, hardware, services, networking, VPN, gaming, power management, and media sharing.

Home Manager modules describe the user environment: shell, editor, GNOME settings, CLI tools, MIME defaults, and user services.

Conceptual layout:

```text
hosts/t480/configuration.nix
  imports system modules for this specific machine

modules/
  system.nix
  users.nix
  fonts.nix
  packages.nix
  desktop.nix
  gaming.nix
  suspend.nix
  power.nix
  vpn.nix
  torrent.nix
  media-share.nix
  torrent-web.nix

home/vova.nix
  imports Home Manager modules

home/
  gnome.nix
  neovim.nix
  shell.nix
  devtools.nix
  packages.nix
  services.nix
  mime.nix
```

Key takeaway:

```text
System modules are for OS/runtime/service concerns.
Home modules are for the user environment.
```

## 4. Home Manager

Home Manager manages the user environment for `vova`.

Important areas:

```text
zsh
aliases
fzf
zoxide
Git identity
Neovim / LazyVim
GNOME settings
MIME/default browser
user packages
```

In this setup, Home Manager is integrated into NixOS, so the usual system switch is enough:

```bash
sudo nixos-rebuild switch --flake .#t480
```

Key takeaway:

```text
Not everything belongs in system packages.
User tooling usually belongs in Home Manager.
```

## 5. Shell and CLI Ergonomics

The CLI setup focuses on practical tools:

```text
zsh
starship
fzf
zoxide
ripgrep
fd
jq
bat
eza
wl-clipboard
direnv
```

Useful checks:

```bash
echo "$SHELL"
which zsh
which rg
which fd
which jq
which bat
which eza
```

Main lesson:

```text
A good shell setup is not about decoration.
It should reduce friction for daily development and debugging.
```

## 6. Neovim / LazyVim

Neovim is configured declaratively through Home Manager.

Important lesson for NixOS:

```text
Prefer installing LSP servers, formatters, and external tools through Nix.
Do not rely too much on Mason downloading random binaries at runtime.
```

LazyVim itself can still manage editor plugins, but runtime tooling should ideally come from Nix packages.

We considered adding Mermaid support for architecture diagrams, but decided not to block documentation work on editor tooling.

Key takeaway:

```text
Documentation should not depend on perfect tooling.
Start with plain Markdown.
Improve Mermaid/preview support later.
```

## 7. Development Environments and Flake Templates

The repo contains project templates for reproducible development environments.

Conceptually:

```text
templates/go
templates/python
templates/node
```

Useful commands:

```bash
nix flake init -t /etc/nixos#go
nix develop
direnv allow
```

Key takeaway:

```text
Flake templates are a way to reuse your personal dev environment standard across projects.
```

## 8. ThinkPad T480 Hardware Notes

Important hardware characteristics:

```text
Intel UHD 620
NVIDIA GeForce MX150
dual batteries
ThinkPad power quirks
suspend/display quirks
```

General approach:

```text
First make it stable.
Then make it ergonomic.
Then optimize power/performance.
```

Avoid endless tuning unless there is a real problem.

## 9. NVIDIA PRIME Offload

The chosen model:

```text
Desktop runs on Intel by default.
Heavy apps can be launched through NVIDIA offload.
```

Useful checks:

```bash
nvidia-smi
nvidia-offload glxinfo -B
```

Steam launch options:

```text
Default / Intel:
mangohud gamemoderun %command%

NVIDIA offload:
nvidia-offload mangohud gamemoderun %command%
```

Key takeaway:

```text
PRIME offload is better for this laptop than keeping the NVIDIA GPU active all the time.
```

## 10. Unfree Packages

NVIDIA and Steam require unfree packages.

Important examples:

```text
nvidia-x11
steam
```

Key takeaway:

```text
On NixOS, unfree software must be allowed explicitly.
```

This is a system-level decision, not just a package install detail.

## 11. Suspend and Display Fixes

The laptop had suspend/display problems.

The important workaround was disabling some Intel i915 power-saving features:

```nix
boot.kernelParams = [
  "i915.enable_psr=0"
  "i915.enable_dc=0"
];
```

Useful checks:

```bash
cat /proc/cmdline | grep -o "i915.enable_[a-z]*=[0-9]" || true
cat /sys/power/mem_sleep
```

Key takeaway:

```text
Older Intel laptop graphics can have suspend/display issues caused by aggressive power-saving features.
```

## 12. Power Management / TLP

Power management uses TLP.

Important ideas:

```text
Use TLP for ThinkPad power management.
Disable conflicting power-profiles-daemon.
Use battery charge thresholds.
Do not over-tune endlessly.
```

Useful commands:

```bash
just power
just battery
just cpu
just power-full
```

Direct commands:

```bash
systemctl status tlp --no-pager
tlp-stat -s
sudo tlp-stat -b
```

Key takeaway:

```text
Power tuning is a rabbit hole.
A stable good-enough setup is better than endless micro-optimization.
```

## 13. Boot Generations and Garbage Collection

Problem:

```text
Too many old NixOS generations in the boot menu.
```

Useful commands:

```bash
just generations
just gc
```

Direct commands:

```bash
sudo nix-env --profile /nix/var/nix/profiles/system --list-generations
sudo nix-collect-garbage --delete-older-than 14d
```

Key takeaway:

```text
Do not aggressively delete all old generations if rollback matters.
```

## 14. Bluetooth Debugging

Bluetooth issues can look like GNOME, GDM, or display problems.

Useful logs:

```bash
journalctl -b -p warning..alert --no-pager
journalctl -b | grep -iE 'bluetooth|gdm|gnome|hci|sco'
```

Key takeaway:

```text
Bluetooth/audio stack problems can surface as desktop-session instability.
Always inspect the journal before guessing.
```

## 15. Secrets with pass / GPG

Secrets are stored with `pass`. The Home Manager package set also includes the `pass-otp`
extension so TOTP secrets can live in the same encrypted password store instead of a separate
mutable authenticator installation.

Important entries:

```text
Personal/Mullvad
Services/qbittorrent/webui
```

Useful commands:

```bash
pass show Personal/Mullvad
pass show Services/qbittorrent/webui
pass otp insert Services/example/totp
pass otp Services/example/totp
```

`pass otp insert` accepts an `otpauth://` URI. Existing entries and secrets remain unchanged when
the extension is added; run the normal flake activation workflow before using the new subcommand.

GPG lesson:

```text
If pass reports an unusable public key, check the trust level of your own GPG key.
```

## 16. Mullvad VPN

Mullvad provides the VPN tunnel.

Main runtime pieces:

```text
mullvad-daemon
mullvad-apply-settings service
wg0-mullvad interface
LAN access allowed
```

Useful commands:

```bash
mullvad status
mullvad connect
mullvad relay get
mullvad lan get
systemctl status mullvad-daemon --no-pager
```

Key takeaway:

```text
“VPN connected” is not enough.
You still need to verify routing, interface binding, exit IP, and application behavior.
```

## 17. qBittorrent Architecture

The main qBittorrent engine runs as a system service.

Important decision:

```text
qBittorrent service runs as dedicated system user: qbittorrent
```

Why:

```text
It does not depend on the desktop session.
Its network access can be restricted by UID.
Its Web UI can stay localhost-only.
Its files live under /srv/torrents.
```

Important paths:

```text
/srv/torrents/incomplete
/srv/torrents/downloads
/srv/torrents/watch
```

Useful checks:

```bash
systemctl status qbittorrent --no-pager
sudo ss -H -tunap | grep -i qbittorrent || true
```

Key takeaway:

```text
The desktop user vova and the torrent engine are separate concerns.
```

## 18. qBittorrent Web UI

The Web UI should not listen directly on the LAN.

Correct model:

```text
qBittorrent Web UI listens on 127.0.0.1:8080.
Caddy exposes it to LAN via http://t480.local.
```

Flow:

```text
LAN browser → http://t480.local → Caddy → 127.0.0.1:8080 → qBittorrent Web UI
```

Useful checks:

```bash
curl -I http://127.0.0.1:8080
curl -I http://t480.local
ss -ltnup | grep -E ':80|:8080' || true
```

Good:

```text
127.0.0.1:8080    qbittorrent
*:80              caddy
```

Bad:

```text
0.0.0.0:8080      qbittorrent
```

Key takeaway:

```text
Expose the reverse proxy to LAN, not the application directly.
```

## 19. mDNS / t480.local

Instead of depending on router DNS or a static IP, the setup uses mDNS:

```text
http://t480.local
```

Key takeaway:

```text
mDNS reduces dependence on a specific home router configuration.
```

Limitation:

```text
Some Android/browser combinations can behave inconsistently with .local names.
```

## 20. nftables qBittorrent Kill Switch

The security goal:

```text
qBittorrent may only use:
  lo
  wg0-mullvad

qBittorrent must not use:
  wlp3s0
  normal LAN/Wi-Fi internet path
  any non-VPN interface
```

The working rule shape:

```nft
meta skuid 991 oifname != { "lo", "wg0-mullvad" } counter reject with icmpx type admin-prohibited
```

Important lesson:

```text
Do not “accept” good qBittorrent traffic in your own nftables base chain.
Only reject bad traffic.
```

Reason:

```text
Mullvad also manages nftables chains.
An accept verdict in one base chain does not necessarily mean the packet is safe through the whole firewall pipeline.
```

Useful checks:

```bash
sudo nft list table inet qbit_killswitch
sudo nft list ruleset | grep -nE 'qbit_killswitch|mullvad|skuid|output|reject|drop' -A8 -B4
```

Key takeaway:

```text
Firewall rules must be validated with real traffic, not just by reading them.
```

## 21. Torrent Networking Debugging

The most useful debugging stack:

```text
1. DNS
2. Route
3. Socket binding
4. Firewall / nftables
5. Tracker response
6. Peers / seeds
7. qBittorrent settings
8. Filesystem permissions
```

DNS check:

```bash
getent hosts tracker.opentrackr.org
sudo -u qbittorrent getent hosts tracker.opentrackr.org
```

Route check:

```bash
ip route get 1.1.1.1
ip route get 130.239.18.158 uid "$(id -u qbittorrent)"
```

Socket check:

```bash
sudo ss -H -tunap | grep -i qbittorrent || true
```

Mullvad exit check as qBittorrent:

```bash
sudo -u qbittorrent curl -4s \
  --interface wg0-mullvad \
  --max-time 10 \
  https://am.i.mullvad.net/json | jq
```

Tracker connectivity check:

```bash
sudo -u qbittorrent curl -4sv \
  --interface wg0-mullvad \
  --max-time 10 \
  http://bttracker.debian.org:6969/announce \
  2>&1 | head -n 80
```

A response like this can be acceptable for a raw tracker request without torrent parameters:

```text
Established connection ... from 10.137.x.x
Empty reply from server
```

Key takeaway:

```text
If a known-good Debian torrent cannot download, the problem is probably local networking/firewall/configuration, not the torrent itself.
```

## 22. qBittorrent States

Useful interpretations:

```text
downloading metadata
```

Can mean:

```text
magnet metadata was not found yet
no useful peers
DHT/PeX disabled
tracker unavailable
dead torrent
```

```text
stalledDL seeds=0 peers=0
```

Can mean:

```text
no reachable peers
tracker did not provide peers
DHT/PeX cannot help or are disabled
network/firewall problem
```

But if a known-good torrent also stalls, suspect the local setup.

Working result looked like:

```text
downloading seeds=39 peers=2 dlspeed=...
```

## 23. DHT / PeX / LSD

Concepts:

```text
DHT  → distributed peer discovery
PeX  → peer exchange
LSD  → local service discovery in LAN
```

Strict current model:

```text
DHT = false
PeX = false
LSD = false
```

Possible future compromise:

```text
DHT = true
PeX = true
LSD = false
```

Key takeaway:

```text
DHT/PeX can help magnet links, but they are a separate privacy and behavior decision.
LSD is not needed for this setup.
```

## 24. qBittorrent API Pattern

Login pattern:

```bash
cookie="$(mktemp)"
base="http://127.0.0.1:8080"
password="$(pass show Services/qbittorrent/webui | head -n1)"

curl -fsS \
  -c "$cookie" \
  -b "$cookie" \
  --data-urlencode "username=admin" \
  --data-urlencode "password=$password" \
  "$base/api/v2/auth/login" >/dev/null

# API calls here

rm -f "$cookie"
```

List torrents:

```bash
curl -fsS \
  -b "$cookie" \
  "$base/api/v2/torrents/info" \
  | jq -r '.[] | "\(.hash)  \(.state)  seeds=\(.num_seeds) peers=\(.num_leechs)  \(.name)"'
```

Trackers for one torrent:

```bash
hash="..."

curl -fsS \
  -b "$cookie" \
  --get \
  --data-urlencode "hash=$hash" \
  "$base/api/v2/torrents/trackers" \
  | jq -r '.[] | [
      .status,
      .num_peers,
      .url,
      .msg
    ] | @tsv'
```

Force reannounce:

```bash
curl -fsS \
  -b "$cookie" \
  --data-urlencode "hashes=$hash" \
  "$base/api/v2/torrents/reannounce"
```

## 25. Torrent Filesystem Permissions

Important lesson:

```text
Filesystem permissions are part of the architecture.
```

Correct model:

```text
owner: qbittorrent
group: qbittorrent
directories: 2775
files: 664
vova is a member of group qbittorrent
```

Fix permissions:

```bash
sudo chown -R qbittorrent:qbittorrent /srv/torrents
sudo find /srv/torrents -type d -exec chmod 2775 {} +
sudo find /srv/torrents -type f -exec chmod 664 {} +
```

Check:

```bash
ls -ld /srv/torrents /srv/torrents/downloads /srv/torrents/incomplete
id vova | grep qbittorrent
```

Expected:

```text
drwxrwsr-x qbittorrent qbittorrent /srv/torrents
drwxrwsr-x qbittorrent qbittorrent /srv/torrents/downloads
drwxrwsr-x qbittorrent qbittorrent /srv/torrents/incomplete
```

Write test:

```bash
sudo -u qbittorrent touch /srv/torrents/downloads/.qbit-test && sudo rm /srv/torrents/downloads/.qbit-test
touch /srv/torrents/downloads/.vova-test && rm /srv/torrents/downloads/.vova-test
```

Key takeaway:

```text
If qBittorrent downloads into incomplete but cannot move to downloads, check ownership and permissions first.
```

## 26. SMB Media Share

The media access goal is simple:

```text
Download torrent on T480.
Open completed file from MiBox/VLC.
Watch video.
```

Chosen solution:

```text
SMB read-only share for /srv/torrents/downloads
```

Flow:

```text
MiBox / VLC → SMB → /srv/torrents/downloads
```

Why SMB is enough:

```text
VLC supports it.
MiBox supports it.
It behaves like a simple network folder.
No metadata system.
No transcoding.
No media-server complexity.
```

Key takeaway:

```text
For the current use case, SMB is simpler and better than Jellyfin/DLNA.
```

## 27. Media Sharing Alternatives

Options discussed:

```text
SMB      → network folder
HTTP     → read-only file listing/download
NFS      → Unix/Linux network filesystem
DLNA     → simple media discovery
Jellyfin → full media library / self-hosted Netflix-like system
```

Current decision:

```text
Keep SMB.
Do not add HTTP.
Do not add NFS.
Do not add Jellyfin/DLNA yet.
```

Key takeaway:

```text
Do not add services without a real need.
```

## 28. Tor, I2P, and VPN

Conceptual comparison:

```text
VPN  → practical for normal torrents
Tor  → private browsing and onion sites, not torrents
I2P  → separate anonymous overlay network, can support I2P-only torrents
```

Current decision:

```text
Use Mullvad + qBittorrent for normal torrents.
Use Tor Browser separately for private browsing if needed.
Treat I2P as a separate future experiment.
```

Key takeaway:

```text
Do not mix Tor/I2P into the working qBittorrent/Mullvad setup without a specific reason.
```

## 29. Documentation Direction

We discussed using:

```text
C4-style diagrams
ADR records
field notes
operations docs
```

The practical documentation split:

```text
docs/
  field-notes.md      → concepts, lessons, debugging notes
  operations.md       → commands and smoke tests
  architecture.md     → diagrams later
  adr/                → decision records later
```

Key takeaway:

```text
C4 explains structure.
ADR explains decisions.
Field notes preserve lessons and debugging knowledge.
```

## 30. ADR Ideas

Possible future ADRs:

```text
0001-use-nixos-flake.md
0002-split-system-and-home-config.md
0003-use-prime-offload-for-nvidia.md
0004-use-tlp-for-thinkpad-power.md
0005-run-qbittorrent-as-system-service.md
0006-route-qbittorrent-through-mullvad.md
0007-use-smb-for-lan-media-access.md
0008-expose-web-ui-through-caddy-and-mdns.md
```

ADR structure:

```markdown
# 0001 Title

## Status

Accepted

## Context

What problem existed?

## Decision

What did we decide?

## Consequences

Positive and negative outcomes.
```

## 31. General Debugging Principles

The most reusable lessons:

```text
1. Declarative config does not replace runtime debugging.
2. Git shows desired state; systemctl, ss, journalctl, and nft show actual state.
3. Every service should be understood through:
   - user
   - process
   - ports
   - filesystem
   - network interfaces
   - firewall rules
   - secrets
4. Avoid changing many layers at once.
5. Known-good test cases are extremely useful.
6. Permissions are part of system design.
7. Security rules must be tested with real traffic.
8. Do not add services just because they are interesting.
9. Stop tuning when the system is stable enough.
10. Document the “why”, not only the “what”.
11. Put user-facing setup, activation, migration, validation, and next steps in README.md when a
    crucial change introduces them.
```

## 32. Universal Debug Checklist

For almost any issue:

```bash
cd /etc/nixos

git status
just check
systemctl --failed
journalctl -b -p warning..alert --no-pager
```

For a specific service:

```bash
systemctl status <service> --no-pager
journalctl -u <service> -b --no-pager
```

For ports and sockets:

```bash
ss -ltnup
sudo ss -H -tunap | grep -i <process>
```

For firewall:

```bash
sudo nft list ruleset
```

For routes:

```bash
ip addr
ip route
ip route get 1.1.1.1
```

For permissions:

```bash
namei -l /path/to/file
ls -ld /path /path/to/dir
id vova
```

## 33. Post-Reboot Smoke Test

Minimal check after reboot:

```bash
cd /etc/nixos

systemctl --failed

mullvad status
just torrent-check

sudo ss -H -tunap | grep -i qbittorrent || true
sudo nft list table inet qbit_killswitch

curl -I http://127.0.0.1:8080
curl -I http://t480.local

ls -ld /srv/torrents /srv/torrents/downloads /srv/torrents/incomplete
id vova | grep qbittorrent
```

Expected result:

```text
No important failed services.
Mullvad is connected.
torrent-check passes.
qBittorrent Web UI listens only on 127.0.0.1:8080.
Torrent traffic uses wg0-mullvad.
No qBittorrent traffic goes through wlp3s0.
Downloads directories are owned by qbittorrent:qbittorrent.
vova is in the qbittorrent group.
```

## 34. Current Stability Principle

Current preferred strategy:

```text
Do not add Mermaid tooling yet.
Do not add Jellyfin/DLNA yet.
Do not add I2P/Tor integration yet.
Do not over-tune power management.
Do not complicate the working torrent/media setup.
```

Current stable core:

```text
NixOS flake repo
Home Manager
GNOME desktop
Neovim/LazyVim
TLP
NVIDIA offload
Mullvad VPN
qBittorrent system service
nftables kill switch
Caddy Web UI proxy
SMB media share
```

Final takeaway:

```text
The system is useful because it is understandable.
Keep it small, documented, and testable.
```

## 35. ApplyPilot Integration

### Context

ApplyPilot is an AGPL-licensed Python application that discovers jobs, scores matches, generates
application material, and can drive Chromium to submit applications.

Upstream installation is not a normal single-package Python install:

```text
ApplyPilot requires Python 3.11 or newer.
Auto-apply requires Node.js, Chromium, and Claude Code.
python-jobspy is installed separately with --no-deps because of its NumPy metadata constraint.
The Playwright MCP server may be fetched by npx at runtime.
```

Installing those Python packages globally would introduce mutable state into the declarative user
environment. Installing them during Home Manager activation would make system rebuilds depend on
PyPI availability and could leave a partially updated environment.

### Decision

The maintained `bluurn/ApplyPilot` fork exports a complete Nix package. The NixOS flake pins that
repository as an input, and `home/applypilot.nix` installs its default package alongside Claude
Code:

```text
ApplyPilot flake package
  builds the maintained fork rather than upstream PyPI 0.3.0
  includes the Python application and python-jobspy
  adds Nix-managed Node.js and Chromium to the launcher PATH
  points Playwright browser variables at Nix-managed paths

Home Manager
  exposes applypilot directly on the user PATH
  installs Claude Code for the optional auto-apply workflow
```

Mutable application files are separated by purpose:

```text
~/.applypilot
  profile, searches, database, generated application material, and .env secrets
```

No post-switch installer is required:

```bash
applypilot --version
applypilot today
applypilot doctor
```

System rebuilds replace only the immutable package. They do not remove the user profile or
generated application data in `~/.applypilot`.

### Consequences

Positive outcomes:

```text
Python packages do not pollute a mutable global or private environment.
Nix owns both Python and native runtime dependencies.
The maintained fork revision is pinned in `flake.lock`.
System rebuilds remain independent from PyPI and do not require an install step.
Application data and secrets stay outside the repository.
The python-jobspy dependency is provided by nixpkgs.
```

Tradeoffs:

```text
The package closure is larger because it includes Chromium and data-science dependencies.
npx may access the network when the auto-apply Playwright MCP server starts.
Updating ApplyPilot requires updating the flake input and validating the workflow again.
```

### Safety Workflow

ApplyPilot can submit forms to third parties, so automatic submission should not be the first
test:

```bash
applypilot doctor
applypilot run --dry-run
applypilot apply --dry-run
```

Review the profile, screening-answer defaults, generated resume, and generated cover letter before
running `applypilot apply` without `--dry-run`. CAPTCHA-solving services are intentionally not
configured declaratively; adding one would require a separate privacy and credential-handling
decision.
