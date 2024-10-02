import 'dart:math';

import 'package:flutter/material.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'rtc_video_renderer_impl.dart';

class RTCVideoView extends StatelessWidget {
  RTCVideoView(
    this._renderer, {
    super.key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
    this.filterQuality = FilterQuality.low,
    this.placeholderBuilder,
  });

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  final FilterQuality filterQuality;
  final WidgetBuilder? placeholderBuilder;

  RTCVideoRenderer get videoRenderer => _renderer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            _buildVideoView(context, constraints));
  }

  BoxFit getFitForObjectFit(RTCVideoViewObjectFit objectFit) {
    switch (objectFit) {
      case RTCVideoViewObjectFit.RTCVideoViewObjectFitContain:
        return BoxFit.contain;
      case RTCVideoViewObjectFit.RTCVideoViewObjectFitCover:
        return BoxFit.cover;
      case RTCVideoViewObjectFit.RTCVideoViewObjectFitFitFill:
        return BoxFit.fill;
      case RTCVideoViewObjectFit.RTCVideoViewObjectFitFitHeight:
        return BoxFit.fitHeight;
      case RTCVideoViewObjectFit.RTCVideoViewObjectFitFitScaleDown:
        return BoxFit.scaleDown;
      case RTCVideoViewObjectFit.RTCVideoViewObjectFitFitWidth:
        return BoxFit.fitWidth;
      default:
        return BoxFit.contain;
    }
  }

  Widget _buildVideoView(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          fit: getFitForObjectFit(objectFit),
          child: Center(
            child: ValueListenableBuilder<RTCVideoValue>(
              valueListenable: videoRenderer,
              builder:
                  (BuildContext context, RTCVideoValue value, Widget? child) {
                return SizedBox(
                  width: constraints.maxHeight * value.aspectRatio,
                  height: constraints.maxHeight,
                  child: child,
                );
              },
              child: Transform(
                transform: Matrix4.identity()..rotateY(mirror ? -pi : 0.0),
                alignment: FractionalOffset.center,
                child: videoRenderer.renderVideo
                    ? Texture(
                        textureId: videoRenderer.textureId!,
                        filterQuality: filterQuality,
                      )
                    : placeholderBuilder?.call(context) ?? Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
