import 'package:tool_core_app/l10n/app_localizations.dart';

import 'api_exception.dart';

/// Maps an error code to a localized message.
String localizeErrorCode(AppLocalizations l10n, String code) {
  switch (code) {
    case 'invalid-credentials':
      return l10n.errorInvalidCredentials;
    case 'validation-error':
      return l10n.errorValidation;
    case 'service-not-found':
      return l10n.errorServiceNotFound;
    case 'service-name-required':
      return l10n.errorServiceNameRequired;
    case 'service-price-invalid':
      return l10n.errorServicePriceInvalid;
    case ClientErrorCodes.workshopNotSelected:
      return l10n.errorWorkshopNotSelected;
    case ClientErrorCodes.network:
      return l10n.errorNetwork;
    case ClientErrorCodes.tooManyRequests:
      return l10n.errorTooManyRequests;
    case ClientErrorCodes.sessionExpired:
      return l10n.errorSessionExpired;
    default:
      return l10n.errorUnexpected;
  }
}
