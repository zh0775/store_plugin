import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:store_plugin/EventBus.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/component/custom_button.dart';
import 'package:store_plugin/component/product_pay_result_page.dart';
import 'package:store_plugin/notify_default.dart';
import 'package:store_plugin/page/mine_store_order_detail.dart';
import 'package:store_plugin/service/http.dart';
import 'package:store_plugin/service/urls.dart';
import 'package:store_plugin/service/user_default.dart';
import 'dart:convert' as convert;
import 'package:intl/intl.dart';
import 'package:store_plugin/third/get/get.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/js.dart' as js;

const String APP_SPLASH_ENABLE = "app_splash_enable";
const String PLUGIN_PACKAGE = "store_plugin";

const String HOME_DATA = "app_home_data";

const String PUBLIC_HOME_DATA = "app_public_home_data";

const String LOGIN_DATA = "app_login_data";

const String USER_TOKEN = "app_user_token";

const String INTEGRAL_STORE_SEARCH_HISTORY =
    "app_integral_store_search_history";

const String HOME_BUSINESS_DATA_STORAGE = "home_business_data_storage";
const String HOME_PRODUCT_DATA_STORAGE = "home_product_data_storage";
const String HOME_INTEGRAL_DATA_STORAGE = "home_integral_data_storage";

class CXStoreConfig {
  static Color pageBackgroundColor = const Color(0xFFF7F7F7);
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String projectName = "标板2.0";

  static const bool isDebug = true;
  static const FontWeight fontBold = FontWeight.w600;
  static const String fromDate = "2022-11-09 09:00:00";
  static const int appDelay = 0;
  static CXStoreConfig? _instance;
  factory CXStoreConfig() => _instance ?? CXStoreConfig.init();

  CXStoreConfig.init() {
    versionOrigin = kIsWeb
        ? 3
        : Platform.isIOS
            ? 2
            : 1;
    // PlatformDeviceId.getDeviceId.then((value) {
    //   deviceId = value!;
    // });
    // checkDay = checkDateForDay();
    _instance = this;
  }
  Map homeData = {};
  int versionOrigin = 0;
  String deviceId = "";

  bool checkDay = false;
  bool safeAlert = true;
  Map publicHomeData = {};
  String imageView = "";
  Map loginData = {};
  bool loginStatus = true;
  String imageUrl = "";
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String token = "";
  String baseUrl = "";
  bool needChangeTheme = true;
  // String lotteryUrl = "";
  // String privacyUrls = "";
  Map updateData = {};
  bool firstAlertFromLogin = false;
  List themeColorList = [];
  int versionOriginForPay() {
    return kIsWeb
        ? 2
        : Platform.isAndroid
            ? 1
            : 2;
    // return 1;
  }

  setThemeColorList() {
    if (publicHomeData.isEmpty || !needChangeTheme) {
      // themeColorList = [];
      return;
    }
    List colorList = ((publicHomeData["versionInfo"] ?? {})["theme"] ??
            {})["themeColorList"] ??
        [];
    themeColorList = colorList.map((e) {
      String colorStr = e["color"];
      int transparency = ((e["transparency"] as double) / 100 * 255).ceil();

      colorStr = colorStr.substring(1);
      String opacity = transparency.toRadixString(16);
      String colorHex = "0x$opacity$colorStr";
      return colorHex;
    }).toList();
  }

  Color? getThemeColor({int index = 0}) {
    if (themeColorList.isNotEmpty && themeColorList.length > index) {
      int? hex = int.tryParse(themeColorList[index]);
      return hex != null ? Color(hex) : null;
    } else {
      return null;
    }
  }
}

Widget gline(double width, double height, {Color? color}) {
  return Container(
    width: width.w,
    height: height,
    color: color ?? AppColor.lineColor,
  );
}

// void callPhone(String phone) {
//   if (phone != null) {
//     if (AppDefault.isDebug) {
//       print('拨打电话--tel://$phone');
//     }

//     launchUrl(Uri(
//       scheme: 'tel',
//       path: phone,
//     ));
//   }
// }

String hidePhoneNum(String? phone) {
  if (phone == null) {
    return "";
  }
  if (phone.length < 7) {
    if (phone.length < 3) {
      return "****";
    }
    return phone.substring(0, 3) + "****";
  }
  return phone.replaceRange(3, 7, "****");
}

void push(dynamic widget, BuildContext? context,
    {String setName = "", Bindings? binding}) {
  if (binding != null) {
    Get.to(widget, binding: binding);
  } else {
    Navigator.of(context ?? CXStoreConfig.navigatorKey.currentContext!)
        .push(CupertinoPageRoute(
            settings: RouteSettings(name: setName),
            builder: (_) {
              return widget;
            }));
  }
}

// void toScanBarCode(Function(String barCode) barcodeCallBack) {
//   Get.to(
//       AppScanBarcode(
//         barcodeCallBack: barcodeCallBack,
//       ),
//       binding: AppScanBarcodeBinding(),
//       transition: Transition.fadeIn);
// }

bool isLoginRoute() {
  return (Get.currentRoute.contains("UserLogin") ||
      Get.currentRoute.contains("UserRegist") ||
      Get.currentRoute.contains("ForgetPwd") ||
      Get.currentRoute.contains("UserAgreementView"));
}

void toLogin({bool allowBack = false}) {
  if (isLoginRoute()) {
    return;
  }
  print("Get.currentRoute === ${Get.currentRoute}");
}

void toPayResult<T>({
  OrderResultType type = OrderResultType.orderResultTypePackage,
  StoreOrderType orderType = StoreOrderType.storeOrderTypePackage,
  Map<dynamic, dynamic> orderData = const {},
  bool success = true,
  String subContent = "",
  bool offUntil = true,
  bool toOrderDetail = false,
}) {
  if (offUntil) {
    Get.offUntil(
        GetPageRoute(
          page: () => toOrderDetail
              ? MineStoreOrderDetail(
                  orderType: orderType,
                  data: orderData,
                )
              : ProductPayResultPage(
                  type: type,
                  orderData: orderData,
                  success: success,
                  subContent: subContent),
          binding: toOrderDetail
              ? MineStoreOrderDetailBinding()
              : ProductPayResultPageBinding(),
        ), (route) {
      if (route is GetPageRoute) {
        if (route.binding is T) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    });
  } else {
    Get.to(
        toOrderDetail
            ? MineStoreOrderDetail(
                orderType: orderType,
                data: orderData,
              )
            : ProductPayResultPage(
                type: type,
                orderData: orderData,
                success: success,
                subContent: subContent),
        binding: toOrderDetail
            ? MineStoreOrderDetailBinding()
            : ProductPayResultPageBinding());
  }
}

void popToUntil<T>({Widget? page, Bindings? binding, T? popTo}) {
  bus.emit(NOTIFY_BACK_TO_MAIN_PLUGIN);
}

AppBar getDefaultAppBar(
  BuildContext context,
  String title, {
  Widget? leading,
  List<Widget>? action,
  double elevation = 0,
  Color color = Colors.transparent,
  Color shadowColor = Colors.transparent,
  TextStyle? titleStyle,
  Widget? flexibleSpace,
  bool blueBackground = false,
  SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle.dark,
  Function()? backPressed,
  bool white = false,
}) {
  return AppBar(
    centerTitle: true,
    elevation: elevation,
    systemOverlayStyle:
        white ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    shadowColor: shadowColor,
    backgroundColor: color,
    flexibleSpace: flexibleSpace == null && blueBackground
        ? Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              CXStoreConfig().getThemeColor() ?? const Color(0xFF6796F5),
              CXStoreConfig().getThemeColor(index: 2) ??
                  const Color(0xFF2368F2),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          )
        : flexibleSpace,
    // shadowColor: const Color(0xFFFFFEE0),
    title: getDefaultAppBarTitile(title, titleStyle: titleStyle, white: white),

    leading: leading ??
        defaultBackButton(context, backPressed: backPressed, white: white),
    actions: action ?? [],
  );
}

