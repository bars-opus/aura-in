import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nano_embryo/core/config/env.dart';
import 'package:nano_embryo/core/services/location_service.dart';
import 'package:nano_embryo/core/services/media/image_picker_service.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/attachment_menu.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final Future<void> Function(
    File file,
    String fileName,
    String mimeType, {
    Map<String, dynamic>? data,
  })?
  onFilePicked;

  /// Called when the user taps Contact to share their own profile card.
  final Future<void> Function()? onContactShare;

  final FocusNode? focusNode;

  const ChatTextField({
    super.key,
    required this.controller,
    required this.onSend,
    this.focusNode,
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
    this.onContactShare,
  });

  @override
  ConsumerState<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends ConsumerState<ChatTextField> {
  late final FocusNode _focusNode;
  bool _ownsNode = false;
  bool _hasText = false;

  // Typing indicator debounce
  Timer? _typingTimer;
  bool _isTyping = false;

  final _imagePicker = ImagePickerService();

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsNode = true;
    }
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _typingTimer?.cancel();
    if (_ownsNode) _focusNode.dispose();
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

  void _showPermissionSnackBar(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label permission denied. Allow access in Settings.'),
        action: SnackBarAction(
          label: 'Open Settings',
          onPressed: () => openAppSettings(),
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  // F2: single source of truth for the size limit (checklist 4.11 / 2.5).
  int get _maxFileBytes => ref.read(chatConfigProvider).maxFileSizeBytes;
  int get _maxFileMb => (_maxFileBytes / (1024 * 1024)).round();

  /// Returns true and shows the snackbar when [file] exceeds the limit.
  Future<bool> _rejectIfTooLarge(File file) async {
    if (await file.length() > _maxFileBytes) {
      if (mounted) _showFileTooLargeSnackBar();
      return true;
    }
    return false;
  }

  void _showFileTooLargeSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File is too large. Maximum size is $_maxFileMb MB.'),
      ),
    );
  }

  Future<void> _handleCamera() async {
    Navigator.pop(context);
    // Wait for the bottom sheet dismiss animation before presenting native camera UI.
    // iOS silently drops a UIViewController presentation while another is still animating.
    await Future.delayed(const Duration(milliseconds: 350));

    final file = await _imagePicker.pickImage(
      fromCamera: true,
      crop: true,
      lockAspectRatio: false,
    );
    if (file == null || !mounted) return;

    // F2: file size guard
    if (await _rejectIfTooLarge(file)) return;

    await widget.onFilePicked?.call(
      file,
      'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      'image/jpeg',
    );
  }

  Future<void> _handleGallery() async {
    Navigator.pop(context);
    // Same timing guard — PHPickerViewController must be presented after the sheet
    // animation completes, otherwise iOS drops the image selection callback.
    await Future.delayed(const Duration(milliseconds: 350));

    final file = await _imagePicker.pickImage(
      fromCamera: false,
      crop: true,
      lockAspectRatio: false,
    );
    if (file == null || !mounted) return;

    // F2: file size guard
    if (await _rejectIfTooLarge(file)) return;

    final ext = file.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    await widget.onFilePicked?.call(
      file,
      'image_${DateTime.now().millisecondsSinceEpoch}.$ext',
      mime,
    );
  }

  Future<void> _handleFilePicker() async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 350));

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final picked = result.files.first;

    // On Android SAF, path may be null — copy bytes to a temp file as fallback.
    File file;
    if (picked.path != null) {
      file = File(picked.path!);
    } else if (picked.bytes != null) {
      final tempDir = await getTemporaryDirectory();
      file = File('${tempDir.path}/${picked.name}');
      await file.writeAsBytes(picked.bytes!);
    } else {
      return;
    }

    // F2: file size guard
    if (await _rejectIfTooLarge(file)) return;

    final mime = _mimeFromExtension(picked.extension ?? '');
    await widget.onFilePicked?.call(file, picked.name, mime);
  }

  Future<void> _handleLocationShare() async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 350));

    // F3: permission check
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showPermissionSnackBar('Location');
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        if (mounted) _showPermissionSnackBar('Location');
        return;
      }
      if (permission == LocationPermission.denied) return;
    }

    // F4: fetch position + build Mapbox thumbnail
    final locationService = LocationService();
    final parsed = await locationService.getCurrentLocationWithDetails();
    if (parsed == null || parsed.latitude == null || parsed.longitude == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get your location. Try again.'),
          ),
        );
      }
      return;
    }

    final lat = parsed.latitude!;
    final lng = parsed.longitude!;
    final address =
        parsed.fullAddress.isNotEmpty ? parsed.fullAddress : '$lat, $lng';
    final token = Environment.mapboxAccessToken;
    final mapUrl =
        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/'
        '$lng,$lat,15,0/300x200@2x?access_token=$token';

    late http.Response response;
    try {
      response = await http.get(Uri.parse(mapUrl));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate map preview. Try again.'),
          ),
        );
      }
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'location_${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}.jpg';
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(response.bodyBytes);

    if (!mounted) return;

    await widget.onFilePicked?.call(
      tempFile,
      fileName,
      'image/jpeg',
      data: {'type': 'location', 'lat': lat, 'lng': lng, 'address': address},
    );
  }

  void _handleContactShare() {
    Navigator.pop(context);
    widget.onContactShare?.call();
  }

  void _startVoiceRecording() {
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
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
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
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
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
                  onPressed: () => _startVoiceRecording(),
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
          maxHeight: 200.h,
          context: context,
          widget: AttachmentMenu(
            onCamera: _handleCamera,
            onGallery: _handleGallery,
            onFile: _handleFilePicker,
            onLocation: _handleLocationShare,
            onContact: _handleContactShare,
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
