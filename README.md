# pb-examples

## Example code for Pixelblaze

The repo started from the patterns as they existed in the v3.4 beta binary.

## Suggested workflow

Since each pattern's code is represented in plaintext, .epe format, and Pixelblaze binaries, this workflow is suggested in order to minimize inconsistent states in the repo.

* Binaries contain all data needed to mint, including code, previews, and controls.
* EPE files are JSON and contain previews and escaped source code

1. Export changed .epe files from a Pixelblaze and put in /epe
2. Run `python3 scripts/extrat_src.py` to extract source code from the JSON in the .epe files. This is mainly just so that standard git can highlight changes made to patterns, and so you can browse the patern code easily.
3. Dump the binaries from Firestorm (hotkey: /), and place these in bin/p/
