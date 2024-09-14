import 'dart:convert';
import 'dart:io';
import 'package:auto_services_ai_notes/screen/final_route.dart';
import 'package:auto_services_ai_notes/screen/form_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../utils/color_schema.dart';

final formViewModelProvider =
    StateNotifierProvider<FormViewModel, CustomFormState>((ref) {

      return FormViewModel();
    });

var downloadUrlBusiness="";


class CustomFormState {
  final String userName;
  final String phoneNumber;
  final String retailName;
  final String metGM; // "Met" or "GM"
  final String metSD; // "Met" or "SD"
  final String interestLevel; // "Hot", "Warm", "Cold"
  final String visitSummary;
  final String nextAction;
  final File? businessCardImage;
  final String voiceUrl;

  CustomFormState({
    this.userName= '',
    this.voiceUrl = '',
    this.phoneNumber = '',
    this.retailName = '',
    this.metGM = '',
    this.metSD = '',
    this.interestLevel = '',
    this.visitSummary = '',
    this.nextAction = '',
    this.businessCardImage,
  });

  CustomFormState copyWith({
    String? userName,
    String? phoneNumber,
    String? retailName,
    String? metGM,
    String? metSD,
    String? interestLevel,
    String? visitSummary,
    String? nextAction,
    File? businessCardImage,
  }) {
    return CustomFormState(
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      retailName: retailName ?? this.retailName,
      metGM: metGM ?? this.metGM,
      metSD: metSD ?? this.metSD,
      interestLevel: interestLevel ?? this.interestLevel,
      visitSummary: visitSummary ?? this.visitSummary,
      nextAction: nextAction ?? this.nextAction,
      businessCardImage: businessCardImage ?? this.businessCardImage,
    );
  }
}
class FormViewModel extends StateNotifier<CustomFormState> {
  FormViewModel() : super(CustomFormState());
  bool loading = false;
  bool isVoiceRecorded = false;


  final _picker = ImagePicker();

  // Any resources that need to be cleaned up should be handled here
  // @override
  // void dispose() {
  //   // Clean up resources, such as closing streams, canceling subscriptions, etc.
  //   print("FormViewModel disposed");
  //
  //   super.dispose();
  // }

  // Reset the form state to initial values
// Reset the form state to initial values
  void resetState() {
    state = state.copyWith(
      userName: '',
      phoneNumber: '', // Reset to empty string or any default values
      retailName: '',
      metGM: '',
      metSD: '',
      interestLevel: '',
      visitSummary: '',
      nextAction: '',
      businessCardImage: null, // Reset image to null
    );
    // state = FormState(
    //   phoneNumber: '', // Reset to empty string or any default values
    //   retailName: '',
    //   metGM: '',
    //   metSD: '',
    //   interestLevel: '',
    //   visitSummary: '',
    //   nextAction: '',
    //   businessCardImage: null, // Reset image to null
    //   voiceUrl: "", // Reset voice URL to empty
    // );
  }
  void updateUserName(String userName){
    state = state.copyWith(userName: userName);
  }
  void updatePhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
  }
