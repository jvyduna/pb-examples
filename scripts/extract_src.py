# Use this to extract the src/ driectory from the contents of epe/.
# Aborts if it finds a file to overwrite; IE, to use this, explicitly delete the
# contents of src/ first, in order to not lose any changes made in the src/
# directory and not yet reflected in the corresponding .epe

import io, os, fnmatch, json, re

# Assumes the script lives in a subdirectory peer of epe/ and src/
script_dir = os.path.dirname(__file__)
indir = os.path.join(script_dir, "..", "epe")
outdir = os.path.join(script_dir, "..", "src")

for epe_filename in fnmatch.filter(os.listdir(indir), "*.epe"):
    print("Extracting source from " + epe_filename)
    with io.open(os.path.join(indir, epe_filename), 'r', 4096, 'utf-8-sig') as epe:
        program = json.load(epe)
        src_filename = re.sub(".epe$", "", epe_filename) + ".pb"
        with io.open(os.path.join(outdir, src_filename), 'x') as sourcecode:
            sourcecode.write(program['sources']['main'])