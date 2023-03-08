import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/component/custom_network_image.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/page/vip_store_confirm_order.dart';
import 'package:store_plugin/service/urls.dart';
import 'package:store_plugin/third/get/get.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

class VipStoreDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<VipStoreDetailController>(VipStoreDetailController());
  }
}

class VipStoreDetailController extends GetxController {
  final _pageBannerIdx = 0.obs;
  int get pageBannerIdx => _pageBannerIdx.value;
  set pageBannerIdx(v) => _pageBannerIdx.value = v;

  List imgList = [];

  loadDetail() {
    simpleRequest(
      url: Urls.userLevelGiftShow(productData["levelGiftId"]),
      params: {},
      success: (success, json) {
        if (success) {
          productData = json["data"] ?? {};
          imgListFormat();
          update();
        }
      },
      after: () {},
    );
  }

  bool isFirst = true;
  Map productData = {};

  dataInit(Map data) {
    if (!isFirst) return;
    isFirst = false;
    productData = data;
    imgListFormat();
    loadDetail();
  }

  imgListFormat() {
    String imgStr = productData["levelGiftImgList"] ?? "";
    imgList = imgStr.split(",");
    if (imgList.isEmpty ||
        (imgList.isNotEmpty && imgList.length == 1 && imgList[0] == "")) {
      imgList.clear();
      imgList.add(productData["levelGiftImg"] ?? "");
    }
  }
}

class VipStoreDetail extends GetView<VipStoreDetailController> {
  final Map productData;
  final Function(dynamic getCtrl)? toAddressPage;
  final Function(dynamic getCtrl, int deliveryType)? toAddressOrContactPage;
  final Function()? alertPayWarn;
  final bool selectContact;
  const VipStoreDetail(
      {super.key,
      this.productData = const {},
      this.toAddressPage,
      this.toAddressOrContactPage,
      this.selectContact = false,
      this.alertPayWarn});

  @override
  Widget build(BuildContext context) {
    controller.dataInit(productData);
    return Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: getDefaultAppBar(context, "礼包详情"),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: (48 + 14 * 2).w + paddingSizeBottom(context),
              child: GetBuilder<VipStoreDetailController>(
                builder: (_) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 375.w,
                          height: 292.w,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: PageView.builder(
                                itemCount: controller.imgList.length,
                                itemBuilder: (context, index) {
                                  return CustomNetworkImage(
                                    src: CXStoreConfig().imageUrl +
                                        controller.imgList[index],
                                    width: 375.w,
                                    height: 292.w,
                                    fit: BoxFit.fill,
                                  );
                                },
                                onPageChanged: (value) {
                                  controller.pageBannerIdx = value;
                                },
                              )),
                              Positioned(
                                  bottom: 19.w,
                                  right: 16.w,
                                  child: GetX<VipStoreDetailController>(
                                    builder: (_) {
                                      return getRichText(
                                          "${controller.pageBannerIdx + 1}",
                                          "/${controller.imgList.isEmpty ? 1 : controller.imgList.length}",
                                          16,
                                          const Color(0xFF1C1C1C),
                                          12,
                                          const Color(0xFF9A9A9A));
                                    },
                                  ))
                            ],
                          ),
                        ),
                        ghb(14),
                        Container(
                          width: 345.w,
                          decoration: getDefaultWhiteDec2(),
                          child: Column(
                            children: [
                              ghb(8),
                              sbRow([
                                getRichText(
                                    "￥",
                                    priceFormat(
                                        controller.productData["nowPrice"] ??
                                            0),
                                    12,
                                    const Color(0xFFFF5A5F),
                                    16,
                                    const Color(0xFFFF5A5F)),
                                getSimpleText(
                                    "月销：${controller.productData["giftBuyCount"] ?? 0}",
                                    15,
                                    const Color(0xFFD4D4D4)),
                              ], width: 345 - 14 * 2),
                              ghb(13),
                              getWidthText(controller.productData["levelName"],
                                  18, AppColor.textBlack3, 315, 2),
                              ghb(5),
                              getWidthText(
                                  controller.productData["levelDescribe"],
                                  13,
                                  const Color(0xFF525C66),
                                  315,
                                  1000),
                              ghb(8),
                            ],
                          ),
                        ),
                        ghb(14),
                        Container(
                          width: 345.w,
                          decoration: getDefaultWhiteDec2(),
                          child: Column(
                            children: [
                              ghb(8),
                              sbRow([
                                getSimpleText("规则说明", 16, AppColor.textBlack3),
                              ], width: 345 - 14 * 2),
                              ghb(8),
                              SizedBox(
                                width: (345 - 10 * 2).w,
                                child: HtmlWidget(controller
                                        .productData["levelGiftParameter"] ??
                                    ""),
                                // Html(
                                //   data: controller
                                //           .productData["levelGiftParameter"] ??
                                //       "",
                                //   // shrinkWrap: true,
                                //   // style: {
                                //   //   "color": Style(color: const Color(0xFF525C66))
                                //   // },
                                // ),
                              ),
                              ghb(8),
                            ],
                          ),
                        ),
                        ghb(20),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: (48 + 14 * 2).w + paddingSizeBottom(context),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ghb(14),
                      getSubmitBtn("立即购买", () {
                        push(
                            VipStoreConfirmOrder(
                                selectContact: selectContact,
                                productData: controller.productData,
                                toAddressPage: toAddressPage,
                                toAddressOrContactPage: toAddressOrContactPage,
                                alertPayWarn: alertPayWarn),
                            context,
                            binding: VipStoreConfirmOrderBinding());
                      })
                    ],
                  ),
                ))
          ],
        ));
  }
}
