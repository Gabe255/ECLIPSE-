import 'package:flutter/material.dart';

/// The original ECLIPSE wordmark with a soft light band sweeping across it.
///
/// Used as the minimal startup indicator while the initial config is applied
/// and the ROM scan runs. The glyph keeps its brand gradient; a translucent
/// white glint travels over it via a [ShaderMask] in [BlendMode.srcATop],
/// which paints the moving gradient only where the logo has pixels.
///
/// With [progress] set, the glint's position tracks that value — the shine
/// crosses the logo exactly in step with the scan. With it null, the glint
/// sweeps on its own on a repeating cycle.
class ShimmeringLogo extends StatefulWidget {
  const ShimmeringLogo({super.key, this.width = 280, this.progress});

  /// Rendered width of the logo; height follows the asset's aspect ratio.
  final double width;

  /// Glint position, 0.0 (off the left edge) to 1.0 (off the right edge).
  /// Null selects the ambient self-paced sweep.
  final double? progress;

  @override
  State<ShimmeringLogo> createState() => _ShimmeringLogoState();
}

class _ShimmeringLogoState extends State<ShimmeringLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Sweep position the glint is actually drawn at, republished from
  /// [_controller] at a capped rate. See [_publishSweep].
  final ValueNotifier<double> _sweep = ValueNotifier<double>(0);

  /// Sweep travel required before the glint is redrawn.
  ///
  /// The controller spans the whole sweep over two seconds, so this is about
  /// one 60 Hz frame's worth of movement, or roughly 2% of the logo's width.
  static const double _minSweepDelta = 0.0075;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.addListener(_publishSweep);
    final progress = widget.progress;
    if (progress == null) {
      _controller.repeat();
    } else {
      _controller.value = progress.clamp(0.0, 1.0);
    }
  }

  /// Republishes the controller's position to [_sweep] once the glint has
  /// moved far enough to be worth redrawing.
  ///
  /// Every repaint rebuilds a [ShaderMask], which forces an offscreen
  /// `saveLayer`. Driving that straight off the controller means paying for it
  /// once per vsync, so the same sweep cost four times as much on a 240 Hz
  /// display as on a 60 Hz one while looking identical. It is shown during
  /// startup and library loading, which is where the app can least afford it.
  ///
  /// The gate is distance travelled rather than elapsed wall-clock time. A
  /// 60 Hz display already covers more than [_minSweepDelta] per frame and so
  /// is unaffected, while a 240 Hz one folds four vsyncs into one repaint of
  /// what is the same picture. Throttling on a [Stopwatch] instead would run
  /// off a clock the animation knows nothing about, ignoring `timeDilation`
  /// and never advancing at all under a test's fake clock.
  ///
  /// A controller that has stopped always publishes, so a settled position is
  /// never left short of where it should be.
  void _publishSweep() {
    final double value = _controller.value;
    if (_controller.isAnimating &&
        (value - _sweep.value).abs() < _minSweepDelta) {
      return;
    }
    _sweep.value = value;
  }

  @override
  void didUpdateWidget(ShimmeringLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final progress = widget.progress;
    if (progress != null) {
      // Ease toward the reported progress: scan updates arrive in discrete
      // jumps, and a hard snap reads as flicker rather than a sweep.
      _controller.stop();
      _controller.animateTo(
        progress.clamp(0.0, 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else if (oldWidget.progress != null) {
      // Scan finished: resume the ambient sweep from wherever the band is,
      // so the handoff is seamless.
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_publishSweep);
    _controller.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const glint = Colors.white;
    final clear = glint.withValues(alpha: 0.0);
    final shine = glint.withValues(alpha: 0.55);

    return ValueListenableBuilder<double>(
      valueListenable: _sweep,
      builder: (context, sweep, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              // Slightly diagonal so the band reads as a glint, not a wipe.
              begin: const Alignment(-1.0, -0.4),
              end: const Alignment(1.0, 0.4),
              colors: [clear, clear, shine, clear, clear],
              stops: const [0.0, 0.38, 0.5, 0.62, 1.0],
              transform: _SlidingGradientTransform(sweep),
            ).createShader(bounds);
          },
          // srcATop draws the glint over the logo but only where the logo has
          // alpha, so the brand colors stay visible underneath the sweep.
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(widget.width * 0.22, widget.width * 0.22),
              painter: const _EclipseMarkPainter(),
            ),
            SizedBox(width: widget.width * 0.035),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ECLIPSE',
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFFF4F0FF),
                      fontSize: widget.width * 0.112,
                      fontWeight: FontWeight.w900,
                      letterSpacing: widget.width * 0.012,
                      height: 0.95,
                    ),
                  ),
                  SizedBox(height: widget.width * 0.018),
                  Text(
                    'YOUR GAMING UNIVERSE',
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFFB99AFF),
                      fontSize: widget.width * 0.027,
                      fontWeight: FontWeight.w800,
                      letterSpacing: widget.width * 0.007,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone ECLIPSE eclipse mark for onboarding and secondary displays.
class EclipseLogoMark extends StatelessWidget {
  const EclipseLogoMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _EclipseMarkPainter(),
    );
  }
}

/// Compact vector mark shared by the splash wordmark and the Android icon.
class _EclipseMarkPainter extends CustomPainter {
  const _EclipseMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 64;
    canvas.save();
    canvas.scale(scale);

    final purple = Paint()
      ..color = const Color(0xFFB99AFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    final cyan = Paint()
      ..color = const Color(0xFF65D9E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(const Offset(32, 32), 22, purple);

    final crescent = Path()
      ..moveTo(37, 12)
      ..cubicTo(52, 18, 56, 36, 47, 48)
      ..cubicTo(40, 58, 26, 58, 18, 50)
      ..cubicTo(30, 52, 41, 44, 42, 32)
      ..cubicTo(43, 23, 40, 17, 37, 12);
    canvas.drawPath(
      crescent,
      Paint()
        ..color = const Color(0xFF100B1D)
        ..style = PaintingStyle.fill,
    );

    final orbit = Path()
      ..moveTo(8, 48)
      ..cubicTo(20, 37, 39, 25, 57, 13);
    canvas.drawPath(orbit, cyan);

    final star = Path()
      ..moveTo(51, 4)
      ..lineTo(54, 10)
      ..lineTo(60, 13)
      ..lineTo(54, 16)
      ..lineTo(51, 22)
      ..lineTo(48, 16)
      ..lineTo(42, 13)
      ..lineTo(48, 10)
      ..close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFF4F0FF));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EclipseMarkPainter oldDelegate) => false;
}

/// Slides the shine band across the glyph, 0 → fully off the left edge,
/// 1 → fully off the right edge.
///
/// The travel range is wider than the logo so the band fully clears both
/// edges — in ambient mode that also gives a short rest between passes.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.progress);

  final double progress;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final dx = bounds.width * (progress * 3.2 - 1.6);
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}
