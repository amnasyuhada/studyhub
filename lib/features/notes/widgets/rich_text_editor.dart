import 'package:flutter/material.dart';

class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;

  const RichTextEditor({
    super.key,
    required this.controller,
    this.hintText = 'Write your notes here...',
    this.enabled = true,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  final FocusNode _focusNode = FocusNode();
  bool _showToolbar = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formatting toolbar
        if (_showToolbar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToolbarButton(
                  icon: Icons.format_bold,
                  onTap: () => _insertMarkdown('**', '**'),
                ),
                _ToolbarButton(
                  icon: Icons.format_italic,
                  onTap: () => _insertMarkdown('*', '*'),
                ),
                _ToolbarButton(
                  icon: Icons.format_underline,
                  onTap: () => _insertMarkdown('__', '__'),
                ),
                const VerticalDivider(width: 8),
                _ToolbarButton(
                  icon: Icons.format_list_bulleted,
                  onTap: () => _insertMarkdown('- ', ''),
                ),
                _ToolbarButton(
                  icon: Icons.format_list_numbered,
                  onTap: () => _insertMarkdown('1. ', ''),
                ),
                const VerticalDivider(width: 8),
                _ToolbarButton(
                  icon: Icons.code,
                  onTap: () => _insertMarkdown('`', '`'),
                ),
                _ToolbarButton(
                  icon: Icons.format_quote,
                  onTap: () => _insertMarkdown('> ', ''),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        
        // Text field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onTap: () => setState(() => _showToolbar = true),
          maxLines: null,
          minLines: 8,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            height: 1.7,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
            ),
          ),
        ),
        
        // Quick formatting hint
        if (_showToolbar)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tip: Use **bold**, *italic*, - for bullet points',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  void _insertMarkdown(String prefix, String suffix) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final start = selection.start;
    final end = selection.end;

    if (selection.isValid && start != end) {
      // Selected text - wrap with formatting
      final selectedText = text.substring(start, end);
      final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');
      widget.controller.text = newText;
      widget.controller.selection = TextSelection(
        baseOffset: start + prefix.length,
        extentOffset: end + prefix.length,
      );
    } else if (prefix == '- ' || prefix == '1. ' || prefix == '> ') {
      // Bullet points - add at line start
      final lines = text.split('\n');
      final cursorLine = text.substring(0, start).split('\n').length - 1;
      if (cursorLine >= 0 && cursorLine < lines.length) {
        lines[cursorLine] = '$prefix${lines[cursorLine]}';
        widget.controller.text = lines.join('\n');
        widget.controller.selection = TextSelection(
          baseOffset: start + prefix.length,
          extentOffset: start + prefix.length,
        );
      }
    } else {
      // Empty selection - insert formatting markers
      final newText = text.replaceRange(start, end, '$prefix$suffix');
      widget.controller.text = newText;
      widget.controller.selection = TextSelection(
        baseOffset: start + prefix.length,
        extentOffset: start + prefix.length,
      );
    }
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18, color: Colors.grey.shade700),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      splashRadius: 20,
    );
  }
}