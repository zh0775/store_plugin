import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:store_plugin/component/custom_alipay.dart';
import 'package:store_plugin/third/get/get.dart';

import 'package:intl/intl.dart';
import 'package:store_plugin/EventBus.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/component/bottom_paypassword.dart';
import 'package:store_plugin/component/custom_button.dart';
import 'package:store_plugin/component/custom_network_image.dart';
import 'package:store_plugin/component/product_pay_result_page.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/notify_default.dart';
import 'package:store_plugin/service/urls.dart';

import 'package:store_plugin/third/pull_refresh/pull_to_refresh.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

import 'package:tobias/tobias.dart' as tobias;

class MineStoreOrderDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineStoreOrderDetailController>(MineStoreOrderDetailController());
  }
}

class MineStoreOrderDetailController extends GetxController {
  bool isFirst = true;

  Timer? timer;
  String timebuildId = "MineStoreOrderDetail_timebuildId";
  String minutes = "30";
  String second = "00";
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");

  late DateTime addDateTime;
  void payCountDown() {
    if (myData.isEmpty ||
        myData["addTime"] == null ||
        myData["addTime"].isEmpty ||
        myData["orderState"] != 0) {
      if (timer != null) {
        timer?.cancel();
        timer = null;
      }
      return;
    }
    DateTime now = DateTime.now();
    addDateTime =
        dateFormat.parse(myData["addTime"]).add(const Duration(minutes: 30));
    Duration duration = addDateTime.difference(now);

    if (duration.inMilliseconds < 0 || myData["orderState"] != 0) {
      if (timer != null) {
        timer?.cancel();
        timer = null;
        loadDetail();
      }
    } else {
      timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        DateTime currentTime = DateTime.now();
        Duration d = addDateTime.difference(currentTime);
        if (d.inMilliseconds < 0 || myData["orderState"] != 0) {
          timer?.cancel();
          timer = null;
          loadDetail();
        }
        int realSeconds = d.inSeconds - d.inMinutes * 60;
        minutes = d.inMinutes < 10 ? "0${d.inMinutes}" : "${d.inMinutes}";
        second = realSeconds < 10 ? "0$realSeconds" : "$realSeconds";
        update([timebuildId]);
        loadDetail();
        print("second == $second");
      });
    }
  }

  RefreshController pullCtrl = RefreshController();

  final _haveSecond = 0.obs;
  get haveSecond => _haveSecond.value;
  set haveSecond(v) => _haveSecond.value = v;

  final _haveMinute = 0.obs;
  get haveMinute => _haveMinute.value;
  set haveMinute(v) => _haveMinute.value = v;

  late BottomPayPassword bottomPayPassword;

  deleteOrderAction() {
    if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
    } else if (orderType == StoreOrderType.storeOrderTypePackage) {}
  }

  payOrderAction() {
    if ((homeData["u_3rd_password"] == null ||
            homeData["u_3rd_password"].isEmpty) &&
        myData["paymentMethodType"] == 2) {
      // showPayPwdWarn(
      //   haveClose: true,
      //   popToRoot: false,
      //   untilToRoot: false,
      //   setSuccess: () {},
      // );
      return;
    }
    if (myData["paymentMethodType"] == 1) {
      payAction("");
    } else if (myData["paymentMethodType"] == 2) {
      bottomPayPassword.show();
    }
  }

  payAction(String pwd) {
    String urls = "";
    if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
      urls = Urls.userPayGiftOrder(myData["id"]);
    } else if (orderType == StoreOrderType.storeOrderTypePackage) {
      urls = Urls.userPayGiftOrder(myData["id"]);
    }
    simpleRequest(
      url: urls,
      params: {
        "orderId": myData["id"],
        "version_Origin": CXStoreConfig().versionOriginForPay(),
        "u_3nd_Pad": pwd,
      },
      success: (success, json) async {
        if (myData["paymentMethod"] != null &&
            myData["paymentMethodType"] != null) {
          if (myData["paymentMethodType"] == 1) {
            if (myData["paymentMethod"] == 1) {
              if (json != null &&
                  json["data"] != null &&
                  json["data"]["aliData"] != null) {
                Map result = await CustomAlipay().payAction(
                  json["data"]["aliData"],
                  payBack: () {
                    alipayH5payBack(
                        url: urls,
                        params: {
                          "orderId": myData["id"],
                          "version_Origin":
                              CXStoreConfig().versionOriginForPay(),
                          "u_3nd_Pad": pwd,
                        },
                        type: orderType == StoreOrderType.storeOrderTypePackage
                            ? OrderResultType.orderResultTypePackage
                            : OrderResultType.orderResultTypeProduct,
                        orderType: orderType);
                  },
                );
                if (!kIsWeb) {
                  if (result["resultStatus"] == "6001") {
                  } else if (result["resultStatus"] == "9000") {
                    toPayResult(
                        type: orderType == StoreOrderType.storeOrderTypePackage
                            ? OrderResultType.orderResultTypePackage
                            : OrderResultType.orderResultTypeProduct,
                        orderData: myData);
                  }
                }
              } else {
                ShowToast.normal("支付失败，请稍后再试");
                return;
              }
            }
          } else if (myData["paymentMethodType"] == 2) {
            if (success) {
              toPayResult(
                  type: orderType == StoreOrderType.storeOrderTypePackage
                      ? OrderResultType.orderResultTypePackage
                      : OrderResultType.orderResultTypeProduct,
                  orderData: myData);
            }
          }
        }
      },
      after: () {},
    );
  }

  cancelOrderAction() {
    String urls = "";
    if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
      urls = Urls.userLevelGiftOrderCancel(myData["id"]);
    } else if (orderType == StoreOrderType.storeOrderTypePackage) {
      urls = Urls.userLevelGiftOrderCancel(myData["id"]);
    }

    // showCustomDialog(
    //   "确定要取消该订单吗",
    //   confirmOnPressed: () {
    //     simpleRequest(
    //       url: urls,
    //       params: {},
    //       success: (success, json) {
    //         if (success) {
    //           loadDetail();
    //         }
    //       },
    //       after: () {},
    //     );
    //     Get.back();
    //   },
    // );

    showAlert(
      CXStoreConfig.navigatorKey.currentContext!,
      "确定要取消该订单吗",
      confirmOnPressed: () {
        simpleRequest(
          url: urls,
          params: {},
          success: (success, json) {
            if (success) {
              loadDetail();
            }
          },
          after: () {},
        );
      },
    );
  }

  checkLogisticsAction() {
    if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
    } else if (orderType == StoreOrderType.storeOrderTypePackage) {}
  }

  confirmOrderAction() {
    String url = "";
    if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
      url = Urls.userLevelGiftOrderConfirm(myData["id"]);
    } else if (orderType == StoreOrderType.storeOrderTypePackage) {
      url = Urls.userLevelGiftOrderConfirm(myData["id"]);
    }

    showAlert(
      CXStoreConfig.navigatorKey.currentContext!,
      "确定要确认收货吗",
      confirmOnPressed: () {
        simpleRequest(
          url: url,
          params: {},
          success: (success, json) {
            if (success) {
              loadDetail();
            }
          },
          after: () {},
        );
      },
    );
  }

  lengthenReceiAction() {
    if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
    } else if (orderType == StoreOrderType.storeOrderTypePackage) {}
  }

  Map myData = {};
  StoreOrderType orderType = StoreOrderType.storeOrderTypeIntegral;

  dataInit(Map data, StoreOrderType type, List statusList) {
    if (!isFirst) {
      return;
    }
    myData = data;
    if (statusList.isNotEmpty) {
      stateDataList = statusList;
    } else {
      loadState();
    }
    payCountDown();
    update();
    orderType = type;
    isFirst = false;
    loadDetail();
  }

  List stateDataList = [];
  loadState() {
    simpleRequest(
      url: Urls.getOrderStatusList,
      params: {},
      success: (success, json) {
        if (success) {
          stateDataList = json["data"];
          // update([timebuildId]);
        }
      },
      after: () {},
    );
  }

  CancelToken token = CancelToken();
  loadDetail({bool isPull = false}) {
    if (myData["id"] == null) {
      ShowToast.normal("订单信息错误，请前往个人中心查看订单");
      pullCtrl.refreshFailed();
      return;
    }
    String url = "";
    if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
      url = Urls.userLevelGiftOrderShow(myData["id"]);
    } else if (orderType == StoreOrderType.storeOrderTypePackage) {
      url = Urls.userLevelGiftOrderShow(myData["id"]);
    }
    simpleRequest(
      url: url,
      params: {},
      cancelToken: token,
      success: (success, json) {
        if (success) {
          myData = json["data"] ?? {};

          update();
          if (isPull) {
            pullCtrl.refreshCompleted();
          }
        } else {
          if (isPull) {
            pullCtrl.refreshFailed();
          }
        }
      },
      after: () {},
    );
  }

  Map homeData = {};
  @override
  void onInit() {
    homeData = CXStoreConfig().homeData;
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotifi);
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        payAction(payPwd);
      },
    );

    super.onInit();
  }

  getHomeDataNotifi(dynamic arg) {
    homeData = CXStoreConfig().homeData;
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotifi);
    if (!token.isCancelled) {
      token.cancel();
    }
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    pullCtrl.dispose();
    super.onClose();
  }
}

