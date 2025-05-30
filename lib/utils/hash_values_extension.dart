// This extension provides the hashValues method that was removed from Flutter
// It's needed for the flutter_treeview package to work properly

import 'dart:ui';

// Add the missing hashValues method that was removed in recent Flutter versions
// This is to support packages like flutter_treeview that still use it
Object hashValues(Object? a, [Object? b, Object? c, Object? d, Object? e]) {
  return Object.hash(a, b, c, d, e);
}
