import 'package:flutter/material.dart';
import 'package:liquid_swipe/Helpers/Helpers.dart';
import 'package:liquid_swipe/Helpers/SlideUpdate.dart';
import 'package:liquid_swipe/Provider/LiquidProvider.dart';
import 'package:provider/provider.dart';
import 'page_reveal.dart';

/// Internal Widget
///
/// PageDragger is a Widget that handles user gestures and provide the data to the [LiquidProvider]
/// from where we perform animations various other methods.
class PageDragger extends StatefulWidget {
  final double horizontalReveal;
  final Widget child;
  final SlideDirection? slideDirection;
  final Size iconSize;
  final WaveType waveType;
  final double verticalReveal;
  final bool enableSideReveal;
  final bool preferDragFromRevealedArea;

  /// Used to make animation faster or slower through it corresponding value
  /// default : [FULL_TRANSITION_PX]
  final double fullTransitionPX;

  /// Slide Icon whichever provided
  final Widget? slideIconWidget;

  /// double value should range from 0.0 - 1.0
  final double? iconPosition;

  /// boolean parameter to make user gesture disabled which LiquidSwipe is still Animating
  final bool ignoreUserGestureWhileAnimating;

  /// The axis along which swipe gestures are detected.
  final Axis swipeAxis;

  ///Constructor with some default values
  PageDragger({
    required this.horizontalReveal,
    required this.child,
    this.slideDirection,
    required this.iconSize,
    required this.waveType,
    required this.verticalReveal,
    required this.enableSideReveal,
    required this.preferDragFromRevealedArea,
    this.fullTransitionPX = FULL_TRANSITION_PX,
    this.slideIconWidget,
    this.iconPosition,
    this.ignoreUserGestureWhileAnimating = false,
    this.swipeAxis = Axis.horizontal,
  });

  @override
  _PageDraggerState createState() => _PageDraggerState();
}

///State for PageDragger
class _PageDraggerState extends State<PageDragger> {
  GlobalKey _keyIcon = GlobalKey();

  ///Current [Offset] of the User Touch
  Offset? dragStart;

  ///Calculated Slide Direction of the Gesture/Swipe
  SlideDirection slideDirection = SlideDirection.none;

  ///Primary reveal percentage (horizontal for h-axis, vertical for v-axis), ranges from 0.0 - 1.0
  double slidePercentHor = 0.0;

  ///Secondary axis percentage, ranges from 0.0 - 1.0
  double slidePercentVer = 0.0;

  bool get _isVertical => widget.swipeAxis == Axis.vertical;

  /// Method invoked when ever user touch the screen and drag starts
  onDragStart(DragStartDetails details) {
    final model = Provider.of<LiquidProvider>(context, listen: false);

    ///Ignoring user gesture if the animation is running (optional)
    if (model.isAnimating && widget.ignoreUserGestureWhileAnimating ||
        model.isUserGestureDisabled) {
      return;
    }
    dragStart = details.globalPosition;
  }

  ///Updating data while user drags and touch offset changes
  onDragUpdate(DragUpdateDetails details) {
    if (dragStart != null) {
      //Getting new position details
      final newPosition = details.globalPosition;

      slideDirection = SlideDirection.none;

      if (_isVertical) {
        // Vertical mode: primary axis is dy
        final dy = dragStart!.dy - newPosition.dy;

        if (dy > 0.0) {
          slideDirection = SlideDirection.bottomToTop;
        } else if (dy < 0.0) {
          slideDirection = SlideDirection.topToBottom;
        }

        if (slideDirection != SlideDirection.none) {
          slidePercentHor =
              (dy / widget.fullTransitionPX).abs().clamp(0.0, 1.0);
          slidePercentVer =
              (newPosition.dx / MediaQuery.of(context).size.width)
                  .abs()
                  .clamp(0.0, 1.0);
        }
      } else {
        // Horizontal mode (existing behavior)
        final dx = dragStart!.dx - newPosition.dx;
        final dy = newPosition.dy;

        if (dx > 0.0) {
          slideDirection = SlideDirection.rightToLeft;
        } else if (dx < 0.0) {
          slideDirection = SlideDirection.leftToRight;
        }

        if (slideDirection != SlideDirection.none) {
          slidePercentHor =
              (dx / widget.fullTransitionPX).abs().clamp(0.0, 1.0);
          slidePercentVer =
              (dy / MediaQuery.of(context).size.height).abs().clamp(0.0, 1.0);
        }
      }

      Provider.of<LiquidProvider>(context, listen: false)
          .updateSlide(SlideUpdate(
        slideDirection,
        slidePercentHor,
        slidePercentVer,
        UpdateType.dragging,
      ));
    }
  }

