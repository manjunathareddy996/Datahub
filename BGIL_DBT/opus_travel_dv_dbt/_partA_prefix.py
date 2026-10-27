import os, re

roots = [
    "BGIL_DBT/opus_travel_dv_dbt/models/automate_dv/standard/staging",
    "BGIL_DBT/opus_travel_dv_dbt/models/automate_dv/augmented/staging",
]

# Match: RECORD_SOURCE: '!<TABLE>'  where <TABLE> does NOT start with OPUS_
pat = re.compile(r"(RECORD_SOURCE:\s*'!)(?!OPUS_)([^']*)(')")

changed_files = []
count = 0
for root in roots:
    for fn in sorted(os.listdir(root)):
        if not fn.endswith(".sql"):
            continue
        p = os.path.join(root, fn)
        with open(p, "r") as f:
            txt = f.read()
        new, n = pat.subn(lambda m: m.group(1) + "OPUS_" + m.group(2) + m.group(3), txt)
        if n > 0:
            with open(p, "w") as f:
                f.write(new)
            changed_files.append((p, n))
            count += n

print("FILES_CHANGED", len(changed_files))
print("LITERALS_PREFIXED", count)
for p, n in changed_files:
    print(n, p)
