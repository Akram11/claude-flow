# Mac remote dev stack & hardening

Akram's setup for working from his phone when away from the MacBook, plus the security posture locked in 2026-05-26.

Machine-specific values (hostnames, IPs, users, key labels) are placeholders here. The real ones live outside this repo.

## Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Network | Tailscale | Private VPN mesh. Mac at `<mac-host>.<tailnet>.ts.net`. Phone is `<phone-host>`. |
| Terminal access | macOS sshd | SSH from Termius (Android). Phone key labeled `<phone-key-label>` in `~/.ssh/authorized_keys`. |
| Session persistence | tmux 3.6a (`brew install tmux`) | Sessions survive SSH drops, lid close. |
| GUI access | code-server 4.112.0 (brew, autostart via brew services) | VS Code in browser at `https://<mac-host>.<tailnet>.ts.net`. |
| HTTPS wrapper | `tailscale serve --bg --https=443 http://localhost:8080` | Wraps code-server with TLS. **Tailnet-only**, not public funnel. |

## Files

- `~/.tmux.conf` — mouse on, 256-color, status bar
- `~/.config/code-server/config.yaml` — binds 127.0.0.1:8080, password auth (password in password manager)
- `~/.ssh/authorized_keys` — contains the phone ED25519 public key
- `~/.zshrc` (bottom block) — aliases below
- `/etc/ssh/sshd_config.d/200-key-only.conf` — SSH hardening drop-in (see below)

## Aliases / functions in ~/.zshrc

```zsh
alias work='tmux attach -t work 2>/dev/null || tmux new -s work'
alias tml='tmux ls'
stay() {
  if [[ -n "$1" ]]; then
    caffeinate -dims -t $(($1 * 3600))
  else
    caffeinate -dims
  fi
}
tm() {
  local name="${1:-work}"
  tmux attach -t "$name" 2>/dev/null || tmux new -s "$name"
}
```

## tmux naming convention

- `tm` (defaults to `work`) — general
- `tm <name>` — one session per project

## Daily flow

1. On Mac: open Warp → `tm web` (or whichever) → `claude`
2. To leave: `Ctrl-b d` to detach, close Warp. Run `stay` first if closing the lid.
3. From phone: Tailscale ON → Termius → SSH host (`<mac-host>.<tailnet>.ts.net`, user `<mac-user>`) → `tm web` → same session.
4. Or: phone Chrome → `https://<mac-host>.<tailnet>.ts.net` → VS Code with integrated terminal → `tm web`.

## Security hardening (locked in 2026-05-26)

| Layer | State |
|-------|-------|
| SSH auth | **Key-only**. `/etc/ssh/sshd_config.d/200-key-only.conf` sets `PasswordAuthentication no`, `KbdInteractiveAuthentication no`, `PermitRootLogin no`. Macos account password gets nothing over SSH. |
| SSH key (`~/.ssh/id_ed25519_github`) | **Passphrase-protected**, passphrase stored in macOS Keychain (service `ssh-key:id_ed25519_github`). `~/.ssh/config` has `UseKeychain yes` + `AddKeysToAgent yes`. |
| App Firewall | Enabled. |
| Stealth mode | On. Mac doesn't reply to ICMP/probes — invisible to LAN scanners. |
| AirPlay Receiver | Off. Closed ports 5000 + 7000. Akram doesn't AirPlay *to* this Mac. |
| File Sharing (SMB) | Off. `smbd` not listening on :445. |
| Tailscale `serve` | tailnet-only, not public Funnel. |
| code-server / postgres / Raycast / helpers | All bound to 127.0.0.1 — not reachable via tailnet. |
| `~/.gitconfig`, `~/.zsh_history` | `chmod 600`. |

**Remaining beyond-localhost listener:** `rapportd *:50384` — Apple Continuity / Handoff / Universal Clipboard / AirDrop. Kept because Akram uses those.

## GitHub auth architecture (locked in 2026-05-26)

**Two-token design** — a narrow PAT in env for package registries, OAuth for everything else.

