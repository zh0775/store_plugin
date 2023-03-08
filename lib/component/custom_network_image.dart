import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:store_plugin/cxstore_config.dart';
import 'package:store_plugin/third/get/get.dart';

class CustomNetworkImageController extends GetxController {
  final _showImage = false.obs;
  get showImage => _showImage.value;
  set showImage(v) => _showImage.value = v;

  String src = "";
  dataInit(String str) async {
    if (!showImage) {
      src = str;
      try {
        var request = await HttpClient().getUrl(Uri.parse(src));
        var response = await request.close();
        if (response.statusCode == HttpStatus.ok) {
          showImage = true;
        } else {
          showImage = false;
        }
        update();
      } catch (e) {
        showImage = false;
      }
    }
  }
}

class CustomNetworkImage extends StatelessWidget {
  final String src;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Color? color;
  final Alignment alignment;
  final Color? errorColor;
  final Widget? errorWidget;
  final Function(bool success)? loadResult;
  const CustomNetworkImage(
      {Key? key,
      required this.src,
      this.fit,
      this.width,
      this.height,
      this.loadResult,
      this.alignment = Alignment.center,
      this.color,
      this.errorWidget,
      this.errorColor})
      : super(key: key);
  // final controller = CustomNetworkImageController();

  @override
  Widget build(BuildContext context) {
    String imageUrl = CXStoreConfig().imageView.isNotEmpty
        ? "$src?${CXStoreConfig().imageView}"
        : src;

    return imageUrl.contains("localhost")
        ? Container(
            width: width,
            height: height,
            color: Colors.transparent,
          )
        :

        // GetBuilder<CustomNetworkImageController>(
        //   init: CustomNetworkImageController(),
        //   builder: (controller) {
        //     // controller.dataInit(src);
        //     return
        CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            width: width,
            color: color,
            alignment: alignment,
            height: height,
            // imageBuilder: (context, imageProvider) {
            //   return Container(
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //           image: imageProvider,
            //           fit: BoxFit.cover,
            //           colorFilter:
            //               const ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
            //     ),
            //   );
            // },
            progressIndicatorBuilder: (context, url, progress) {
              if (progress.progress == null || progress.progress == 1.0) {
                if (loadResult != null) {
                  loadResult!(true);
                }
              }
              // print("progress.downloaded; === ${progress.progress}");
              return gemp();
            },
            // placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) {
              if (loadResult != null) {
                loadResult!(false);
              }
              return Container(
                width: width,
                height: height,
                color: Colors.transparent,
              );
            },
          );
    // controller.showImage ?
    // Image.network(
    //   AppDefault().imageView.isNotEmpty
    //       ? "$src?${AppDefault().imageView}"
    //       : src,
    //   fit: fit,
    //   width: width,
    //   color: color,
    //   alignment: alignment,
    //   height: height,
    //   errorBuilder: (context, error, stackTrace) {
    //     return errorWidget ??
    //         Container(
    //           width: width,
    //           height: height,
    //           color: errorColor ?? Colors.transparent,
    //         );
    //     // Image.asset(assetsName("common/bg_empty0"),
    //     //     width: width, height: height, fit: fit);
    //   },
    //   loadingBuilder: (context, child, loadingProgress) {
    //     // if (loadingProgress == null) {
    //     //   if (context.widget is Image) {
    //     //     Image image = context.widget as Image;
    //     //     if (image.image is NetworkImage) {
    //     //       NetworkImage networkImage = image.image as NetworkImage;
    //     //       print(
    //     //           "CustomNetworkImage load_image_success === ${networkImage.url}");
    //     //     }
    //     //   }
    //     // }
    //     return loadingProgress == null
    //         ? child
    //         :
    //         // Image.asset(assetsName("common/bg_empty0"),
    //         //     width: width, height: height, fit: fit);
    // Container(
    //     width: width,
    //     height: height,
    //     color: Colors.transparent,
    //   );
    //   },
    // )
    // : Center(
    //     child: SizedBox(
    //       width: width,
    //       height: height,
    //     ),
    //   )

    //   },
    // );
    // try {
    //   return Image.network(
    //     src,
    //     fit: fit,
    //     width: width,
    //     height: height,
    //     errorBuilder: (context, error, stackTrace) {
    //       return Image.asset(assetsName("common/bg_empty0"),
    //           width: width, height: height, fit: fit);
    //     },
    //     loadingBuilder: (context, child, loadingProgress) {
    //       return loadingProgress == null
    //           ? child
    //           : Image.asset(assetsName("common/bg_empty0"),
    //               width: width, height: height, fit: fit);
    //     },
    //   );
    // } catch (e) {
    //   return Image.asset(assetsName("common/bg_empty0"),
    //       width: width, height: height, fit: fit);
    // }
  }
}
