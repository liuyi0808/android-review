# android-review

Android development review skills for [Claude Code](https://claude.ai/claude-code).

## Skills

| Skill | Description |
|-------|-------------|
| `android-review:security-audit` | OWASP MASVS v2.0 security audit and secure coding guidance |
| `android-review:architecture` | Clean Architecture, MVVM/MVI, Hilt DI, modularization standards |
| `android-review:performance` | Startup optimization, recomposition, ANR prevention, memory, baseline profiles |
| `android-review:compose-ui` | Jetpack Compose state management, side effects, navigation, theming, accessibility |
| `android-review:play-store` | Google Play Store submission and compliance checklist |

## Publish to GitHub

First time only. Push the local repo to GitHub:

```bash
# 1. Create an empty repo on GitHub (do NOT add README or LICENSE)
#    https://github.com/new -> repo name: android-review

# 2. Push local repo
cd ~/Documents/android-review
git branch -M main
git remote add origin git@github.com:<your-github-username>/android-review.git
git push -u origin main
```

After updating skills locally, push changes:

```bash
cd ~/Documents/android-review
git add -A
git commit -m "update skills"
git push
```

## Install

In Claude Code, run:

```
/plugin marketplace add <your-github-username>/android-review
/plugin install android-review@android-review
```

To update after pushing new changes to GitHub:

```
/plugin install android-review@android-review
```

## Local Testing

Test locally without GitHub, using `--plugin-dir`:

```bash
claude --plugin-dir ~/Documents/android-review
```

## Usage

Skills trigger automatically based on context, or invoke manually:

```
/android-review:security-audit
/android-review:architecture
/android-review:performance
/android-review:compose-ui
/android-review:play-store
```

## License

MIT
