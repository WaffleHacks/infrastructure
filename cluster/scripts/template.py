#!/usr/bin/env python

import json
from pathlib import Path
import subprocess
import sys

WORKING_DIR = Path(__file__).parent
PROJECT_DIR = WORKING_DIR.parent
MODULE = sys.argv[1]

USER_DATA = PROJECT_DIR / "modules" / MODULE / "user-data"
SCRIPT = USER_DATA / "script.sh"

OUTPUT_DIR = WORKING_DIR / "templated" / MODULE

# Find all variables needing to be templated
result = subprocess.run(["grep", "${[a-z0-9_]*}", "-rno", USER_DATA], stdout=subprocess.PIPE, check=True)

# Group variables by file
variables = {}
for line in result.stdout.decode().splitlines():
    [file, _, variable] = line.split(":")
    file = Path(file).relative_to(USER_DATA)

    variables.setdefault(str(file), []).append(variable[2:-1])

# Open the template mappings for the module
with open(WORKING_DIR / "template-mappings" / f"{MODULE}.json", "r") as f:
    mappings = json.load(f)


def template(file: Path) -> str:
    relative_path = file.relative_to(USER_DATA)
    mapped_variables = mappings.get(str(relative_path), {})

    # Check if any mappings are missing
    to_replace = variables.get(str(relative_path), [])
    missing = set(to_replace) - set(mapped_variables.keys())
    if len(missing) != 0:
        print(f"Missing mapping for variables {missing} in {file.relative_to(USER_DATA)}")
        sys.exit(1)

    # Read the file
    with open(file, "r") as f:
        content = f.read()
    
    # Recursively template files
    for variable, spec in mapped_variables.items():
        if isinstance(spec, dict):
            value = template(USER_DATA / spec["ref"])
            
            if spec["ref"].endswith(".sh"):
                value = value.replace("$", "\\$")
        else:
            value = spec
        
        content = content.replace(f"${{{variable}}}", value)

    # Write the file if it is a script
    if content.startswith("#!/"):
        output = OUTPUT_DIR / relative_path
        output.parent.mkdir(parents=True, exist_ok=True)
        with open(output, "w") as f:
            f.write(content)
    
    return content


OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
template(SCRIPT)
