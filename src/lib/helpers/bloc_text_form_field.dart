import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocTextFormField<TBloc extends StateStreamable<TState>, TState>
    extends StatefulWidget {
  const BlocTextFormField({
    required this.selector,
    this.initialValue,
    this.onChanged,
    this.decoration,
    this.keyboardType,
    this.inputFormatters,
    super.key,
    this.validator,
    required this.bloc,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.onTapOutside,
  });

  final String? initialValue;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final String? Function(TState value) selector;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final TBloc bloc;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final TapRegionCallback? onTapOutside;

  @override
  State<BlocTextFormField<TBloc, TState>> createState() =>
      _BlocTextFormFieldState<TBloc, TState>();
}

class _BlocTextFormFieldState<TBloc extends StateStreamable<TState>, TState>
    extends State<BlocTextFormField<TBloc, TState>> {
  late TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TBloc, TState>(
      bloc: widget.bloc,
      listener: (context, state) {
        final text = widget.selector(state);

        if (text != null && text != _controller.text) {
          _controller.text = text;
          _controller.selection =
              TextSelection.collapsed(offset: (text).length);
        }
      },
      child: TextFormField(
        controller: _controller,
        decoration: widget.decoration,
        onTapOutside: widget.onTapOutside ??
            (e) => FocusManager.instance.primaryFocus?.unfocus(),
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        textInputAction: widget.textInputAction,
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onFieldSubmitted,
        autofocus: widget.autofocus,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialValue ?? widget.selector(widget.bloc.state);
    _controller = TextEditingController(text: initialText);
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
