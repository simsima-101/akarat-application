import 'package:flutter/material.dart';

// Colored Button
class CButton extends StatelessWidget {
  const CButton({
    super.key,
    this.buttonHeight,
    this.buttonWidth,
    required this.buttonColor,
    required this.buttonWidget,
    this.onPressed,
    this.borderRadius,
    this.borderRadiusOnly,
    this.elevation,
    this.padding,
    this.borderColor, // Optional border color
    this.borderWidth, // Optional border width
  });

  final double? buttonHeight;
  final double? buttonWidth;
  final Color buttonColor;
  final Widget buttonWidget;
  final double? borderRadius;
  final BorderRadiusGeometry? borderRadiusOnly;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final void Function()? onPressed;
  final Color? borderColor; // Optional border color
  final double? borderWidth; // Optional border width

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(padding ?? EdgeInsets.zero),
          elevation: WidgetStateProperty.all(elevation ?? 2),
          backgroundColor: WidgetStateProperty.all(buttonColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: borderRadiusOnly != null
                  ? borderRadiusOnly!
                  : BorderRadius.circular(borderRadius ?? 8),
              side: BorderSide(
                color: borderColor ??
                    Colors
                        .transparent, // Default to transparent if no color is given
                width: borderWidth ?? 0, // Default to 0 if no width is given
              ),
            ),
          ),
        ),
        child: buttonWidget,
      ),
    );
  }
}

// Outline Button
class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    this.buttonHeight,
    this.buttonWidth,
    required this.buttonColor,
    this.onPressed,
    required this.borderColor,
    required this.buttonWidget,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.borderWidth, // Optional border width
  });

  final double? buttonHeight;
  final double? buttonWidth;
  final Color buttonColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;
  final void Function()? onPressed;
  final Widget buttonWidget;
  final double? elevation;
  final double? borderWidth; // Optional border width

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(padding ?? EdgeInsets.zero),
          elevation: WidgetStateProperty.all(elevation ?? 0),
          shadowColor: WidgetStateProperty.all(Colors.black26),
          backgroundColor: WidgetStateProperty.all(buttonColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              side: BorderSide(
                color: borderColor,
                width: borderWidth ?? 1, // Default to 1 if no width is given
              ),
            ),
          ),
        ),
        child: Center(
          child: buttonWidget,
        ),
      ),
    );
  }
}
