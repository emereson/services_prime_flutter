import 'package:flutter/material.dart';

class LabelTopSelect extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final Function(String?)? onChanged;
  final IconData? icon;

  const LabelTopSelect({
    super.key,
    required this.label,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.icon,
  });

  @override
  State<LabelTopSelect> createState() => _LabelTopSelectState();
}

class _LabelTopSelectState extends State<LabelTopSelect> {
  late String? _currentValue;
  bool _isOpen = false;
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selectedValue;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _toggleOverlay();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: offset.dy + size.height + 5,
            left: offset.dx,
            width: size.width,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: widget.options.length * 54,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: widget.options.map((option) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentValue = option;
                          widget.onChanged?.call(option);
                          _toggleOverlay();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 15,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleOverlay() {
    if (_isOpen) {
      _closeOverlay();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _closeOverlay() {
    if (_isOpen) {
      _overlayEntry.remove();
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          _toggleOverlay();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _toggleOverlay,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _currentValue ?? 'Seleccione',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
