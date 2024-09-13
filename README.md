Auto Service AI Notes
Overview
Auto Service AI Notes is a comprehensive mobile application designed for efficient data collection and management in the auto service industry. The app allows users to input detailed information, record audio notes, capture photos, and automatically store location and time data. All collected data is uploaded to Firebase, and notifications are sent to a Slack channel upon successful upload.

Features
User Data Entry: Collects user information, including username, phone number, and retail name.
Voice Recording: Allows users to record and upload audio notes.
Location and Time Tracking: Automatically records the user's location and the current time.
Photo Capture: Enables users to take and upload photos.
Firebase Integration: Stores all data in Firebase for secure and scalable storage.
Slack Notifications: Sends notifications to a specified Slack channel once data upload is complete.
Technologies Used
Flutter: Framework for building the cross-platform mobile application.
Firebase: Backend services for authentication, real-time database, and file storage.
SharedPreferences: For local data storage.
Slack API: For sending notifications to a Slack channel.
Getting Started
Prerequisites
Flutter SDK installed.
A Firebase project set up.
A Slack workspace with a webhook URL configured.
Setup
Clone the Repository:

bash
Copy code
git clone https://github.com/yourusername/auto_service_ai_notes.git
cd auto_service_ai_notes
Install Dependencies:

bash
Copy code
flutter pub get
Configure Firebase:

Add your google-services.json (Android) and GoogleService-Info.plist (iOS) files to the respective directories.
Set up Firebase Authentication, Firestore, and Storage in the Firebase console.
Set Up Slack Integration:

Obtain your Slack webhook URL.
Update the sendNotification function in your code with your webhook URL.
Run the App:

bash
Copy code
flutter run

Usage
Fill Out the Form: Enter your username, phone number, retail name, and other required fields.
Record Audio: Press the record button to start and stop recording your audio notes.
Capture Photo: Use the provided button to take a photo related to your service note.
Submit Data: After filling out the form, recording audio, and capturing the photo, submit the data. The app will upload everything to Firebase and notify the Slack channel.
Contribution
Feel free to fork the repository and submit pull requests. For significant changes or features, please open an issue first to discuss your ideas.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Contact
For any questions or issues, please contact mehboobcodes@gmail.com.