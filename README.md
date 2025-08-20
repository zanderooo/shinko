# Shinkō (進行)

Make progress feel good. Shinkō turns your habits into streaks, levels, and tiny wins that snowball.

## What you can do right now

- Create habits and build streaks without worrying about “XP exploits” — completion grants XP once per day, unchecking removes it
- See your progress in the Journey tab with real XP graphs (no fake data)
- Complete daily quests (auto-generated, 3–5 per day) and unlock the Mystery Chest by finishing all habits
- Export/Import your data as JSON from Settings so you can switch devices safely
- Explore the Style tab and equip cosmetics you unlock (themes, icons, trails)

## Highlights

- Anti-spam XP with proper uncheck handling
- Streaks and best streak tracking
- Daily quests + bonus chest (XP reward), compact UI on the dashboard
- Style tab with cosmetic unlock/equip storage (applied theming is coming next)
- Export/Import backups (local JSON via share & file picker)
- Smooth animations and a clean Japanese-inspired dark UI

## Get started

```bash
flutter pub get
flutter run
```

Works best on Android right now. iOS/Web should build, but the primary target is Android.

## Power-user notes

- Data is stored locally (SQLite). Back up via Settings → Export. Restore via Settings → Import.
- Quests regenerate each day and progress is based on today’s completions.
- Bonus chest appears when all active habits are done. Claim it for extra XP (and soon: a cosmetic).

## Contributing

PRs are welcome: small, focused, and with a quick note on the UX thinking behind the change.

Ideas that would help:
- Confetti/haptics wired into every meaningful event
- Notification nudges (streak save, “one away from chest”, weekly review)
- Applying equipped themes/icons globally

## License

MIT — see `LICENSE`.

–––

Made with Flutter. 進行 — progress through small wins.