void updateIsRecorded(bool newValue){
    isVoiceRecorded = newValue;
}
  void updateRetailName(String value) {
    state = state.copyWith(retailName: value);
  }

  void updateMetGM(String value) {
    state = state.copyWith(metGM: value);
  }

  void updateMetSD(String value) {
    state = state.copyWith(metSD: value);
  }

  void updateInterestLevel(String value) {
    state = state.copyWith(interestLevel: value);
  }

  void updateVisitSummary(String value) {
    state = state.copyWith(visitSummary: value);
  }
  void updateNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }
  //first thing
  void setLoading(bool value) {
    loading = value;
    state = state.copyWith(); // Trigger a rebuild by updating the state
  }

  Future<void> pickBusinessCardImage(BuildContext context,String voiceUrl) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
   try{
     if (pickedFile != null) {
       state = state.copyWith(businessCardImage: File(pickedFile.path));
       Navigator.push(context, MaterialPageRoute(builder: (context)=>FinalRoute(voiceUrl)));
     }
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("everything is right")));

   }catch(e){
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
   }
  }

  Future<void> submitForm(String voiceUrl, BuildContext context) async {
    setLoading(true);

    try {
      Position? position = await getCurrentLocation(context);

      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to get location.')),
        );
        return;
      }

      String gpsCoordinates = '${position.latitude}, ${position.longitude}';

      final dbRef = FirebaseDatabase.instance.ref().child('formData').child(state.phoneNumber);

           // Generate a new key (ref ID) for this entry
           final newRef = dbRef.push();
           final refId = newRef.key; // Get the generated key

           // Prepare the Firebase Storage reference for the business card image
           final storageRef = FirebaseStorage.instance
               .ref()
               .child('business_cards/${DateTime.now().toIso8601String()}');

           // Upload the business card image to Firebase Storage
           if (state.businessCardImage != null) {
             final uploadTask = storageRef.putFile(state.businessCardImage!);
             final snapshot = await uploadTask;
             final downloadUrl = await snapshot.ref.getDownloadURL();
             downloadUrlBusiness=downloadUrl;

             // Save the form data along with the ref ID to Realtime Database
             await newRef.set({
               'refId': refId, // Save the generated ref ID here
               'userName':state.userName,
               'phoneNumber': state.phoneNumber,
               'retailName': state.retailName,
               'metGM': state.metGM,
               'metSD': state.metSD,
               'interestLevel': state.interestLevel,
               'visitSummary': state.visitSummary,
               'nextAction': state.nextAction,
               'businessCardUrl': downloadUrl ?? '',
               'voiceUrl': voiceUrl ?? '' ,
               'gpsCoordinates': gpsCoordinates ?? '',
             });
           }

      sendNotification(user: state.phoneNumber,phone: state.phoneNumber, retailName: state.retailName, time: DateTime.now().toIso8601String(), gps: gpsCoordinates, metGM: state.metGM, metSD: state.metSD, linkToBusCard: downloadUrlBusiness, audioFile: voiceUrl,context: context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during form submission: $e')),
      );
    } finally {
      setLoading(false);
    }
  }


  // Future<void> sendNotification({
  //
  //   required String user,
  //   required String retailName,
  //   required String time,
  //   required String gps,
  //   required String metGM,
  //   required String metSD,
  //   required String linkToBusCard,
  //   required String audioFile,
  //   required BuildContext context
  // }) async {
  //   final channel = 'dealervisit';
  //   final message = 'User:$user-'
  //       'retailName:$retailName-'
  //       'Time:$time-'
  //       'LinkToBusCard:$linkToBusCard-'
  //       'GPS:$gps-'
  //       'MetGM:$metGM-'
  //       'MetSD:$metSD-'
  //       'AudioFile:$audioFile';
  //
  //   final url = Uri.parse('https://eu-west-1.aws.data.mongodb-api.com/app/application-2-febnp/endpoint/sendSlackNotification?channel=$channel&message=${Uri.encodeComponent(message)}');
  //
  //   print('Constructed URL: $url'); // Print URL for debugging
  //
  //   try {
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       print('Notification sent successfully');
  //       print('Response: ${response.body}');
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //                  SnackBar(content: Text('Form and API Submitted Successfully'.toUpperCase(), style: GoogleFonts.quicksand(
  //                    fontWeight: FontWeight.w500,
  //                    color: kWhiteColor,
  //                  ),)));
  //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FormView()));
  //
  //     } else {
  //       print('Failed to send notification: ${response.statusCode}');
  //       print('Response Body: ${response.body}');
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //                  SnackBar(content: Text('API Error: ${response.body}'.toUpperCase(), style: GoogleFonts.quicksand(
  //                    fontWeight: FontWeight.w500,
  //                    color: kWhiteColor,
  //                  ),)),
  //                );
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }


  Future<void> sendNotification({
    required String user,
    required String phone,
    required String retailName,
    required String time,
    required String gps,
    required String metGM,
    required String metSD,
    required String linkToBusCard,
    required String audioFile,
    required BuildContext context,
  }) async {
    final channel = 'dealervisit';

    // Construct the message for Slack notification
    final message = 'User:$user-'
        'retailName:$retailName-'
        'Time:$time-'
        'LinkToBusCard:$linkToBusCard-'
        'GPS:$gps-'
        'MetGM:$metGM-'
        'MetSD:$metSD-'
        'AudioFile:$audioFile';

    // Construct the Slack notification URL
    final slackUrl = Uri.parse(
        'https://eu-west-1.aws.data.mongodb-api.com/app/application-2-febnp/endpoint/sendSlackNotification?channel=$channel&message=${Uri.encodeComponent(message)}');

    print('Constructed Slack URL: $slackUrl'); // Print URL for debugging

    try {
      // Send Slack notification
      final slackResponse = await http.get(slackUrl);

      if (slackResponse.statusCode == 200) {
        print('Notification sent successfully');
        print('Response: ${slackResponse.body}');
      } else {
        print('Failed to send Slack notification: ${slackResponse.statusCode}');
        print('Response Body: ${slackResponse.body}');
      }

      // Construct the message for the API request by concatenating all fields
      final apiMessage = 'User: $user, Retail Name: $retailName, Time: $time, GPS: $gps, Met GM: $metGM, Met SD: $metSD, Bus Card: $linkToBusCard, Audio: $audioFile';

      // Construct the API URL
      final apiUrl = Uri.parse(
          'https://common.autoservice.ai/app?phone=$phone&message=${Uri.encodeComponent(apiMessage)}');

      print('Constructed API URL: $apiUrl'); // Print API URL for debugging

      // Send request to the external API
      final apiResponse = await http.get(apiUrl);

      if (apiResponse.statusCode == 200) {
        print('API request sent successfully');
        print('Response: ${apiResponse.body}');

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Form and API Submitted Successfully'.toUpperCase(),
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ));

        // Navigate to the form view after successful submission
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const FormView()));
      } else {
        print('Failed to send API request: ${apiResponse.statusCode}');
        print('Response Body: ${apiResponse.body}');

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'API Error: ${apiResponse.body}'.toUpperCase(),
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Future<void> submitForm(String voiceUrl,BuildContext context) async {
 //    // Start the loading state
 //    setLoading(true);
 //
 //    try {
 //
 //      Position position = await _getCurrentLocation();
 //
 //      String gpsCoordinates = '${position.latitude}, ${position.longitude}';
 //      // Get a reference to the Realtime Database
 //      final dbRef = FirebaseDatabase.instance.ref().child('formData').child(state.phoneNumber);
 //
 //      // Generate a new key (ref ID) for this entry
 //      final newRef = dbRef.push();
 //      final refId = newRef.key; // Get the generated key
 //
 //      // Prepare the Firebase Storage reference for the business card image
 //      final storageRef = FirebaseStorage.instance
 //          .ref()
 //          .child('business_cards/${DateTime.now().toIso8601String()}');
 //
 //      // Upload the business card image to Firebase Storage
 //      if (state.businessCardImage != null) {
 //        final uploadTask = storageRef.putFile(state.businessCardImage!);
 //        final snapshot = await uploadTask;
 //        final downloadUrl = await snapshot.ref.getDownloadURL();
 //        downloadUrlBusiness=downloadUrl;
 //
 //        // Save the form data along with the ref ID to Realtime Database
 //        await newRef.set({
 //          'refId': refId, // Save the generated ref ID here
 //          'phoneNumber': state.phoneNumber,
 //          'retailName': state.retailName,
 //          'metGM': state.metGM,
 //          'metSD': state.metSD,
 //          'interestLevel': state.interestLevel,
 //          'visitSummary': state.visitSummary,
 //          'nextAction': state.nextAction,
 //          'businessCardUrl': downloadUrl,
 //          'voiceUrl': voiceUrl,
 //          'gpsCoordinates': gpsCoordinates,
 //        });
 //      }
 //
 //      // API Call after successful Firebase submission
 //      final response = await http.post(
 //        Uri.parse('https://eu-west-1.aws.data.mongodb-api.com/app/application-2-febnp/endpoint/sendSlackNotification'),
 //        headers: {
 //          'Content-Type': 'application/json',
 //        },
 //        body: jsonEncode({
 //          'channel': 'dealervisit',
 //          'message': {
 //            'user': state.phoneNumber,
 //            'retailName': state.retailName,
 //            'time': DateTime.now().toIso8601String(),
 //            'gps': gpsCoordinates,  // Add GPS if available
 //            'metGM': state.metGM,
 //            'metSD': state.metSD,
 //            'linkToBusCard': downloadUrlBusiness,  // The URL of the uploaded business card
 //            'audioFile': voiceUrl,  // The voice URL
 //          }
 //        }),
 //      );
 //
 //      print('URL: https://eu-west-1.aws.data.mongodb-api.com/app/application-2-febnp/endpoint/sendSlackNotification');
 //
 //      // Check if the response is successful
 //      if (response.statusCode == 200) {
 //        // Successful response, continue to the next screen
 //        ScaffoldMessenger.of(context).showSnackBar(
 //          SnackBar(content: Text('Form and API Submitted Successfully'.toUpperCase(), style: GoogleFonts.quicksand(
 //            fontWeight: FontWeight.w500,
 //            color: kWhiteColor,
 //          ),)),
 //        );
 //        print('Response status: ${response.statusCode}');
 //        print('Response body: ${response.body}');
 //        // Reset the state and navigate
 //        resetState();
 //        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FormView()));
 //      } else {
 //        // Show error if the API call fails
 //        ScaffoldMessenger.of(context).showSnackBar(
 //          SnackBar(content: Text('API Error: ${response.body}'.toUpperCase(), style: GoogleFonts.quicksand(
 //            fontWeight: FontWeight.w500,
 //            color: kWhiteColor,
 //          ),)),
 //        );
 //      }
 //
 //
 //
 //
 //      // If successful, reset the state
 //      // resetState();
 //    } catch (e) {
 //      // Handle any errors during the process
 //      print("Error during form submission: $e");
 //      ScaffoldMessenger.of(context).showSnackBar(
 //        SnackBar(content: Text('Error during form submission: $e'.toUpperCase(),style: GoogleFonts.quicksand(
 //            fontWeight: FontWeight.w500
 //            ,color: kWhiteColor
 //        ),)),
 //      );
 //      // You can also show an error message to the user or log it to a service like Firebase Crashlytics
 //    } finally {
 //      // Stop the loading state, regardless of success or failure
 //      setLoading(false);
 //    }
 //  }



  Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable location services
      _showLocationServicesDisabledDialog(context);
      return null;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show a message to the user about location permissions
        _showLocationPermissionDeniedDialog(context);
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show a message to the user about permanently denied permissions
      _showLocationPermissionPermanentlyDeniedDialog(context);
      return null;
    }

    // If permissions are granted, get the position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      // Handle any errors while retrieving the location
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      return null;
    }
  }


  void _showLocationServicesDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to use this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open location settings
                Geolocator.openLocationSettings();
              },
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Denied'),
          content: Text('Please grant location permission to use this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open app settings
                Geolocator.openAppSettings();
              },
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Permanently Denied'),
          content: Text('Please grant location permission in app settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open app settings
                Geolocator.openAppSettings();
              },
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
