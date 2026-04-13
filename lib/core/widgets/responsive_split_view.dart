import 'package:flutter/material.dart';

class ResponsiveSplitView extends StatelessWidget {
  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;
  final double breakpoint;
  final bool forceScrollOnMobile;
  final double? activeMobileRightHeight;
  final bool scrollableLeft;

  const ResponsiveSplitView({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 2,
    this.rightFlex = 3,
    this.breakpoint = 900,
    this.forceScrollOnMobile = true,
    this.activeMobileRightHeight = 600,
    this.scrollableLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          // Mobile / Tablet Layout (Vertical)
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Panel (Form)
                if (scrollableLeft)
                   left
                else
                   SizedBox(height: 500, child: left), // Fixed height if list on mobile
                
                const Divider(thickness: 4, height: 32),
                
                // Bottom Panel (List)
                if (activeMobileRightHeight != null)
                   SizedBox(height: activeMobileRightHeight, child: right)
                else
                   right,
              ],
            ),
          );
        } else {
          // Desktop Layout (Horizontal)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: leftFlex,
                child: scrollableLeft 
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: left,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: left,
                    ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: rightFlex,
                child: right,
              ),
            ],
          );
        }
      },
    );
  }
}
