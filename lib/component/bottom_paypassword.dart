import 'package:flutter/material.dart';
import 'package:store_plugin/third/get/get.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/component/custom_button.dart';
import 'package:store_plugin/component/custom_pin_textfield.dart';
import 'package:store_plugin/cxstore_config.dart';

import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

class BottomPayPassword {
  final Widget? centerWidget;
  final double? centerWidgetHeight;
  final Function()? closeClick;
  final BuildContext? context;
  final String? title;
  final String? subTitle;
  final String? btnTitle;
  final String? errorText;
  final bool showValue;
  final Function(String payPwd)? confirmClick;
  BottomPayPassword.init({
    this.centerWidget,
    this.closeClick,
    this.centerWidgetHeight,
    this.context,
    this.showValue = false,
    this.title = "请输入支付密码",
    this.subTitle = "为了您的交易安全，支付前请先输入平台支付密码",
    this.btnTitle = "确认",
    this.errorText = "请输入6位支付密码",
    this.confirmClick,
  }) {
    // for (var i = 0; i < pwdCtrlList.length; i++) {
    //   TextEditingController e = pwdCtrlList[i];
    //   e.addListener(() {
    //     pwdListener(e, i);
    //   });
    // }
    // pwdCtrl = TextEditingController();
    // key = GlobalKey();
    homeData = CXStoreConfig().homeData;
  }
  // late GlobalKey key;
  // TextEditingController? pwdCtrl;
  final pwdCounts = [0, 0, 0, 0, 0, 0];
  List pwdCtrlList = [];
  List pwdFocusNodeList = [];
  String pwd = "";
  Map homeData = {};

  // pwdListener(TextEditingController ctrl, int index) {
  //   if (ctrl.text.isNotEmpty && pwdCounts[index] == 0) {
  //     if (index < pwdFocusNodeList.length - 1) {
  //       FocusScope.of(context ?? Global.navigatorKey.currentContext!)
  //           .requestFocus(pwdFocusNodeList[index + 1]);
  //     }
  //   } else if (ctrl.text.isEmpty && pwdCounts[index] != 0) {
  //     if (index > 0) {
  //       FocusScope.of(context ?? Global.navigatorKey.currentContext!)
  //           .requestFocus(pwdFocusNodeList[index - 1]);
  //     }
  //   }
  //   pwdCounts[index] = ctrl.text.length;
  //   int tCount = 0;
  //   for (TextEditingController item in pwdCtrlList) {
  //     if (item.text.isNotEmpty) {
  //       tCount++;
  //     }
  //   }
  //   if (tCount == 6) {}
  // }

  show() {
    pwd = "";
    // if (pwdCtrl != null) {
    //   pwdCtrl!.dispose();
    // }
    // pwdCtrl = TextEditingController();
    // dispos();
    // initCtrl();
    Get.bottomSheet(
      SizedBox(
        width: 375.w,
        height: (344.5 + (centerWidgetHeight ?? 35)).w,
        child: Stack(
          children: [
            Positioned(
                right: 24.w,
                top: 0,
                width: 37.w,
                height: 56.5.w,
                child: CustomButton(
                  onPressed: () {
                    takeBackKeyboard(
                        CXStoreConfig.navigatorKey.currentContext!);
                    if (closeClick != null) {
                      closeClick!();
                      Navigator.pop(CXStoreConfig.navigatorKey.currentContext!);
                    } else {
                      Navigator.pop(CXStoreConfig.navigatorKey.currentContext!);
                    }
                  },
                  child: Image.asset(
                    assetsName(
                      "store/btn_model_close",
                    ),
                    width: 37.w,
                    height: 56.5.w,
                    fit: BoxFit.fill,
                    package: PLUGIN_PACKAGE,
                  ),
                )),
            Positioned(
                top: 56.5.w,
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => takeBackKeyboard(
                      CXStoreConfig.navigatorKey.currentContext!),
                  child: Container(
                    width: 375.w,
                    height: ((344.5 + (centerWidgetHeight ?? 35)) - 56.5).w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(6.w))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 49.w,
                          child: Center(
                            child: getSimpleText(
                                title ?? "", 16, AppColor.textBlack,
                                isBold: true),
                          ),
                        ),
                        gline(375, 0.5),
                        centerWidget ?? ghb(35),
                        CustomPinTextfield(
                          obscureText: !showValue,
                          controller: TextEditingController(),
                          width: 375 - 25 * 2,
                          onChanged: (v) {
                            pwd = v;
                            // debugPrint(v);
                            // if (v.length >= 6) {}
                          },
                        ),
                        ghb(30),
                        getSimpleText(subTitle ?? "", 13, AppColor.textGrey),
                        ghb(45),
                        getSubmitBtn(btnTitle ?? "", () {
                          // String text = "";
                          // for (var item in pwdCtrlList) {
                          //   text += (item.text.isEmpty ? "" : item.text);
                          // }
                          // if (text.length < 6 && errorText != null) {
                          //   ShowToast.normal(errorText!);
                          // }
                          if (confirmClick != null) {
                            // confirmClick!(pwdCtrl!.text);
                            if (pwd == null || pwd.length == 0) {
                              ShowToast.normal("请输入支付密码");
                              return;
                            } else if (pwd.length < 6) {
                              ShowToast.normal("请输入6位支付密码");
                              return;
                            } else {
                              confirmClick!(pwd);
                            }
                            Navigator.pop(
                                CXStoreConfig.navigatorKey.currentContext!);
                          }
                        }),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
    );
  }

  dispos() {
    // for (var i = 0; i < pwdCtrlList.length; i++) {
    //   TextEditingController e = pwdCtrlList[i];
    //   FocusNode n1 = pwdFocusNodeList[i];
    //   if (e != null) {
    //     e.removeListener(() {});
    //     e.dispose();
    //   }
    //   if (n1 != null) {
    //     n1.dispose();
    //   }
    // }
    // if (pwdCtrl != null) {
    //   pwdCtrl!.dispose();
    // }
  }

  initCtrl() {
    // pwdCtrlList = [
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    //   TextEditingController(),
    // ];
    // pwdFocusNodeList = [
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode(),
    //   FocusNode()
    // ];
    // for (var i = 0; i < pwdCtrlList.length; i++) {
    //   TextEditingController e = pwdCtrlList[i];
    //   e.addListener(() {
    //     pwdListener(e, i);
    //   });
    //   pwdCounts[i] = 0;
    // }
    // pwdCtrl == TextEditingController();
  }
}
