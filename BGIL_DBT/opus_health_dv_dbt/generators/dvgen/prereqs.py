"""Import checks for the Builder's third-party prerequisites.

``require`` imports each named module and, when any import fails, raises
``PrereqMissing`` naming every missing module with a pip install hint for
the running interpreter. It never installs anything itself.

Requirements 10.1, 10.3.
"""
from __future__ import annotations

import importlib
import sys
from types import ModuleType
from typing import Iterable, Union

# Import name -> pip distribution name, where the two differ.
PIP_NAMES = {
    "yaml": "PyYAML",
}

# Modules the build itself needs (tests additionally need pytest, hypothesis).
BUILD_MODULES = ("openpyxl", "yaml")


class PrereqMissing(ImportError):
    """One or more prerequisite modules could not be imported."""

    def __init__(self, missing: list[tuple[str, str]]):
        # missing: list of (module name, import error text)
        self.missing = list(missing)
        self.modules = [name for name, _ in self.missing]
        super().__init__(self._message())

    def _message(self) -> str:
        lines = ["Missing build prerequisite(s):"]
        for name, err in self.missing:
            lines.append(f"  - {name}: {err}")
        packages = " ".join(pip_name(name) for name in self.modules)
        lines.append("Install with:")
        lines.append(f'  "{sys.executable}" -m pip install {packages}')
        return "\n".join(lines)


def pip_name(module: str) -> str:
    """Return the pip distribution name for an import name."""
    top = module.split(".", 1)[0]
    return PIP_NAMES.get(top, top)


def require(modules: Union[str, Iterable[str]]) -> dict[str, ModuleType]:
    """Import every module in ``modules`` and return them by name.

    Raises ``PrereqMissing`` listing every module that fails to import,
    with an install hint. Nothing is installed.
    """
    names = [modules] if isinstance(modules, str) else list(modules)
    loaded: dict[str, ModuleType] = {}
    missing: list[tuple[str, str]] = []
    for name in names:
        try:
            loaded[name] = importlib.import_module(name)
        except ImportError as exc:
            missing.append((name, str(exc) or type(exc).__name__))
    if missing:
        raise PrereqMissing(missing)
    return loaded
