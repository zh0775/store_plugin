import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:store_plugin/component/custom_alipay.dart';
import 'package:store_plugin/third/get/get.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/component/bottom_paypassword.dart';
import 'package:store_plugin/component/custom_button.dart';
import 'package:store_plugin/component/custom_input.dart';
import 'package:store_plugin/component/custom_network_image.dart';
import 'package:store_plugin/component/product_pay_result_page.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/service/urls.dart';

import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

import 'dart:convert' as convert;
import 'package:tobias/tobias.dart' as tobias;

class VipStoreConfirmOrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<VipStoreConfirmOrderController>(VipStoreConfirmOrderController());
  }
}

class VipStoreConfirmOrderController extends GetxController {
  bool isFirst = true;
  Map productData = {};
  final _address = Rx<Map>({});
  Map get address => _address.value;
  set address(v) => _address.value = v;
  TextEditingController bzTextCtrl = TextEditingController();

  Timer? orderConfirmTimer;

  String adressBuildId = "VipStoreConfirmOrder_adressBuildId";

  Map addressLocation = {};
  Map branchLocation = {};

  final _deliveryType = 0.obs;
  get deliveryType => _deliveryType.value;
  set deliveryType(v) {
    _deliveryType.value = v;
    if (deliveryType == 0) {
      address = addressLocation;
    } else if (v == 1) {
      address = branchLocation;
    }
  }

  final _currentCount = 1.obs;
  get currentCount => _currentCount.value;
  set currentCount(v) {
    if (v < 1) {
      ShowToast.normal("最少购买1件哦");
      return;
    }
    _currentCount.value = v;
    // update([confirmButtonBuildId]);
    loadPreviewOrder();
  }

  final _currentPayIndex = 0.obs;
  int get currentPayIndex => _currentPayIndex.value;
  set currentPayIndex(v) {
    if (_currentPayIndex.value != v) {
      _currentPayIndex.value = v;
      loadPreviewOrder();
    }
  }

  setAddress(Map setAddress) {
    if (setAddress.isNotEmpty) {
      address = setAddress;
      update([adressBuildId]);
    }
  }

  Map previewOrderData = {};

  late BottomPayPassword bottomPayPassword;

  loadPreviewOrder() {
    Map<String, dynamic> params = {
      "delivery_Method": 1,
      // "levelConfigId": isBag ? payType["levelGiftId"] : productData["teamId"],
      // "levelTeamId": productData["levelGiftId"] ?? -1,
      "levelConfigId": productData["levelGiftId"] ?? -1,
      "num": currentCount,
      "contactID": address["id"] ?? 0,
      "pay_MethodType": payTypeList[currentPayIndex]["u_Type"],
      "pay_Method": payTypeList[currentPayIndex]["value"]
    };
    simpleRequest(
      url: Urls.previewOrder,
      params: params,
      success: (success, json) {
        if (success) {
          previewOrderData = json["data"];
          update();
        }
      },
      after: () {},
    );
  }

  loadAddress() {
    // simpleRequest(
    //     url: Urls.userContactList,
    //     params: {},
    //     success: (success, json) {
    //       if (success) {
    //         List aList = json["data"];
    //         if (aList.isNotEmpty) {
    //           if (aList.length == 1) {
    //             address = aList[0];
    //           } else {
    //             for (var item in aList) {
    //               if (item["isDefault"] == 1) {
    //                 address = item;
    //                 break;
    //               }
    //             }
    //           }
    //           if (address.isEmpty) {
    //             address = aList[0];
    //           }
    //           update([adressBuildId]);
    //         }
    //         loadPreviewOrder();
    //       }
    //     },
    //     after: () {},
    //     useCache: true);

    simpleRequest(
        url: Urls.userContactList,
        params: {},
        success: (success, json) {
          if (success) {
            List aList = json["data"];
            if (aList.isNotEmpty) {
              if (aList.length == 1) {
                addressLocation = aList[0];
              } else {
                for (var item in aList) {
                  if (item["isDefault"] == 1) {
                    addressLocation = item;
                    break;
                  }
                }
              }
              if (address.isEmpty) {
                addressLocation = aList[0];
              }
            }
            if (deliveryType == 0) {
              address = addressLocation;
            }
            loadPreviewOrder();
          }
        },
        after: () {},
        useCache: true);

    simpleRequest(
        url: Urls.userNetworkContactList,
        params: {},
        success: (success, json) {
          if (success) {
            List bList = json["data"];
            if (bList.isNotEmpty) {
              branchLocation = bList[0];
            }
            if (deliveryType == 1) {
              address = branchLocation;
            }
          }
        },
        after: () {});
  }

