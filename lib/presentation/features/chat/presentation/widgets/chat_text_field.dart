import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/services/media/image_picker_service.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ChatTextField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final List<ChatTextFieldAction> actions;
  final double cornerRadius;
  final bool showSendButton;
  final EdgeInsetsGeometry padding;
  final bool autoAdjustBottomInset;

  /// Called when the user starts/stops typing.
  /// Used to send Sendbird typing indicators.
  final VoidCallback? onTypingStarted;
  final VoidCallback? onTypingStopped;

  /// Channel-aware file send — called when a file/image is picked.
  final Future<void> Function(File file, String fileName, String mimeType)?
  onFilePicked;

  const ChatTextField({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
    this.hintText = 'Type a message...',
    this.onChanged,
    this.actions = const [],
    this.cornerRadius = 20.0,
    this.showSendButton = true,
    this.autoAdjustBottomInset = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.onTypingStarted,
    this.onTypingStopped,
    this.onFilePicked,
  });

  @override
  ConsumerState<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends ConsumerState<ChatTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  // Typing indicator debounce
  Timer? _typingTimer;
  bool _isTyping = false;

  final _imagePicker = ImagePickerService();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _typingTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    if (hasText) {
      _onTypingStarted();
    } else {
      _onTypingStopped();
    }
  }

  void _onTypingStarted() {
    if (!_isTyping) {
      _isTyping = true;
      widget.onTypingStarted?.call();
    }
    // Reset the stop timer on each keystroke
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), _onTypingStopped);
  }

  void _onTypingStopped() {
    _typingTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      widget.onTypingStopped?.call();
    }
  }

  void _handleSend() {
    if (_hasText && !widget.isSending) {
      _onTypingStopped();
      widget.onSend();
    }
  }

  // ─── Attachment handlers ─────────────────────────────────────────────────

  Future<void> _handleCamera(BuildContext context) async {
    Navigator.pop(context);
    final file = await _imagePicker.pickImage(fromCamera: true);
    if (file == null || !mounted) return;
    await widget.onFilePicked?.call(
      file,
      'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      'image/jpeg',
    );
  }

  Future<void> _handleGallery(BuildContext context) async {
    Navigator.pop(context);
    final file = await _imagePicker.pickImage(fromCamera: false);
    if (file == null || !mounted) return;
    final ext = file.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    await widget.onFilePicked?.call(
      file,
      'image_${DateTime.now().millisecondsSinceEpoch}.$ext',
      mime,
    );
  }

  Future<void> _handleFilePicker(BuildContext context) async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    final file = File(picked.path!);
    final mime = _mimeFromExtension(picked.extension ?? '');
    await widget.onFilePicked?.call(file, picked.name, mime);
  }

  void _handleLocationShare(BuildContext context) {
    Navigator.pop(context);
    // Location sharing — future implementation
  }

  void _handleContactShare(BuildContext context) {
    Navigator.pop(context);
    // Contact sharing — future implementation
  }

  void _startVoiceRecording(BuildContext context) {
    HapticFeedback.mediumImpact();
    // Voice recording — future implementation
  }

  String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  // ─── Build helpers ───────────────────────────────────────────────────────

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          ),
        );
      },
      child:
          _hasText
              ? Container(
                key: const ValueKey('send_icon'),
                child:
                    widget.isSending
                        ? const CircularLoadingIndicator()
                        : GestureDetector(
                          onTap: widget.isSending ? null : _handleSend,
                          child: Container(
                            height: 30.h,
                            width: 30.w,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.send,
                              color: colorScheme.onPrimary,
                              size: 20.0,
                            ),
                          ),
                        ),
              )
              : Container(
                key: const ValueKey('mic_icon'),
                child: IconButton(
                  onPressed: () => _startVoiceRecording(context),
                  icon: Icon(
                    Icons.mic,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24.0,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
    );
  }

  Widget _buildPrefixIcon(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        BottomSheetUtils.showDocumentationBottomSheet(
          padding: 20.h,
          context: context,
          widget: AttachmentMenu(
            onCamera: () => _handleCamera(context),
            onGallery: () => _handleGallery(context),
            onFile: () => _handleFilePicker(context),
            onLocation: () => _handleLocationShare(context),
            onContact: () => _handleContactShare(context),
          ),
        );
      },
      child: SizedBox(
        height: 20.h,
        width: 20.w,
        child: Center(
          child: Icon(Icons.add_circle, color: colorScheme.onSurface),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom:
            (!_focusNode.hasFocus || !_hasText) ? Spacing.xxl.w : Spacing.md.w,
      ),
      decoration: BoxDecoration(
        color:
            (!_focusNode.hasFocus || !_hasText)
                ? Colors.transparent
                : colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          width: .1,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            prefixIcon:
                !_focusNode.hasFocus || !_hasText
                    ? _buildPrefixIcon(colorScheme)
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            filled: true,
            fillColor: Colors.transparent,
            hintText: widget.hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: _buildSuffixIcon(colorScheme),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 5,
          minLines: 1,
          textInputAction: TextInputAction.send,
          onChanged: (text) {
            widget.onChanged?.call(text);
          },
          onSubmitted: (_) => _handleSend(),
          onTap: () => setState(() {}),
          onEditingComplete: () => setState(() {}),
        ),
      ),
    );
  }
}

// ─── Supporting classes ──────────────────────────────────────────────────────

class ChatTextFieldAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const ChatTextFieldAction({
    required this.icon,
    required this.onPressed,
    this.tooltip = '',
  });
}

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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildItem(0, Icons.camera_alt, 'Camera', widget.onCamera),
              _buildItem(1, Icons.photo_library, 'Photos', widget.onGallery),
              _buildItem(
                2,
                Icons.insert_drive_file,
                'File',
                widget.onFile,
              ),
              _buildItem(3, Icons.location_on, 'Location', widget.onLocation),
              _buildItem(4, Icons.person, 'Contact', widget.onContact),
            ],
          ),
          Gap(20.h),
          Center(
            child: AppTextButton(
              alignment: Alignment.center,
              onPressed: () => Navigator.pop(context),
              text: 'Cancel',
            ),
          ),
          Gap(30.h),
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
          Navigator.pop(context);
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
