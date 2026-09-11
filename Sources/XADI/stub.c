#include "XADI.h"

// XADI is a dynamic SwiftPM product backed by a static binary target.
// Keep one relocation to the C API so the linker extracts xadibase
// while producing libXADI.{so,dylib}.
__attribute__((used, retain, visibility("hidden")))
static void (*volatile const xadi_link_anchor)(const char *) = xadi_Load;
