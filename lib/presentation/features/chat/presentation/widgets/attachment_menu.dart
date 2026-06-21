import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class AttachmentMenu extends StatefulWidget {
  final VoidCallback onGallery;
  final VoidCallback onFile;
  final VoidCallback onLocation;
  final VoidCallback onContact;
  final VoidCallback onCamera;

  const AttachmentMenu({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onFile,
    required this.onLocation,
    required this.onContact,
  });

  @override
  State<AttachmentMenu> createState() => _AttachmentMenuState();
}

class _AttachmentMenuState extends State<AttachmentMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ListView(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Gap(Spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildItem(0, Icons.camera_alt, 'Camera', widget.onCamera),
              _buildItem(1, Icons.photo_library, 'Photos', widget.onGallery),
              _buildItem(2, Icons.insert_drive_file, 'File', widget.onFile),
              _buildItem(3, Icons.location_on, 'Location', widget.onLocation),
              _buildItem(4, Icons.person, 'Contact', widget.onContact),
            ],
          ),
          Gap(Spacing.md),
          Center(
            child: AppTextButton(
              alignment: Alignment.center,
              onPressed: () => Navigator.pop(context),
              text: 'Cancel',
            ),
          ),
          Gap(Spacing.md),
        ],
      ),
    );
  }

  Widget _buildItem(
    int index,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final itemScale =
            Tween<double>(begin: 0.0, end: 1.0)
                .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      index * 0.05,
                      1.0,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                )
                .value;
        final opacity = ((_controller.value - index * 0.05).clamp(0.0, 1.0));
        return Transform.scale(
          scale: itemScale,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          // Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 150), onTap);
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 28.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                icon,
                size: 28.0,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