| Path | Token | Storage | Scope |
|------|-------|---------|-------|
| `git push`/`pull` | SSH key | `~/.ssh/id_ed25519_github` (passphrase in Keychain) | — |
| Package installs from GitHub Packages | Classic PAT, `read:packages` only, **no expiration** | macOS Keychain (`security find-generic-password -s github-pat`) | one scope only |
| `gh` CLI (PR/issue/repo ops) | OAuth token, `repo, workflow, read:org, read:packages, gist` | macOS Keychain via `gh` (managed by gh CLI) | broad |
| GitHub MCP server | — | — | **removed**; CLI is preferred |

### Why this design

- The narrow `read:packages` PAT exists for projects whose package-manager config reads `${GITHUB_TOKEN}` from env.
- The OAuth token (broader scopes) is auto-managed by `gh` — no manual rotation. SSO bounces are handled by a quick browser auth.
- The `repo`/`workflow`/etc. scopes are kept *out* of the env var so they're not exposed to subprocesses or accidentally leaked.

### Critical detail: how `gh` avoids the narrow env token

**`~/.zshrc`** sets the narrow PAT in env:

```zsh
export GITHUB_TOKEN="$(security find-generic-password -a "$USER" -s 'github-pat' -w 2>/dev/null)"
```

**`~/.local/bin/gh`** is a PATH-shadowed wrapper that strips `$GITHUB_TOKEN` from gh's environment, forcing it to use the OAuth token in macOS Keychain:

```bash
#!/usr/bin/env bash
GITHUB_TOKEN= exec /opt/homebrew/bin/gh "$@"
```

Because the wrapper is on disk (not a shell function), it works in **every** context — interactive zsh, bash subprocesses, Claude Code's Bash tool, CI scripts. No per-invocation `unset GITHUB_TOKEN; gh ...` workaround is needed.

`~/.local/bin` is ahead of `/opt/homebrew/bin` in PATH, so plain `gh` always resolves to the wrapper.

If you ever need the raw gh binary (e.g., to test something with the narrow token deliberately): `/opt/homebrew/bin/gh ...`.

### Rotating

- **Narrow PAT**: regenerate at https://github.com/settings/tokens/new (classic, `read:packages` only, no expiration), then:
  ```sh
  read -rs "?paste new PAT: " T; security add-generic-password -a "$USER" -s 'github-pat' -w "$T" -U; unset T
  ```
  Open a new shell to pick it up.
- **gh OAuth**: `GITHUB_TOKEN= gh auth refresh` (or `gh auth login --web` for a fresh one). Run if `gh auth status` complains.

To re-verify all of the above:
```sh
# Listening surface beyond localhost
lsof -nP -iTCP -sTCP:LISTEN | awk 'NR==1 || ($9 !~ /^127\./ && $9 !~ /^\[::1\]/)'

# Firewall + stealth
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode

# SSH effective auth config
sudo sshd -T | grep -iE 'passwordauth|kbdint|permitroot|permitempty|pubkey'

# Tailscale exposure
tailscale serve status
tailscale funnel status   # should show "tailnet only", NOT a funnel
```

## Tailscale socket leak — known upstream bug

