import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocTextFormField<TBloc extends StateStreamable<TState>, TState>
    extends StatefulWidget {
  const BlocTextFormField(
      {required this.selector,
      this.initialValue,
      this.onChanged,
      this.decoration,
      this.keyboardType,
      this.inputFormatters,
      super.key,
      this.validator,
      required this.bloc});

  final String? initialValue;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final String? Function(TState value) selector;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final TBloc bloc;

  @override
  State<BlocTextFormField<TBloc, TState>> createState() =>
      _BlocTextFormFieldState<TBloc, TState>();
}

class _BlocTextFormFieldState<TBloc extends StateStreamable<TState>, TState>
    extends State<BlocTextFormField<TBloc, TState>> {
  _BlocTextFormFieldState();

  late TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TBloc, TState>(
      bloc: widget.bloc,
      listener: (context, state) {
        String? text = widget.selector(state);

        if (text != null && text != _controller.text) {
          _controller.text = text;
          _controller.selection =
              TextSelection.collapsed(offset: (text).length);
        }
      },
      child: TextFormField(
        controller: _controller,
        decoration: widget.decoration,
        onTapOutside: (e) => FocusManager.instance.primaryFocus?.unfocus(),
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_changed);
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    widget.onChanged?.call(_controller.text);
  }
}
