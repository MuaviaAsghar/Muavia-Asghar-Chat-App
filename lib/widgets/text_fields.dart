import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      required this.type,
      required this.hint,
      required this.label,
      this.controller,
      this.isPassword = false,
      required FocusNode focusNode});

  final String hint;
  final String label;
  final bool isPassword;
  final TextEditingController? controller;
  final String type;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration = InputDecoration(
      hintText: widget.hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      label: Text(widget.label),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
    );

    if (widget.type == 'email') {
      return TextField(
        keyboardType: TextInputType.emailAddress,
        obscureText: widget.isPassword,
        controller: widget.controller,
        decoration: inputDecoration,
      );
    } else if (widget.type == 'password') {
      return TextField(
        obscureText: _obscureText,
        controller: widget.controller,
        decoration: inputDecoration.copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
        keyboardType: TextInputType.visiblePassword,
      );
    } else if (widget.type == 'username') {
      return TextField(
        controller: widget.controller,
        decoration: inputDecoration,
        keyboardType: TextInputType.name,
      );
    } else if (widget.type == 'otp') {
      return TextField(
        controller: widget.controller,
        decoration: inputDecoration,
        keyboardType: TextInputType.number,
      );
    } else {
      return TextField(
        controller: widget.controller,
        decoration: inputDecoration.copyWith(
          hintText: 'Unknown type',
          label: const Text('Unknown'),
        ),
      );
    }
  }
}
