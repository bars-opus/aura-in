import 'package:in_app_review/in_app_review.dart';

/// Thin seam around the [InAppReview] singleton so the prompter is
/// unit-testable without spinning up platform channels.
abstract class InAppReviewClient {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing({String? appStoreId});
}

class DefaultInAppReviewClient implements InAppReviewClient {
  final InAppReview _delegate;
  DefaultInAppReviewClient([InAppReview? delegate])
    : _delegate = delegate ?? InAppReview.instance;

  @override
  Future<bool> isAvailable() => _delegate.isAvailable();

  @override
  Future<void> requestReview() => _delegate.requestReview();

  @override
  Future<void> openStoreListing({String? appStoreId}) =>
      _delegate.openStoreListing(appStoreId: appStoreId);
}
