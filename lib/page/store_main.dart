import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletons/skeletons.dart';
import 'package:store_plugin/EventBus.dart';
import 'package:store_plugin/component/custom_button.dart';
import 'package:store_plugin/component/custom_empty_view.dart';
import 'package:store_plugin/component/custom_network_image.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/notify_default.dart';
import 'package:store_plugin/page/vip_store_detail.dart';
import 'package:store_plugin/service/urls.dart';
import 'package:store_plugin/third/get/get.dart';
import 'package:store_plugin/third/pull_refresh/pull_to_refresh.dart';
import 'package:store_plugin/third/screenutil/flutter_screenutil.dart';

class StoreMainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StoreMainController>(StoreMainController());
  }
}

class StoreMainController extends GetxController {
  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (_topIndex.value != v) {
      _topIndex.value = v;
      update();
      loadList();
    }
  }

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  // RefreshController pullCtrl = RefreshController();
  List pageNos = [];
  List pageSizes = [];
  List counts = [];

  onLoad() {
    loadList(isLoad: true);
  }

  onRefresh() {
    loadList();
  }

  List dataList = [];

  int levelType = 1;

  loadList({bool isLoad = false}) {
    isLoad ? pageNos[topIndex]++ : pageNos[topIndex] = 1;
    if (dataList[topIndex].isEmpty) {
      isLoading = true;
    }
    Map<String, dynamic> params = {
      "level_Type": levelType,
      "pageSize": pageSizes[topIndex],
      "pageNo": pageNos[topIndex],
    };
    if (!hideFilter) {
      if (xhList.isNotEmpty && topIndex <= xhList.length - 1) {
        if (xhList[topIndex]["enumValue"] != -1) {
          // params["tmId"] = xhList[topIndex]["enumValue"];
          params["tbId"] = xhList[topIndex]["enumValue"];
        }
      }
    }

    simpleRequest(
      url: Urls.memberList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[topIndex] = data["count"];
          isLoad
              ? dataList[topIndex] = [
                  ...dataList[topIndex],
                  ...(data["data"] ?? [])
                ]
              : dataList[topIndex] = data["data"] ?? [];
          // isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          update();
        } else {
          // isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  @override
  void onInit() {
    loadXh();
    loadList();
    super.onInit();
  }

  List xhList = [];
  loadXh() {
    Map publicHomeData = CXStoreConfig().publicHomeData;
    // Map userData = await getUserData();
    // // Map homeData = userData["homeData"];
    // Map publicHomeData = userData["publicHomeData"];
    // if (publicHomeData.isNotEmpty &&
    //     publicHomeData["terminalBrand"].isNotEmpty &&
    //     publicHomeData["terminalBrand"] is List) {
    //   ppList = (publicHomeData["terminalBrand"] as List)
    //       .map((e) => {...e, "selected": false})
    //       .toList();

    //   update([ppListBuildId]);
    // }
    // if (publicHomeData.isNotEmpty &&
    //     publicHomeData["terminalConfig"].isNotEmpty &&
    //     publicHomeData["terminalConfig"] is List) {
    //   zcList = (publicHomeData["terminalConfig"] as List)
    //       .map((e) => {...e, "selected": false})
    //       .toList();
    //   update([zcListBuildId]);
    // }
    // if (publicHomeData.isNotEmpty &&
    //     publicHomeData["terminalMod"] != null &&
    //     publicHomeData["terminalMod"].isNotEmpty &&
    //     publicHomeData["terminalMod"] is List) {
    //   xhList = [
    //     {"enumValue": -1, "enumName": "全部"},
    //     ...publicHomeData["terminalMod"]
    //   ].map((e) => {...e, "selected": false}).toList();
    //   dataList = [];
    //   pageNos = [];
    //   pageSizes = [];
    //   counts = [];
    //   for (var e in xhList) {
    //     dataList.add([]);
    //     pageNos.add(1);
    //     pageSizes.add(20);
    //     counts.add(0);
    //   }
    if (!hideFilter &&
        publicHomeData.isNotEmpty &&
        publicHomeData["terminalBrand"] != null &&
        publicHomeData["terminalBrand"].isNotEmpty &&
        publicHomeData["terminalBrand"] is List) {
      xhList = (publicHomeData["terminalBrand"] as List)
          .map((e) => {...e, "selected": false})
          .toList();
      dataList = [];
      pageNos = [];
      pageSizes = [];
      counts = [];
      for (var e in xhList) {
        dataList.add([]);
        pageNos.add(1);
        pageSizes.add(20);
        counts.add(0);
      }
      // update([xhListBuildId]);
    } else {
      dataList.add([]);
      pageNos.add(1);
      pageSizes.add(20);
      counts.add(0);
    }
  }

  bool isFirst = true;
  Function()? backAction;
  bool hideFilter = true;

  dataInit(Function()? back, bool hide, int lType) {
    if (!isFirst) return;
    isFirst = true;
    backAction = back;
    hideFilter = hide;
    levelType = lType;
    bus.on(NOTIFY_BACK_TO_MAIN_PLUGIN, backToMainNotify);
  }

  backToMainNotify(arg) {
    needBack();
  }

  needBack() {
    if (backAction != null) {
      backAction!();
    }
  }

  @override
  void onClose() {
    bus.off(NOTIFY_BACK_TO_MAIN_PLUGIN, backToMainNotify);
    // pullCtrl.dispose();
    super.onClose();
  }
}

class StoreMain extends GetView<StoreMainController> {
  final String title;
  final bool hideFilter;
  final bool selectContact;

  final Function()? backAction;
  final Function(dynamic getCtrl)? toAddressPage;
  final Function(dynamic getCtrl, int deliveryType)? toAddressOrContactPage;
  final Function()? alertPayWarn;

  final int levelType;

  const StoreMain(
      {super.key,
      this.title = "VIP礼包",
      this.backAction,
      this.toAddressPage,
      this.toAddressOrContactPage,
      this.selectContact = false,
      this.alertPayWarn,
      this.hideFilter = false,
      this.levelType = 1});

  @override
  Widget build(BuildContext context) {
    controller.dataInit(backAction, hideFilter, levelType);
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        title,
        blueBackground: true,
        white: true,
        backPressed: () {
          controller.needBack();
        },
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          hideFilter
              ? gemp()
              : Positioned(
                  top: -1.w,
                  left: 0,
                  right: 0,
                  height: 33.w,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      CXStoreConfig().getThemeColor() ??
                          const Color(0xFF6796F5),
                      CXStoreConfig().getThemeColor(index: 2) ??
                          const Color(0xFF2368F2),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                            controller.xhList.length,
                            (index) => topBtn(index,
                                controller.xhList[index]["enumName"] ?? "")),
                      ),
                    ),
                  )),
          Positioned(
              top: hideFilter ? 0 : 33.w,
              left: 0,
              right: 0,
              bottom: 0,
              child: GetBuilder<StoreMainController>(
                builder: (_) {
                  int count = controller.counts[controller.topIndex];
                  List datas = controller.dataList[controller.topIndex];
                  return EasyRefresh(
                    // controller: controller.pullCtrl,
                    // onLoading: controller.onLoad,
                    header: const CupertinoHeader(),
                    footer: const CupertinoFooter(),
                    onLoad: datas.length >= count
                        ? null
                        : () => controller.loadList(isLoad: true),
                    onRefresh: () => controller.loadList(),
                    // enablePullUp: count > datas.length,
                    child: GetX<StoreMainController>(
                      builder: (_) {
                        return Skeleton(
                            isLoading: controller.isFirstLoading,
                            skeleton: SkeletonListView(
                              item: SkeletonItem(
                                  child: Column(
                                children: [
                                  ghb(15),
                                  Row(
                                    children: [
                                      SkeletonAvatar(
                                        style: SkeletonAvatarStyle(
                                            shape: BoxShape.rectangle,
                                            width: 130.w,
                                            height: 130.w),
                                      ),
                                      gwb(10),
                                      Expanded(
                                        child: SkeletonParagraph(
                                          style: SkeletonParagraphStyle(
                                              lines: 4,
                                              spacing: 10.w,
                                              lineStyle: SkeletonLineStyle(
                                                randomLength: true,
                                                height: 20.w,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                // minLength: 150.w,
                                                // maxLength: 160.w,
                                              )),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )),
                            ),
                            child: datas.isEmpty
                                ? GetX<StoreMainController>(
                                    builder: (_) {
                                      return SingleChildScrollView(
                                        child: Center(
                                          child: CustomEmptyView(
                                            isLoading: controller.isLoading,
                                            bottomSpace: 200,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.only(bottom: 20.w),
                                    itemCount: datas.length,
                                    itemBuilder: (context, index) {
                                      return storeCell(index, datas[index]);
                                    },
                                  ));
                      },
                    ),
                  );
                },
              ))
        ],
      ),
    );
  }

  Widget storeCell(int index, Map data) {
    // String imUrl = CXStoreConfig().imageUrl + (data["levelGiftImg"] ?? "");
    return Align(
      child: CustomButton(
        onPressed: () {
          push(
              VipStoreDetail(
                  selectContact: selectContact,
                  productData: data,
                  toAddressPage: toAddressPage,
                  toAddressOrContactPage: toAddressOrContactPage,
                  alertPayWarn: alertPayWarn),
              null,
              binding: VipStoreDetailBinding());
        },
        child: Container(
          width: 345.w,
          height: 132.w,
          margin: EdgeInsets.only(top: 12.w),
          decoration: getDefaultWhiteDec2(radius: 10),
          child: sbRow([
            ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: CustomNetworkImage(
                src: CXStoreConfig().imageUrl + (data["levelGiftImg"] ?? ""),
                width: 132.w,
                height: 132.w,
                fit: BoxFit.fill,
              ),
            ),
            centRow([
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  centClm([
                    ghb(8),
                    getWidthText(data["levelName"] ?? "", 15,
                        const Color(0xFF2D3033), 189, 2),
                  ]),
                  getWidthText(data["levelDescribe"] ?? "", 13,
                      const Color(0xFF525C66), 189, 2),
                  centClm([
                    sbRow([
                      getRichText("￥", priceFormat(data["nowPrice"] ?? 0), 14,
                          const Color(0xFFFF5A5F), 18, const Color(0xFFFF5A5F)),
                      Container(
                        width: 63.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13.w),
                            gradient: LinearGradient(
                                colors: [
                                  CXStoreConfig().getThemeColor() ??
                                      const Color(0xFF6796F5),
                                  CXStoreConfig().getThemeColor(index: 2) ??
                                      const Color(0xFF2368F2)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight)),
                        child: Center(
                            child: getSimpleText("去购买", 13, Colors.white)),
                      )
                    ], width: 189),
                    ghb(8)
                  ])
                ],
              ),
              gwb(12)
            ])
          ]),
        ),
      ),
    );
  }

  Widget topBtn(int index, String t1) {
    return GetX<StoreMainController>(
      initState: (_) {},
      builder: (_) {
        return CustomButton(
          onPressed: () {
            controller.topIndex = index;
          },
          child: SizedBox(
            width: 375.w / 4 - 0.1.w,
            height: 33.w,
            child: Center(
              child: centClm([
                getSimpleText(t1, 14, Colors.white),
                ghb(controller.topIndex == index ? 3 : 0),
                controller.topIndex == index
                    ? Container(
                        width: 30.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2.w)),
                      )
                    : ghb(0),
              ]),
            ),
          ),
        );
      },
    );
  }
}
