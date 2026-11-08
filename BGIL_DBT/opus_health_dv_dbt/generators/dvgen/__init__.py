"""dvgen: shared Builder core for the Health LOB Data Vault dbt projects.

This package is byte-identical in opus_health_dv_dbt and
maximus_health_dv_dbt (Requirement 10.3). It imports nothing from outside
its own Health_Project. Project-specific values live in
``generators/project_config.py`` and the project adapter, never here.
"""
