import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;
  final bool enabled;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String _countryCode = '+591'; // Default to Bolivia
  String _countryFlag = '🇧🇴';

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        textStyle: Theme.of(context).textTheme.bodyMedium!,
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Buscar país',
          hintText: 'Escribe el nombre del país',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
        searchTextStyle: Theme.of(context).textTheme.bodyMedium!,
      ),
      onSelect: (Country country) {
        setState(() {
          _countryCode = '+${country.phoneCode}';
          _countryFlag = country.flagEmoji;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        // Selector de país
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.enabled ? _showCountryPicker : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_countryFlag, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      _countryCode,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Campo de teléfono
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: widget.labelText ?? 'Teléfono',
              hintText: widget.hintText ?? '123456789',
              prefixIcon: Icon(
                Icons.phone_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted != null
                ? (_) => widget.onFieldSubmitted!()
                : null,
            autocorrect: false,
            enableSuggestions: false,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  // Método para obtener el número completo con código de país
  String getFullPhoneNumber() {
    final phoneNumber = widget.controller.text.trim();
    if (phoneNumber.isEmpty) return '';
    return '$_countryCode$phoneNumber';
  }

  // Método para validar el número de teléfono
  bool isValidPhoneNumber() {
    final fullNumber = getFullPhoneNumber();
    if (fullNumber.isEmpty) return false;

    try {
      final parsed = PhoneNumber.parse(fullNumber);
      return parsed.isValid();
    } catch (e) {
      return false;
    }
  }
}