**Upstream issue:** [tailscale/tailscale#19016](https://github.com/tailscale/tailscale/issues/19016) (open). Same root cause (`io.tailscale.ipn.macsys.network-extension` stuck in `terminated_waiting_to_uninstall_on_reboot`); their reporter hit a kernel panic, Akram hit TIME_WAIT exhaustion. Both are downstream effects of the same lifecycle bug.

### Install variant

Tailscale here is the **standalone (macsys)** variant, installed via Homebrew Cask (`brew install --cask tailscale-app`, bundle id `io.tailscale.ipn.macsys`). Updates flow via Sparkle (not the Mac App Store). Auto-install is already off (`defaults read io.tailscale.ipn.macsys SUAutomaticallyUpdate` → `0`), so updates only happen when Akram clicks "Install" on a Sparkle prompt — but **every upgrade can leave an orphan extension**.

### Prevention (the actual win)

**Reboot the Mac immediately after every Tailscale upgrade.**

When you click "Install and Relaunch" in Sparkle, the new system extension activates while the old one enters `terminated_waiting_to_uninstall_on_reboot`. The orphan only fully unloads on the next OS reboot. If you don't reboot, the orphan parks sockets for hours/days until ephemeral ports exhaust. Reboot right after upgrade and the orphan never gets a chance to leak. ~1 minute of downtime, prevents the bug entirely.

Do **not** disable Sparkle auto-checks (`SUEnableAutomaticChecks`) — you want the update prompts for security patches.

### Symptoms (if it slipped through)

- `gh` / `curl` / Claude API fail with `dial tcp <ip>:443: connect: can't assign requested address` (EADDRNOTAVAIL). DNS resolves fine, only TCP connect fails.
- `netstat -an | awk '$NF=="TIME_WAIT"' | wc -l` shows >15,000 and **doesn't decay** over 20s (macOS `net.inet.tcp.msl = 15000` says it should).
- Top TIME_WAIT remotes look like probe traffic: `1.1.1.1:443`, `8.8.8.8:443`, Cloudflare/Hetzner.
- macOS ephemeral range default is 49152–65535 (~16k ports). Once full, no outbound connection can bind a source port.

### Diagnosis (skip if you've seen this before — just reboot)

1. `netstat -an | awk '$NF=="TIME_WAIT"' | wc -l` → high
2. Sample 20s later → delta ≈ 0 (not decaying)
3. `systemextensionsctl list` → look for a Tailscale entry in `terminated waiting to uninstall on reboot`

### Fix when it has already happened

- **Real fix**: reboot. Confirm post-boot with `systemextensionsctl list` (should show only one Tailscale entry).
- **Tactical relief** (no reboot): `sudo sysctl -w net.inet.ip.portrange.first=10000` widens the ephemeral range to ~55k slots, reverts on reboot. Buys time only; does not flush the parked sockets.
- **Do NOT** install a LaunchDaemon to persist the sysctl tweak — that just gives the leak more room and adds permanent config debt.

### Origin

First observed 2026-05-22: a 21k-TIME_WAIT pile-up made Claude Code throw 500s mid-session and aborted a work session. Network to Anthropic's API was failing because the local socket layer couldn't allocate a source port. Diagnose this before blaming the model, the network provider, or Claude's servers.

## Wake-from-sleep network outage — open investigation

**Status (2026-05-28):** observed once, root cause not confirmed. Distinct from the socket leak above — different downstream signature.

### Symptom
On wake-from-sleep (NOT cold boot), no outbound network. `ping 1.1.1.1` 100% loss, DNS resolution fails. `netstat -rn` looks superficially fine (default route via the router on en0, RouterARPVerified TRUE), but no packets traverse.

### Quick fix that worked
Removed the Wi-Fi network from System Settings → Wi-Fi and re-joined it. Forces clean DHCP cycle + re-triggers NetworkExtension on-demand evaluation. Connectivity returned immediately.

### Distinguishing it from the socket leak
| | Socket leak | Wake-from-sleep outage |
|--|--|--|
| Outage scope | Specific apps (those opening new TCP) | Everything outbound |
| `ping 1.1.1.1` | Usually works (no source-port allocation needed for ICMP) | Fails 100% |
| `TIME_WAIT` count | >15,000, not decaying | Normal (<1k) |
| `systemextensionsctl list` | Has `terminated_waiting_to_uninstall_on_reboot` entry | One enabled+active entry |
| Fix | Reboot | Re-add Wi-Fi network (or possibly reboot) |

### State observed afterwards (healthy)
- `tailscale status` says **stopped**, but `scutil --nc list` says Tailscale VPN is **Connected**, and `systemextensionsctl list` shows the network extension `[activated enabled]` with its process running. State mismatch between userspace daemon and NetworkExtension framework is the loudest oddity.
- 6 utun interfaces (utun0–utun5). Four of them (utun0, utun1, utun3, utun4) hold IPv6 default routes via `fe80::%utunN`. MTU fingerprints:
  - utun1=1380 → Tailscale userspace tunnel (1500−WG overhead)
  - utun5=1280+CHANNEL_IO → Tailscale kernel-mode tunnel
  - utun0/2/3/4 → mix of NextDNS DoH and other Apple NE tunnels
- NextDNS DoH profile `NextDNS (<profile-id>)` installed at `/Library/Preferences/com.apple.networkextension` with `OnDemandRules`.

### Working hypothesis (unconfirmed)
On wake-from-sleep, a race between Wi-Fi association/DHCP completing and NetworkExtension restoring tunnels (NextDNS + Tailscale extension) leaves IPv6 default routes installed via utun before IPv4 has a working egress. Re-adding Wi-Fi forces a clean DHCP cycle AND re-evaluates NE on-demand rules — fixing both in one shot.

### Capture this next time (do it BEFORE re-adding Wi-Fi)
```sh
{
  echo "--- uptime ---"; uptime
  echo "--- tailscale CLI ---"; tailscale status 2>&1
  echo "--- scutil --nc ---"; scutil --nc list
  echo "--- systemextensionsctl ---"; systemextensionsctl list
  echo "--- ifconfig (utun) ---"; for i in 0 1 2 3 4 5 6 7; do ifconfig utun$i 2>/dev/null; done
  echo "--- routes v4 ---"; netstat -rn -f inet
  echo "--- routes v6 ---"; netstat -rn -f inet6 | grep -E 'default|utun'
  echo "--- TIME_WAIT ---"; netstat -an | awk '$NF=="TIME_WAIT"' | wc -l
  echo "--- DNS ---"; scutil --dns | head -20
} > ~/wake-outage-$(date +%H%M%S).txt
```
Without that snapshot we can't tell whether the utun IPv6 default routes were the cause or just persistent benign state.

### Cleanup attempted (2026-05-28, partial success)

**Tailscale state mismatch:** ran `tailscale up`. All three observers (`tailscale status`, `scutil --nc`, `systemextensionsctl list`) now agree the tunnel is up. utun5 holds Tailscale's IPv4 `100.x.y.z` and IPv6 ULA `fd7a:115c:a1e0::…` — peer ping to phone works.

**Orphan IPv6 default routes:** confirmed they survived `tailscale up`, so they are NOT Tailscale's — they belong to NextDNS DoH and/or other Apple NE tunnels. Deleted them surgically:

```sh
sudo route delete -inet6 default -ifscope utun0
sudo route delete -inet6 default -ifscope utun1
sudo route delete -inet6 default -ifscope utun3
sudo route delete -inet6 default -ifscope utun4
```

**Note the syntax:** on macOS, `-inet6` comes AFTER `delete`, not at the top-level (`route -inet6 delete …` errors with "illegal option").

Result: only the legitimate Tailscale IPv6 default (`fd7a:115c:a1e0::` via utun5) remains. Orphans did not re-install over a 5s observation window. Connectivity intact (Google 200, Tailscale ping works). IPv4 routing table now also has the Tailscale exit-node default (`link#24 via utun5`) which is normal.

**What's still leaked:** the 6 utun *interfaces* themselves persist (utun0–utun5). They no longer hold default routes, so they're idle/benign — but they only fully unload on reboot. Next reboot baseline check should confirm count drops to ~2.

**Open question:** what re-installs these IPv6 default routes on wake-from-sleep? Probably NextDNS DoH (since `NextDNS (<profile-id>)` profile has OnDemandRules in `/Library/Preferences/com.apple.networkextension`). To prove it, capture the snapshot script (above) immediately after wake but before re-adding Wi-Fi, and watch which utun gets created at what timestamp.

## Claude Code auto mode

Don't put machine paths or host details in `autoMode.environment` — `settings.json` is shared across machines via `claude-flow`. Describe the host here instead.

## Open gaps (decided to skip)

- **Keep-mac-awake** — relies on either `stay` in a tmux window before leaving, or System Settings → Battery → "Prevent automatic sleeping" toggle. Not automated.
- **mosh** — not installed. Plain SSH via Termius is enough for waiting-room-length sessions. Add later if reconnection friction becomes painful.
