# Demo video manuscript

Just under four minutes, English, read over a screen recording of the Pixel 6 emulator. Each scene
says what is on screen and what to say over it. The timings are rough, so a take that drifts ten
seconds either way is fine.

The emulator is a Pixel 6 on Android 16, API level 36. Say the version out loud at the end, since
the hand-in has to state it.

---

## 1. Start screen, English (0:00 to 0:20)

**On screen:** The app just opened. The title in a black band, a Play button, a How to play
button, and a two-way language toggle with English filled in.

**Say:** "This is Hangman, built in Flutter and Dart, running on a Pixel 6 emulator. The phone is
set to English, and the app follows the phone, so it comes up in English. Every word on this screen
comes out of a resource file, one per language."

---

## 2. The rules, from the start screen (0:20 to 0:42)

**On screen:** Tap How to play. The rules open over the screen. Scroll down once, slowly. Close
them.

**Say:** "How to play is here on the start screen and again inside a game. It opens over what you
were doing, so you can check the rules without losing your round. It covers the six wrong guesses and where the word comes from. This
text sits in the same resource files as the buttons, so it translates with everything else."

---

## 3. Switching to Norwegian (0:42 to 1:05)

**On screen:** Two buttons sit side by side, Norsk and English, the active one filled in.
Tap Norsk. The fill moves across and the screen turns Norwegian: Spill, Slik spiller du.

**Say:** "The app starts in the phone's language, and the toggle switches it. Norsk, and the screen
changes under you, no restart needed. The choice is saved too, so if I close the app and open it
again, it comes back in Norwegian."

---

## 4. The rules in Norwegian (1:05 to 1:18)

**On screen:** Tap Slik spiller du. The same rules in Norwegian. Close them.

**Say:** "Same page, same code, Norwegian text. That is what two languages has to mean here: every
screen you can reach, not just the title."

---

## 5. Playing in Norwegian (1:18 to 1:55)

**On screen:** Tap Spill. The game: the gallows frame, "6 forsøk igjen", one empty box per letter,
the keyboard. Linger on the last three keys. Guess two or three letters that land, then two that
miss, so the figure starts filling in.

**Say:** "Here is the game in Norwegian. Look at the keyboard: twenty nine keys, and the last three
are æ, ø and å. The alphabet belongs to the language, so the Norwegian keyboard is longer than the
English one, and the Norwegian word list actually uses those letters. A letter that is in the word
shows up everywhere it appears. A letter that is not costs an attempt, the counter drops, and the
drawing gains a piece in red. A key that was in the word keeps a heavy green border, a key that was
not goes red with the letter struck through, so you can still tell them apart in a grey print. The
app paints the figure itself, one stroke per miss, instead of swapping between six pictures."

---

## 6. Typing instead of tapping (1:55 to 2:10)

**On screen:** Guess the next two letters on the hardware keyboard rather than the screen, including
one of æ, ø or å. Then press a letter already used, and a digit, so nothing happens.

**Say:** "On an emulator most people would rather type than tap, so letters from the keyboard count
as guesses, æ, ø and å with them. Press something that is not a letter, or one you have already
used, and nothing happens."

---

## 7. Leaving, coming back, losing (2:10 to 2:45)

**On screen:** Before finishing the round, swipe the app away and open it again from the launcher.
The start screen now has Fortsett spillet. Tap it: same word, same guesses. Then keep missing until
the figure is finished. The result: Du tapte, the word revealed, Spill igjen and Tilbake til start.

**Say:** "If I leave in the middle, the round is saved. Close the app, open it, and the start screen
offers to continue exactly where I was. Six misses and it is over. It shows you the word it was
hiding, which is the least it can do, and you can take another one or go back."

---

## 8. Winning (2:45 to 3:05)

**On screen:** Tap Spill igjen. A new word. Guess it out, ideally dropping one wrong guess on the
way. The result shows Du vant and the line with the count.

**Say:** "New round, new word from the same list. Win it, and the result counts your misses in
proper Norwegian, one bom or several, which only works because the translation file carries the
plural forms instead of one fixed string."

---

## 9. Dark mode and landscape (3:05 to 3:25)

**On screen:** From the start screen, pull down the emulator's quick settings and turn on dark
theme, so the switch happens on camera. Then rotate the emulator to landscape, where the drawing
moves beside the keyboard instead of above it. Rotate back.

**Say:** "It follows the phone into dark mode too, where the whole thing inverts to white on black
and the green and the red stay exactly where they were. And it turns sideways: in landscape the
drawing moves next to the keyboard instead of sitting on top of it, so all twenty nine keys still
fit."

---

## 10. How it is built, and close (3:25 to 3:55)

**On screen:** Tilbake til start, tap English on the toggle, hold on the English start
screen.

**Say:** "English again, back where we started. Underneath it is Dart on Flutter, compiled to
native code and drawing its own interface. The rules of the game are plain Dart with no Flutter in
them, so they can be tested without a device at all. There are ninety eight tests, and the ones I
would point at are the golden images, which catch a layout break I would otherwise find during a
demo. The report says why Flutter won over Ionic, Cordova, React Native and Kirigami. Tested on a
Pixel 6 emulator, Android 16, API level 36."

---

## Notes for recording

- Clear the recents view first so nothing else shows up when you swipe.
- Record the emulator window, not the whole desktop.
- `adb shell screenrecord` stops at three minutes, so either record the window from the host or take
  two clips and join them.
- Dark mode from the shell instead of quick settings, if that is easier to hit on camera:
  `adb shell "cmd uimode night yes"`, and `no` to go back.
- Rotation from the shell: `adb shell settings put system accelerometer_rotation 0`, then
  `adb shell settings put system user_rotation 1` for landscape and `0` for portrait.
- Speak slower than feels right. The lines above are 581 words, which is roughly three and three quarter
  minutes of speech, and the pauses make up the rest.
