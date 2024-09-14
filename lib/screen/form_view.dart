import 'package:auto_services_ai_notes/utils/color_schema.dart';
import 'package:auto_services_ai_notes/utils/custom_form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common_button.dart';
import '../components/common_text_field.dart';
import '../services/audio_services.dart';
import '../utils/const_widgets.dart';
import '../view_model/form_view_model.dart';

class FormView extends ConsumerStatefulWidget {
  const FormView({super.key});

  @override
  ConsumerState<FormView> createState() => _FormViewState();
}

class _FormViewState extends ConsumerState<FormView> with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _downloadVoiceUrl;
  late AnimationController _controller;
  late Animation<double> _animation;

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _audioRecorder.initializeRecorder();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _loadUserData(); // Load user data when initializing
  }

  @override
  void dispose() {
    _audioRecorder.disposeRecorder();
    _controller.dispose();
    _userNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? '';
    final phoneNumber = prefs.getString('phoneNumber') ?? '';

    // Debug prints
    print('Loaded UserName: $userName');
    print('Loaded PhoneNumber: $phoneNumber');

    // Ensure UI update happens on main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _userNameController.text = userName;
        _phoneNumberController.text = phoneNumber;
      });
    });
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userName', userName);
  }

  Future<void> _saveUserPhone(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
  }


  void _onRecordButtonPressed() async {
    if (_audioRecorder.isRecording) {
      await _audioRecorder.stopRecording();
      String? downloadUrl = await _audioRecorder.uploadAudioFile();
      setState(() {
        _downloadVoiceUrl = downloadUrl;
      });
    } else {
      await _audioRecorder.startRecording();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final formState = ref.watch(formViewModelProvider);
    final formViewModel = ref.read(formViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: kBGDarkColor,
      appBar: AppBar(
        backgroundColor: kBGDarkColor,
        centerTitle: true,
        title: const Text('AutoService AI Notes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Add form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(
                controller: _userNameController,
                hintText: "User name",
                label: "User name",
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  formViewModel.updateUserName(value);
                  _saveUserName(_userNameController.text);
                  formViewModel.updateUserName(_userNameController.text);

                },

                validator: (value) => CFValidators.phoneNum(value), // Add validation logic
              ),
              CommonTextField(
                controller: _phoneNumberController,
                hintText: "Phone Number",
                label: "Phone Number",
                keyboardType: TextInputType.phone,
                onChanged: (value) {

                  formViewModel.updatePhoneNumber(value);
                  _saveUserPhone(_phoneNumberController.text); // Save phone number
                  formViewModel.updatePhoneNumber(_phoneNumberController.text);
                },
                validator: (value) => CFValidators.phoneNum(value), // Add validation logic
              ),
              CommonTextField(
                hintText: "Retail Name",
                label: "Retail Name",
                onChanged: (value) => formViewModel.updateRetailName(value),
                validator: (value) => CFValidators.retailName(value),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text('Met GM', style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    const Text('YES'),
                    Radio<String>(
                      value: 'YES',
                      groupValue: formState.metGM,
                      toggleable: true,
                      onChanged: (value) => formViewModel.updateMetGM(value!),
                    ),
                    const Text('NO'),
                    Radio<String>(
                      value: 'NO',
                      groupValue: formState.metGM,
                      onChanged: (value) => formViewModel.updateMetGM(value!),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text('Met SD', style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, fontSize: 20)),
                    ),
                    const Text('YES'),
                    Radio<String>(
                      value: 'YES',
                      groupValue: formState.metSD,
                      onChanged: (value) => formViewModel.updateMetSD(value!),
                    ),
                    const Text('NO'),
                    Radio<String>(
                      value: 'NO',
                      groupValue: formState.metSD,
                      onChanged: (value) => formViewModel.updateMetSD(value!),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("Interest", style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: kBlackColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: kWhiteColor)),
                    child: DropdownButton<String>(
                      underline: const SizedBox.shrink(),
                      value: formState.interestLevel.isNotEmpty ? formState.interestLevel : null,
                      hint: const Text('Interested'),
                      items: kItems,
                      onChanged: (value) => formViewModel.updateInterestLevel(value!),
                    ),
                  ),
                ],
              ),
              CommonTextField(
                validator: (value) => CFValidators.visitSummary(value),
                hintText: "Visit Summ.",
                label: "Visit Summ.",
                onChanged: (value) => formViewModel.updateVisitSummary(value),
                maxLines: 4,
              ),
              CommonTextField(
                validator: (value) => CFValidators.nextAction(value),
                hintText: "Next Action",
                label: "Next Action",
                onChanged: (value) => formViewModel.updateNextAction(value),
              ),
              const SizedBox(height: 16.0),
              voiceRecordButton(size, formViewModel),
              CommonButton(
                onPressed: () async {
                      formViewModel.updateUserName(_userNameController.text);
                      formViewModel.updatePhoneNumber(_phoneNumberController.text);

                      await formViewModel.pickBusinessCardImage(context, _downloadVoiceUrl?? '');

                },
                label: 'Click to Take Photo of Bus Card',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding voiceRecordButton(Size size, FormViewModel formModelProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _audioRecorder.isRecording ? _animation.value : 1.0,
            child: ElevatedButton(
              onPressed: _onRecordButtonPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    color: formModelProvider.isVoiceRecorded ? Colors.red.shade400 : Colors.white,
                    _downloadVoiceUrl == null ? Icons.record_voice_over : Icons.stop,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _audioRecorder.isRecording ? 'Stop Session'.toUpperCase() : 'Record Session'.toUpperCase(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