Widget getDefaultAppBarTitile(String title,
    {TextStyle? titleStyle, bool white = false}) {
  return getSimpleText(
      title,
      titleStyle != null ? titleStyle.fontSize! : 18,
      titleStyle != null
          ? titleStyle.color!
          : (white ? Colors.white : AppColor.textBlack2),
      isBold:
          titleStyle != null && titleStyle.fontWeight != CXStoreConfig.fontBold
              ? false
              : false,
      fw: titleStyle != null && titleStyle.fontWeight != null
          ? titleStyle.fontWeight
          : null);
}

String snNoFormat(String sn) {
  String formatSn = "";
  if (sn.isNotEmpty) {
    String substring = sn;
    int i = 0;
    int length = 5;
    while (substring.length > length) {
      switch (i) {
        case 0:
          length = 5;
          break;
        case 1:
          length = 6;
          break;
        case 2:
          length = 5;
          break;
        case 3:
          length = 4;
          break;
        default:
          length = 4;
      }
      String tmp =
          substring.substring(substring.length - length, substring.length);

      formatSn = i == 0 ? tmp : "$tmp $formatSn";

      substring = substring.substring(0, substring.length - length);
      i++;
    }

    if (substring.isNotEmpty) {
      formatSn = "$substring $formatSn";
    }

    return formatSn;
  }
  return formatSn;
}

Widget getTerminalNoText(String terminalNo,
    {TextStyle? highlightStyle, TextStyle? style}) {
  List<Widget> texts = [];
  List<Widget> returnWidget = [];
  TextStyle hStyle = highlightStyle ??
      TextStyle(
        fontSize: 16.sp,
        color: const Color(
          0xFFEB5757,
        ),
        fontWeight: CXStoreConfig.fontBold,
      );
  TextStyle nStyle = highlightStyle ??
      TextStyle(
        fontSize: 16.sp,
        color: AppColor.textBlack,
        fontWeight: CXStoreConfig.fontBold,
      );

  if (terminalNo.isNotEmpty) {
    String substring = terminalNo;
    int i = 0;
    int length = 5;

    while (substring.length > length) {
      switch (i) {
        case 0:
          length = 5;
          break;
        case 1:
          length = 6;
          break;
        case 2:
          length = 5;
          break;
        case 3:
          length = 4;
          break;
        default:
          length = 4;
      }
      String tmp =
          substring.substring(substring.length - length, substring.length);

      texts.add(Text(
        tmp,
        style: i == 0 ? hStyle : nStyle,
      ));

      texts.add(gwb(5));
      substring = substring.substring(0, substring.length - length);
      i++;
    }
    if (substring.isNotEmpty) {
      texts.add(Text(
        substring,
        style: nStyle,
      ));
    } else {
      texts.removeLast();
    }

    for (var i = texts.length - 1; i >= 0; i--) {
      returnWidget.add(texts[i]);
    }
  }
  return centRow(returnWidget);
}

String assetsName(String img, {String suffix = "png"}) {
  return "icons/images/$img.$suffix";
}

String addZero(dynamic num) {
  if (num == null) {
    return "";
  }
  late int n;
  if (num is int) {
    n = num;
  } else if (num is double) {
    n = num.ceil();
  } else if (num is String) {
    n = int.parse(num);
  }
  if (n < 10) {
    return "0$n";
  } else {
    return "$n";
  }
}

Widget getInputSubmitBody(BuildContext context, String title,
    {Function()? onPressed,
    List<Widget>? children,
    double? marginTop,
    double? fromTop,
    Color? contentColor,
    double? buttonHeight,
    Widget Function(double boxHeight, BuildContext context)? build}) {
  return Builder(
    builder: (context) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ghb(marginTop ?? 0),
            getRealityBody(context,
                children: children,
                buttonHeight: buttonHeight,
                marginTop: marginTop,
                contentColor: contentColor,
                fromTop: fromTop,
                build: build),
            getBottomBlueSubmitBtn(context, title, onPressed: onPressed)
          ],
        ),
      );
    },
  );
}

Widget getInputBodyNoBtn(BuildContext context,
    {List<Widget>? children,
    double? marginTop,
    Color? contentColor,
    Widget? submitBtn,
    double? buttonHeight = 80,
    double? fromTop,
    Widget Function(double boxHeight, BuildContext context)? build}) {
  return Builder(
    builder: (context) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ghb(marginTop ?? 0),
            getRealityBody(context,
                children: children,
                marginTop: marginTop,
                buttonHeight: buttonHeight ?? 80,
                contentColor: contentColor,
                fromTop: fromTop,
                build: build),
            submitBtn ?? const SizedBox(),
          ],
        ),
      );
    },
  );
}

Widget getBottomBlueSubmitBtn(BuildContext context, String title,
    {Function()? onPressed, bool enalble = true}) {
  return Container(
    width: 375.w,
    height: 80.w + paddingSizeBottom(context),
    color: Colors.white,
    padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
    child: Center(
      child: getSubmitBtn(title, onPressed ?? () {}, enable: enalble),
    ),
  );
}

Widget getRealityBody(BuildContext context,
    {List<Widget>? children,
    double? marginTop,
    double? fromTop,
    Color? contentColor,
    double? buttonHeight,
    Widget Function(double boxHeight, BuildContext context)? build}) {
  double screenHeight = ScreenUtil().screenHeight;

  double appBarMaxHeight = (Scaffold.of(context).appBarMaxHeight ?? 0);

  double btnHeight = buttonHeight ?? (80.w + paddingSizeBottom(context));

  // double paddingBottom = paddingSizeBottom(context);
  double paddingBottom = 0;

  double tMargin = (marginTop != null ? marginTop.w : 0);
  double topSpace = (fromTop != null ? fromTop.w : 0);

  double boxHeight = screenHeight -
      appBarMaxHeight -
      btnHeight -
      paddingBottom -
      tMargin -
      topSpace;

  return Container(
      color: contentColor ?? AppColor.pageBackgroundColor,
      width: 375.w,
      height: boxHeight,
      child: children != null
          ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: children,
              ),
            )
          : build != null
              ? build(boxHeight, context)
              : Container());
}

Widget assetsSizeImage(String img, double width, double height) {
  return Image.asset(assetsName(img),
      width: width.w,
      height: height.w,
      fit: BoxFit.fill,
      package: PLUGIN_PACKAGE);
}

String integralFormat(dynamic num) {
  if (num == null || (num is String && num.isEmpty)) {
    return "0";
  }
  if (num is int) {
    return "$num";
  } else if (num is double) {
    List tmpList = "$num".split(".");
    if (tmpList.length > 1) {
      if (int.parse(tmpList[1]) > 0) {
        return "$num";
      } else if (int.parse(tmpList[1]) == 0) {
        return "${tmpList[0]}";
      }
    }
  } else if (num is String) {
    double e = double.parse(num);
    List tmpList = "$e".split(".");
    if (tmpList.length > 1) {
      if (int.parse(tmpList[1]) > 0) {
        return "$e";
      } else if (int.parse(tmpList[1]) == 0) {
        return "${tmpList[0]}";
      }
    }
  }
  return "$num";
}

