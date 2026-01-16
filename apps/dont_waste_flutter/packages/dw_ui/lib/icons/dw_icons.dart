import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom SVG icon widget for DontWaste app
class DwIcon extends StatelessWidget {
  final String assetName;
  final double? size;
  final Color? color;

  const DwIcon(
    this.assetName, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? Colors.black;
    final iconSize = size ?? IconTheme.of(context).size ?? 24.0;

    return SvgPicture.asset(
      'packages/dw_ui/assets/icons/$assetName.svg',
      width: iconSize,
      height: iconSize,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}

/// Icon asset paths for DontWaste app
class DwIcons {
  DwIcons._();

  // Tab bar icons
  static const String tabHome = 'tab_home';
  static const String tabDiscover = 'tab_discover';
  static const String tabMap = 'tab_map';
  static const String tabOrders = 'tab_orders';
  static const String tabProfile = 'tab_profile';

  // Action icons
  static const String search = 'icon_search';
  static const String filter = 'icon_filter';
  static const String heart = 'icon_heart';
  static const String heartOutline = 'icon_heart_outline';
  static const String cart = 'icon_cart';
  static const String notification = 'icon_notification';
  static const String location = 'icon_location';
  static const String star = 'icon_star';
  static const String clock = 'icon_clock';
  static const String qrScan = 'icon_qr_scan';

  // Category icons
  static const String categoryFood = 'category_food';
  static const String categoryElectronics = 'category_electronics';
  static const String categoryClothing = 'category_clothing';
  static const String categoryFurniture = 'category_furniture';
}

/// Extension for easy icon creation
extension DwIconExtension on String {
  Widget toIcon({double? size, Color? color}) {
    return DwIcon(this, size: size, color: color);
  }
}
