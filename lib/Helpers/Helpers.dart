import 'package:liquid_swipe/PageHelpers/animated_page_dragger.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

/// A constant value with works like a sensitivity of reveal.
/// Used if not mentioned here [LiquidSwipe.fullTransitionValue]
const FULL_TRANSITION_PX = 300.0;

/// Helper Factor for Completing the Animation when user is done with dragging
const PERCENT_PER_MILLISECOND = 0.00125;

///SlideDirections Enum with 3 Values
///[SlideDirection.leftToRight] if user swipes from left to right
///[SlideDirection.rightToLeft] if user swipes from right to left
///[SlideDirection.none] if user is not swipe at all.
enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
  none,
}

/// Returns true if the direction is vertical (topToBottom or bottomToTop).
bool isVerticalDirection(SlideDirection d) =>
    d == SlideDirection.topToBottom || d == SlideDirection.bottomToTop;

/// Returns true if the direction is a "previous page" direction (leftToRight or topToBottom).
bool isPreviousDirection(SlideDirection d) =>
    d == SlideDirection.leftToRight || d == SlideDirection.topToBottom;

/// Returns true if the direction is a "next page" direction (rightToLeft or bottomToTop).
bool isNextDirection(SlideDirection d) =>
    d == SlideDirection.rightToLeft || d == SlideDirection.bottomToTop;

///UpdateType Enum with 4 values
///[UpdateType.dragging] when user starts dragging or currently being dragging
///[UpdateType.doneDragging] when user is done with dragging
///[UpdateType.animating] when we are manually animating the Swipe using [AnimatedPageDragger]
///[UpdateType.doneAnimating] we are done with animating now update values like currentPage and nextPage etc.
///
/// Flow will always be [UpdateType.dragging] > [UpdateType.doneDragging] > [UpdateType.animating] > [UpdateType.doneAnimating]
enum UpdateType {
  dragging,
  doneDragging,
  animating,
  doneAnimating,
}

///Current Transition in the LiquidSwipe, whether to open the reveal or close the reveal
enum TransitionGoal {
  open,
  close,
}

///WaveType :  Type of wave you want currently support 2, [WaveType.circularReveal] and [WaveType.liquidReveal]
///see also : [LiquidSwipe.waveType]
enum WaveType {
  circularReveal,
  liquidReveal,
}

///Utils Methods
mixin Utils {
  ///Temporary fix to the misalignment of the icon.
  static double handleIconAlignment(double ver) {
    if (ver > 0.5) {
      ver += (0.5 - ver).abs() / 20;
    } else {
      ver -= (0.5 - ver).abs() / 15;
    }
    return ver;
  }
}