void copyClipboard(String text,
    {bool needToast = true, String toastText = "已复制"}) {
  Clipboard.setData(ClipboardData(text: text));
  if (needToast) {
    ShowToast.normal(toastText);
  }
}

Widget defaultBackButton(BuildContext context,
    {Color? color,
    Function()? backPressed,
    double? width,
    bool white = false}) {
  return CustomButton(
    onPressed: () {
      if (backPressed != null) {
        backPressed();
      } else {
        Navigator.pop(context);
      }
    },
    child: SizedBox(
      width: width ?? (16 + 16).w,
      height: kToolbarHeight,
      child: Align(
          alignment: Alignment.centerRight,
          child: Image.asset(
            assetsName(white
                ? "store/btn_navigater_back_white"
                : "store/btn_navigater_back"),
            height: 16.w,
            // width: 16.w,
            fit: BoxFit.fitHeight,
            package: PLUGIN_PACKAGE,
          )),
    ),
  );
}

showAppUpdateAlert(Map data, {Function()? close}) {
  if (data != null && data.isNotEmpty) {
    Map d = data;
    if (d["isShow"] != null && d["isShow"] == false) {
      return;
    }
    bool isDownload = d["isDownload"] ?? false;
    // bool isDownload = false;

    // // String? name = ModalRoute.of(context!)!.settings.name;
    // print("Get.currentRoute === ${Get.currentRoute}");
    // if (Get.currentRoute.contains("appUpdateAlert")) {
    //   return;
    // }
    showGeneralDialog(
      barrierLabel: "",
      routeSettings: const RouteSettings(name: "appUpdateAlert"),
      context: CXStoreConfig.navigatorKey.currentContext!,
      pageBuilder: (context, animation, secondaryAnimation) {
        return UnconstrainedBox(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 260.w,
              child: Container(
                width: 260.w,
                // height: 200.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.w)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50.w,
                      child: Center(
                        child: getSimpleText("更新提示", 16, AppColor.textBlack,
                            isBold: true),
                      ),
                    ),
                    gline(250, 0.5),
                    ghb(10),
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: getSimpleText(
                          "您有新的版本可以更新，V${d["newVersionNumber"] ?? ""}",
                          15,
                          AppColor.textBlack,
                          maxLines: 1000),
                    ),
                    // getContentText(
                    //     "您有新的版本可以更新，V${d["newVersionNumber"] ?? ""}",
                    //     15,
                    //     AppColor.textBlack,
                    //     200,
                    //     80,
                    //     3,
                    //     alignment: Alignment.topLeft),
                    ghb(9.5),
                    gline(250, 0.5),
                    centRow([
                      CustomButton(
                        onPressed: () async {
                          String urlStr = d["newVersionDownloadUrl"] ?? "";
                          if (urlStr.isEmpty) {
                            Navigator.pop(context);
                            return;
                          }
                          bool lanuch = await launchUrl(Uri.parse(urlStr),
                              mode: LaunchMode.externalApplication);
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          width: 124.75.w,
                          height: 50.w,
                          child: Center(
                            child: getSimpleText("确定", 16, AppColor.textBlack,
                                isBold: true),
                          ),
                        ),
                      ),
                      !isDownload ? gline(0.5, 30) : gwb(0),
                      !isDownload
                          ? CustomButton(
                              onPressed: () {
                                simpleRequest(
                                  url: Urls.closeTodayUpdateVersion,
                                  params: {
                                    "userVersionNumber": CXStoreConfig().version
                                  },
                                  success: (success, json) {},
                                  after: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              child: SizedBox(
                                width: 124.75.w,
                                height: 50.w,
                                child: Center(
                                  child: getSimpleText(
                                    "取消",
                                    16,
                                    AppColor.textBlack,
                                  ),
                                ),
                              ),
                            )
                          : gwb(0),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if (close != null) {
        close();
      }
    });
  }
}

showReminderAlert({
  bool haveClose = true,
  String content = "",
  String subContent = "",
  String btnTitle = "",
  bool untilToRoot = true,
  required Widget page,
  required Bindings binding,
  Function()? routeAction,
  Function()? close,
  Function()? closePress,
  barrierDismissible = false,
}) {
  showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    barrierColor: Colors.black.withOpacity(.5),
    context: CXStoreConfig.navigatorKey.currentContext!,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: SizedBox(
          width: 300.w,
          height: 360.w + (haveClose ? 56.5.w : 0),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                haveClose
                    ? CustomButton(
                        onPressed: closePress ??
                            () {
                              Navigator.pop(context);
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
                      )
                    : ghb(0),
                SizedBox(
                  width: 300.w,
                  height: 360.w,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Image.asset(
                        assetsName("store/bg_needauth_alert"),
                        width: 300.w,
                        height: 360.w,
                        fit: BoxFit.fill,
                        package: PLUGIN_PACKAGE,
                      )),
                      Positioned.fill(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          getSimpleText(content, 25, AppColor.textBlack,
                              isBold: true),
                          ghb(12),
                          getWidthText(
                              subContent, 14, AppColor.textGrey, 237.w, 2,
                              textAlign: TextAlign.center),
                          ghb(15),
                          CustomButton(
                            onPressed: () {
                              if (routeAction != null) {
                                routeAction();
                              } else {
                                if (untilToRoot) {
                                  popToUntil(page: page, binding: binding);
                                } else {
                                  Get.back();
                                  Get.to(page, binding: binding);
                                }
                              }
                            },
                            child: Container(
                              width: 240.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF4282EB),
                                        Color(0xFF5BA3F7),
                                      ]),
                                  borderRadius: BorderRadius.circular(20.w)),
                              child: Center(
                                child: getSimpleText(btnTitle, 16, Colors.white,
                                    isBold: true),
                              ),
                            ),
                          ),
                          ghb(24.5)
                        ],
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).then((value) {
    if (close != null) {
      close();
    }
  });
}

// showAuthAlert({
//   required BuildContext context,
//   required bool isAuth,
//   Function()? close,
//   bool haveClose = true,
//   bool alipay = false,
//   barrierDismissible = false,
// }) {
//   String content = "";
//   String subContent = "";
//   String btnTitle = "";
//   Widget page;
//   Bindings binding;
//   if (alipay) {
//     content = "支付宝绑定提醒";
//     subContent = "您目前没有绑定支付宝账户，您需要完成绑定支付宝账户才能使用更多功能";
//     btnTitle = "立即绑定";
//     page = const IdentityAuthenticationAlipay();
//     binding = IdentityAuthenticationAlipayBinding();
//   } else {
//     if (isAuth) {
//       content = "实名认证提醒";
//       subContent = "您目前是未实名认证用户，您需要完成实名认证才能使用更多功能";
//       btnTitle = "立即认证";
//       page = const IdentityAuthentication();
//       binding = IdentityAuthenticationBinding();
//     } else {
//       content = "绑定结算卡提醒";
//       subContent = "您目前未绑定结算卡，您需要绑定结算卡才能使用更多功能";
//       btnTitle = "立即绑卡";
//       page = const DebitCardManager();
//       binding = DebitCardManagerBinding();
//     }
//   }

//   showReminderAlert(
//       close: close,
//       content: content,
//       subContent: subContent,
//       btnTitle: btnTitle,
//       page: page,
//       haveClose: haveClose,
//       binding: binding,
//       barrierDismissible: barrierDismissible);
// }

// showPayPwdWarn({
//   Function()? close,
//   Function()? closePress,
//   bool haveClose = false,
//   bool popToRoot = true,
//   bool untilToRoot = true,
//   Function()? setSuccess,
//   Function()? noSetBack,
// }) {
//   showReminderAlert(
//       close: close,
//       closePress: closePress,
//       content: "设置支付密码提醒",
//       subContent: "您目前未设置支付密码，您需要设置支付密码才能使用更多功能",
//       btnTitle: "立即设置",
//       untilToRoot: untilToRoot,
//       page: MineVerifyIdentity(
//         type: MineVerifyIdentityType.setPayPassword,
//         popToRoot: popToRoot,
//         setSuccess: setSuccess,
//         noSetBack: noSetBack,
//       ),
//       binding: MineVerifyIdentityBinding(),
//       haveClose: haveClose);
// }

showNewsAlert(
    {required BuildContext context,
    Map newData = const {},
    Function()? close,
    barrierDismissible = false}) {
  showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    barrierColor: Colors.black.withOpacity(.5),
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return UnconstrainedBox(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: 300.w,
              height: 360.w + 56.5.w,
              child: Column(
                children: [
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                  ),
                  SizedBox(
                    width: 300.w,
                    height: 360.w,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment(0, 0),
                                  colors: [Color(0xFFE6EAFC), Colors.white])),
                        )),
                        Positioned.fill(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            centClm([
                              ghb(15),
                              getSimpleText(newData["title"] ?? "", 25,
                                  AppColor.textBlack,
                                  isBold: true),
                              ghb(15),
                              getWidthText(newData["n_Meta"] ?? "", 14,
                                  AppColor.textBlack, 237.w, 100,
                                  alignment: Alignment.topLeft,
                                  textAlign: TextAlign.start),
                            ]),
                            CustomButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Container(
                                width: 240.w,
                                height: 40.w,
                                margin: EdgeInsets.only(bottom: 20.w),
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF4282EB),
                                          Color(0xFF5BA3F7),
                                        ]),
                                    borderRadius: BorderRadius.circular(20.w)),
                                child: Center(
                                  child: getSimpleText("知道了", 16, Colors.white,
                                      isBold: true),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  ).then((value) {
    if (close != null) {
      close();
    }
  });
}