  List payTypeList = [];

  payAction() {
    if (address.isEmpty) {
      ShowToast.normal("请选择或填写收货地址");
      return;
    }

    if (payTypeList[currentPayIndex]["u_Type"] == 1) {
      loadPayOrder();
    } else {
      if (CXStoreConfig().homeData["u_3rd_password"] == null ||
          CXStoreConfig().homeData["u_3rd_password"].isEmpty) {
        // showPayPwdWarn(
        //   haveClose: true,
        //   popToRoot: false,
        //   untilToRoot: false,
        //   setSuccess: () {},
        // );

        //@warnning 支付密码弹窗
        if (alertPayWarn != null) {
          alertPayWarn!();
        }
        return;
      }
      bottomPayPassword.show();
    }
  }

  loadPayOrder({String? payPwd}) {
    Map<String, dynamic> params = {
      "delivery_Method": 1,
      // "levelConfigId": isBag ? payType["levelGiftId"] : productData["teamId"],
      "levelConfigId": productData["levelGiftId"] ?? -1,
      "num": currentCount,
      "contactID": address.isEmpty ? 0 : address["id"],
      "pay_MethodType": payTypeList[currentPayIndex]["u_Type"],
      "pay_Method": payTypeList[currentPayIndex]["value"],
      "version_Origin": CXStoreConfig().versionOriginForPay(),
      "u_3nd_Pad": payPwd ?? "",
    };
    // if (payTypeList[currentPayTypeIndex]["u_Type"] == 2) {
    //   params["u_3nd_Pad"] = payPwd;
    // }
    // if (isBag) params["levelTeamId"] = productData["teamId"];
    // params["levelTeamId"] = productData["teamId"];

    simpleRequest(
      url: Urls.userLevelGiftPay,
      params: params,
      success: (success, json) async {
        if (!success) {
          return;
        }
        Map data = success ? (json["data"] ?? {}) : {};
        if (payTypeList[currentPayIndex]["u_Type"] == 1) {
          if (payTypeList[currentPayIndex]["value"] == 1) {
            if (data["aliData"] == null || data["aliData"].isEmpty) {
              ShowToast.normal("支付失败，请稍后再试");
              return;
            }
            // 测试
            // ShowToast.normal("订单编号： ${data["order_NO"]}");
            // String biz = "";
            // for (var e in (data["aliData"] as String).split("&")) {
            //   if (e is String && e.contains("biz_content")) {
            //     ShowToast.normal("alidata订单编号： ${e.split("V")[1]}");
            //   }
            // }
            // return;
            Map order = data["orderInfo"] ?? {};
            Map aliData = await CustomAlipay().payAction(
              data["aliData"],
              payBack: () {
                alipayH5payBack(
                    url: Urls.userLevelGiftOrderShow(order["id"] ?? -1),
                    params: {},
                    type: OrderResultType.orderResultTypeProduct,
                    orderType: StoreOrderType.storeOrderTypeProduct);
              },
            );

            if (!kIsWeb) {
              simpleRequest(
                url: Urls.userLevelGiftOrderShow(order["id"] ?? -1),
                params: {},
                success: (success, json) {
                  if (success) {
                    Map orderData = json["data"] ?? {};
                    if (aliData["resultStatus"] == "6001") {
                      toPayResult(
                          orderType: StoreOrderType.storeOrderTypeProduct,
                          orderData: orderData,
                          toOrderDetail: true);
                    } else if (aliData["resultStatus"] == "9000") {
                      toPayResult(
                          type: OrderResultType.orderResultTypeProduct,
                          orderData: orderData);
                    }
                  } else {
                    ShowToast.normal("获取订单信息失败");
                  }
                },
                after: () {},
              );
            }
          }
        } else {
          if (!success) {
            return;
          }
          Map order = data["orderInfo"] ?? {};
          checkOrderRequest(
            true,
            orderNo: order["id"] ?? -1,
            orderCheck: (check) {
              simpleRequest(
                url: Urls.userLevelGiftOrderShow(order["id"] ?? -1),
                params: {},
                success: (orderSuccess, json) {
                  if (orderSuccess) {
                    Map orderData = json["data"] ?? {};
                    if (check) {
                      toPayResult(
                          type: OrderResultType.orderResultTypeProduct,
                          orderData: orderData);
                    } else {
                      toPayResult(
                          orderType: StoreOrderType.storeOrderTypeProduct,
                          orderData: orderData,
                          toOrderDetail: true);
                    }
                  } else {
                    ShowToast.normal("获取订单信息失败");
                  }
                },
                after: () {},
              );
            },
          );

          // simpleRequest(
          //   url: Urls.userLevelGiftOrderShow(order["id"] ?? -1),
          //   params: {},
          //   success: (orderSuccess, json) {
          //     if (orderSuccess) {
          //       Map orderData = json["data"] ?? {};
          //       if (success) {
          //         toPayResult(
          //             type: OrderResultType.orderResultTypeProduct,
          //             orderData: orderData);
          //       } else {
          //         toPayResult(
          //             orderType: StoreOrderType.storeOrderTypeProduct,
          //             orderData: orderData,
          //             toOrderDetail: true);
          //       }
          //     } else {
          //       ShowToast.normal("获取订单信息失败");
          //     }
          //   },
          //   after: () {},
          // );
        }
      },
      after: () {},
    );
  }

