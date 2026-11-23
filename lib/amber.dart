import 'package:flutter/material.dart';

/// Amber for text, icons and outlines: the bright amber is only 1.6:1 on light cards,
/// so light mode uses a darker one (about 5.6:1 on white).
Color amberInk(ColorScheme s) =>
    s.brightness == Brightness.dark ? s.tertiary : const Color(0xFF8A5A00);
