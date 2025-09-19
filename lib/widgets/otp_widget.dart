import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPWidget extends StatelessWidget {
  final TextEditingController otpController;

  const OTPWidget({super.key, required this.otpController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: PinCodeTextField(
        textStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        appContext: context,
        length: 6,
        onChanged: (value) {
          // Handle OTP value change
        },
        onCompleted: (value) {
          otpController.text = value;
        },
        controller: otpController,
        keyboardType: TextInputType.number,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(15),
          fieldHeight: 50,
          fieldWidth: 40,
          selectedColor: Colors.red,
          inactiveColor: Colors.grey,
          activeColor: Colors.white,
          activeFillColor: Colors.white,
          selectedFillColor: Colors.white,
        ),
      ),
    );
  }
}