Widget gemp() {
  return const Align(
      child: SizedBox(
    width: 0,
    height: 0,
  ));
}

// saveImageToAlbum(Uint8List? imageBytes) async {
//   if (imageBytes != null) {
//     final result = await ImageGallerySaver.saveImage(imageBytes, quality: 100);
//     if (result['isSuccess']) {
//       ShowToast.normal("保存成功");
//     } else {
//       ShowToast.normal("保存失败");
//     }
//   }
// }

showCustomDialog(String title,
    {String confirmText = "确定",
    String cancelText = "取消",
    TextStyle? titleStyle,
    TextStyle? confirmStyle,
    TextStyle? cancelStyle,
    Function()? confirmOnPressed,
    Function()? cancelOnPressed}) {
  Get.dialog(Material(
    color: Colors.transparent,
    child: Center(
      child: Container(
        width: 225.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12.w)),
        child: Column(
          children: [
            ghb(15),
            getWidthText(
                title,
                titleStyle != null && titleStyle.fontSize != null
                    ? titleStyle.fontSize!
                    : 17,
                titleStyle != null && titleStyle.color != null
                    ? titleStyle.color!
                    : AppColor.textBlack,
                225 - 15 * 2,
                1000,
                isBold: titleStyle != null && titleStyle.fontWeight != null
                    ? (titleStyle.fontWeight! == CXStoreConfig.fontBold
                        ? true
                        : false)
                    : true,
                fw: titleStyle != null && titleStyle.fontWeight != null
                    ? titleStyle.fontWeight
                    : null),
            ghb(15),
            gline(225, 0.5),
            Row(
              children: [
                CustomButton(
                  onPressed: () {
                    if (cancelOnPressed != null) {
                      cancelOnPressed();
                    } else {
                      Get.back();
                    }
                  },
                  child: SizedBox(
                    width: (225 / 2 - 0.1 - 0.25).w,
                    height: 45.w,
                    child: Center(
                      child: getSimpleText(
                          cancelText,
                          cancelStyle != null && cancelStyle.fontSize != null
                              ? cancelStyle.fontSize!
                              : 15,
                          cancelStyle != null && cancelStyle.color != null
                              ? cancelStyle.color!
                              : AppColor.textGrey2,
                          isBold: cancelStyle != null &&
                                  cancelStyle.fontWeight != null
                              ? (cancelStyle.fontWeight! ==
                                      CXStoreConfig.fontBold
                                  ? true
                                  : false)
                              : false),
                    ),
                  ),
                ),
                gline(0.5, 45),
                CustomButton(
                  onPressed: () {
                    if (confirmOnPressed != null) {
                      confirmOnPressed();
                    } else {
                      Get.back();
                    }
                  },
                  child: SizedBox(
                    width: (225 / 2 - 0.1 - 0.25).w,
                    height: 45.w,
                    child: Center(
                      child: getSimpleText(
                          confirmText,
                          confirmStyle != null && confirmStyle.fontSize != null
                              ? confirmStyle.fontSize!
                              : 15,
                          confirmStyle != null && confirmStyle.color != null
                              ? confirmStyle.color!
                              : AppColor.textGrey2,
                          isBold: confirmStyle != null &&
                                  confirmStyle.fontWeight != null
                              ? (confirmStyle.fontWeight! ==
                                      CXStoreConfig.fontBold
                                  ? true
                                  : false)
                              : false),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  ));
}

showAlert(BuildContext context, String title,
    {String confirmText = "确定",
    String cancelText = "取消",
    TextStyle? titleStyle,
    TextStyle? confirmStyle,
    TextStyle? cancelStyle,
    Function()? confirmOnPressed,
    Function()? cancelOnPressed}) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: SizedBox(
          width: 225.w,
          // getSimpleText(
          //     title,
          //     titleStyle != null && titleStyle.fontSize != null
          //         ? titleStyle.fontSize!
          //         : 17,
          //     titleStyle != null && titleStyle.color != null
          //         ? titleStyle.color!
          //         : AppColor.textBlack,
          // isBold: titleStyle != null && titleStyle.fontWeight != null
          //     ? (titleStyle.fontWeight! == FontWeight.bold ? true : false)
          //     : true),
          child: getWidthText(
              title,
              titleStyle != null && titleStyle.fontSize != null
                  ? titleStyle.fontSize!
                  : 17,
              titleStyle != null && titleStyle.color != null
                  ? titleStyle.color!
                  : AppColor.textBlack,
              225,
              1000,
              isBold: titleStyle != null && titleStyle.fontWeight != null
                  ? (titleStyle.fontWeight! == CXStoreConfig.fontBold
                      ? true
                      : false)
                  : true,
              fw: titleStyle != null && titleStyle.fontWeight != null
                  ? titleStyle.fontWeight
                  : null),
        ),
        actions: [
          CupertinoDialogAction(
            child: getSimpleText(
                cancelText,
                cancelStyle != null && cancelStyle.fontSize != null
                    ? cancelStyle.fontSize!
                    : 15,
                cancelStyle != null && cancelStyle.color != null
                    ? cancelStyle.color!
                    : AppColor.textGrey2,
                isBold: cancelStyle != null && cancelStyle.fontWeight != null
                    ? (cancelStyle.fontWeight! == CXStoreConfig.fontBold
                        ? true
                        : false)
                    : false),
            onPressed: () {
              if (cancelOnPressed != null) {
                cancelOnPressed();
              }
              bus.emit(NOTIFY_BACK_TO_MAIN_PLUGIN);
              // Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              if (confirmOnPressed != null) {
                confirmOnPressed();
              }
              bus.emit(NOTIFY_BACK_TO_MAIN_PLUGIN);
              // Navigator.of(context).pop();
            },
            child: getSimpleText(
                confirmText,
                confirmStyle != null && confirmStyle.fontSize != null
                    ? confirmStyle.fontSize!
                    : 15,
                confirmStyle != null && confirmStyle.color != null
                    ? confirmStyle.color!
                    : AppColor.textGrey2,
                isBold: confirmStyle != null && confirmStyle.fontWeight != null
                    ? (confirmStyle.fontWeight! == CXStoreConfig.fontBold
                        ? true
                        : false)
                    : false),
          ),
        ],
      );
    },
  );
}

bool checkDateForDay() {
  DateTime now = DateTime.now();
  DateTime before =
      DateFormat("yyyy-MM-dd HH:mm:ss").parse(CXStoreConfig.fromDate);
  before = before.add(const Duration(days: CXStoreConfig.appDelay));
  return now.isAfter(before);
}

SizedBox ghb(double height) {
  return SizedBox(
    height: height.w,
  );
}

SizedBox gwb(double width) {
  return SizedBox(
    width: width.w,
  );
}

simpleRequest(
    {required String url,
    required Map<String, dynamic> params,
    required Function(bool success, dynamic json) success,
    required Function() after,
    CancelToken? cancelToken,
    dynamic otherData,
    bool useCache = false}) {
  if (useCache) {
    UserDefault.get(url + convert.jsonEncode(params)).then((value) {
      if (value != null) {
        success(true, convert.jsonDecode(value));
      }
    });
  }
  Http().doPost(
    url,
    params,
    cancelToken: cancelToken,
    otherData: otherData,
    success: (json) {
      if (json is String) {
        success(false, json);
        return;
      }
      if (json["success"]) {
        if (useCache) {
          UserDefault.saveStr(
              url + convert.jsonEncode(params), convert.jsonEncode(json));
        }
        success(true, json);
      } else {
        success(false, json);
      }
    },
    fail: (reason, code, json) {
      success(false, json);
    },
    after: () {
      after();
    },
  );
}

Widget sbRow(
  List<Widget> children, {
  double? width,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
}) {
  return SizedBox(
    width: width != null ? width.w : 345.w,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    ),
  );
}

Widget sbhRow(
  List<Widget> children, {
  double? width,
  double? height,
}) {
  return SizedBox(
    width: width != null ? width.w : 345.w,
    height: height == null ? 30.w : height.w,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    ),
  );
}

