# sphinx_ar

A Flutter AR experience inspired by ancient Egyptian aesthetics.

## What This App Does

`sphinx_ar` is an image-tracked augmented reality app.

When you point your camera at the Sphinx target image, the app detects it and places a 3D pharaoh crown model in AR space. The experience includes a cinematic dark-and-gold UI, animated effects, and guided onboarding steps.

## Home Screen Style (UI Theme)

The app UI follows the same style used in `lib/screens/home_screen.dart`:

- Dark desert-night gradient background
- Gold glowing accents and mystical iconography
- Floating Sphinx preview card with shimmer
- "How to Use" instruction panel
- Prominent `ENTER AR EXPERIENCE` call-to-action button

## Target Image

Use this image as the tracking target before launching AR:

![Sphinx tracking target](assets/images/sphinx_face.jpg)

## Video Preview


https://github.com/user-attachments/assets/b543e227-9cfc-40ba-ab32-239e1a279bf7



## Quick Start

```bash
flutter pub get
flutter run
```

## Repository

Remote repository:

- `https://github.com/3shmawi/sphinx_ar.git`

## Push to Remote

Use these commands to connect and push:

```bash
git remote add origin https://github.com/3shmawi/sphinx_ar.git
git branch -M main
git add .
git commit -m "docs(readme): update app overview and repository setup"
git push -u origin main
```
