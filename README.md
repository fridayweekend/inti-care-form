# INTI Care

A Flutter campus service request app for the Form Widget and Firebase assignment.
Uses fictional student data, anonymous authentication and Cloud Firestore.

## Run

```powershell
flutter pub get
flutter run -d chrome
```

Web is configured for Firebase project `inti-care`, app `INTI Care Web`.
Anonymous sign-in is enabled and the tested `firestore.rules` are published.
See [Firebase implementation](docs/firebase-implementation.md) for schema,
setup, restart recovery and live evidence requirements.

## Valid sample

Name: Alex Tan. ID: INTI-2026001. Email: alex@student.example.edu.
Choose Facilities & maintenance, location Block B room 2-14, subject Study room
lighting, and details The main light in the study room is flickering during evening sessions.
Select Normal urgency, Email contact, today or a future date, and accept the declaration.
Send request waits for server acknowledgement. The dialog shows the real document
ID. Closing it retrieves the saved record. Reset begins a new request and preserves
the database document. This prototype does not contact university staff.

## Requirement coverage

- GlobalKey<FormState>, validate before save, onSaved, complete reset.
- Six text fields plus conditional location; six service categories.
- Dropdown, chips, date picker, checkbox and field-level errors.
- Scrollable responsive layout, appropriate keyboards, visible labels.
- Three advanced customizations: conditional location, live counter, reusable field.
- Firebase startup error screen, anonymous owner, auto document ID, server time.
- Pending/success/error states; duplicate prevention; server-only retrieval.
- Local retained ID for retrieval after restart under the same account.
- Owner-only create/read rules, updates and deletes blocked.

## Verification

```powershell
flutter analyze
flutter test
flutter build web --release
```

For local security tests (requires Node and Java supported by Firebase CLI):

```powershell
npm install --prefix .tools firebase-tools @firebase/rules-unit-testing firebase
.\.tools\node_modules\.bin\firebase.cmd emulators:exec --only firestore --project demo-inti-care "node test/firestore_rules.cjs"
```

See [test results](docs/test-results.md). Tests use a fake store for widget states
and a real local Firestore emulator for rules; neither is live-project evidence.
See [customization explanation](docs/assignment-explanation.md) for the required
100–150 word explanation and planning decisions.

Live Firebase screenshots are in docs/firebase-evidence/. Older docs/screenshots images depict simulated submissions and are excluded from the submission ZIP. Do not package build/, .tools/,
.dart_tool/, debug logs, passwords or service-account keys.


## Campus announcements and services

The existing INTI Care app now has Request, Announcements and Services destinations.
The request form and Firebase request records remain available. An IndexedStack
retains form inputs, bookmark selections and scroll positions when changing tabs.

Eight fictional announcements use stable IDs, scrollable cards and individual
detail routes. Six service tiles open matching sample information. The services
grid uses two columns below 420 logical pixels, three below 700, and four at 700
or above. Tile heights adapt to accessibility text scaling. Bookmarks persist
for the current app session, including detail navigation and tab changes.

Implementation: lib/models/campus_content.dart, lib/data/campus_data.dart,
lib/screens/campus_content_screens.dart and the IntiCareHome navigation in
lib/main.dart. All added campus information is explicitly demonstration data.
