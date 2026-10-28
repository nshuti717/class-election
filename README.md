git# Class Election

Class Election lets students vote once for a class representative and follow the live election results.

## Local data

Election data is saved on this device using `shared_preferences`. Candidate names and vote totals, along with the cleaned names of students who have voted, are stored locally and restored when the app starts.

## Live weather

The home screen shows live weather for Kigali from the free [Open-Meteo API](https://open-meteo.com/). Weather requires an internet connection; use Retry after reconnecting if a request fails.

## Features

- Add and remove candidates; candidates with votes cannot be removed.
- Clean names before comparing them and allow only one vote per student.
- Show ranked results, percentages, progress bars, and winner or tie status.
- Reset votes after confirmation.
- Persist the election locally across app restarts.
- Show current Kigali temperature, condition, humidity, wind, and update time.
- Show a retryable error state when weather cannot be loaded.

## Screenshots

Add the assignment screenshots at these paths:

- `screenshots/before.png`
- `screenshots/after.png`
- `screenshots/api.png`
- `screenshots/no-internet.png`

## Think questions

1. **Why must names be cleaned before they are compared? Give an example of what goes wrong otherwise.**
   Cleaning removes accidental spaces and normalizes capitalization so the same person is recognized consistently. Without it, `  aLINE ` and `Aline` could be treated as two different voters and vote twice.
2. **How does your app decide between a winner and a tie? Explain it in plain words.**
   The app finds the highest vote count. If one candidate has that count, that candidate is the leader; if multiple candidates share it, the result is a tie. When there are no votes, it says “No votes yet.”
3. **What happens to locally saved election data when the app is opened on another phone? What kind of storage would keep the same data for every phone?**
   The saved data stays on the first phone and does not automatically appear on another one. A shared cloud database or server backed by an account would let multiple phones use the same election data.
