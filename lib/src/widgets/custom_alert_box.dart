import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'custom_button.dart';



void customAlertBox({
  required BuildContext context,
  required String title,
  required Function() onPress,
  required String icons,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black38, // Slight dimming background
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // White background for light theme
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Gap(25),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'No',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(30),
                      CButton(
                        onPressed: onPress,
                        buttonColor: Colors.red, // Red accent for confirmation
                        buttonWidget: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        borderRadius: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top icon
            Positioned(
              top: 0,
              right: 10,
              child: Image.asset(
                icons,
                height: 48,
              ),
            ),
          ],
        ),
      );
    },
  );
}
