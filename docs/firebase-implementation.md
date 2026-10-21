# Firebase implementation and submission evidence

Project: `inti-care`. Registered app: `INTI Care Web`. Target: Flutter web.
Database: `(default)`, `asia-southeast1` (Singapore).
Authentication: anonymous sign-in (verified enabled in console).

## Run

Run `flutter pub get`, then `flutter run -d chrome`.
For restart tests use a stable origin: `flutter run -d web-server --web-port 5184 --web-hostname 127.0.0.1` and open http://127.0.0.1:5184 in the same browser profile.
Do not clear site data between tests.

The lecturer should configure their own project using `flutterfire configure --platforms=web`, enable Anonymous authentication, create Firestore and publish `firestore.rules`. Do not share a Google login. The supplied client configuration identifies the student's demonstration project; it is not an admin credential.

## Schema

Collection: `campusRequests`. Automatically generated Firestore document IDs.

| Field | Type | Meaning |
| --- | --- | --- |
| ownerUid | string | Anonymous Firebase UID |
| studentName, studentId, email, phone | string | Fictional student details; phone may be empty |
| serviceCategory, subject, description | string | Service and request details |
| urgency | string | Low, Normal or High |
| preferredContact | string | Email or Phone |
| preferredDate | timestamp | End of the selected local day |
| declaration | boolean | Must be true |
| status | string | submitted |
| createdAt | timestamp | Server timestamp |
| location | string | Required for Facilities and Accommodation; otherwise empty |

`location` is the documented customization to the base assignment schema. All base field names remain unchanged. Rules explicitly validate this extra field. End-of-day timestamps allow today's date while rules reject dates earlier than server time. An offline request whose preferred day has passed will be rejected and must be corrected.

## Submission and recovery

Validation precedes FormState.save. onSaved collects validated fields. While writing, controls and Reset are blocked. One auto-generated document ID and its owner are retained locally before the write begins. There is no short write timeout or automatic retry with a new ID.

Pending sync remains visible until Firestore acknowledges the write. Only then does the success dialog show the request reference. Closing it triggers Source.server retrieval of that same ID. Read failures are separate from write failures and never create another request.

Restart restores the retained ID and offers Retrieve saved request. The same anonymous account and browser profile are required. If the server record is missing, the app conservatively blocks another submission: a queued operation may still complete in another tab. Keep the original tab open while a write is pending. Web persistence retains Firestore writes, but draft form fields are not separately stored across reloads.

Reset clears form state and the locally retained reference, not the saved Firestore document. Copy the reference before Reset if needed for evidence.

## Access rules

Authentication and matching ownerUid are required. Rules check allowed fields, types, lengths, ID format, categories, contact, declaration and timestamps. Users can create requests and read their own. Updates, deletes and access to other collections are denied. Anonymous accounts do not verify university enrollment. Use fictional data.

## Live verification completed

Rules were published with the project owner's confirmation on 20 October 2026.
The Flutter website created request `mXzwP1vZRivvHfBMUIj4` using fictional student
Alex Tan. The console confirmed all 15 fields, owner UID, submitted status and
createdAt timestamp at 22:59:19 Malaysia time. The browser was reloaded and the
same document retrieved using Source.server under the retained anonymous account.

Screenshots in firebase-evidence/ show field errors, completed form, pending sync,
server-confirmed ID, server retrieval, matching console record and retrieval after
restart. The old docs/screenshots folder is not Firebase evidence.

The live Firebase SDK verification script created a separate fictional record
`ihRxhK8KMyphiayfuv9n`. With networking disabled, acknowledgement remained pending;
after reconnecting, the original ID was confirmed and exactly one document existed
for its owner. A different anonymous account was denied access to the Flutter-created
record, and a write with a false declaration was rejected. See live-sdk-results.json.
This offline test exercised the real Firebase JavaScript SDK; Flutter UI pending
and duplicate-prevention behavior was separately verified by widget tests. A manual
browser-network disconnection demonstration remains useful before presenting.

## Short live demonstration for the lecturer

1. Open the app and press Send request with empty inputs to show field errors.
2. Enter the fictional sample in README; show the conditional room field and counter.
3. Submit and explain Pending sync. Show the server-confirmed document ID.
4. Close the summary to retrieve the server record. Show the matching Firestore entry.
5. Reload the same browser origin. Use Retrieve saved request to show persistence.
6. Close the retrieval dialog and Reset; confirm fields clear while the database record remains.

The app is ready for this demonstration. The saved screenshots are evidence, not
a screen recording. Add your own student identity and class to the submission cover.