  checkOrderRequest(bool check,
      {dynamic orderNo, required Function(bool check) orderCheck}) {
    orderConfirmTimer?.cancel();
    orderConfirmTimer = null;
    simpleRequest(
      url: Urls.userGiftOrderVerifi(orderNo),
      params: {},
      success: (success, json) {
        orderCheck(success);
        // if (success) {
        // orderConfirmTimer?.cancel();
        // orderConfirmTimer = null;
        // }
      },
      after: () {},
    );
    // if (check) {
    //   orderConfirmTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //     simpleRequest(
    //       url: Urls.userGiftOrderVerifi(orderNo),
    //       params: {},
    //       success: (success, json) {
    //         if (success) {
    //           orderConfirmTimer?.cancel();
    //           orderConfirmTimer = null;
    //         }
    //       },
    //       after: () {},
    //     );
    //   });
    // }
  }

  Function()? alertPayWarn;

  dataInit(Map data, Function()? alert) {
    if (!isFirst) return;
    isFirst = false;
    productData = data;
    alertPayWarn = alert;
    payTypeList =
        convert.jsonDecode(productData["levelGiftPaymentMethod"] ?? "");
    loadAddress();
  }

  @override
  void onInit() {
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadPayOrder(payPwd: payPwd);
      },
    );
    super.onInit();
  }

  @override
  void onClose() {
    orderConfirmTimer?.cancel();
    orderConfirmTimer = null;
    bzTextCtrl.dispose();
    super.onClose();
  }
}

class VipStoreConfirmOrder extends GetView<VipStoreConfirmOrderController> {
  final Map productData;
  final Function(dynamic getCtrl)? toAddressPage;
  final Function(dynamic getCtrl, int deliveryType)? toAddressOrContactPage;
  final Function()? alertPayWarn;
  final bool selectContact;
  const VipStoreConfirmOrder(
      {super.key,
      this.productData = const {},
      this.toAddressPage,
      this.toAddressOrContactPage,
      this.selectContact = false,
      this.alertPayWarn});

