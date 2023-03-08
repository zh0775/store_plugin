import 'package:flutter/material.dart';
import 'package:store_plugin/third/get/get.dart';
import 'package:store_plugin/app_color.dart';
import 'package:store_plugin/cxstore_config.dart';

enum OrderResultType {
  orderResultTypeIntegral,
  orderResultTypePackage,
  orderResultTypeProduct,
}

enum StoreOrderType {
  storeOrderTypeIntegral,
  storeOrderTypePackage,
  storeOrderTypeProduct,
}

class ProductPayResultPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductPayResultPageController>(ProductPayResultPageController());
  }
}

class ProductPayResultPageController extends GetxController {}

class ProductPayResultPage extends StatelessWidget {
  final OrderResultType type;
  final bool success;
  final Map orderData;
  final String subContent;
  const ProductPayResultPage({
    Key? key,
    this.type = OrderResultType.orderResultTypePackage,
    this.orderData = const {},
    this.success = true,
    this.subContent = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        "",
        backPressed: () {
          popToUntil();
        },
      ),
      body: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              top: paddingSizeTop(context),
              bottom: paddingSizeBottom(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  centClm([
                    Image.asset(
                      assetsName(
                          "store/bg_pay_${success ? "success" : "fail"}"),
                      width: 101.5,
                      fit: BoxFit.fitWidth,
                      package: PLUGIN_PACKAGE,
                    ),
                    ghb(50),
                    getSimpleText(
                        "支付${success ? "成功" : "失败"}", 22, AppColor.textBlack,
                        isBold: true),
                    ghb(20),
                    getWidthText(subContent, 15, AppColor.textGrey, 315, 10),
                  ]),
                  centClm([
                    getSubmitBtn("返回首页", () {
                      popToUntil();
                    }),
                    ghb(7),
                    getSubmitBtn("查看订单", () {
                      if (type == OrderResultType.orderResultTypeIntegral) {
                        // toIntegralPayResult(
                        //   toOrderDetail: true,
                        //   orderData: orderData,
                        // );
                      } else {
                        toPayResult(
                            toOrderDetail: true,
                            orderData: orderData,
                            orderType:
                                type == OrderResultType.orderResultTypePackage
                                    ? StoreOrderType.storeOrderTypePackage
                                    : StoreOrderType.storeOrderTypeProduct);
                      }
                    }, color: Colors.white, textColor: AppColor.textBlack),
                    ghb(50),
                  ]),
                ],
              ))
        ],
      ),
    );
  }
}
