# Test results

Verified 20 October 2026, Malaysia time.

| Check | Result and evidence |
| --- | --- |
| Flutter static analysis | Passed, no issues |
| Flutter release web build | Passed |
| Form validation and reset | Passed in widget tests and live validation screenshot |
| Pending sync and duplicate prevention | Passed with controlled widget backend |
| Read failure does not repeat write | Passed with controlled widget backend |
| Restart reference retrieval | Passed in widget test and live browser reload |
| 320, 390 and 1440 pixel layout, keyboard and large text | Passed |
| Firestore security rules | 20 local emulator checks passed |
| Live Flutter submit and matching console document | Passed, mXzwP1vZRivvHfBMUIj4 |
| Live server retrieval after browser restart | Passed, same document ID |
| Offline/reconnect | Passed against live Firebase SDK; one ID and no premature acknowledgement |
| Different owner read | Live Firebase SDK denied with permission-denied |
| Invalid live write | Missing declaration rejected with permission-denied |
| Screenshots | Seven images in firebase-evidence/ |

Totals: 10 Flutter tests, 20 emulator rules checks and 6 live SDK checks passed.

Rules tests cover valid create/read, guest rejection, another owner's rejected
read, spoofed owner, update/delete rejection and twelve malformed payloads.
The live offline test used Firebase JavaScript SDK networking controls; it is not
a claim that the browser's physical network connection was disconnected. Flutter
pending UI behavior is covered separately. No screen recording has been created;
follow the live demonstration sequence in firebase-implementation.md.
