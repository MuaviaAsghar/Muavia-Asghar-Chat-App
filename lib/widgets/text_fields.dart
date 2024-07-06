import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.type,
    required this.hint,
    required this.label,
    this.controller,
    this.isPassword = false,
    required FocusNode focusNode,
  });

  final String hint;
  final String label;
  final bool isPassword;
  final TextEditingController? controller;
  final String type;

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
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
      return TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter your name';
          } else if (!value.contains('@')) {
            return "The entered mail does'nt' ";
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        obscureText: widget.isPassword,
        controller: widget.controller,
        decoration: inputDecoration,
      );
    } else if (widget.type == 'password') {
      return TextFormField(
        validator: (value) {
          if (value!.length < 5) {
            return "Your password must contains at least six digit";
          }
          return null;
        },
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
      return TextFormField(
        controller: widget.controller,
        decoration: inputDecoration,
        keyboardType: TextInputType.name,
      );
    } else if (widget.type == 'otp') {
      return TextFormField(
        controller: widget.controller,
        decoration: inputDecoration,
        keyboardType: TextInputType.number,
      );
    } else {
      return TextFormField(
        controller: widget.controller,
        decoration: inputDecoration.copyWith(
          hintText: 'Unknown type',
          label: const Text('Unknown'),
        ),
      );
    }
  }
}
