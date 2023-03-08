import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';
import 'package:store_plugin/tools.dart';

class CustomInput extends StatefulWidget {
  final double? width;
  final double? heigth;
  final Function(String str)? onEditingComplete;
  final Function(String str)? onChange;
  final TextInputType? keyboardType;
  final String? placeholder;
  final bool? showValue;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final TextAlignVertical? textAlignVertical;
  final StrutStyle? strutStyle;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;
  final TextEditingController? textEditCtrl;
  final bool? autofocus;
  final String amend;
  final bool readOnly;
  final double? cursorHeight;
  final bool? enable;

  const CustomInput({
    Key? key,
    this.textEditCtrl,
    this.strutStyle,
    this.focusNode,
    this.heigth = 50,
    this.width = 345,
    this.autofocus = false,
    this.placeholderStyle,
    this.showValue = true,
    this.keyboardType,
    this.onChange,
    this.onEditingComplete,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.maxLength,
    this.cursorHeight,
    this.textInputAction,
    this.onSubmitted,
    this.amend = "测试",
    this.placeholder,
    this.enable = true,
    this.readOnly = false,
    this.padding = const EdgeInsets.all(0),
    this.textAlignVertical,
  }) : super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  String inputString = "";
  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        width: widget.width,
        height: widget.heigth,
        child: CupertinoTextField(
          readOnly: widget.readOnly,
          enabled: widget.enable,
          autofocus: widget.autofocus ?? false,
          strutStyle: widget.strutStyle,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          cursorHeight: widget.cursorHeight ??
              calculateTextHeight(
                  widget.amend,
                  widget.style != null && widget.style!.fontSize != null
                      ? widget.style!.fontSize!
                      : 15.sp,
                  widget.style != null && widget.style!.fontWeight != null
                      ? widget.style!.fontWeight!
                      : FontWeight.normal,
                  double.infinity,
                  1,
                  context,
                  color: AppColor.textBlack),

          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          placeholderStyle: widget.placeholderStyle ??
              TextStyle(color: const Color(0xFFBBBBBB), fontSize: 15.sp),
          obscureText: widget.showValue != null ? !widget.showValue! : false,
          controller: widget.textEditCtrl,
          textAlign: widget.textAlign!,
          textAlignVertical: widget.textAlignVertical,
          style: widget.style ??
              TextStyle(color: AppColor.textBlack, fontSize: 15.sp),
          decoration:
              const BoxDecoration(color: Colors.transparent, border: Border()),
          padding: widget.padding,

          // obscureText: true,
          placeholder: widget.placeholder,
          maxLength: widget.maxLength,
          maxLines: widget.showValue != null && widget.showValue != true
              ? 1
              : widget.maxLines,
          // maxLines: 1,
          // clearButtonMode: OverlayVisibilityMode.always,
          onChanged: (value) {
            if (widget.onChange != null) {
              widget.onChange!(inputString);
            }
            inputString = value;
            // checkLogin();
          },
          onEditingComplete: () {
            if (widget.onEditingComplete != null) {
              widget.onEditingComplete!(inputString);
            }
          },
          onSubmitted: (value) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!(value);
            } else {
              takeBackKeyboard(context);
            }
          },
        ),
      ),
    );
  }
}
