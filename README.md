# DSH Official Modifier

**DSH Official Modifier** is the upgrade path for an existing official DeepSeek Harness checkout. It applies the same reviewed remote/web-only patch without replacing the checkout, deleting provider source packages, or modifying unrelated plugin work.

> The modifier requires a clean Git worktree because it must not mix the product patch with uncommitted changes. Commit or stash local work before running it.

## Modify an existing official Harness

Clone the official repository if you do not already have it:

```bash
git clone https://github.com/deepseek-ai/deepseek-harness.git "$HOME/deepseek-harness"
cd "$HOME/deepseek-harness"
git checkout b150a551b8d465e31e418e1b2eaf5e79bbb7d28e
```

Download this product and apply the patch:

```bash
git clone https://github.com/DHS-M/dsh-official-modifier.git "$HOME/dsh-official-modifier"
BUILD=1 "$HOME/dsh-official-modifier/modify-official.sh" "$HOME/deepseek-harness"
```

Use `BUILD=0` to apply the source patch and install dependencies without building immediately:

```bash
BUILD=0 "$HOME/dsh-official-modifier/modify-official.sh" "$HOME/deepseek-harness"
```

The script is idempotent: if the patch is already applied, it does not apply it twice. It refuses a dirty worktree and rejects an official checkout where the patch no longer applies cleanly.

## Run the modified web interface

```bash
cd "$HOME/deepseek-harness"
pnpm dsh web --host 0.0.0.0 --open-authority --no-open
```

The browser interface is served on port `3080`. For temporary remote testing:

```bash
cloudflared tunnel --url http://127.0.0.1:3080
```

## What the patch changes

The patch adds a centralized open-authority switch to the core connection transport and ApiProxy capability declaration. It propagates the server authority to the browser, keeps host-backed settings enabled for non-loopback callers, replaces the native configuration-file handoff with an in-page browser editor, and retains browser filesystem browsing for remote workspace selection.

The active base composition no longer mounts the DeepSeek chat provider or its DeepSeek web-search companion. Their source packages remain untouched so an official checkout or custom overlay can re-enable them intentionally.

## Documentation and patch contents

The web documentation is in [`docs/index.html`](docs/index.html). The exact patch is in [`patches/open-authority-web-only.patch`](patches/open-authority-web-only.patch), and the pinned upstream commit is recorded in [`UPSTREAM-COMMIT.txt`](UPSTREAM-COMMIT.txt).

## License and attribution

This is a modification layer for the official DeepSeek Harness. Preserve the upstream license and attribution in [`UPSTREAM-LICENSE`](UPSTREAM-LICENSE). The upstream project is <https://github.com/deepseek-ai/deepseek-harness>.
