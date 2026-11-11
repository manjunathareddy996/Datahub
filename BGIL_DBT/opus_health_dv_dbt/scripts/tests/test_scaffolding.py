"""Unit tests for the Health_Project scaffolding.

Covers macros, packages, profile name, dbt_project.yml and .gitignore
against the Partner_Project.

Validates: Requirements 2.1, 2.2, 2.3, 3.2, 3.3, 3.5, 3.6, 3.9
"""
import hashlib
from pathlib import Path

import pytest
import yaml

HEALTH = Path(__file__).resolve().parents[2]
PARTNER = HEALTH.parent / "opus_partner_dv_dbt"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def files(root: Path):
    return sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file())


def load(path: Path):
    return yaml.safe_load(path.read_text(encoding="utf-8"))


PARTNER_MACROS = sorted(p.name for p in (PARTNER / "macros").glob("*.sql"))


def test_partner_has_eight_macros():
    assert len(PARTNER_MACROS) == 8


@pytest.mark.parametrize("name", PARTNER_MACROS)
def test_macro_byte_equal_to_partner(name):
    assert sha(HEALTH / "macros" / name) == sha(PARTNER / "macros" / name)


def test_no_extra_sql_macros():
    assert sorted(p.name for p in (HEALTH / "macros").glob("*.sql")) == PARTNER_MACROS


def test_packages_yml_byte_equal():
    assert (HEALTH / "packages.yml").read_bytes() == (PARTNER / "packages.yml").read_bytes()


@pytest.mark.parametrize("pkg", ["dbt_utils", "automate_dv"])
def test_vendored_package_equal_to_partner(pkg):
    h, p = HEALTH / "dbt_packages" / pkg, PARTNER / "dbt_packages" / pkg
    assert (h / "dbt_project.yml").is_file()
    assert files(h) == files(p)
    for rel in files(p):
        assert (h / rel).read_bytes() == (p / rel).read_bytes(), rel


def test_packages_local_paths_exist():
    for entry in load(HEALTH / "packages.yml")["packages"]:
        target = (HEALTH / entry["local"]).resolve()
        assert (target / "dbt_project.yml").is_file(), entry["local"]


def test_profile_name_matches_project():
    project = load(HEALTH / "dbt_project.yml")
    profiles = load(HEALTH / "profiles.yml")
    assert project["profile"] == "opus_health_dbt"
    assert project["profile"] in profiles
    assert {"dev", "prod"} <= set(profiles[project["profile"]]["outputs"])


def _substituted_partner():
    text = (PARTNER / "dbt_project.yml").read_text(encoding="utf-8")
    text = text.replace("opus_partner_dv_dbt", "opus_health_dv_dbt")
    text = text.replace("opus_partner_dbt", "opus_health_dbt")
    return yaml.safe_load(text)


def test_dbt_project_equals_partner_apart_from_vars():
    health = load(HEALTH / "dbt_project.yml")
    partner = _substituted_partner()
    health.pop("vars")
    partner.pop("vars")
    assert health == partner


def test_dbt_project_health_vars_and_no_old_layout():
    health = load(HEALTH / "dbt_project.yml")
    assert set(health["vars"]) == {"health_raw_database", "health_raw_schema"}
    assert "automate_dv" not in (HEALTH / "dbt_project.yml").read_text(encoding="utf-8")
    assert "config-version" not in health
    assert "raw_vault" in health["models"]["opus_health_dv_dbt"]


def _ignore_entries(path: Path):
    return [
        ln.strip()
        for ln in path.read_text(encoding="utf-8").splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    ]


def test_gitignore_has_partner_entries_and_does_not_ignore_dbt_packages():
    partner = [e for e in _ignore_entries(PARTNER / "gitignore.txt") if "dbt_packages" not in e]
    health = _ignore_entries(HEALTH / ".gitignore")
    for entry in partner:
        assert entry in health, entry
    assert {"target/", "logs/"} <= set(health) or {"target", "logs"} <= set(health)
    assert not [e for e in health if "dbt_packages" in e]