Column centClm(
  List<Widget> children, {
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: crossAxisAlignment,
    mainAxisSize: MainAxisSize.min,
    children: children,
  );
}

Widget sbClm(
  List<Widget> children, {
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceBetween,
  double height = 200,
}) {
  return SizedBox(
    height: height.w,
    child: Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    ),
  );
}

Widget sbwClm(
  List<Widget> children, {
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  double height = 200,
  double width = 100,
}) {
  return SizedBox(
    height: height.w,
    width: width.w,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    ),
  );
}

Row centRow(List<Widget> children,
    {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: children,
    crossAxisAlignment: crossAxisAlignment,
  );
}

// AppBar getMainAppBar(int index,
//     {Widget? leftWidget,
//     Widget? rightWidget,
//     Function()? leftDefaultAction,
//     Function()? rightDefaultAction}) {
//   bool checkDay = CXStoreConfig().checkDay;
//   List t = checkDay ? ["收益", "数据", "首页", "产品", "个人"] : ["积分", "首页", "产品", "个人"];

//   return AppBar(
//     leading: leftWidget ??
//         (index == (checkDay ? 2 : 1)
//             ? CustomButton(
//                 onPressed: leftDefaultAction,
//                 child: Image.asset("assets/images/home/icon_navi_left.png",
//                     width: 20.w, fit: BoxFit.fitWidth),
//               )
//             : null),
//     actions: [
//       Padding(
//         padding: EdgeInsets.only(right: 15.w),
//         child: rightWidget ??
//             (index == (checkDay ? 2 : 1)
//                 ? CustomButton(
//                     onPressed: rightDefaultAction,
//                     child: Image.asset("assets/images/home/icon_navi_left.png",
//                         width: 20.w, fit: BoxFit.fitWidth),
//                   )
//                 : null),
//       ),
//     ],
//     centerTitle: true,
//     flexibleSpace: Container(
//       decoration: const BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               stops: [0.3, 0.7],
//               colors: [Color(0xFF4282EB), Color(0xFF5BA3F7)])),
//     ),
//     title: SizedBox(
//         width: 170.w,
//         height: 28.w,
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: checkDay
//                       ? [
//                           Text(
//                             //  0 = 3  1 = 4
//                             t[index - 2 < 0 ? index + 3 : index - 2],
//                             style: TextStyle(
//                                 color: Colors.white38, fontSize: 12.sp),
//                           ),
//                           Text(
//                             t[index - 1 < 0 ? t.length - 1 - index : index - 1],
//                             style: TextStyle(
//                                 color: Colors.white60, fontSize: 14.sp),
//                           ),
//                           Text(
//                             t[index],
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 20.sp),
//                           ),
//                           Text(
//                             t[index + 1 > t.length - 1
//                                 ? index + 1 - t.length
//                                 : index + 1],
//                             style: TextStyle(
//                                 color: Colors.white60, fontSize: 14.sp),
//                           ),
//                           Text(
//                             t[index + 2 > t.length - 1
//                                 ? index + 2 - t.length
//                                 : index + 2],
//                             style: TextStyle(
//                                 color: Colors.white38, fontSize: 12.sp),
//                           ),
//                         ]
//                       : [
//                           Text(
//                             t[index - 1 < 0 ? t.length - 1 - index : index - 1],
//                             style: TextStyle(
//                                 color: Colors.white60, fontSize: 14.sp),
//                           ),
//                           Text(
//                             t[index],
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 20.sp),
//                           ),
//                           Text(
//                             t[index + 1 > t.length - 1
//                                 ? index + 1 - t.length
//                                 : index + 1],
//                             style: TextStyle(
//                                 color: Colors.white60, fontSize: 14.sp),
//                           ),
//                         ]),
//             ),
//             Positioned(
//                 left: 0,
//                 top: 0,
//                 bottom: 0,
//                 width: 15.w,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                           colors: [Color(0xFF4282EB), Color(0x1E4282EB)])),
//                 )),
//             Positioned(
//                 right: 0,
//                 top: 0,
//                 bottom: 0,
//                 width: 15.w,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                           colors: [Color(0x1E5BA3F7), Color(0xFF5BA3F7)])),
//                 ))
//           ],
//         )),
//   );
// }

