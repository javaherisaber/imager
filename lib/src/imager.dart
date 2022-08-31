library imager;

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imager/src/extensions/widget.dart';

/// Utility class to conveniently create image and transform it
class Imager {
  static const BoxDecoration _circle = BoxDecoration(
    shape: BoxShape.circle,
  );
  static String placeholderPath = 'assets/drawable/placeholder.png';

  /// Create an image from memory with [bytes]
  ///
  /// [backOffSizing] determine whether to use backOff dimension if not set
  /// eg. if width is not set, use height instead
  /// [enableMirror] will make your image mirrored!
  static Widget fromMemory(
    Uint8List bytes, {
    double? width,
    double? height,
    Color? color,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool isCircle = false,
    BoxFit fit = BoxFit.contain,
    bool backOffSizing = true,
    bool enableMirror = false,
  }) {
    double? measuredHeight = height ?? (backOffSizing ? width : null);
    double? measuredWidth = width ?? (backOffSizing ? height : null);
    Widget image = Image.memory(
      bytes,
      width: measuredWidth,
      height: measuredHeight,
      color: color,
      fit: fit,
    );
    return Container(
      padding: padding,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: isCircle == true ? _circle : decoration,
      child: image,
    ).makeMirror(enableMirror);
  }

  /// Create an image from [file]
  ///
  /// [backOffSizing] determine whether to use backOff dimension if not set
  /// eg. if width is not set, use height instead
  /// [enableMirror] will make your image mirrored!
  static Widget fromFile(
    File file, {
    double? width,
    double? height,
    Color? color,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool isCircle = false,
    BoxFit fit = BoxFit.contain,
    bool backOffSizing = true,
    bool enableMirror = false,
  }) {
    double? measuredHeight = height ?? (backOffSizing ? width : null);
    double? measuredWidth = width ?? (backOffSizing ? height : null);
    Widget image = Image.file(
      file,
      width: measuredWidth,
      height: measuredHeight,
      color: color,
      fit: fit,
    );
    return Container(
      padding: padding,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: isCircle == true ? _circle : decoration,
      child: image,
    ).makeMirror(enableMirror);
  }

  /// Create an image from [assetName] of your local assets
  ///
  /// [backOffSizing] determine whether to use backOff dimension if not set
  /// eg. if width is not set, use height instead
  /// [enableMirror] will make your image mirrored!
  static Widget fromLocal(
    String assetName, {
    double? width,
    double? height,
    Color? color,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool isCircle = false,
    BoxFit fit = BoxFit.contain,
    bool backOffSizing = true,
    bool enableMirror = false,
  }) {
    bool isSvg = assetName.split('.')[1] == 'svg';
    double? measuredHeight = height ?? (backOffSizing ? width : null);
    double? measuredWidth = width ?? (backOffSizing ? height : null);
    Widget image;
    if (isSvg) {
      image = SvgPicture.asset(
        assetName,
        height: measuredHeight,
        width: measuredWidth,
        color: color,
        fit: fit,
        placeholderBuilder: (context) {
          return SizedBox(width: measuredWidth, height: measuredHeight);
        },
      );
    } else {
      image = Image.asset(
        assetName,
        width: measuredWidth,
        height: measuredHeight,
        color: color,
        fit: fit,
      );
    }
    return Container(
      padding: padding,
      margin: margin,
      decoration: isCircle == true ? _circle : decoration,
      child: image,
    ).makeMirror(enableMirror);
  }

  /// Fetch the image from [url], cache it and load into a proper widget
  ///
  /// [backOffSizing] determine whether to use backOff dimension if not set
  /// eg. if width is not set, use height instead
  /// [enableMirror] will make your image mirrored!
  static Widget fromNetwork(String? url,
      {double? width,
      double? height,
      Color? color,
      BoxDecoration? decoration,
      EdgeInsets? padding,
      EdgeInsets? margin,
      String? placeholder,
      bool showPlaceholder = true,
      bool isCircle = false,
      BoxFit fit = BoxFit.contain,
      BoxFit placeholderFit = BoxFit.contain,
      bool backOffSizing = true,
      bool enableMirror = false}) {
    double? measuredHeight = height ?? (backOffSizing ? width : null);
    double? measuredWidth = width ?? (backOffSizing ? height : null);
    Widget placeholderImage = fromLocal(
      placeholder ?? placeholderPath,
      width: width,
      height: height,
      decoration: decoration,
      padding: padding,
      margin: margin,
      isCircle: isCircle,
      fit: placeholderFit,
      backOffSizing: backOffSizing,
    );
    Widget emptySpace = SizedBox(
      height: measuredHeight,
      width: measuredWidth,
    );
    if (url == null) {
      return showPlaceholder ? placeholderImage : emptySpace;
    }
    if (url.endsWith('.svg')) {
      return SvgPicture.network(
        url,
        height: measuredHeight,
        width: measuredWidth,
        color: color,
        fit: fit,
        placeholderBuilder: (context) {
          return showPlaceholder ? placeholderImage : emptySpace;
        },
      );
    } else if (url.endsWith('.gif')) {
      return Image.network(
        url,
        height: measuredHeight,
        width: measuredWidth,
        color: color,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            showPlaceholder ? placeholderImage : emptySpace,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return showPlaceholder ? placeholderImage : emptySpace;
        },
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      color: color,
      imageBuilder: (context, imageProvider) {
        final decorationImage = DecorationImage(image: imageProvider, fit: fit);
        return Container(
          padding: padding,
          margin: margin,
          width: measuredWidth,
          height: measuredHeight,
          decoration: isCircle == true
              ? _circle.copyWith(image: decorationImage)
              : (decoration ?? const BoxDecoration())
                  .copyWith(image: decorationImage),
        );
      },
      errorWidget: (context, url, _) =>
          showPlaceholder ? placeholderImage : emptySpace,
      placeholder: (context, url) =>
          showPlaceholder ? placeholderImage : emptySpace,
    ).makeMirror(enableMirror);
  }

  /// Create a [DecorationImage] from local [assetName]
  static DecorationImage decorationImage(
    String assetName, {
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
  }) {
    return DecorationImage(
      image: AssetImage(assetName),
      alignment: alignment,
      repeat: repeat,
      fit: fit,
    );
  }
}
