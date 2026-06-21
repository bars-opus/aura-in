/// A message the user asked to send that has not yet been confirmed by the
/// server. Persisted (encrypted) so an app kill mid-send doesn't lose it, and
/// replayed on reconnect.
///
/// Identified by [clientReqId] (checklist 2.18): the same id rides every retry
/// so the receiver/UI can collapse the optimistic + confirmed pair and the
/// server can dedupe. Never regenerated once created.
class PendingSend {
  final String clientReqId;
  final String channelUrl;
  final PendingSendKind kind;
  final String? text;
  final String? filePath;
  final String? fileName;
  final String? mimeType;
  final String? caption;
  final int? parentMessageId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final int attempts;

  const PendingSend({
    required this.clientReqId,
    required this.channelUrl,
    required this.kind,
    required this.createdAt,
    this.text,
    this.filePath,
    this.fileName,
    this.mimeType,
    this.caption,
    this.parentMessageId,
    this.data,
    this.attempts = 0,
  });

  PendingSend copyWith({int? attempts}) => PendingSend(
        clientReqId: clientReqId,
        channelUrl: channelUrl,
        kind: kind,
        createdAt: createdAt,
        text: text,
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
        caption: caption,
        parentMessageId: parentMessageId,
        data: data,
        attempts: attempts ?? this.attempts,
      );

  Map<String, dynamic> toJson() => {
        'clientReqId': clientReqId,
        'channelUrl': channelUrl,
        'kind': kind.index,
        'text': text,
        'filePath': filePath,
        'fileName': fileName,
        'mimeType': mimeType,
        'caption': caption,
        'parentMessageId': parentMessageId,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'attempts': attempts,
      };

  factory PendingSend.fromJson(Map<String, dynamic> json) => PendingSend(
        clientReqId: json['clientReqId'] as String,
        channelUrl: json['channelUrl'] as String,
        kind: PendingSendKind.values[json['kind'] as int],
        text: json['text'] as String?,
        filePath: json['filePath'] as String?,
        fileName: json['fileName'] as String?,
        mimeType: json['mimeType'] as String?,
        caption: json['caption'] as String?,
        parentMessageId: (json['parentMessageId'] as num?)?.toInt(),
        data: json['data'] != null
            ? Map<String, dynamic>.from(json['data'] as Map)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      );
}

enum PendingSendKind { text, file }
