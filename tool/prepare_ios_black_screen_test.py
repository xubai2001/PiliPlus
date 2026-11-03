"""Prepare a controlled iOS PiP comparison; does not claim to fix black screens."""

import argparse
import plistlib
from pathlib import Path


PIP_REGISTRATION = '''    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PipPlugin") {
      PipPlugin.register(with: registrar)
    }
'''


def prepare(root: Path, variant: str) -> None:
    delegate = root / "ios/Runner/AppDelegate.swift"
    if variant == "no-pip":
        source = delegate.read_text(encoding="utf-8")
        if source.count(PIP_REGISTRATION) != 1:
            raise RuntimeError("Expected exactly one upstream PiP registration block")
        delegate.write_text(source.replace(PIP_REGISTRATION, "", 1), encoding="utf-8")

    plist_path = root / "ios/Runner/Info.plist"
    with plist_path.open("rb") as handle:
        info = plistlib.load(handle)
    label = "A" if variant == "baseline" else "B"
    info["CFBundleDisplayName"] = f"PiliPlus Test {label}"
    with plist_path.open("wb") as handle:
        plistlib.dump(info, handle, sort_keys=False)
    print(f"Prepared {variant}: PiliPlus Test {label}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("variant", choices=("baseline", "no-pip"))
    args = parser.parse_args()
    prepare(Path(__file__).resolve().parents[1], args.variant)