class MineStoreOrderDetail extends GetView<MineStoreOrderDetailController> {
  final Map data;
  final StoreOrderType orderType;
  final List statusList;
  const MineStoreOrderDetail(
      {Key? key,
      required this.data,
      required this.orderType,
      this.statusList = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(data, orderType, statusList);
    return WillPopScope(
      onWillPop: () async {
        if (controller.timer != null) {
          controller.timer!.cancel();
          controller.timer = null;
        }
        return true;
      },
      child: Scaffold(
        appBar: getDefaultAppBar(context, "订单详情", backPressed: () {
          if (controller.timer != null) {
            // if (!controller.token.isCancelled) {
            //   controller.token.cancel();
            // }
            controller.timer!.cancel();
            controller.timer = null;
          }
          Get.back();
        }, white: true, blueBackground: true),
        body: GetBuilder<MineStoreOrderDetailController>(
            init: controller,
            builder: (_) {
              bool isReal = true;
              String unit = "";
              int payType = controller.myData["paymentMethodType"] ?? 1;
              int payMethod = controller.myData["paymentMethod"] ?? 1;
              if (payType == 1) {
                isReal = true;
                unit = "元";
              } else if (payType == 2) {
                isReal = false;
                switch (payMethod) {
                  case 1:
                    unit = "分润";
                    break;
                  case 2:
                    unit = "返现";
                    break;
                  case 3:
                    unit = "奖励金";
                    break;
                  case 4:
                    unit = "积分";
                    break;
                  case 5:
                    unit = "激活豆";
                    break;
                  default:
                }
              }
              return getInputBodyNoBtn(context,
                  contentColor: AppColor.pageBackgroundColor,
                  build: (boxHeight, context) {
                return SmartRefresher(
                  physics: const BouncingScrollPhysics(),
                  onRefresh: () {
                    controller.loadDetail(isPull: true);
                  },
                  controller: controller.pullCtrl,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GetBuilder<MineStoreOrderDetailController>(
                          id: controller.timebuildId,
                          builder: (_) {
                            return topStatus();
                          },
                        ),
                        ghb(14),
                        controller.myData["recipient"] == null &&
                                controller.myData["recipientMobile"] == null
                            ? ghb(0)
                            : Container(
                                width: 345.w,
                                decoration: getDefaultWhiteDec2(),
                                child: Column(
                                  children: [
                                    ghb(14),
                                    // sbRow([
                                    //   getSimpleText("收货人信息", 16, AppColor.textBlack,
                                    //       isBold: true),
                                    // ], width: 345 - 14 * 2),
                                    // ghb(18),
                                    sbRow([
                                      Image.asset(
                                        assetsName("store/icon_dzxx"),
                                        width: 34.w,
                                        fit: BoxFit.fitWidth,
                                        package: PLUGIN_PACKAGE,
                                      ),
                                      centClm([
                                        centRow([
                                          getSimpleText(
                                            controller.myData["recipient"] ??
                                                "",
                                            14,
                                            Colors.black,
                                          ),
                                          gwb(6),
                                          getSimpleText(
                                            controller.myData[
                                                    "recipientMobile"] ??
                                                "",
                                            14,
                                            Colors.black,
                                          ),
                                        ]),
                                        ghb(3),
                                        getWidthText(
                                            controller.myData["userAddress"] ??
                                                "",
                                            14,
                                            const Color(0xFF2D3033),
                                            272,
                                            3,
                                            fw: FontWeight.w500),
                                      ],
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start)
                                    ], width: 345 - 12 * 2),
                                    ghb(10),
                                    // Image.asset(
                                    //   assetsName("common/line"),
                                    //   width: (345 - 10.5 * 2).w,
                                    //   height: 2.w,
                                    //   fit: BoxFit.fill,
                                    // )
                                  ],
                                ),
                              ),
                        ghb(10),
                        GetBuilder<MineStoreOrderDetailController>(
                          init: controller,
                          builder: (_) {
                            return Container(
                              width: 345.w,
                              decoration: getDefaultWhiteDec2(),
                              child: Column(
                                children: [
                                  // sbhRow(
                                  //     orderType ==
                                  //             StoreOrderType
                                  //                 .storeOrderTypeIntegral
                                  //         ? [
                                  //             getSimpleText("积分商城", 16,
                                  //                 AppColor.textBlack,
                                  //                 isBold: true),
                                  //           ]
                                  //         : [],
                                  //     width: 345 - 15 * 2,
                                  //     height: 67),
                                  // gline(345, 0.5),
                                  // ghb(17.5),
                                  ghb(13),
                                  controller.myData["commodity"] != null &&
                                          controller
                                              .myData["commodity"].isNotEmpty
                                      ? Column(
                                          children: [
                                            ...(controller.myData["commodity"]
                                                    as List)
                                                .map((e) => centClm([
                                                      sbRow([
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          child:
                                                              CustomNetworkImage(
                                                            src:
                                                                "${CXStoreConfig().imageUrl}${e["shopImg"]}",
                                                            width: 100.w,
                                                            height: 100.w,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                        centClm([
                                                          getContentText(
                                                              e["shopName"],
                                                              15,
                                                              AppColor
                                                                  .textBlack,
                                                              193.5,
                                                              50,
                                                              2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                          ghb(25),
                                                          sbRow([
                                                            getSimpleText(
                                                                "数量x${e["num"]}",
                                                                12,
                                                                AppColor
                                                                    .textGrey),
                                                            Text.rich(TextSpan(
                                                                text: isReal
                                                                    ? ""
                                                                    : unit,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10.sp,
                                                                    color: AppColor
                                                                        .textBlack),
                                                                children: [
                                                                  TextSpan(
                                                                      text:
                                                                          "${e["nowPrice"]}${isReal ? unit : ""}",
                                                                      style: TextStyle(
                                                                          fontSize: 14
                                                                              .sp,
                                                                          color:
                                                                              AppColor.textBlack)),
                                                                ]))
                                                          ], width: 193.5),
                                                        ])
                                                      ], width: 345 - 15 * 2),
                                                      ghb(17.5),
                                                    ]))
                                                .toList()
                                          ],
                                        )
                                      : sbRow([
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.w),
                                            child: CustomNetworkImage(
                                              src:
                                                  "${CXStoreConfig().imageUrl}${controller.myData["levelGiftImg"] ?? ""}",
                                              width: 100.w,
                                              height: 100.w,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          centClm([
                                            getContentText(
                                                controller
                                                        .myData["levelName"] ??
                                                    "",
                                                15,
                                                AppColor.textBlack,
                                                193.5,
                                                50,
                                                2,
                                                textAlign: TextAlign.start),
                                            ghb(25),
                                            sbRow([
                                              getSimpleText(
                                                  "数量x${controller.myData["num"] ?? 1}",
                                                  12,
                                                  AppColor.textGrey),
                                              Text.rich(TextSpan(
                                                  // text: isReal ? "" : unit,
                                                  style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color:
                                                          AppColor.textBlack),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "${isReal ? "￥" : ""}${priceFormat(controller.myData["totalPrice"] ?? 0)}",
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: AppColor
                                                                .color40)),
                                                  ]))
                                            ], width: 193.5),
                                          ])
                                        ], width: 345 - 15 * 2),
                                  ghb(20),
                                  gline(313, 0.5),
                                  ghb(15),
                                  sbRow([
                                    getSimpleText(
                                        "商品总额", 14, AppColor.textBlack),
                                    getSimpleText(
                                      "${isReal ? "￥" : ""}${priceFormat(controller.myData["totalPrice"] ?? 0)}",
                                      14,
                                      AppColor.color40,
                                    ),
                                  ], width: 345 - 15 * 2),
                                  ghb(15),
                                  // sbRow([
                                  //   getSimpleText("运费", 14, AppColor.textBlack),
                                  //   getSimpleText(
                                  //       controller.myData["rownum"] != 0
                                  //           ? "${controller.myData["rownum"]}"
                                  //           : "包邮",
                                  //       14,
                                  //       AppColor.color40,
                                  //       ),
                                  // ], width: 345 - 15 * 2),
                                  // ghb(15),
                                  sbRow([
                                    getSimpleText("总计", 14, AppColor.textBlack),
                                    getSimpleText(
                                        "${isReal ? "￥" : ""}${controller.myData["totalPrice"] ?? 0}",
                                        18,
                                        AppColor.integralTextRed,
                                        isBold: true),
                                  ], width: 345 - 15 * 2),

                                  ghb(20),
                                ],
                              ),
                            );
                          },
                        ),
                        ghb(12),
                        GetBuilder<MineStoreOrderDetailController>(
                          builder: (_) {
                            return Container(
                              width: 345.w,
                              decoration: getDefaultWhiteDec2(),
                              child: Column(
                                children: [
                                  ghb(20),
                                  sbRow([
                                    getSimpleText(
                                      "订单编号",
                                      14,
                                      const Color(0xFF8A9199),
                                    ),
                                    CustomButton(
                                      onPressed: () {
                                        copyClipboard(
                                            controller.myData["orderNo"] ?? "",
                                            toastText: "订单编号已复制");
                                      },
                                      child: centRow([
                                        getSimpleText(
                                          "${controller.myData["orderNo"] ?? ""}",
                                          12,
                                          const Color(0xFF8A9199),
                                        ),
                                        gwb(3),
                                        Image.asset(
                                          assetsName("store/btn_orderno_copy"),
                                          width: 12.w,
                                          fit: BoxFit.fitWidth,
                                          package: PLUGIN_PACKAGE,
                                        ),
                                      ]),
                                    )
                                  ], width: 345 - 15 * 2),
                                  ghb(11),
                                  sbRow([
                                    getSimpleText(
                                      "创建时间",
                                      14,
                                      const Color(0xFF8A9199),
                                    ),
                                    getSimpleText(
                                      "${controller.myData["addTime"] ?? ""}",
                                      13,
                                      const Color(0xFF8A9199),
                                    ),
                                  ], width: 345 - 15 * 2),
                                  ghb(19),
                                ],
                              ),
                            );
                          },
                        ),
                        ghb(55.5)
                      ],
                    ),
                  ),
                );
              },
                  submitBtn: haveBottom()
                      ? Container(
                          padding: EdgeInsets.only(
                              bottom: paddingSizeBottom(context)),
                          color: Colors.white,
                          width: 375.w,
                          height: 80.w + paddingSizeBottom(context),
                          child: Center(
                            child: sbRow([
                              gwb(0),
                              centRow([
                                ...statusButtons(controller.myData, context)
                              ])
                            ], width: 375 - 20 * 2),
                          ),
                        )
                      : null,
                  buttonHeight:
                      haveBottom() ? 80.w + paddingSizeBottom(context) : 0);
            }),
      ),
    );
  }

  bool haveBottom() {
    if (controller.myData == null || controller.myData["orderState"] == null) {
      return false;
    } else {
      if (controller.myData["orderState"] == 1 ||
          controller.myData["orderState"] == 6 ||
          controller.myData["orderState"] == 7 ||
          controller.myData["orderState"] == 8) {
        return false;
      } else {
        return true;
      }
    }
  }

  // controller.myData["orderState"] == 0
  //             ? Container()
  //             : controller.myData["orderState"] == 1
  //                 ? Container()
  //                 : Container()

  Widget topStatus() {
    bool timeOut = false;
    DateTime now = DateTime.now();
    String autoConfirmDay = "";
    String autoConfirmHour = "";
    if (controller.myData["orderState"] == 0) {
      Duration duration = controller.dateFormat
          .parse(controller.myData["addTime"])
          .add(const Duration(minutes: 30))
          .difference(now);
      timeOut = (duration.inMilliseconds < 0);
    } else if (controller.myData["orderState"] == 2) {
      Duration duration = controller.dateFormat
          .parse(controller.myData["addTime"])
          .add(const Duration(days: 7))
          .difference(now);
      autoConfirmDay = "${duration.inDays}";
      int hour = duration.inHours - duration.inDays * 24;
      autoConfirmHour = "$hour";
    }

    String orderStatusTitle = "";
    String orderStatusSubTitle = "";

    switch (controller.myData["orderState"]) {
      case 0:
        orderStatusTitle = "等待支付订单";
        orderStatusSubTitle =
            "请在${controller.minutes}分${controller.second}秒内完成支付";
        break;
      case 1:
        orderStatusTitle = "已付款成功";
        orderStatusSubTitle = "请耐心等待发货，发货后可查询快递单号";
        break;
      case 2:
        orderStatusTitle = "已发货";
        orderStatusSubTitle = "还剩$autoConfirmDay天$autoConfirmHour小时自动确认收货";
        break;
      case 3:
        orderStatusTitle = "已完成";
        orderStatusSubTitle = "订单已确认收货";
        break;
      case 4:
        orderStatusTitle = "退货中";
        orderStatusSubTitle = "";
        break;
      case 5:
        orderStatusTitle = "退货完成";
        orderStatusSubTitle = "";
        break;
      case 6:
        orderStatusTitle = "支付超时";
        orderStatusSubTitle = "";
        break;
      case 7:
      case 8:
        orderStatusTitle = "已取消";
        orderStatusSubTitle = "";
        break;
      default:
    }

    return Container(
      height: 90.w,
      width: 375.w,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        CXStoreConfig().getThemeColor() ?? const Color(0xFF6796F5),
        CXStoreConfig().getThemeColor(index: 2) ?? const Color(0xFF2368F2),
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(
        child: sbhRow([
          centRow(
            [
              gwb(21),
              centClm([
                getSimpleText(orderStatusTitle, 20, Colors.white),
                ghb(9),
                getSimpleText(orderStatusSubTitle, 14, Colors.white),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ],
          ),
          centRow([
            Image.asset(
              assetsName(
                  "store/icon_${controller.myData["orderState"] != 3 ? "waitfh" : "ddwc"}"),
              width: 75.w,
              fit: BoxFit.fitWidth,
              package: PLUGIN_PACKAGE,
            ),
            gwb(18)
          ])
        ], width: 375 - 5 * 2, height: 90),
      ),

      // Center(
      //   child: centClm([
      //     getSimpleText(
      //       controller.myData["orderState"] == 0
      //           ? (timeOut ? "订单未在有效期内付款，稍后会自动取消订单" : "订单未付款，请在规定时间内完成支付")
      //           : orderStatusTitle,
      //       controller.myData["orderState"] == 0 ? 15 : 18,
      //       AppColor.textBlack,
      //       isBold: controller.myData["orderState"] == 0 ? false : true,
      //     ),
      //     ghb(15),
      //     controller.myData["orderState"] == 0
      //         ? timeOut
      //             ? ghb(0)
      //             : centRow([
      //                 Container(
      //                   width: 45.w,
      //                   height: 30.w,
      //                   decoration: BoxDecoration(
      //                       color: AppColor.textRed,
      //                       borderRadius: BorderRadius.circular(2.w)),
      //                   child: Center(
      //                     child: getSimpleText(
      //                         controller.minutes, 18, Colors.white,
      //                         isBold: true),
      //                   ),
      //                 ),
      //                 gwb(6.5),
      //                 getSimpleText("分", 13, AppColor.textBlack),
      //                 gwb(6.5),
      //                 Container(
      //                   width: 45.w,
      //                   height: 30.w,
      //                   decoration: BoxDecoration(
      //                       color: AppColor.textRed,
      //                       borderRadius: BorderRadius.circular(2.w)),
      //                   child: Center(
      //                     child: getSimpleText(
      //                         controller.second, 18, Colors.white,
      //                         isBold: true),
      //                   ),
      //                 ),
      //                 gwb(6.5),
      //                 getSimpleText("秒", 13, AppColor.textBlack)
      //               ])
      //         : getSimpleText(orderStatusSubTitle, 14, AppColor.textBlack),
      //   ]),
      // ),
    );
  }

  showExpressNoModel(BuildContext context, String expressNo) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Align(
          child: SizedBox(
            width: 345.w,
            height: 165.w,
            child: Column(
              children: [
                CustomButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: Icon(
                    Icons.highlight_off,
                    size: 36.w,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 1.5.w,
                  height: 19.w,
                  color: Colors.white,
                ),
                Container(
                  width: 345.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                      color: AppColor.lineColor,
                      borderRadius: BorderRadius.circular(5.w)),
                  child: Column(
                    children: [
                      ghb(25),
                      getSimpleText("点击快递编号即可复制查询", 15, AppColor.textBlack,
                          isBold: true),
                      ghb(13.5),
                      CustomButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: expressNo));
                          ShowToast.normal("已复制");
                        },
                        child: Container(
                          width: 270.w,
                          height: 35.w,
                          decoration: getDefaultWhiteDec(),
                          child: Center(
                              child: getSimpleText(
                                  expressNo, 20, AppColor.textBlack,
                                  isBold: true)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> statusButtons(
    Map data,
    BuildContext context,
  ) {
    List<Widget> l = [];
    // if (controller.stateDataList.isEmpty) {
    //   return l;
    // }

    if (data["orderState"] == 0) {
      bool timeOut = false;
      DateTime now = DateTime.now();
      Duration duration = controller.dateFormat
          .parse(data["addTime"])
          .add(const Duration(minutes: 30))
          .difference(now);
      timeOut = (duration.inMilliseconds < 0);
      l.addAll([
        statusButton(
          "取消订单",
          const Color(0xFF7B8A99),
          const Color(0xFF8A9199),
          onPressed: () {
            controller.cancelOrderAction();
          },
        ),
        gwb(timeOut ? 0 : 13.5),
        timeOut
            ? gwb(0)
            : statusButton(
                "立即支付",
                const Color(0xFFFD255C),
                const Color(0xFFFD255C),
                bgColor: Colors.white,
                onPressed: () {
                  controller.payOrderAction();
                },
              ),
      ]);
    } else if (data["orderState"] == 1) {
      l.addAll([
        // statusButton(
        //   "查看物流",
        //   AppColor.textBlack,
        //   const Color(0xFFB3B3B3),
        //   onPressed: () {
        //     controller.checkLogisticsAction();
        //     showExpressNoModel(context, data["courierNo"]);
        //   },
        // ),
        // gwb(13.5),
        // statusButton(
        //   "确认收货",
        //   const Color(0xFFF2892D),
        //   const Color(0xFFF2892D),
        //   bgColor: Colors.white,
        //   onPressed: () {
        //     controller.confirmOrderAction();
        //   },
        // ),
      ]);
    } else if (data["orderState"] == 2) {
      l.addAll([
        statusButton(
          "查看物流",
          const Color(0xFF7B8A99),
          const Color(0xFF8A9199),
          onPressed: () {
            // controller.confirmOrderAction(index, status);
            if (data["courierNo"] != null) {
              showExpressNoModel(context, data["courierNo"] ?? "");
            } else {
              ShowToast.normal("暂无物流信息，请稍后再试");
            }
          },
        ),
        gwb(13.5),
        statusButton(
          "确认收货",
          const Color(0xFFF2892D),
          const Color(0xFFF2892D),
          bgColor: Colors.white,
          onPressed: () {
            controller.confirmOrderAction();
          },
        ),
      ]);
    } else if ((data["orderState"] == 3 ||
            data["orderState"] == 4 ||
            data["orderState"] == 5) ||
        data["courierNo"] != null && data["courierNo"].isNotEmpty) {
      l.addAll([
        // statusButton(
        //   "删除订单",
        //   AppColor.textBlack,
        //   const Color(0xFFB3B3B3),
        //   onPressed: () {
        //     controller.checkLogisticsAction();
        //   },
        // ),
        // gwb(13.5),
        statusButton(
          "查看物流",
          const Color(0xFF7B8A99),
          const Color(0xFF8A9199),
          onPressed: () {
            if (data["courierNo"] != null) {
              showExpressNoModel(context, data["courierNo"] ?? "");
            } else {
              ShowToast.normal("暂无物流信息，请稍后再试");
            }
          },
        ),
      ]);
    } else if (data["orderState"] == 6 ||
        data["orderState"] == 7 ||
        data["orderState"] == 8) {
      l.addAll([
        // statusButton(
        //   "删除订单",
        //   AppColor.textBlack,
        //   const Color(0xFFB3B3B3),
        //   onPressed: () {
        //     controller.checkLogisticsAction();
        //   },
        // ),
      ]);
    }
    return l;
  }

  Widget statusButton(
    String t1,
    Color textColor,
    Color borderColor, {
    Function()? onPressed,
    Color? bgColor = Colors.transparent,
  }) {
    return CustomButton(
      onPressed: onPressed,
      child: Container(
        width: 90.w,
        height: 32.w,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(width: 0.5.w, color: borderColor)),
        child: Center(
          child: getSimpleText(t1, 14, textColor),
        ),
      ),
    );
  }
}
