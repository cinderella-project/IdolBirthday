#!/usr/bin/env python3
import plistlib
import os
import subprocess

def current_version():
    with open("./App/macOS/Info.plist", "rb") as f:
        return plistlib.load(f)["CFBundleVersion"]

def load_template():
    with open("project.template.yml", "r") as r:
        return r.read()
os.chdir(os.path.dirname(os.path.abspath(__file__)))

out = load_template().replace("${REPLACE_WITH_ACTUAL_CURRENT_PROJECT_VERSION}", f'"{current_version()}"')
with open(".project.generated.yml", "w") as f:
    f.write(out)
exit(subprocess.call(["xcodegen", "-s", ".project.generated.yml"]))
