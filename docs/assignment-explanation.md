# INTI Care customization explanation

INTI Care helps students submit campus service requests through a clear, responsive form. I chose red for the main actions, navy for navigation, pale field backgrounds and green for confirmation. Four sections organize student details, request information, contact preferences and consent. Validation checks names, fictional student IDs, email addresses, phone numbers, request lengths and dates. Students select one of six campus services, three urgency levels and two contact methods. My three advanced customizations are a conditional building or room field, a live description character counter and a reusable CampusTextField widget. Firebase anonymous authentication associates each request with its owner. The app shows success only after Firestore confirms the write, then retrieves the saved record from the server. Reset clears the form without deleting the stored request.

## Planning worksheet

| Item | Decision |
| --- | --- |
| App and form | INTI Care, campus service request |
| Primary and accent | Red #BD1830, green #237564 |
| Field fill and text | #F8F9FC, navy #202C3D |
| Services | IT & Wi-Fi, Facilities & maintenance, Library services, Accommodation, Academic advice, Student activities |
| Contact | Email or Phone call |
| Date | Today or a future preferred response date |
| Confirmation | Server acknowledgement, reference and retrieval summary |
| Three advanced choices | Conditional location, live counter, reusable CampusTextField |

Add your name, student ID, class and submission date to the assignment cover sheet. See firebase-implementation.md for the schema, setup and live evidence checklist.
