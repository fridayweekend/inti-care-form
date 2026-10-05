# INTI Care customization explanation

INTI Care is a campus service request app designed to make student support approachable. I used INTI red, a dark navy sidebar, pale input backgrounds and green success feedback. The form groups student details, request information, contact preferences and confirmation into four numbered sections. It validates full names, a fictional INTI student ID format, email addresses, phone numbers and request lengths. Students choose from six services, three urgency levels and two contact methods. The preferred date cannot be in the past, and the declaration must be accepted. My three advanced customizations are a conditional building or room field, a live description character counter and a reusable CampusTextField widget. A submission dialog also presents the saved details and a reference number. Reset clears every field and selection. The responsive layout supports mobile and desktop screens, while submissions remain simulated.

## Screenshot evidence

- 01-desktop.png: app identity, colors, field grouping and desktop layout.
- 02-mobile.png: narrow-screen layout and student fields.
- 03-validation.png: specific field-level errors after unsuccessful submission.
- 04-request-details.png: conditional location field and live character counter. Reusable CampusTextField is implemented in lib/main.dart.
- 05-confirmation.png: date preference, declaration and actions.
- 06-success.png: simulated successful submission and saved summary.

The sample student and ID convention are fictional. Add your own name, student ID and class to your submission cover sheet as required by your lecturer.
