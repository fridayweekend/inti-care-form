# INTI Care

A new Flutter campus service request app for the Form Widget assignment. The app uses fictional sample details and simulates submissions; it does not contact INTI or store requests. GitHub publication is deferred.

## Run

Open this project folder in a terminal:

```powershell
flutter pub get
flutter run -d chrome
```

Or double-click `run-app.bat` on a computer with Flutter installed. The project includes the web target. For Android or other platforms, generate the appropriate runner using Flutter before building for that platform.

## Try a valid request

1. Full name: Alex Tan
2. Student ID: INTI-2026001 (a fictional project convention)
3. Campus email: alex@student.example.edu (a fictional example domain; other valid email domains are accepted)
4. Leave phone blank for email contact, or enter +60123456789 for phone contact.
5. Choose Facilities & maintenance and enter Block B, room 2-14.
6. Subject: Study room lighting
7. Details: The main light in the study room is flickering during evening sessions. Please arrange a check.
8. Choose an urgency level, contact method, and today or a future date.
9. Select the declaration and press Send request.
10. Inspect the saved summary. Back to form preserves your values; New request resets everything.

## Assignment mapping

| Requirement | Implementation |
| --- | --- |
| Form, GlobalKey and state | CampusRequestPage with one persistent GlobalKey<FormState> |
| Text fields | Name, student ID, email, phone, subject, details; conditional building/room field |
| At least five services | Six campus service categories |
| Multiple input controls | TextFormField, DropdownButtonFormField, ChoiceChip, date picker, checkbox |
| Validation | Full name, ID convention, email structure, phone digits, subject length, 20–500 character description, required selections, non-past date, declaration |
| Conditional phone | Phone number becomes required when Phone call is selected |
| Form lifecycle | validate before save; onSaved builds the summary; reset clears FormField and external state |
| Feedback | Field-level errors, SnackBar, saved submission summary with reference |
| Accessibility | Floating labels, text errors, responsive rows, keyboard actions, scrollable body, large-text checks |
| Customization | INTI Care identity, red primary, green success/accent, pale field fill, dark sidebar, campus assets |
| Advanced option 1 | Conditional location field for Facilities and Accommodation |
| Advanced option 2 | Live 500-character description counter |
| Advanced option 3 | Reusable CampusTextField widget |
| Additional advanced option | Submission summary dialog |
| Explanation and screenshots | docs/assignment-explanation.md and docs/screenshots/ |

The form does not retain entries after browser refresh. Preferred dates do not reserve appointments. Urgency levels do not notify an emergency service.

## Verification

```powershell
flutter analyze
flutter test
flutter build web --release
```

The tests cover validator boundaries, invalid submissions preserving data, successful saving, new-request and reset behavior, conditional fields, and 320/390/1440-pixel layouts with keyboard insets and larger text.

## Hosting later

This is a web-ready Flutter project. GitHub repository creation, workflow configuration and publication have not been performed. A future GitHub Pages build must use the base path matching the final repository name.
