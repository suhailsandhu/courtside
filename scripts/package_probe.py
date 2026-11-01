"""Validate the device bundle and package it; this does NOT sign anything."""
import hashlib
import json
import plistlib
from pathlib import Path
import subprocess
import sys
import zipfile

app = Path(sys.argv[1]).resolve()
out = Path(sys.argv[2]).resolve()
out.mkdir(parents=True, exist_ok=True)
widget = app / "PlugIns" / "CourtsideWidget.appex"
assert widget.is_dir(), "Widget extension missing: refuse to package an app-only build"
records = []
for bundle in [app, widget]:
    with (bundle / "Info.plist").open("rb") as file:
        info = plistlib.load(file)
    binary = bundle / info["CFBundleExecutable"]
    assert binary.is_file(), f"Executable missing: {binary}"
    architectures = subprocess.check_output(["lipo", "-archs", str(binary)], text=True).strip()
    assert "arm64" in architectures.split(), "Must build a physical-device ARM64 binary"
    if bundle == widget:
        assert info["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.widgetkit-extension"
    records.append({"bundle_id": info["CFBundleIdentifier"], "architectures": architectures})
assert records[1]["bundle_id"].startswith(records[0]["bundle_id"] + ".")
ipa = out / "Courtside-UNSIGNED.ipa"
with zipfile.ZipFile(ipa, "w", zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(app.rglob("*")):
        if path.is_file():
            archive.write(path, str(Path("Payload") / app.name / path.relative_to(app)))
report = {
    "status": "UNSIGNED - requires Sideloadly Apple Account signing and device installation",
    "bundles": records,
    "ipa_sha256": hashlib.sha256(ipa.read_bytes()).hexdigest(),
    "device_installation_verified": False,
    "widget_on_device_verified": False,
}
(out / "bundle-inspection.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
print(json.dumps(report, indent=2))