  @override
  Widget build(BuildContext context) {
    controller.dataInit(productData, alertPayWarn);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
          appBar: getDefaultAppBar(context, "确认订单",
              blueBackground: true, white: true),
          body: getInputBodyNoBtn(
            context,
            buttonHeight: (44 + 12 * 2).w + paddingSizeBottom(context),
            submitBtn: Container(
              width: 375.w,
              height: (44 + 12 * 2).w + paddingSizeBottom(context),
              color: Colors.white,
              child: Column(
                children: [
                  ghb(12),
                  sbRow([
                    GetBuilder<VipStoreConfirmOrderController>(
                      builder: (_) {
                        return getRichText(
                            "￥ ",
                            priceFormat(
                                controller.previewOrderData["pay_Amount"] ?? 0),
                            16,
                            const Color(0xFFFF0000),
                            24,
                            const Color(0xFFFF0000));
                      },
                    ),
                    CustomButton(
                      onPressed: () {
                        showPayList(context);
                      },
                      child: Container(
                        width: 115.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  CXStoreConfig().getThemeColor() ??
                                      const Color(0xFF6796F5),
                                  CXStoreConfig().getThemeColor(index: 2) ??
                                      const Color(0xFF2368F2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(22.w)),
                        child: Center(
                          child: getSimpleText("立即付款", 15, Colors.white),
                        ),
                      ),
                    )
                  ], width: 375 - 16 * 2)
                ],
              ),
            ),
            children: [
              ghb(14),
              gwb(375),
              Container(
                width: 345.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.w)),
                child: GetBuilder<VipStoreConfirmOrderController>(
                  id: controller.adressBuildId,
                  builder: (_) {
                    return Column(
                      children: [
                        selectContact
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(2, (idx) {
                                  return CustomButton(
                                    onPressed: () {
                                      if (controller.deliveryType != idx) {
                                        controller.deliveryType = idx;
                                      }
                                    },
                                    child: GetX<VipStoreConfirmOrderController>(
                                      builder: (_) {
                                        return SizedBox(
                                          width: (300 / 2).w,
                                          height: 40.w,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              getSimpleText(
                                                  idx == 0 ? "快递送货" : "网点自提",
                                                  16,
                                                  AppColor.textBlack,
                                                  isBold: true),
                                              gwb(8),
                                              Icon(
                                                Icons.check_circle,
                                                size: 12.5.w,
                                                color: idx ==
                                                        controller.deliveryType
                                                    ? CXStoreConfig()
                                                            .getThemeColor() ??
                                                        AppColor.blue
                                                    : const Color(0xFFF0F0F0),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              )
                            : ghb(0),
                        selectContact ? gline(315, 0.5) : ghb(0),
                        ghb(15),
                        GetX<VipStoreConfirmOrderController>(
                          builder: (_) => centClm([
                            controller.address.isEmpty
                                ? ghb(0)
                                : sbRow([
                                    centRow([
                                      getSimpleText(
                                          controller.address["recipient"] ?? "",
                                          14,
                                          AppColor.textBlack3),
                                      gwb(12),
                                      getSimpleText(
                                          controller
                                                  .address["recipientMobile"] ??
                                              "",
                                          14,
                                          AppColor.textBlack3)
                                    ])
                                  ], width: 345 - 14 * 2),
                            ghb(controller.address.isEmpty ? 0 : 7),
                            sbRow([
                              controller.address.isEmpty
                                  ? CustomButton(
                                      onPressed: () {
                                        if (selectContact) {
                                          if (toAddressOrContactPage != null) {
                                            toAddressOrContactPage!(controller,
                                                controller.deliveryType);
                                          }
                                        } else {
                                          if (toAddressPage != null) {
                                            toAddressPage!(controller);
                                          }
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 14.w),
                                        child: getSimpleText("请添加您的收货地址", 17,
                                            const Color(0xFFB3B3B3)),
                                      ),
                                    )
                                  : centRow([
                                      gwb(14),
                                      (controller.address["isDefault"] ?? 0) ==
                                              1
                                          ? Container(
                                              width: 30.w,
                                              height: 16.w,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.w),
                                                  color: AppColor.blue),
                                              child: Center(
                                                child: getSimpleText(
                                                    "默认", 10, Colors.white),
                                              ),
                                            )
                                          : gwb(0),
                                      gwb((controller.address["isDefault"] ??
                                                  0) ==
                                              1
                                          ? 7
                                          : 0),
                                      getSimpleText(
                                          "${controller.address["provinceName"] ?? ""} | ",
                                          12,
                                          AppColor.textBlack3),
                                      getSimpleText(
                                          "${controller.address["cityName"] ?? ""} | ",
                                          12,
                                          AppColor.textBlack3),
                                      getSimpleText(
                                          "${controller.address["areaName"] ?? ""}",
                                          12,
                                          AppColor.textBlack3),
                                    ]),
                              CustomButton(
                                onPressed: () {
                                  //@warnning 进入地址管理页面
                                  // push(
                                  //     MineAddressManager(
                                  //       getCtrl: controller,
                                  //       addressType: AddressType.address,
                                  //     ),
                                  //     context,
                                  //     binding: MineAddressManagerBinding());

                                  if (selectContact) {
                                    if (toAddressOrContactPage != null) {
                                      toAddressOrContactPage!(
                                          controller, controller.deliveryType);
                                    }
                                  } else {
                                    if (toAddressPage != null) {
                                      toAddressPage!(controller);
                                    }
                                  }
                                },
                                child: SizedBox(
                                  width: 37.w,
                                  height: 37.w,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      assetsName(
                                          "store/btn_confirm_order_edit"),
                                      width: 18.w,
                                      fit: BoxFit.fitWidth,
                                      package: PLUGIN_PACKAGE,
                                    ),
                                  ),
                                ),
                              )
                            ], width: 345),
                            // ghb(5),
                            sbRow([
                              getWidthText(
                                  controller.address["address"] ?? "",
                                  14,
                                  AppColor.textBlack3,
                                  345 - 14 - 37 - 2,
                                  3),
                            ], width: 345 - 14 * 2),
                          ]),
                        ),
                        ghb(15),
                        Image.asset(
                          assetsName("store/line2"),
                          width: 345.w,
                          height: 3.w,
                          fit: BoxFit.fill,
                          package: PLUGIN_PACKAGE,
                        )
                      ],
                    );
                  },
                ),
              ),
              ghb(15),
              Container(
                width: 345.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Column(
                  children: [
                    ghb(13),
                    sbRow([
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: CustomNetworkImage(
                          src: CXStoreConfig().imageUrl +
                              (productData["levelGiftImg"] ?? ""),
                          width: 115.w,
                          height: 115.w,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        height: 115.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            centClm([
                              getWidthText(productData["levelName"] ?? "", 14,
                                  AppColor.textBlack3, 189, 2),
                              ghb(5),
                              getWidthText(productData["levelDescribe"] ?? "",
                                  12, AppColor.textBlack6, 189, 3),
                            ]),
                            sbRow([
                              getRichText(
                                  "￥",
                                  priceFormat(productData["nowPrice"] ?? 0),
                                  13,
                                  const Color(0xFFFF5A5F),
                                  18,
                                  const Color(0xFFFF5A5F)),
                            ], width: 189),
                          ],
                        ),
                      )
                    ], width: 345 - 14 * 2),
                    ghb(6),
                    sbhRow([
                      getSimpleText("数量", 14, AppColor.textBlack7),
                      centRow([
                        CustomButton(
                          onPressed: () {
                            controller.currentCount--;
                          },
                          child: SizedBox(
                            // width: 40.w,
                            height: 40.w,
                            child: Center(
                              child: Image.asset(
                                assetsName("store/btn_vip_sub"),
                                width: 18.w,
                                fit: BoxFit.fitWidth,
                                package: PLUGIN_PACKAGE,
                              ),
                            ),
                          ),
                        ),
                        GetX<VipStoreConfirmOrderController>(
                          builder: (_) {
                            return SizedBox(
                              width: 37.w,
                              child: Center(
                                child: getSimpleText(
                                    "${controller.currentCount}",
                                    14,
                                    AppColor.textBlack7),
                              ),
                            );
                          },
                        ),
                        CustomButton(
                          onPressed: () {
                            controller.currentCount++;
                          },
                          child: SizedBox(
                            // width: 40.w,
                            height: 40.w,
                            child: Center(
                              child: Image.asset(
                                assetsName("store/btn_vip_add"),
                                width: 18.w,
                                fit: BoxFit.fitWidth,
                                package: PLUGIN_PACKAGE,
                              ),
                            ),
                          ),
                        ),
                      ])
                    ], width: 345 - 14 * 2, height: 54),
                    orderCell("配送方式", "普通快递", topLine: true, bottomLine: true),
                    orderCell("配送时间", "七个工作日内安排发货", bottomLine: true),
                    GetBuilder<VipStoreConfirmOrderController>(
                      builder: (_) {
                        return orderCell(
                            "运费",
                            (controller.previewOrderData["pay_Freight"] ?? 0) ==
                                    0
                                ? "包邮"
                                : "${(controller.previewOrderData["pay_Freight"] ?? 0)}",
                            bottomLine: true);
                      },
                    ),
                    sbRow(
                      [
                        SizedBox(
                          width: 50.w,
                          height: 54.w,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: getSimpleText("备注", 14, AppColor.textBlack7),
                          ),
                        ),
                        SizedBox(
                          width: (345 - 50 - 14 * 2 - 20).w,
                          height: 54.w,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: CustomInput(
                              width: (345 - 50 - 14 * 2 - 20).w,
                              heigth: 35.w,
                              textEditCtrl: controller.bzTextCtrl,
                              textAlign: TextAlign.end,
                              placeholder: "请输入留言",
                              placeholderStyle: TextStyle(
                                  fontSize: 14.sp, color: AppColor.textGrey5),
                              style: TextStyle(
                                  fontSize: 14.sp, color: AppColor.textBlack4),
                            ),
                          ),
                        )
                      ],
                      width: 345 - 14 * 2,
                    ),
                    ghb(30),
                  ],
                ),
              ),
              ghb(20)
            ],
            // build: (boxHeight, context) {
            //   return SizedBox(
            //     width: 375.w,
            //     height: boxHeight,
            //     child: SingleChildScrollView(
            //       child: Column(
            //         children: [],
            //       ),
            //     ),
            //   );
            // },
          )),
    );
  }

  Widget orderCell(String t1, String t2,
      {bool topLine = false, bool bottomLine = false}) {
    return centClm([
      topLine ? gline(315, 1, color: const Color(0xFFEEEFF0)) : ghb(0),
      sbhRow([
        getSimpleText(t1, 14, AppColor.textBlack7),
        getSimpleText(t2, 14, AppColor.textBlack7),
      ], width: 345 - 14 * 2, height: 54),
      bottomLine ? gline(315, 1, color: const Color(0xFFEEEFF0)) : ghb(0),
    ]);
  }

  showPayList(BuildContext context) {
    double modelHeight = 343.w;
    if (controller.payTypeList.length > 3) {
      modelHeight += (controller.payTypeList.length - 3) * 57.w;
    }
    Get.bottomSheet(
        Container(
          width: 375.w,
          height: modelHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
              color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              centClm([
                sbhRow([
                  gwb(50),
                  getSimpleText("请选择支付方式", 16, AppColor.textBlack7),
                  CustomButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: SizedBox(
                      width: 50.w,
                      height: 40.w,
                      child: Center(
                          child: Image.asset(
                        assetsName("store/btn_model_close2"),
                        width: 12.w,
                        fit: BoxFit.fitWidth,
                        package: PLUGIN_PACKAGE,
                      )),
                    ),
                  )
                ], width: 375, height: 56),
                // getSimpleText(text, fontSize, color)
                ...List.generate(
                    controller.payTypeList.length,
                    (index) => payCell(index, controller.payTypeList[index],
                        line: index == controller.payTypeList.length - 1
                            ? false
                            : true))
              ]),
              centClm([
                GetBuilder<VipStoreConfirmOrderController>(
                  builder: (_) {
                    return getSubmitBtn(
                        "立即支付￥${priceFormat(controller.previewOrderData["pay_Amount"] ?? 0)}",
                        () {
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        //
                        controller.payAction();
                      });
                    });
                  },
                ),
                SizedBox(
                  height: paddingSizeBottom(context),
                ),
                ghb(15),
              ])
            ],
          ),
        ),
        isScrollControlled: true);
  }

  Widget payCell(int index, Map data, {bool line = true}) {
    return CustomButton(
      onPressed: () {
        controller.currentPayIndex = index;
      },
      child: centClm([
        sbhRow([
          centRow([
            CustomNetworkImage(
              src: CXStoreConfig().imageUrl + (data["img"] ?? ""),
              width: 22.w,
              fit: BoxFit.fitWidth,
              errorColor: Colors.transparent,
            ),
            gwb(15),
            getSimpleText(data["name"] ?? "", 16, AppColor.textBlack3)
          ]),
          GetX<VipStoreConfirmOrderController>(
            builder: (_) {
              return ColorFiltered(
                colorFilter: ColorFilter.mode(
                    CXStoreConfig().getThemeColor() != null
                        ? (controller.currentPayIndex == index
                            ? CXStoreConfig().getThemeColor()!
                            : Colors.white)
                        : Colors.white,
                    BlendMode.modulate),
                child: Image.asset(
                  assetsName(
                      "store/pay_${controller.currentPayIndex == index && CXStoreConfig().getThemeColor() == null ? "" : "un"}selected"),
                  width: 22.w,
                  fit: BoxFit.fitWidth,
                  package: PLUGIN_PACKAGE,
                ),
              );
            },
          )
        ], width: 375 - 22 * 2, height: 56),
        line ? gline(342.5, 1, color: const Color(0xFFF7F7F7)) : ghb(0)
      ]),
    );
  }
}
