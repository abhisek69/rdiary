import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum LoaderType {
  newtonCradle,
  staggeredDotsWave,
  threeArchedCircle,
  fourRotatingDots,
  inkDrop,
  flickr,
  hexagonDots,
  halfTriangleDot,
  horizontalRotatingDots,
  discreteCircle,
  waveDots,
  twoRotatingArc,
  threeRotatingDots,
}

class AppLoader extends StatelessWidget {
  final Color loadingColor;
  final double size;
  final LoaderType type;

  const AppLoader({
    super.key,
    required this.loadingColor,
    this.size = 80,
    this.type = LoaderType.newtonCradle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildLoader(),
    );
  }

  Widget _buildLoader() {
    switch (type) {
      case LoaderType.newtonCradle:
        return LoadingAnimationWidget.newtonCradle(
          color: loadingColor,
          size: size,
        );

      case LoaderType.staggeredDotsWave:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: loadingColor,
          size: size,
        );

      case LoaderType.threeArchedCircle:
        return LoadingAnimationWidget.threeArchedCircle(
          color: loadingColor,
          size: size,
        );

      case LoaderType.fourRotatingDots:
        return LoadingAnimationWidget.fourRotatingDots(
          color: loadingColor,
          size: size,
        );

      case LoaderType.inkDrop:
        return LoadingAnimationWidget.inkDrop(
          color: loadingColor,
          size: size,
        );

      case LoaderType.flickr:
        return LoadingAnimationWidget.flickr(
          leftDotColor: loadingColor,
          rightDotColor: loadingColor.withOpacity(0.6),
          size: size,
        );

      case LoaderType.hexagonDots:
        return LoadingAnimationWidget.hexagonDots(
          color: loadingColor,
          size: size,
        );

      case LoaderType.halfTriangleDot:
        return LoadingAnimationWidget.halfTriangleDot(
          color: loadingColor,
          size: size,
        );

      case LoaderType.horizontalRotatingDots:
        return LoadingAnimationWidget.horizontalRotatingDots(
          color: loadingColor,
          size: size,
        );

      case LoaderType.discreteCircle:
        return LoadingAnimationWidget.discreteCircle(
          color: loadingColor,
          size: size,
        );



      case LoaderType.waveDots:
        return LoadingAnimationWidget.waveDots(
          color: loadingColor,
          size: size,
        );

      case LoaderType.twoRotatingArc:
        return LoadingAnimationWidget.twoRotatingArc(
          color: loadingColor,
          size: size,
        );

      case LoaderType.threeRotatingDots:
        return LoadingAnimationWidget.threeRotatingDots(
          color: loadingColor,
          size: size,
        );
    }
  }
}
