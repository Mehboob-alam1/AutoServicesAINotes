import 'package:auto_services_ai_notes/components/common_button.dart';
import 'package:auto_services_ai_notes/utils/color_schema.dart';
import 'package:auto_services_ai_notes/view_model/form_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinalRoute extends ConsumerWidget {
  const FinalRoute(this.voiceUrl, {super.key});
final String voiceUrl;
  @override
  Widget build(BuildContext context,ref) {
    final formState = ref.watch(formViewModelProvider);
    final formViewModel = ref.read(formViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: kBGDarkColor,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(formState.businessCardImage!),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: formViewModel.loading ? Center(child: CircularProgressIndicator(),) :Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonButton(onPressed: (){}, label: "Make sure the business card info is visible"),
                  CommonButton(onPressed: () async {

                    await formViewModel.submitForm(voiceUrl,context);

                  }, label: "Submit")

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
