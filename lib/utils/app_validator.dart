import '../common/app_enums.dart' show ValidatorType;
import '../generated/l10n.dart';
import 'extensions/string_extension.dart' show StringExtension;

String? onValidate(ValidatorType type, String? value) {
  if (value.isValidate) {
    return S.current.er_required_field;
  }

  if (!RegExp(type.rawReg).hasMatch(value!)) {
    return switch(type) {
      ValidatorType.email => S.current.er_email_field,
      ValidatorType.password => S.current.er_password_field,
      ValidatorType.name => S.current.er_name_field,
      ValidatorType.phone => S.current.er_phone_field,
    };
  }

  return null;
}