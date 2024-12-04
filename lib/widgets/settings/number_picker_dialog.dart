import 'package:flutter/material.dart';

class NumberPickerDialog extends StatefulWidget {
  final String title;
  final int initialValue;
  final int minValue;
  final int maxValue;

  const NumberPickerDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  State<NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _value > widget.minValue
                ? () => setState(() => _value--)
                : null,
          ),
          Text(
            _value.toString(),
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _value < widget.maxValue
                ? () => setState(() => _value++)
                : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _value),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
