# ShiftSwitch for Mac

ShiftSwitch is a macOS menu bar utility that lets you switch between any two saved input sources with a single tap of `Shift`, similar to the Windows typing workflow many multilingual users are already used to.

## Requirements

1. macOS `14` or later
2. `Intel` or `Apple Silicon`
3. `Input Monitoring` permission must be granted on first use
4. If you are using an unsigned build, macOS may ask you to approve the app manually the first time you open it

## What It Does

- Tap `Shift` by itself to switch between two saved input sources
- `Shift + letter` does not trigger a switch
- `Shift + number` does not trigger a switch
- `Shift + mouse click` does not trigger a switch
- `Caps Lock` keeps its normal capitalization behavior when the macOS language-switch shortcut is disabled

## Installation

### 1. Move the app to Applications

1. Unzip the app bundle you downloaded
2. Drag `ShiftSwitch.app` into `/Applications`

Running the app from Downloads can cause permission and launch-at-login issues.

### 2. Open the app for the first time

If macOS blocks the app on first launch, use one of these methods.

Method A: approve it in Privacy & Security

1. Double-click `ShiftSwitch.app`
2. If macOS shows a warning, close the dialog
3. Open `System Settings > Privacy & Security`
4. Scroll down until you find the blocked `ShiftSwitch` entry
5. Click `Open Anyway`
6. Confirm the next dialog if macOS asks again

Method B: open it from the context menu

1. Find `ShiftSwitch.app` in `/Applications`
2. Right-click the app and choose `Open`
3. Confirm the dialog

ShiftSwitch runs as a menu bar app. After launch, click the keyboard icon in the top-right menu bar to open its controls.

### 3. Grant Input Monitoring

1. Open `ShiftSwitch`
2. Follow the in-app button, or open:
   `System Settings > Privacy & Security > Input Monitoring`
3. Enable `ShiftSwitch`
4. Quit the app completely
5. Open it again

If `ShiftSwitch` does not appear in the list yet, confirm that the app is already in `/Applications`, then launch it once more.

### 4. Turn off the built-in Caps Lock language switcher

1. Open `System Settings > Keyboard`
2. Go to `Text Input > Edit`
3. Disable the option that uses `Caps Lock` to switch languages or input sources

This prevents macOS from conflicting with ShiftSwitch.

### 5. Save your two input sources

1. Switch to the first input source you want to use
2. In `ShiftSwitch`, click `Save Current as Primary`
3. Switch to the second input source you want to use
4. Click `Save Current as Secondary`

After that, a single tap of `Shift` will switch between those two saved input sources.

## Typical Use Cases

- English and Japanese
- English and Korean
- English and Pinyin
- English and a custom keyboard layout
- Any other pair of selectable macOS input sources

## Privacy

ShiftSwitch works locally on your Mac. It uses Input Monitoring permission only to detect a standalone `Shift` key tap and trigger an input-source switch. It is not designed to upload your keystrokes or typing content.

## Troubleshooting

### Why won't the app open?

If you are using an unsigned build, macOS may block it the first time. Open `System Settings > Privacy & Security` and choose `Open Anyway`, or right-click the app and open it from the context menu.

### Why does tapping Shift do nothing?

The most common causes are:

- `Input Monitoring` permission has not been granted
- You have not saved both a `Primary` and `Secondary` input source yet

### I already granted permission, but it still does not work

Try this order:

1. Confirm `ShiftSwitch.app` is in `/Applications`
2. Turn `ShiftSwitch` off and on again in `Input Monitoring`
3. Quit `ShiftSwitch`
4. Reopen `ShiftSwitch`

### Does it work on Intel Macs?

Yes. It supports both `Intel` and `Apple Silicon`.

### Which macOS versions are supported?

Current minimum version: `macOS 14`.
