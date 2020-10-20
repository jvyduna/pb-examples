# pb-examples

## Example code for Pixelblaze 3

The repo started from the patterns as they existed in the v3.4 beta binary.

## Suggested workflow

Since each pattern's code is represented in both plaintext and .epe format, this workflow is suggested in order to minimize inconsistent states in the repo. 

The .epe is the definitive representation, and the .js files are extracted from the .epes. The value of extracting the .js source is that git will then provide us with normal per-line version control, and you can browse them nicely on GitHub.

.epe files are JSON and contain the ID, name, escaped source code, and base64-encoded JPEG/JFIF previews.

1. Export .epe files from a Pixelblaze and put or replace in /epe. Please beware that your workflo not change the ID embedded (upload an .epe, modify on a board, download that .epe)
2. Delete the contents of src/
3. Run `python3 scripts/extrat_src.py` to extract source code from the JSON in the .epe files.

## Binaries

Using the binaries is not required or suggested for most contributions.

Binaries contain all the data needed to mint (image) a pattern-less Pixelblaze, including code, previews, and controls. Firestorm's clone function retrieves and pushes these around.

The binaries are bytecode, and are slightly platform dependent (a Pixelblaze v3 binary will be different than the exact same pattern on Pixelblaze v2).

`/bin/p/\<patttern ID\>` is similar to .epe: Code, name, preview
`/bin/p/\<patttern ID\>.c` current values for the UI controls, if there are any. 

For the most part, improving patterns shouldn't need to worry about keeping the binaries in sync. However, if you have a need to:

  1. Dump all the binaries from a board into a zip file from Firestorm (hotkey: /), and replace all of them in bin/p/
  2. If you want to push the binaries to a board, see scripts/replace_all.sh and scripts/replace_one.sh
