import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

class CustomPinTextfield extends StatefulWidget {
  final double width;
  final int length;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  const CustomPinTextfield(
      {Key? key,
      this.width = 345,
      this.length = 6,
      required this.controller,
      this.onCompleted,
      this.onChanged,
      this.obscureText = false,
      this.keyboardType = TextInputType.number})
      : super(key: key);

  @override
  State<CustomPinTextfield> createState() => _CustomPinTextfieldState();
}

class _CustomPinTextfieldState extends State<CustomPinTextfield> {
  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        width: widget.width.w,
        child: PinCodeTextField(
          appContext: context,

          // pastedTextStyle: TextStyle(
          //   color: const Color(0xFFF2F2F2),
          //   fontWeight: FontWeight.bold,
          // ),
          errorTextSpace: 0,
          length: widget.length,
          obscureText: widget.obscureText,
          obscuringCharacter: '*',
          // obscuringWidget: const FlutterLogo(
          //   size: 24,
          // ),
          // blinkWhenObscuring: true,

          scrollPadding: EdgeInsets.zero,
          animationType: AnimationType.fade,
          // validator: (v) {
          //   if (v!.length < 3) {
          //     return "I'm from validator";
          //   } else {
          //     return null;
          //   }
          // },
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            selectedFillColor: const Color(0xFFF2F2F2),
            inactiveFillColor: const Color(0xFFF2F2F2),
            activeFillColor: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(6.w),
            disabledColor: const Color(0xFFF2F2F2),
            selectedColor: const Color(0xFFF2F2F2),
            activeColor: const Color(0xFFF2F2F2),
            inactiveColor: const Color(0xFFF2F2F2),
            fieldHeight: 40.w,
            fieldWidth: 40.w,
            borderWidth: 0.5,
            errorBorderColor: const Color(0xFFF2F2F2),
          ),
          cursorColor: Colors.black,
          animationDuration: const Duration(milliseconds: 200),
          enableActiveFill: true,
          // errorAnimationController:
          //     controller.errorController,
          controller: widget.controller,
          keyboardType: widget.keyboardType,

          onCompleted: widget.onCompleted,

          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          // beforeTextPaste: (text) {
          //   debugPrint("Allowing to paste $text");
          //   //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
          //   //but you can show anything you want here, like your pop up saying wrong paste format or etc
          //   return true;
          // },
        ),
      ),
    );
  }
}
