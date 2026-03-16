#!/usr/bin/env python3
import sys
import json
import subprocess
import os

def set_annotation(config, arch, flavour, value, annotations_file):
    """Executes the Debian script to enforce a specific kernel configuration."""

    cmd = [
        "python3",
        "debian/scripts/misc/annotations",
        "--file", annotations_file,
        "--arch", arch,
        "--flavour", flavour,
        "--config", config,
        "--write", value
    ]

    print(f"Setting {config} for {arch} ({flavour}) to '{value}'")

    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        print(f"  [ERROR] Failed to apply {config} on {arch} ({flavour})", file=sys.stderr)

def main():
    # Fetch the environment variable exported by helper
    target_file = os.environ.get("KERNEL_CONFIG_ANNOTATIONS")

    # Fail fast if the annotations file is not defined
    if not target_file:
        print("[FATAL ERROR] KERNEL_CONFIG_ANNOTATIONS environment variable is not set.", file=sys.stderr)
        print("Aborting to prevent modifying the wrong configuration file.", file=sys.stderr)
        sys.exit(1)

    print(f"[INFO] Target annotations file: {target_file}")

    # Read and parse the JSON policy from stdin
    try:
        policy_dict = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"[FATAL ERROR] Invalid JSON policy format: {e}", file=sys.stderr)
        sys.exit(1)

    # Process the nested dictionary
    for config, archs in policy_dict.items():
        for key, value in archs.items():
            
            # Check if the key contains a flavour delimiter (e.g., "arm64/generic-64k")
            if "/" in key:
                arch, flavour = key.split("/", 1)
                set_annotation(config, arch, flavour, value, target_file)
            
            # Backward compatibility for nested dicts (just in case)
            elif isinstance(value, dict):
                for flavour_nested, val_nested in value.items():
                    set_annotation(config, key, flavour_nested, val_nested, target_file)
            
            # If it's just a plain string without a slash, default to 'generic'
            else:
                set_annotation(config, key, "generic", value, target_file)

if __name__ == "__main__":
    main()