  ///This method executes when user ends dragging and leaves the screen
  onDragEnd(DragEndDetails details) {
    Provider.of<LiquidProvider>(context, listen: false).updateSlide(SlideUpdate(
      SlideDirection.none,
      slidePercentHor,
      slidePercentVer,
      UpdateType.doneDragging,
    ));

    //Making dragStart to null for the reallocation
    slidePercentHor = slidePercentVer = 0;
    slideDirection = SlideDirection.none;
    dragStart = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.slideIconWidget != null)
        Provider.of<LiquidProvider>(context, listen: false)
            .setIconSize(_keyIcon.currentContext!.size!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LiquidProvider>(context, listen: false);

    // Choose drag callbacks based on axis
    final GestureDragStartCallback? onStart = model.isInProgress ? null : onDragStart;
    final GestureDragUpdateCallback? onUpdate = model.isInProgress ? null : onDragUpdate;
    final GestureDragEndCallback? onEnd = model.isInProgress ? null : onDragEnd;

    // Build icon alignment based on axis
    final iconAlignment = _isVertical
        ? Alignment(
            -1.0 + Utils.handleIconAlignment(widget.iconPosition!) * 2,
            1 - slidePercentHor,
          )
        : Alignment(
            1 - slidePercentHor,
            -1.0 + Utils.handleIconAlignment(widget.iconPosition!) * 2,
          );

    final hideIcon = _isVertical
        ? slideDirection == SlideDirection.topToBottom
        : slideDirection == SlideDirection.leftToRight;

    return GestureDetector(
        behavior: widget.preferDragFromRevealedArea
            ? HitTestBehavior.translucent
            : null,
        onHorizontalDragStart:
            widget.preferDragFromRevealedArea && !_isVertical ? onStart : null,
        onHorizontalDragUpdate:
            widget.preferDragFromRevealedArea && !_isVertical ? onUpdate : null,
        onHorizontalDragEnd:
            widget.preferDragFromRevealedArea && !_isVertical ? onEnd : null,
        onVerticalDragStart:
            widget.preferDragFromRevealedArea && _isVertical ? onStart : null,
        onVerticalDragUpdate:
            widget.preferDragFromRevealedArea && _isVertical ? onUpdate : null,
        onVerticalDragEnd:
            widget.preferDragFromRevealedArea && _isVertical ? onEnd : null,
        child: Stack(
          children: [
            PageReveal(
              //next page reveal
              horizontalReveal: widget.horizontalReveal,
              slideDirection: widget.slideDirection,
              iconSize: widget.iconSize,
              waveType: widget.waveType,
              verticalReveal: widget.verticalReveal,
              enableSideReveal: widget.enableSideReveal,
              swipeAxis: widget.swipeAxis,
              child: widget.child,
            ),
            GestureDetector(
              behavior: !widget.preferDragFromRevealedArea
                  ? HitTestBehavior.translucent
                  : null,
              onHorizontalDragStart:
                  !widget.preferDragFromRevealedArea && !_isVertical
                      ? onStart
                      : null,
              onHorizontalDragUpdate:
                  !widget.preferDragFromRevealedArea && !_isVertical
                      ? onUpdate
                      : null,
              onHorizontalDragEnd:
                  !widget.preferDragFromRevealedArea && !_isVertical
                      ? onEnd
                      : null,
              onVerticalDragStart:
                  !widget.preferDragFromRevealedArea && _isVertical
                      ? onStart
                      : null,
              onVerticalDragUpdate:
                  !widget.preferDragFromRevealedArea && _isVertical
                      ? onUpdate
                      : null,
              onVerticalDragEnd:
                  !widget.preferDragFromRevealedArea && _isVertical
                      ? onEnd
                      : null,
              child: Align(
                alignment: iconAlignment,
                child: Opacity(
                  opacity: 1 - slidePercentHor,
                  child: !hideIcon && widget.slideIconWidget != null
                      ? SizedBox(
                          key: _keyIcon,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 10.0),
                            child: widget.slideIconWidget,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ));
  }
}
