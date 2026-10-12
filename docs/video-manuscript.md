# Demo video manuscript

Target length three and a half minutes, English, read over a screen recording of the Pixel 6
emulator. Each scene gives what is on screen and the line to say. Timings are cumulative and
approximate, so a take that drifts ten seconds either way is fine.

The emulator is the Pixel 6 AVD running Android 16, API level 36. Say the version out loud in the
last scene, because the assignment asks for it.

---

## 1. Opening, start screen in English (0:00 to 0:20)

**On screen:** The app has just been opened. Start screen: the title Hangman, the line "Guess the
word one letter at a time.", a Play button, a How to play button, and the language dropdown showing
"Device language".

**Say:** "This is Hangman, built with Flutter and Dart as a cross-platform app, running here on a
Pixel 6 Android emulator. The emulator is set to English, and the app follows the language of the
device, so it opens in English. Everything you see is loaded from a resource file, including the
alphabet, which matters in a moment."

---

## 2. The info page from the start screen (0:20 to 0:45)

**On screen:** Tap How to play. The info page opens with the rules in three paragraphs. Scroll once,
slowly. Then go back with the system back gesture.

**Say:** "The assignment asks for an info page reachable at startup and during play. This is it,
from the start screen. It explains the rules, the six wrong guesses, and that the word comes from
the list for the language the app is running in. The text is part of the translated resources, not
hard-coded in the screen."

---

## 3. Switching the app to Norwegian (0:45 to 1:10)

**On screen:** Open the language dropdown. Three options: Device language, Norsk, English. Pick
Norsk. The whole start screen changes: Spill, Slik spiller du, Språk, and the tagline in Norwegian.

**Say:** "The app supports Norwegian and English in full. You can leave it on the device language or
override it here. Choosing Norsk changes every label on the screen at once, with no restart, because
the whole interface reads from the Norwegian resource file."

---

## 4. The info page in Norwegian (1:10 to 1:25)

**On screen:** Tap Slik spiller du. The same page, now in Norwegian. Go back.

**Say:** "Same page, same code, Norwegian text. This is what full support for two languages means in
practice: not a translated title, but every screen the user can reach."

---

## 5. Playing in Norwegian, including the alphabet (1:25 to 2:15)

**On screen:** Tap Spill. The game screen appears: gallows frame, "6 bom igjen", the masked word as
spaced underscores, and the keyboard. Point out the last three keys. Guess two or three letters that
hit, then two that miss so the figure starts appearing.

**Say:** "Here is the game in Norwegian. Note the keyboard: twenty-nine keys, ending in æ, ø and å.
The alphabet is part of the localised data, so the Norwegian keyboard is longer than the English one,
and the Norwegian word list uses those letters. A correct guess reveals the letter everywhere it
appears. A wrong one costs an attempt, the counter above goes down, and the drawing gains a part.
The gallows is drawn by the app with a canvas painter, one more stroke per wrong guess, not picked
from a set of images."

---

## 6. Losing a round (2:15 to 2:40)

**On screen:** Keep guessing wrong until the figure is complete. The result appears: Du tapte, the
word revealed, Spill igjen and Tilbake til start.

**Say:** "Six wrong guesses and the round is over. The app shows the word it was hiding, so the
player learns it, and offers another round or a way back to the start screen."

---

## 7. Winning a round (2:40 to 3:10)

**On screen:** Tap Spill igjen. A new word. Guess it out, ideally with one wrong guess on the way.
The result shows Du vant and the line with the number of wrong guesses.

**Say:** "Play again picks a new word from the same list. Guess the whole word and you win, and the
result line uses the correct Norwegian plural for the number of wrong guesses you used, which is the
kind of detail that only works if the translation file carries plural forms rather than a single
string."

---

## 8. Back to English and closing (3:10 to 3:30)

**On screen:** Tilbake til start, then switch the dropdown to English. The start screen is English
again. Hold on it.

**Say:** "Back to English, and we are where we started. The app is written in Dart on Flutter, which
compiles to native code and draws its own interface, and I chose it over Ionic, Cordova, React Native
and Kirigami for the reasons in the report. Tested on the Pixel 6 emulator with Android 16, API
level 36. Thanks for watching."

---

## Recording notes

- Switch the emulator to a clean home screen before starting so no other app is in the recents view.
- Record the emulator window only, not the whole desktop.
- `adb shell screenrecord` tops out at three minutes per file, so either record the host window with
  a screen recorder or capture two clips and join them.
- Speak slower than feels natural. The whole script is about 430 words, which is a comfortable three
  and a half minutes.