Text getSimpleText(String text, double fontSize, Color? color,
    {bool isBold = false,
    FontWeight? fw,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextBaseline? textBaseline,
    double? textHeight,
    TextOverflow overflow = TextOverflow.ellipsis}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: TextStyle(
        fontSize: fontSize.sp,
        color: (isBold || fw == CXStoreConfig.fontBold) &&
                color == AppColor.textBlack
            ? AppColor.textBlack2
            : color,
        height: textHeight,
        textBaseline: textBaseline,
        fontWeight:
            fw ?? (isBold ? CXStoreConfig.fontBold : FontWeight.normal)),
  );
}

Widget getRichText(
  String text,
  String text2,
  double fontSize,
  Color color,
  double fontSize2,
  Color color2, {
  bool isBold = false,
  FontWeight? fw,
  int maxLines = 1,
  bool isBold2 = false,
  FontWeight? fw2,
  int maxLines2 = 1,
  double? widht,
  double? h1,
  double? h2,
}) {
  return SizedBox(
    width: widht?.w,
    child: Text.rich(
      TextSpan(text: "", children: [
        TextSpan(
            text: text,
            style: TextStyle(
                fontSize: fontSize.sp,
                color: (isBold || fw == CXStoreConfig.fontBold) &&
                        color == AppColor.textBlack
                    ? AppColor.textBlack2
                    : color,
                height: h1,
                fontWeight: fw ??
                    (isBold ? CXStoreConfig.fontBold : FontWeight.normal))),
        TextSpan(
            text: text2,
            style: TextStyle(
                fontSize: fontSize2.sp,
                color: (isBold2 || fw2 == CXStoreConfig.fontBold) &&
                        color2 == AppColor.textBlack
                    ? AppColor.textBlack2
                    : color2,
                height: h2,
                fontWeight: fw2 ??
                    (isBold2 ? CXStoreConfig.fontBold : FontWeight.normal)))
      ]),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

// Widget getCustomDashLine(double length, double width,
//     {bool v = true,
//     double dashSingleWidth = 6,
//     double dashSingleGap = 8,
//     double strokeWidth = 1,
//     Color? color}) {
//   Path path = Path();
//   path.moveTo(0, 0);
//   if (v) {
//     path.lineTo(0, length.w);
//   } else {
//     path.lineTo(length.w, 0);
//   }
//   return CustomPaint(
//     painter: CustomDottedPinePainter(
//         color: color ?? AppColor.textGrey,
//         dashSingleWidth: dashSingleWidth.w,
//         dashSingleGap: dashSingleGap.w,
//         strokeWidth: strokeWidth.w,
//         // path: parseSvgPathData('m0,0 l0,${62.5.w} Z')),
//         path: path),
//     size: Size(v ? width.w : length.w, v ? length.w : width.w),
//   );
// }

Widget getDefaultTilte(String title, {Widget? rightWidget}) {
  return sbRow([
    centRow([
      Container(
        width: 4.w,
        height: 16.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.w),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2368F2),
                Color(0x002368F2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
      ),
      gwb(8),
      getSimpleText(title, 18, AppColor.textBlack)
    ]),
    rightWidget ?? gwb(0),
  ], width: 345);
}

int getMaxCount(double maxNum) {
  int maxInt = maxNum.ceil();
  if (maxInt <= 20) {
    return 20;
  } else if (maxInt <= 40) {
    return 40;
  } else if (maxInt <= 80) {
    return 80;
  } else {
    String numStr = "1";
    for (var i = 0; i < "$maxInt".length; i++) {
      numStr += "0";
    }
    return int.parse(numStr);
  }
}

Map getChartScale(double maxNum) {
  Map scale = {0: "0", 1: "1", 2: "2", 3: "3", 4: "4"};
  int maxInt = getMaxCount(maxNum);
  int decrease = (maxInt / (scale.values.length - 1)).ceil();
  for (var i = (scale.values.length - 1); i >= 0; i--) {
    int s = maxInt - decrease * (i - (scale.values.length - 1)).abs();
    scale[i] = "${s > 1000 ? "${s / 1000}K" : s}";
  }
  return scale;
}

BoxDecoration getBBDec({List<Color>? colors}) {
  return BoxDecoration(
      borderRadius: BorderRadius.circular(8.w),
      gradient: LinearGradient(
        colors: colors ??
            [
              const Color(0xFFEBF3F7),
              const Color(0xFFFAFAFA),
            ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: [
        BoxShadow(
            color: const Color(0x33666666),
            offset: Offset(0, 5.w),
            blurRadius: 8.w),
      ]);
}

BoxDecoration getDefaultWhiteDec({double radius = 5}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular((radius).w),
  );
}

BoxDecoration getDefaultWhiteDec2({double radius = 12}) {
  return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        (radius).w,
      ),
      boxShadow: [
        BoxShadow(
            color: const Color(0x26333333),
            offset: Offset(0, 5.w),
            blurRadius: 15.w)
      ]);
}

String numToChinessNum(int num) {
  List nums = [
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九",
    "十",
  ];
  if (num < 11) {
    return nums[num - 1];
  } else if (num > 10 && num < 100) {
    String n = "$num";
    int first = int.parse(n.substring(0, 1));
    int second = int.parse(n.substring(1, 2));
    if (second == 0) {
      return "${nums[first - 1]}十";
    } else if (num < 20) {
      return "十${nums[second - 1]}";
    } else {
      return "${nums[first - 1]}十${nums[second - 1]}";
    }
  }

  return "$num";
}

Widget getContentText(
  String text,
  double fontSize,
  Color color,
  double w,
  double h,
  int maxLine, {
  bool isBold = false,
  TextAlign textAlign = TextAlign.start,
  AlignmentGeometry alignment = Alignment.centerLeft,
  FontWeight? fw,
  TextOverflow overflow = TextOverflow.ellipsis,
}) {
  return SizedBox(
    width: w.w,
    height: h.w,
    child: Align(
      alignment: alignment,
      child: Text(
        text,
        maxLines: maxLine,
        overflow: overflow,
        textAlign: textAlign,
        style: TextStyle(
            fontSize: fontSize.sp,
            color: (isBold || fw == CXStoreConfig.fontBold) &&
                    color == AppColor.textBlack
                ? AppColor.textBlack2
                : color,
            fontWeight:
                fw ?? (isBold ? CXStoreConfig.fontBold : FontWeight.normal)),
      ),
    ),
  );
}

Widget getWidthText(
  String text,
  double fontSize,
  Color color,
  double width,
  int? maxLine, {
  bool isBold = false,
  Alignment alignment = Alignment.centerLeft,
  TextAlign textAlign = TextAlign.start,
  StrutStyle? strutStyle,
  FontWeight? fw,
}) {
  return SizedBox(
    width: width.w,
    child: Align(
      alignment: alignment,
      child: Text(
        text,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        strutStyle: strutStyle,
        style: TextStyle(
            fontSize: fontSize.sp,
            color: (isBold || fw == CXStoreConfig.fontBold) &&
                    color == AppColor.textBlack
                ? AppColor.textBlack2
                : color,
            fontWeight:
                fw ?? (isBold ? CXStoreConfig.fontBold : FontWeight.normal)),
      ),
    ),
  );
}

String priceFormat(dynamic price,
    {bool tenThousand = false, int savePoint = 2}) {
  if (price is int) {
    if (tenThousand && price > 10000) {
      return "${doublePriceFormat(price / 10000.0, savePoint: savePoint)}万";
    } else {
      return stringPriceFormat("$price", savePoint: savePoint);
    }
  } else if (price is double) {
    if (tenThousand && price > 10000) {
      return "${doublePriceFormat(price / 10000.0, savePoint: savePoint)}万";
    } else {
      return doublePriceFormat(price, savePoint: savePoint);
    }
  } else if (price is String) {
    if (tenThousand &&
        double.tryParse(price) != null &&
        double.tryParse(price)! > 10000) {
      return "${doublePriceFormat(double.parse(price) / 10000, savePoint: savePoint)}万";
    } else {
      return stringPriceFormat(price, savePoint: savePoint);
    }
  }
  return "";
}

String doublePriceFormat(double price, {int savePoint = 2}) {
  return stringPriceFormat("$price", savePoint: savePoint);
}

String stringPriceFormat(String price, {int savePoint = 2}) {
  List t2 = price.split(".");
  if (t2.length > 1) {
    if (savePoint == 0) {
      return "${t2[0]}";
    } else if ((t2[1] as String).length > savePoint) {
      return "${t2[0]}.${(t2[1] as String).substring(0, savePoint)}";
    } else if ((t2[1] as String).length == savePoint) {
      return "${t2[0]}.${t2[1]}";
    } else {
      for (var i = 0; i < (savePoint - (t2[1] as String).length); i++) {
        t2[1] += "0";
      }
      return "${t2[0]}.${t2[1]}";
    }
  } else {
    String zero = "";
    if (savePoint > 0) {
      for (var i = 0; i < savePoint; i++) {
        if (i == 0) zero += ".";
        zero += "0";
      }
    }
    return "${t2[0]}$zero";
  }
}

String thousandFormat(dynamic num, {int savePoint = 0, bool haveUnit = true}) {
  double dTmp = 0.0;
  if (num is int) {
    dTmp = num * 1.0;
    return "${("${(num / 10000)}".split("."))[0]}${haveUnit ? "万" : ""}";
  } else if (num is double) {
    dTmp = num;
  } else if (num is String) {
    List t = num.split(".");
    if (t.length > 1) {
      dTmp = int.parse(t[0]) * 1.0;
    } else {
      dTmp = int.parse(num) * 1.0;
    }
  }

  List t2 = "${dTmp / 10000}".split(".");
  if (t2.length > 1) {
    if (savePoint > 0) {
      String result = "";
      if (t2[1].length < savePoint) {
        result = "${t2[0]}.${t2[1]}";
        for (var i = 0; i < savePoint - t2[1].length; i++) {
          result += "0";
        }
      } else {
        result = "${t2[0]}.${(t2[1] as String).substring(0, savePoint)}";
      }
      return "$result${haveUnit ? "万" : ""}";
    } else {
      return "${t2[0]}${haveUnit ? "万" : ""}";
    }
  } else {
    if (savePoint > 0) {
      String result = "${t2[0]}.";
      for (var i = 0; i < savePoint; i++) {
        result += "0";
      }
      return "$result${haveUnit ? "万" : ""}";
    } else {
      return "${t2[0]}${haveUnit ? "万" : ""}";
    }
  }
}

void alipayH5payBack(
    {required String url,
    required Map<String, dynamic> params,
    required OrderResultType type,
    required StoreOrderType orderType,
    bool needJump = true}) {
  simpleRequest(
    url: url,
    params: params,
    success: (success, json) {
      if (success) {
        Map data = json["data"] ?? {};
        if (data["orderState"] != null) {
          alipayCallBackHandle(
              result: {
                "resultStatus": data["orderState"] == 0 ? "6001" : "9000"
              },
              payOrder: data,
              orderType: orderType,
              type: type,
              needJump: needJump);
        }
      }
    },
    after: () {},
  );
}

void alipayCallBackHandle(
    {required Map result,
    required OrderResultType type,
    required StoreOrderType orderType,
    bool needJump = true,
    required Map payOrder}) {
  if (result["resultStatus"] == "6001") {
    if (needJump) {
      toPayResult(
          orderType: orderType, orderData: payOrder, toOrderDetail: true);
    }
  } else if (result["resultStatus"] == "9000") {
    toPayResult(type: type, orderData: payOrder);
  }
}

Widget getSubmitBtn(
  String? title,
  Function() onPressed, {
  bool enable = true,
  double? width,
  double? height,
  Color? color,
  Color? textColor,
  double? radius,
}) {
  return CustomButton(
    onPressed: enable ? onPressed : null,
    child: Opacity(
      opacity: enable ? 1.0 : 0.5,
      child: Container(
        width: width != null ? width.w : 345.w,
        height: height != null ? height.w : 50.w,
        decoration: BoxDecoration(
          gradient: color != null
              ? null
              : LinearGradient(
                  begin: Alignment(-1, -1),
                  end: Alignment(0, -1),
                  colors: [
                      CXStoreConfig().getThemeColor() ??
                          const Color(0xFF6796F5),
                      CXStoreConfig().getThemeColor(index: 2) ??
                          const Color(0xFF2368F2),
                    ]),
          color: color,
          borderRadius: BorderRadius.circular(radius ?? 25.w),
        ),
        child: Center(
          child: getSimpleText(
            title ?? "",
            16,
            textColor ?? Colors.white,
          ),
        ),
      ),
    ),
  );
}

Widget getLoginBtn(
  String? title,
  Function() onPressed, {
  bool enable = true,
  double? width,
  double? height,
  Color? color,
  Color? textColor,
  bool haveShadow = true,
}) {
  return CustomButton(
    onPressed: enable ? onPressed : null,
    child: Opacity(
      opacity: enable ? 1.0 : 0.5,
      child: Container(
        width: width != null ? width.w : 228.w,
        height: height != null ? height.w : 52.w,
        decoration: BoxDecoration(
            color: const Color(0xFF2368F2),
            borderRadius: BorderRadius.circular(26.w),
            boxShadow: enable && haveShadow
                ? [
                    BoxShadow(
                        color: const Color(0x4C1652C9),
                        offset: Offset(0, 5.w),
                        blurRadius: 15.w)
                  ]
                : null),
        child: Center(
          child: getSimpleText(title ?? "", 15, textColor ?? Colors.white,
              isBold: true),
        ),
      ),
    ),
  );
}

takeBackKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

String bankCardFormat(String cardId) {
  String tmp = "";
  String tmp2 = cardId;
  if (cardId.isNotEmpty && cardId.length > 3) {
    tmp += tmp2.substring(0, 4);
    tmp2 = tmp2.substring(4, tmp2.length);

    while (tmp2.length > 3) {
      tmp += "  ${tmp2.substring(0, 4)}";
      tmp2 = tmp2.substring(4, tmp2.length);
    }

    if (tmp2.length > 0) {
      tmp += "  ${tmp2.substring(0, tmp2.length)}";
    }
  }

  return tmp;
}

// showPayPasswordModel(Function()? payback) {
//   Get.bottomSheet(

//   );
// }

double paddingSizeBottom(BuildContext context) {
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  padding = padding.copyWith(bottom: data.viewPadding.bottom);
  return padding.bottom;
}

double paddingSizeTop(BuildContext context) {
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  padding = padding.copyWith(bottom: data.viewPadding.top);
  return padding.top;
}

Future<String> image2Base64(String path) async {
  File file = File(path);
  List<int> imageBytes = await file.readAsBytes();
  return convert.base64Encode(imageBytes);
}

Future<void> setUserDataFormat(
    bool isSetOrClean, Map? hData, Map? pData, Map? lData,
    {bool sendNotification = false}) async {
  CXStoreConfig appDefault = CXStoreConfig();
  if (isSetOrClean) {
    appDefault.loginStatus = true;
    if (hData != null && hData.isNotEmpty) {
      appDefault.homeData = hData;
      appDefault.imageView = hData["imageView"] ?? "";
      await UserDefault.saveStr(HOME_DATA, convert.jsonEncode(hData));
    }
    if (pData != null && pData.isNotEmpty) {
      appDefault.publicHomeData = pData;
      await UserDefault.saveStr(PUBLIC_HOME_DATA, convert.jsonEncode(pData));
      getImageUrl(pData);
    }
    if (lData != null && lData.isNotEmpty) {
      appDefault.loginData = lData;
      await UserDefault.saveStr(LOGIN_DATA, convert.jsonEncode(lData));
      if (lData["token"] != null) {
        await UserDefault.saveStr(USER_TOKEN, lData["token"]);
        appDefault.token = lData["token"];
      }
    }
    if (sendNotification) {
      bus.emit(USER_LOGIN_NOTIFY);
    }
  } else {
    if (appDefault.loginStatus == true) {
      appDefault.loginStatus = false;
    }
    UserDefault.removeByKey(HOME_DATA);
    // UserDefault.removeByKey(PUBLIC_HOME_DATA);
    UserDefault.removeByKey(LOGIN_DATA);
    UserDefault.removeByKey(USER_TOKEN);
    appDefault.token = "";
    appDefault.homeData = {};
    // appDefault.publicHomeData = {};
    appDefault.loginData = {};
    // appDefault.imageUrl = "";
    if (sendNotification) {
      bus.emit(USER_LOGIN_NOTIFY);
    }
  }
  return Future.value();
}

Future<Map> getUserData() async {
  CXStoreConfig appDefault = CXStoreConfig();
  Map userData = {};
  if (appDefault.homeData.isEmpty) {
    String homeDataStr = await UserDefault.get(HOME_DATA) ?? "";
    userData["homeData"] =
        homeDataStr.isNotEmpty ? convert.jsonDecode(homeDataStr) : {};
    appDefault.homeData = userData["homeData"];

    String publicHomeDataStr = await UserDefault.get(PUBLIC_HOME_DATA) ?? "";
    userData["publicHomeData"] = publicHomeDataStr.isNotEmpty
        ? convert.jsonDecode(publicHomeDataStr)
        : {};
    appDefault.publicHomeData = userData["publicHomeData"];
    getImageUrl(appDefault.publicHomeData);
    appDefault.imageView = appDefault.homeData["imageView"] ?? "";
  } else {
    userData["homeData"] = appDefault.homeData;
    userData["publicHomeData"] = appDefault.publicHomeData;
    // appDefault.imageUrl = appDefault.publicHomeData.isNotEmpty
    //     ? userData["publicHomeData"]["webSiteInfo"]["System_Images_Url"]
    //     : "";
    getImageUrl(appDefault.publicHomeData);
    appDefault.imageView = appDefault.homeData["imageView"] ?? "";
  }
  appDefault.loginStatus =
      appDefault.homeData.isNotEmpty && appDefault.publicHomeData.isNotEmpty;
  if (appDefault.loginStatus && appDefault.deviceId.isEmpty) {
    appDefault.deviceId = await PlatformDeviceId.getDeviceId ?? "";
  }
  return userData;
}

String getImageUrl(Map pData) {
  CXStoreConfig appDefault = CXStoreConfig();
  Map webSiteInfo = pData["webSiteInfo"] ?? {};
  if (webSiteInfo["System_Images_Url"] != null) {
    appDefault.imageUrl = webSiteInfo["System_Images_Url"] ?? "";
  } else if (webSiteInfo["app"] != null &&
      webSiteInfo["app"]["apP_Images_Url"] != null) {
    appDefault.imageUrl = webSiteInfo["app"]["apP_Images_Url"] ?? "";
  }
  return appDefault.imageUrl;
}

String jsonConvert(dynamic object, int deep, {bool isObject = false}) {
  var buffer = StringBuffer();
  var nextDeep = deep + 1;
  if (object is Map) {
    var list = object.keys.toList();
    if (!isObject) {
      //如果map来自某个字段，则不需要显示缩进
      buffer.write(getDeepSpace(deep));
    }
    buffer.write("{");
    if (list.isEmpty) {
      //当map为空，直接返回‘}’
      buffer.write("}");
    } else {
      buffer.write("\n");
      for (int i = 0; i < list.length; i++) {
        buffer.write("${getDeepSpace(nextDeep)}\"${list[i]}\":");
        buffer.write(jsonConvert(object[list[i]], nextDeep, isObject: true));
        if (i < list.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}}");
    }
  } else if (object is List) {
    if (!isObject) {
      //如果list来自某个字段，则不需要显示缩进
      buffer.write(getDeepSpace(deep));
    }
    buffer.write("[");
    if (object.isEmpty) {
      //当list为空，直接返回‘]’
      buffer.write("]");
    } else {
      buffer.write("\n");
      for (int i = 0; i < object.length; i++) {
        buffer.write(jsonConvert(object[i], nextDeep));
        if (i < object.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}]");
    }
  } else if (object is String) {
    //为字符串时，需要添加双引号并返回当前内容
    buffer.write("\"$object\"");
  } else if (object is num || object is bool) {
    //为数字或者布尔值时，返回当前内容
    buffer.write(object);
  } else {
    //如果对象为空，则返回null字符串
    buffer.write("null");
  }
  return buffer.toString();
}

String getDeepSpace(int deep) {
  var tab = StringBuffer();
  for (int i = 0; i < deep; i++) {
    tab.write("\t");
  }
  return tab.toString();
}

int getRandomInt(int min, int max) {
  final _random = math.Random();
//将 参数min + 取随机数（最大值范围：参数max -  参数min）的结果 赋值给变量 result;
  var result = min + _random.nextInt(max - min);
//返回变量 result 的值;
  return result;
}

enum ToastType { normal, success, fail }

class ShowToast {
  static normal(String? message) {
    if (message != null && message.isNotEmpty) {
      ShowToast.tt(message, ToastType.normal);
    }
  }

  static success(String? message) {
    if (message != null && message.isNotEmpty) {
      ShowToast.tt(message, ToastType.success);
    }
  }

  static error(String? message) {
    if (message != null && message.isNotEmpty) {
      ShowToast.tt(message, ToastType.fail);
    }
  }

  static tt(String message, ToastType toastType) {
    Color toastColor;
    switch (toastType) {
      case ToastType.normal:
        toastColor = AppColor.textBlack;
        break;
      case ToastType.success:
        toastColor = const Color(0xff404351);
        break;
      case ToastType.fail:
        toastColor = const Color(0xff404351);
        break;
    }
    if (kIsWeb) {
      js.context.callMethod(
        "showToast",
        [
          message,
          "#333333",
          "center",
          "center",
          ScreenUtil().screenHeight / 2 - 50
        ],
      );
    } else {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: toastColor,
          textColor: Colors.white,
          fontSize: 12.sp);
    }
  }
}
