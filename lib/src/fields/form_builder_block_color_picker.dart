import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

const List<Color> _defaultColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];

class FormBuilderBlockColorPicker extends StatefulWidget {
  final String attribute;
  final List<FormFieldValidator> validators;
  final Color initialValue;
  final bool readOnly;
  final bool autovalidate;
  final InputDecoration decoration;
  final ValueTransformer valueTransformer;
  final FormFieldSetter onSaved;

  final ValueChanged<Color> onColorChanged;
  final List<Color> availableColors;
  final PickerItemBuilder itemBuilder;
  final PickerLayoutBuilder layoutBuilder;

  FormBuilderBlockColorPicker({
    Key key,
    @required this.attribute,
    @required this.onColorChanged,
    @required this.initialValue,
    this.validators = const [],
    this.readOnly = false,
    this.autovalidate = false,
    this.decoration = const InputDecoration(),
    this.valueTransformer,
    this.onSaved,
    this.availableColors = _defaultColors,
    this.itemBuilder = BlockPicker.defaultItemBuilder,
    this.layoutBuilder = BlockPicker.defaultLayoutBuilder,
  });

  @override
  _FormBuilderBlockColorPickerState createState() =>
      _FormBuilderBlockColorPickerState();
}

class _FormBuilderBlockColorPickerState
    extends State<FormBuilderBlockColorPicker> {
  bool _readOnly = false;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  FormBuilderState _formState;
  Color _initialValue;

  @override
  void initState() {
    _formState = FormBuilder.of(context);
    _formState?.registerFieldKey(widget.attribute, _fieldKey);
    _initialValue = widget.initialValue ??
        (_formState.initialValue.containsKey(widget.attribute)
            ? _formState.initialValue[widget.attribute]
            : null);
    super.initState();
  }

  @override
  void dispose() {
    _formState?.unregisterFieldKey(widget.attribute);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _readOnly = (_formState?.readOnly == true) ? true : widget.readOnly;

    return FormField<Color>(
      key: _fieldKey,
      enabled: !_readOnly,
      initialValue: _initialValue,
      autovalidate: widget.autovalidate,
      validator: (val) {
        for (int i = 0; i < widget.validators.length; i++) {
          if (widget.validators[i](val) != null)
            return widget.validators[i](val);
        }
        return null;
      },
      onSaved: (val) {
        var transformed;
        if (widget.valueTransformer != null) {
          transformed = widget.valueTransformer(val);
          _formState?.setAttributeValue(widget.attribute, transformed);
        } else {
          _formState?.setAttributeValue(widget.attribute, val);
        }
        if (widget.onSaved != null) {
          widget.onSaved(transformed ?? val);
        }
      },
      builder: (FormFieldState<dynamic> state) {
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              child: AlertDialog(
                content: SingleChildScrollView(
                  child: BlockPicker(
                    onColorChanged: widget.onColorChanged,
                    pickerColor: _initialValue,
                    availableColors: widget.availableColors,
                    itemBuilder: widget.itemBuilder,
                    layoutBuilder: widget.layoutBuilder,
                  ),
                ),
              ),
            );
          },
          child: InputDecorator(
            decoration: widget.decoration.copyWith(
              errorText: state.errorText,
            ),
            child: Text(
              state.value?.value.toString() ?? "",
              style: TextStyle(color: state.value ?? Colors.black),
            ),
          ),
        );
      },
    );
  }
}