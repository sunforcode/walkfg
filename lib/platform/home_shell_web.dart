import 'dart:js_interop';

@JS('hideWalkHomeShell')
external void _hideWalkHomeShell();

void hideHomeShell() => _hideWalkHomeShell();
