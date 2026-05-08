import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/animated_circle.dart';

class AppInitializationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.appColors.appColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedCircle(
              size: 30,
              stroke: 2,
              animateSize: true,
              animateShape: true,
              firstColor: Colors.white,
            ),
            Container(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/initializing_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
