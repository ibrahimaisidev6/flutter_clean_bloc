import 'package:flutter/material.dart';
import 'pulse_loading.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Size? minimumSize;
  final Size? maximumSize;
  final BorderSide? side;
  final ButtonStyle? style;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.minimumSize,
    this.maximumSize,
    this.side,
    this.style,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: isEnabled ? widget.onPressed : null,
              style: widget.style ?? _getButtonStyle(context),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: widget.isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        height: 20,
                        width: 20,
                        child: CustomLoadingIndicator(
                          size: 20,
                          strokeWidth: 2,
                          color: widget.foregroundColor ?? Colors.white,
                        ),
                      )
                    : widget.child,
              ),
            ),
          );
        },
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      disabledBackgroundColor: widget.disabledBackgroundColor,
      disabledForegroundColor: widget.disabledForegroundColor,
      padding: widget.padding,
      elevation: widget.elevation,
      minimumSize: widget.minimumSize,
      maximumSize: widget.maximumSize,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        side: widget.side ?? BorderSide.none,
      ),
    );
  }
}

class AnimatedOutlinedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledForegroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Size? minimumSize;
  final Size? maximumSize;
  final BorderSide? side;
  final ButtonStyle? style;

  const AnimatedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.padding,
    this.borderRadius,
    this.minimumSize,
    this.maximumSize,
    this.side,
    this.style,
  });

  @override
  State<AnimatedOutlinedButton> createState() => _AnimatedOutlinedButtonState();
}

class _AnimatedOutlinedButtonState extends State<AnimatedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: OutlinedButton(
              onPressed: isEnabled ? widget.onPressed : null,
              style: widget.style ?? _getButtonStyle(context),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: widget.isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        height: 20,
                        width: 20,
                        child: CustomLoadingIndicator(
                          size: 20,
                          strokeWidth: 2,
                          color: widget.foregroundColor ?? 
                                 Theme.of(context).primaryColor,
                        ),
                      )
                    : widget.child,
              ),
            ),
          );
        },
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: widget.foregroundColor,
      backgroundColor: widget.backgroundColor,
      disabledForegroundColor: widget.disabledForegroundColor,
      padding: widget.padding,
      minimumSize: widget.minimumSize,
      maximumSize: widget.maximumSize,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      side: widget.side,
    );
  }
}