# Push this project to GitHub (worekk)

Your repo: **https://github.com/devz906/worekk**

Run these commands from the **GameHub-iOS** folder (with Git installed and in PATH).

## One-time setup

```bash
cd C:\Users\angui\GameHub-iOS

git init
git add .
git commit -m "Initial commit: GameHub for iPhone 16 Pro (JIT + BoxedWine containers)"

git branch -M main
git remote add origin https://github.com/devz906/worekk.git

git push -u origin main
```

When prompted, sign in with your GitHub account (or use a [Personal Access Token](https://github.com/settings/tokens) as the password).

## If the repo already has content (e.g. README)

```bash
git remote add origin https://github.com/devz906/worekk.git
git branch -M main
git pull origin main --allow-unrelated-histories
# resolve any conflicts, then:
git add .
git commit -m "Add GameHub iOS project"
git push -u origin main
```

## Optional: push from a different folder name

If you want the repo to live in a folder named `worekk`:

```bash
cd C:\Users\angui
ren GameHub-iOS worekk
cd worekk
# then run the "One-time setup" commands above
```
