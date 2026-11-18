#!/usr/bin/env python3
"""
Are satellite columns named the same in every LOB and source?

Each satellite is compared with the same satellite (same table name) in every other project: Partner,
Travel, Health and Motor; OPUS and MAXIMUS. For every column (src_cdk + src_payload) the script finds the
name each project uses and says how the names differ: only underscores, a _CK suffix, shorthand,
spelling, synonym, word order or one extra word. Two names that sit side by side in one project's
satellite are always different columns and are never matched to each other.

Reads only these files, on every run (no JSON report and no other validation tool):
  <project>/models/**/satellites/sat_*.sql   satellite models (yaml_metadata block)
  <project>/dbt_project.yml                  to see which projects write the shared BGIL_DATA_MODEL schema

Name to use = team rule in BGIL_DBT/.kiro/steering/modeller-learnings.md (2026-11-16): one attribute, one
column name in every LOB; use the UPPER_SNAKE name if any project has it, otherwise keep partner's name.

    python3 BGIL_DBT/validation/tools/gen_sat_column_consistency.py

Output (overwritten): BGIL_DBT/validation/SAT_COLUMN_CONSISTENCY_ALL_LOBS.xlsx, three sheets:
  Summary, Name differences, All columns.
"""
from __future__ import annotations

import datetime as dt
import json
import math
import re
from collections import Counter, OrderedDict, defaultdict, namedtuple
from itertools import combinations
from pathlib import Path

import yaml
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

ROOT = Path(__file__).resolve().parents[2]  # BGIL_DBT
OUT = ROOT / "validation" / "SAT_COLUMN_CONSISTENCY_ALL_LOBS.xlsx"
DONE_FILE = Path(__file__).with_name("sat_column_done.json")  # finished sats with their pre-fix rows
LOB_ORDER = ("PARTNER", "TRAVEL", "HEALTH", "MOTOR")  # also the baseline order of the LOB comparisons
SYSTEM_ORDER = ("OPUS", "MAXIMUS")
SHARED_SCHEMA = "BGIL_DATA_MODEL"
# Decisions already taken by the team that override the general rule (modeller-learnings, 2026-11-16).
EXCEPTIONS = {
    ("SAT_PARTY_KYC_REFERENCE", "KYCREFERENCETYPE"):
        "team decision 2026-11-16: travel and partner keep KYCREFERENCETYPE unless you decide otherwise",
}

# =====================================================================================================
# Naming knowledge. Used only to RECOGNISE a variant; nothing is renamed by this script.
# =====================================================================================================
ABBR = {  # shorthand -> full word(s)
    "AC": ("ACCOUNT",), "ACC": ("ACCOUNT", "ACCIDENT"), "ACCT": ("ACCOUNT",),
    "ACK": ("ACKNOWLEDGEMENT", "ACKNOWLEDGMENT", "ACKNOWLEDGED"), "ADDL": ("ADDITIONAL",),
    "ADDR": ("ADDRESS",), "ADJ": ("ADJUSTMENT",), "AMNT": ("AMOUNT",), "AMT": ("AMOUNT",),
    "APPL": ("APPLICATION",), "APPR": ("APPROVAL", "APPROVED"), "ASMT": ("ASSESSMENT",),
    "ASSMT": ("ASSESSMENT",), "AUTH": ("AUTHORISATION", "AUTHORIZATION", "AUTHORISED", "AUTHORIZED", "AUTHORITY"),
    "AVG": ("AVERAGE",), "BAL": ("BALANCE",), "BR": ("BRANCH",), "BRCH": ("BRANCH",), "BRN": ("BRANCH",),
    "CANC": ("CANCELLATION", "CANCELLED"), "CAT": ("CATEGORY",), "CATG": ("CATEGORY",), "CCY": ("CURRENCY",),
    "CD": ("CODE",), "CERT": ("CERTIFICATE",), "CHNL": ("CHANNEL",), "CLM": ("CLAIM",), "CNT": ("COUNT",),
    "CNTRY": ("COUNTRY",), "COMM": ("COMMISSION", "COMMUNICATION"), "CORR": ("CORRESPONDENCE",),
    "CR": ("CREDIT",), "CTRY": ("COUNTRY",), "CUM": ("CUMULATIVE",), "CUMM": ("CUMULATIVE",),
    "CURR": ("CURRENT", "CURRENCY"), "CUST": ("CUSTOMER",),
    "DEPT": ("DEPARTMENT",), "DESC": ("DESCRIPTION",), "DESCR": ("DESCRIPTION",),
    "DISC": ("DISCOUNT", "DISCLOSURE"), "DIST": ("DISTRICT", "DISTANCE"), "DOC": ("DOCUMENT",),
    "DOCS": ("DOCUMENTS",), "DT": ("DATE",), "DTE": ("DATE",), "DTTM": ("DATETIME",),
    "EDU": ("EDUCATION", "EDUCATIONAL"), "EFF": ("EFFECTIVE",), "EMP": ("EMPLOYEE", "EMPLOYER", "EMPLOYMENT"),
    "ENDT": ("ENDORSEMENT",), "EXP": ("EXPIRY", "EXPIRATION", "EXPERIENCE", "EXPENSE", "EXPENSES"),
    "FLG": ("FLAG",), "GRP": ("GROUP",), "HOSP": ("HOSPITAL",), "ID": ("IDENTIFIER", "IDENTIFICATION"),
    "INCEP": ("INCEPTION",), "IND": ("INDICATOR",), "INFO": ("INFORMATION",),
    "INS": ("INSURANCE", "INSURED", "INSURER"), "INTL": ("INTERNATIONAL",), "LANG": ("LANGUAGE",),
    "LMT": ("LIMIT",), "LOC": ("LOCATION",), "MAX": ("MAXIMUM",), "MED": ("MEDICAL", "MEDICINE"),
    "MEM": ("MEMBER", "MEMBERSHIP"), "MFG": ("MANUFACTURING", "MANUFACTURE"), "MFR": ("MANUFACTURER",),
    "MGMT": ("MANAGEMENT",), "MGR": ("MANAGER",), "MIN": ("MINIMUM",), "MISC": ("MISCELLANEOUS",),
    "MISCELL": ("MISCELLANEOUS",), "MOB": ("MOBILE",), "MTH": ("MONTH",), "MTHS": ("MONTHS",),
    "NATL": ("NATIONAL",), "NBR": ("NUMBER",), "NM": ("NAME",), "NO": ("NUMBER",), "NOM": ("NOMINEE",),
    "NUM": ("NUMBER",), "OCC": ("OCCUPATION", "OCCUPANCY"), "ORG": ("ORGANISATION", "ORGANIZATION"),
    "PCT": ("PERCENTAGE", "PERCENT"), "PERC": ("PERCENTAGE", "PERCENT"), "PERCENT": ("PERCENTAGE",),
    "PERM": ("PERMANENT",), "PH": ("PHONE",), "PMT": ("PAYMENT",), "POL": ("POLICY",),
    "PREF": ("PREFERENCE", "PREFERRED"), "PREM": ("PREMIUM",), "PREV": ("PREVIOUS",),
    "PROD": ("PRODUCT", "PRODUCTION"), "PRV": ("PREVIOUS",), "PYMT": ("PAYMENT",), "QTY": ("QUANTITY",),
    "QUAL": ("QUALIFICATION",), "RCVD": ("RECEIVED",), "RECD": ("RECEIVED",), "REF": ("REFERENCE",),
    "REG": ("REGISTRATION",), "REGD": ("REGISTERED",), "REGN": ("REGISTRATION",),
    "REL": ("RELATIONSHIP", "RELATION"), "RELN": ("RELATIONSHIP", "RELATION"), "SEQ": ("SEQUENCE",),
    "SETL": ("SETTLEMENT",), "SPEC": ("SPECIALITY", "SPECIALTY", "SPECIALISATION", "SPECIFICATION"),
    "SRC": ("SOURCE",), "STAT": ("STATUS",), "STLMT": ("SETTLEMENT",),
    "STS": ("STATUS",), "SYS": ("SYSTEM",), "TEL": ("TELEPHONE",), "TM": ("TIME",), "TOT": ("TOTAL",),
    "TRAN": ("TRANSACTION",), "TRANS": ("TRANSACTION",), "TRX": ("TRANSACTION",), "TS": ("TIMESTAMP",),
    "TXN": ("TRANSACTION",), "VAL": ("VALUE",), "VEH": ("VEHICLE",), "YR": ("YEAR",), "YRS": ("YEARS",),
}
FILLERS = frozenset({"OF", "THE", "AND", "FOR", "A", "AN"})
# Words whose presence or absence alone does not make a different column (plus the satellite's own words).
# DATE / STATUS / TYPE are left out on purpose: CREDIT_SCORE and CREDIT_SCORE_DATE are two columns.
QUALIFIERS = frozenset({
    "AMOUNT", "AMT", "CD", "CODE", "DAYS", "DESC", "DESCRIPTION", "DETAIL", "DETAILS", "FLAG", "FLG", "HOURS",
    "ID", "IDENTIFIER", "IND", "INDICATOR", "INFO", "INFORMATION", "LIST", "MASKED", "MONTHS", "NAME", "NM",
    "NO", "NUM", "NUMBER", "REF", "REFERENCE", "TEXT", "TXT", "VAL", "VALUE", "YEARS",
})
# Any other single extra word is accepted only when the names share at least this many words.
MIN_SHARED_FOR_ANY_EXTRA = 3
WORD_FORM_SUFFIXES = ("AL", "ALS", "ED", "D", "ER", "ERS", "ING", "LY", "OR", "ORS")
# An unknown piece like ITY / ITUDE / ISATION after a known word is the end of one longer word
# (NATIONAL+ITY = NATIONALITY), not a separate word. OR is left out: FATHERORSPOUSENAME has the word OR.
WORD_ENDINGS = frozenset({
    "ITY", "ITIES", "ITUDE", "ISATION", "IZATION", "ATION", "ATIONS", "ITION", "ENCE", "ANCE", "ISM", "IST",
    "ISTS", "ICAL", "ABLE", "IBLE", "OUS", "IVE", "IVES", "URE", "URES", "AGE", "AGES", "ERY", "ARY", "ORY",
    "IAN", "IANS", "EER", "ITE", "IZE", "ISE", "ENT", "ANT", "EMENT", "MENT", "NESS", "SHIP", "HOOD", "WARD",
    "WARDS", "IFY", "IFIED", "ISED", "IZED", "ING", "INGS", "ED", "ER", "ERS", "AL", "ALS", "LY", "S", "ES",
})
SAT_NAME_NOISE = frozenset({"SAT", "AUG", "LNK"})
SYNONYM_GROUPS = (
    frozenset({"FLAG", "FLG", "INDICATOR", "IND"}),
    frozenset({"SEX", "GENDER"}),
    frozenset({"PIN", "ZIP", "POST", "POSTAL"}),
    frozenset({"DETAIL", "DETAILS", "DESCRIPTION"}),
)
COMPOUNDS = {"PINCODE": ("PIN", "CODE"), "ZIPCODE": ("ZIP", "CODE"), "POSTCODE": ("POST", "CODE")}
OPPOSITES = {frozenset(p) for p in (
    ("MIN", "MAX"), ("MINIMUM", "MAXIMUM"), ("START", "END"), ("BEGIN", "END"), ("FROM", "TO"),
    ("LOWER", "UPPER"), ("OPEN", "CLOSE"), ("OPENING", "CLOSING"), ("OPENED", "CLOSED"),
    ("INWARD", "OUTWARD"), ("INCOMING", "OUTGOING"), ("INBOUND", "OUTBOUND"), ("DEBIT", "CREDIT"),
    ("BEFORE", "AFTER"), ("PRE", "POST"), ("FIRST", "LAST"), ("OLD", "NEW"), ("PREVIOUS", "NEXT"),
    ("PREVIOUS", "CURRENT"), ("MALE", "FEMALE"), ("GROSS", "NET"), ("INCLUDED", "EXCLUDED"),
    ("INCLUSION", "EXCLUSION"), ("INCLUDE", "EXCLUDE"), ("APPROVED", "REJECTED"), ("ACCEPTED", "REJECTED"),
    ("HIGH", "LOW"), ("HIGHER", "LOWER"), ("INPUT", "OUTPUT"), ("SENDER", "RECEIVER"), ("PAYER", "PAYEE"),
    ("EMPLOYER", "EMPLOYEE"), ("INSURER", "INSURED"), ("ASSIGNOR", "ASSIGNEE"), ("LESSOR", "LESSEE"),
    ("BUYER", "SELLER"), ("INCOME", "OUTCOME"), ("PRIMARY", "SECONDARY"), ("INTERNAL", "EXTERNAL"),
    ("ONLINE", "OFFLINE"), ("MINOR", "MAJOR"), ("DAILY", "MONTHLY"), ("MONTHLY", "YEARLY"),
)}
# CHEQUE / CHECK is left out on purpose: CHECK (verification) is far more common than the banking word.
UK_US_PAIRS = {frozenset(p) for p in (
    ("TYRE", "TIRE"), ("KERB", "CURB"), ("GREY", "GRAY"), ("AGEING", "AGING"), ("STOREY", "STORY"),
    ("ALUMINIUM", "ALUMINUM"), ("DRAUGHT", "DRAFT"), ("MOULD", "MOLD"), ("PLOUGH", "PLOW"),
    ("DESPATCH", "DISPATCH"),
)}
# Look like UK/US pairs but mean different things here (CUBIC_METRE is a unit, HOUR_METER a device).
NOT_UK_US = {frozenset(("METRE", "METER")), frozenset(("METRES", "METERS"))}
# Short forms that are the normal way to write the word in this repo (ORG_UNIT_*, *_ID, PRE_AUTH_*).
ACCEPTED_SHORT = frozenset({"ID", "ORG", "AUTH"})

UNDERSCORE, CK_SUFFIX, SHORTHAND, SPELLING, SYNONYM, WORD_ORDER, EXTRA = (
    "Underscores", "_CK suffix", "Shorthand", "Spelling", "Synonym", "Word order", "Extra word")
KIND_ORDER = (UNDERSCORE, CK_SUFFIX, SHORTHAND, SPELLING, SYNONYM, WORD_ORDER, EXTRA)
KIND_RANK = {k: i + 1 for i, k in enumerate(KIND_ORDER)}
KIND_HELP = OrderedDict([
    (UNDERSCORE, "Same letters, only the underscores differ.  BANK_NAME / BANKNAME,  ADDRESS_LINE_1 / ADDRESSLINE1"),
    (CK_SUFFIX, "One name ends in _CK, the other does not.  COVERAGE_REFERENCE / COVERAGE_REFERENCE_CK"),
    (SHORTHAND, "A word is shortened or a small word is left out.  NO / NUMBER,  AMT / AMOUNT,  "
                "NUMBER_SONS / NUMBER_OF_SONS"),
    (SPELLING, "A word is spelt differently (typo, UK/US, singular/plural, word form).  DETAIL / DETAILS,  "
               "EDUCATION / EDUCATIONAL"),
    (SYNONYM, "A different word with the same meaning.  FLAG / INDICATOR,  DETAILS / DESCRIPTION"),
    (WORD_ORDER, "Same words, different order.  QUALIFICATION_PASSING_MONTH / QUALIFICATION_MONTH_OF_PASSING"),
    (EXTRA, "One name has one more word.  OTHER_QUALIFICATION / OTHER_QUALIFICATION_DESCRIPTION  "
            "(can be a different column, so check)"),
])

Rel = namedtuple("Rel", "kinds detail cost")


def rel_rank(r):
    return max(KIND_RANK[k] for k in r.kinds)


def kinds_label(kinds):
    return " + ".join(k for k in KIND_ORDER if k in kinds)


# =====================================================================================================
# Small helpers
# =====================================================================================================
def _parts(name):
    return [t for t in name.split("_") if t]


def _compact(name):
    return name.replace("_", "")


def _up(v):
    return str(v).strip().strip('"').upper() if v is not None else ""


def _up_list(v):
    if v is None:
        return []
    if isinstance(v, str):
        v = [v]
    return [_up(x) for x in v]


def _osa(a, b, maxd):
    """Optimal-string-alignment (Damerau-Levenshtein) distance, or maxd + 1 once it is exceeded."""
    if abs(len(a) - len(b)) > maxd:
        return maxd + 1
    prev2, prev = None, list(range(len(b) + 1))
    for i in range(1, len(a) + 1):
        cur = [i] + [0] * len(b)
        low = i
        for j in range(1, len(b) + 1):
            v = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] != b[j - 1]))
            if i > 1 and j > 1 and a[i - 1] == b[j - 2] and a[i - 2] == b[j - 1]:
                v = min(v, prev2[j - 2] + 1)
            cur[j] = v
            low = min(low, v)
        if low > maxd:
            return maxd + 1
        prev2, prev = prev, cur
    return prev[len(b)]


def _is_subsequence(s, word):
    it = iter(word)
    return all(ch in it for ch in s)


def _uk_us_norm(w):
    w = w.replace("ISATION", "IZATION").replace("YSE", "YZE")
    w = re.sub(r"IS(E|ED|ES|ER|ERS|ING)", r"IZ\1", w)
    w = re.sub(r"OUR(S|ED|ING|ITE|ABLE)?$", r"OR\1", w)
    w = re.sub(r"([^AEIOU])RE$", r"\1ER", w)
    w = re.sub(r"NCE$", "NSE", w)
    w = re.sub(r"OGUE$", "OG", w)
    w = re.sub(r"MME$", "M", w)
    w = re.sub(r"DGEMENT", "DGMENT", w)
    return w.replace("LL", "L").replace("AE", "E").replace("OE", "E")


def _uk_us(x, y):
    if x == y or frozenset((x, y)) in NOT_UK_US:
        return False
    return frozenset((x, y)) in UK_US_PAIRS or _uk_us_norm(x) == _uk_us_norm(y)


def _plural(x, y):
    a, b = sorted((x, y), key=len)
    return b in (a + "S", a + "ES") or (a.endswith("Y") and b == a[:-1] + "IES")


def _word_form(x, y):
    """EDUCATION / EDUCATIONAL, CAPTURE / CAPTURED, CLAIM / CLAIMED: one word with an ending added."""
    a, b = sorted((x, y), key=len)
    return len(a) >= 4 and b.startswith(a) and b[len(a):] in WORD_FORM_SUFFIXES


def _opposite(x, y):
    if frozenset((x, y)) in OPPOSITES:
        return True
    a, b = sorted((x, y), key=len)
    if any(b == pre + a for pre in ("IN", "UN", "NON", "DIS", "IM", "IR", "IL")):
        return True  # negation: ACTIVE / INACTIVE
    return (len(x) == len(y) and x[:-2] == y[:-2]
            and {x[-2:], y[-2:]} <= {"ER", "EE", "ED", "OR"})  # EMPLOYER / EMPLOYEE, ISSUER / ISSUED


def _typo_pattern(t, w):
    """How a rare word t differs from a common word w, when it looks like a slip of the keyboard."""
    if _uk_us(t, w):
        return "UK/US spelling"
    if _plural(t, w) or _word_form(t, w) or _opposite(t, w):
        return None
    if abs(len(t) - len(w)) == 1:
        s, l = (t, w) if len(t) < len(w) else (w, t)
        for i in range(len(l)):
            if l[:i] + l[i + 1:] != s:
                continue
            if (i > 0 and l[i] == l[i - 1]) or (i + 1 < len(l) and l[i] == l[i + 1]):
                return "double letter"
            if 0 < i < len(l) - 1 and len(l) >= 8:
                return "letter missing or extra"
            if s == t and i == len(l) - 1 and l[i] in "AEIOUY" and len(s) >= 4:
                return "last letter missing"
        return None
    if len(t) == len(w):
        diff = [i for i in range(len(t)) if t[i] != w[i]]
        if len(diff) == 2 and diff[1] == diff[0] + 1 and t[diff[0]] == w[diff[1]] and t[diff[1]] == w[diff[0]]:
            return "letters swapped"
        if len(diff) == 1 and 0 < diff[0] < len(t) - 1 and len(t) >= 9:
            return "one letter wrong"
    return None


def _synonym(x, y):
    return any(x in g and y in g for g in SYNONYM_GROUPS)


def _initialism(s, toks):
    if len(s) < 2 or not s.isalpha() or not all(t.isalpha() for t in toks):
        return False
    lean = "".join(t[0] for t in toks if t not in FILLERS)
    return s == "".join(t[0] for t in toks) or (len(lean) >= 2 and s == lean)


def _canon(t):
    return ABBR[t][0] if t in ABBR else t


# =====================================================================================================
# Projects and satellite models
# =====================================================================================================
YAML_RE = re.compile(r"\{%-?\s*set\s+yaml_metadata\s*-?%\}(.*?)\{%-?\s*endset\s*-?%\}", re.S)


def model_schemas(dbt_project_yml):
    cfg = yaml.safe_load(dbt_project_yml.read_text()) or {}
    found = set()

    def walk(node):
        if isinstance(node, dict):
            for k, v in node.items():
                if k in ("+schema", "schema") and isinstance(v, str):
                    found.add(v.upper())
                else:
                    walk(v)

    walk(cfg.get("models") or {})
    return found


class Project:
    def __init__(self, path, system, lob):
        self.path, self.dir, self.system, self.lob = path, path.name, system, lob
        self.code = system[0] + lob[0]
        self.shared = SHARED_SCHEMA in model_schemas(path / "dbt_project.yml")
        self.sats = OrderedDict()

    @property
    def label(self):
        return f"{self.lob.title()} {self.system} ({self.code})"


class Sat:
    def __init__(self, project, path):
        m = YAML_RE.search(path.read_text())
        if not m:
            raise ValueError("no {% set yaml_metadata %} block")
        meta = yaml.safe_load(m.group(1)) or {}
        if not isinstance(meta.get("src_payload"), list):
            raise ValueError("src_payload is missing or not a list")
        self.project = project
        self.file = str(path.relative_to(ROOT))
        self.name = path.stem.upper()
        self.layer = "augmented" if "augmented" in path.parts else "standard"
        self.pk = _up(meta.get("src_pk"))
        self.cdk = _up_list(meta.get("src_cdk"))
        self.payload = _up_list(meta.get("src_payload"))
        self.cols = OrderedDict()  # business column -> role
        for c in self.cdk:
            self.cols[c] = "CDK"
        for c in self.payload:
            self.cols[c] = "CDK+PAYLOAD" if self.cols.get(c) == "CDK" else "PAYLOAD"


def discover_projects():
    projects, skipped = [], []
    for d in sorted(ROOT.glob("*_dv_dbt")):
        m = re.fullmatch(r"(opus|maximus)_([a-z]+)_dv_dbt", d.name)
        if m and (d / "dbt_project.yml").exists():
            projects.append(Project(d, m.group(1).upper(), m.group(2).upper()))
        else:
            skipped.append(d.name)
    projects.sort(key=lambda p: (LOB_ORDER.index(p.lob) if p.lob in LOB_ORDER else len(LOB_ORDER), p.lob,
                                 SYSTEM_ORDER.index(p.system)))
    seen = Counter(p.code for p in projects)
    for p in projects:
        if seen[p.code] > 1:
            p.code = p.system[0] + p.lob[:2]
    return projects, skipped


# =====================================================================================================
# Vocabulary + matching
# =====================================================================================================
class Lexicon:
    """Words seen in UPPER_SNAKE names across all projects; used to split squashed names into words."""

    def __init__(self, entries):  # entries: (project_code, name)
        entries = sorted(set(entries))
        names_with = defaultdict(set)
        self.spread = defaultdict(set)
        for code, name in entries:
            if "_" in name:
                for t in set(_parts(name)):
                    names_with[t].add(name)
                    self.spread[t].add(code)
        self.freq = Counter({t: len(n) for t, n in names_with.items()})
        self.words = set(self.freq)
        self._tok = {}
        singles = defaultdict(set)
        for code, name in entries:  # a squashed name that is not made of known words is a word itself
            if "_" not in name and name not in self.words and not name.isdigit() and len(self._segment(name)) == 1:
                singles[name].add(code)
        for w, codes in singles.items():
            self.freq[w] += 1
            self.spread[w] |= codes
        self.words |= set(singles)
        for code, name in entries:  # squashed names still count as usage of their words
            if "_" not in name:
                for t in self.tokens(name):
                    if t in self.words:
                        self.spread[t].add(code)

    def established(self, t):
        return self.freq[t] >= 3 and len(self.spread[t]) >= 2

    def _word_cost(self, w):
        base = 1.0 if len(w) >= 3 else (1.35 if len(w) == 2 else 1.9)
        return base - 0.02 * math.log1p(self.freq[w])

    def _segment(self, s):
        n = len(s)
        best, back = [math.inf] * (n + 1), [0] * (n + 1)
        best[0] = 0.0
        for i in range(1, n + 1):
            for j in range(i):
                if best[j] == math.inf:
                    continue
                piece = s[j:i]
                if piece.isdigit():
                    c = 1.0
                elif piece in self.words:
                    c = self._word_cost(piece)
                elif j > 0 and piece in WORD_ENDINGS:
                    c = 1.2  # an ending glued to the word before it: MOTHER+S, NATIONAL+ITY
                else:
                    c = 3.0 + 0.25 * len(piece)
                if best[j] + c < best[i] - 1e-12:
                    best[i], back[i] = best[j] + c, j
        pieces, i = [], n
        while i > 0:
            pieces.append(s[back[i]:i])
            i = back[i]
        out = []
        for piece in reversed(pieces):  # NATIONAL + ITY -> NATIONALITY, MOTHER + S -> MOTHERS
            if out and piece not in self.words and piece in WORD_ENDINGS and not out[-1].isdigit():
                out[-1] += piece
            else:
                out.append(piece)
        return tuple(out)

    def tokens(self, name):
        if name not in self._tok:
            out = []
            for part in _parts(name):
                if part in COMPOUNDS:
                    out.extend(COMPOUNDS[part])
                elif part.isdigit() or part in self.words:
                    out.append(part)
                else:
                    out.extend(self._segment(part))
            self._tok[name] = tuple(out)
        return self._tok[name]

    def style(self, name):
        if "_" in name:
            return "UPPER_SNAKE"
        return "SQUASHED" if len(self.tokens(name)) > 1 else "ONE WORD"


class Matcher:
    def __init__(self, lex):
        self.lex = lex
        self._rel, self._tok = {}, {}

    # ---------------------------------------------------------------- word level
    def abbreviation(self, s, l):
        if len(s) >= len(l) or not s.isalpha() or not l.isalpha():
            return None
        if l in ABBR.get(s, ()):
            return "shorthand"
        if s in ABBR or len(s) < 3 or len(l) - len(s) < 2 or self.lex.established(s) or _word_form(s, l):
            return None
        if l.startswith(s):
            return "shortened"
        if s[0] == l[0] and s[-1] == l[-1] and _is_subsequence(s, l):
            return "shortened"
        return None

    def word_spelling(self, x, y):
        if x == y or not (x.isalpha() and y.isalpha()):
            return None
        if _uk_us(x, y):
            return "UK/US spelling"
        if _plural(x, y):
            return "singular/plural"
        if _word_form(x, y):
            return "word form"
        if _opposite(x, y):
            return None
        longest = max(len(x), len(y))
        if longest < 5:
            return None
        limit = 1 if longest <= 8 else 2
        if _osa(x, y, limit) > limit:
            return None
        if self.lex.established(x) and self.lex.established(y):
            return None  # two real words (RATE / DATE, MODE / MODEL), not a typo
        return "typo?"

    def word_relation(self, x, y):
        key = (x, y)
        if key not in self._tok:
            s, l = (x, y) if len(x) < len(y) else (y, x)
            how = self.abbreviation(s, l)
            sp = None if how else self.word_spelling(x, y)
            if how:
                res = (SHORTHAND, f"{s} = {l} ({how})", 1.0)
            elif sp and sp != "typo?":  # DETAIL / DETAILS is singular/plural before it is a synonym
                res = (SPELLING, f"{x} / {y} ({sp})", 1.5)
            elif _synonym(x, y):
                res = (SYNONYM, f"{x} / {y} (synonym)", 1.5)
            else:
                res = (SPELLING, f"{x} / {y} ({sp})", 1.5) if sp else None
            self._tok[key] = res
        return self._tok[key]

    # ---------------------------------------------------------------- name level
    def relation(self, a, b, ctx=frozenset()):
        """How two different column names relate, or None when they are not the same column."""
        key = (a, b, ctx) if a < b else (b, a, ctx)
        if key not in self._rel:
            self._rel[key] = self._relation(key[0], key[1], ctx)
        return self._rel[key]

    def _relation(self, a, b, ctx):
        if a == b:
            return None
        if a.endswith("_CK") != b.endswith("_CK"):  # child-key copy: COVERAGE_REFERENCE vs COVERAGE_REFERENCE_CK
            sa, sb = (a[:-3] if a.endswith("_CK") else a), (b[:-3] if b.endswith("_CK") else b)
            if sa == sb:
                return Rel(frozenset({CK_SUFFIX}), "_CK on one side only", 0.3)
            inner = self.relation(sa, sb, ctx)
            if inner is None:
                return None
            return Rel(inner.kinds | {CK_SUFFIX}, inner.detail + "; _CK on one side only", inner.cost + 0.3)
        if _compact(a) == _compact(b):
            return Rel(frozenset({UNDERSCORE}), "only underscores differ", 0.1)
        A, B = self.lex.tokens(a), self.lex.tokens(b)
        style_diff = {self.lex.style(a), self.lex.style(b)} == {"UPPER_SNAKE", "SQUASHED"}
        found = self._align(A, B, ctx)
        if found:
            cost, ops = found
            free_extra = [w for k, _, w in ops if k == EXTRA and w not in QUALIFIERS and w not in ctx]
            shared = (set(A) & set(B)) - FILLERS
            if not free_extra or len(shared) >= MIN_SHARED_FOR_ANY_EXTRA:
                kinds = {k for k, _, _ in ops}
                notes = [t for k, t, _ in ops if k != UNDERSCORE]
                if style_diff or UNDERSCORE in kinds:
                    kinds.add(UNDERSCORE)
                    notes.append("underscores differ")
                return Rel(frozenset(kinds), "; ".join(OrderedDict.fromkeys(notes)), cost)
        why = self._loose_spelling(a, b, A, B)
        if why:
            kinds = {SPELLING} | ({UNDERSCORE} if style_diff else set())
            return Rel(frozenset(kinds), why + ("; underscores differ" if style_diff else ""), 3.0)
        ca = [_canon(t) for t in A if t not in FILLERS]
        cb = [_canon(t) for t in B if t not in FILLERS]
        if len(ca) > 1 and ca != cb and sorted(ca) == sorted(cb):
            kinds = {WORD_ORDER} | ({UNDERSCORE} if style_diff else set())
            if [t for t in A if t not in FILLERS and t in ABBR] or [t for t in B if t not in FILLERS and t in ABBR]:
                kinds.add(SHORTHAND)
            return Rel(frozenset(kinds), "same words in a different order", 4.0)
        return None

    def _align(self, A, B, ctx):
        """Cheapest word-by-word alignment of two names; returns (cost, ops) or None."""
        quals = QUALIFIERS | ctx
        nA, nB, memo = len(A), len(B), {}

        def go(i, j, extra_used):
            key = (i, j, extra_used)
            if key in memo:
                return memo[key]
            if i == nA and j == nB:
                return 0.0, ()
            best = None

            def take(cost, ni, nj, ne, op):
                nonlocal best
                sub = go(ni, nj, ne)
                if sub is not None and (best is None or cost + sub[0] < best[0]):
                    best = (cost + sub[0], ((op,) if op else ()) + sub[1])

            if i < nA and j < nB:
                if A[i] == B[j]:
                    take(0.0, i + 1, j + 1, extra_used, None)
                else:
                    w = self.word_relation(A[i], B[j])
                    if w:
                        take(w[2], i + 1, j + 1, extra_used, (w[0], w[1], None))
            for k in range(2, 6):
                if i < nA and j + k <= nB:
                    seg = B[j:j + k]
                    if A[i] == "".join(seg):
                        take(0.2, i + 1, j + k, extra_used, (UNDERSCORE, "", None))
                    elif _initialism(A[i], seg):
                        take(1.0, i + 1, j + k, extra_used,
                             (SHORTHAND, f"{A[i]} = {'_'.join(seg)} (initials)", None))
                if j < nB and i + k <= nA:
                    seg = A[i:i + k]
                    if B[j] == "".join(seg):
                        take(0.2, i + k, j + 1, extra_used, (UNDERSCORE, "", None))
                    elif _initialism(B[j], seg):
                        take(1.0, i + k, j + 1, extra_used,
                             (SHORTHAND, f"{B[j]} = {'_'.join(seg)} (initials)", None))
            if i < nA and A[i] in FILLERS:
                take(0.5, i + 1, j, extra_used, (SHORTHAND, f"'{A[i]}' left out", None))
            if j < nB and B[j] in FILLERS:
                take(0.5, i, j + 1, extra_used, (SHORTHAND, f"'{B[j]}' left out", None))
            if not extra_used:  # at most one extra word; qualifiers are cheaper than any other word
                if i < nA:
                    take(2.0 if A[i] in quals else 2.5, i + 1, j, True, (EXTRA, f"extra word {A[i]}", A[i]))
                if j < nB:
                    take(2.0 if B[j] in quals else 2.5, i, j + 1, True, (EXTRA, f"extra word {B[j]}", B[j]))
            memo[key] = best
            return best

        return go(0, 0, False)

    def _loose_spelling(self, a, b, A, B):
        """Letter-level typo check for names whose words could not be lined up."""
        ca, cb = _compact(a), _compact(b)
        if re.findall(r"\d+", ca) != re.findall(r"\d+", cb):
            return None  # ADDRESS_LINE_1 / ADDRESS_LINE_2 are different columns
        longest = max(len(ca), len(cb))
        if longest < 6 or abs(len(ca) - len(cb)) > 2:
            return None
        limit = 1 if longest <= 10 else 2
        if _osa(ca, cb, limit) > limit:
            return None
        only_a, only_b = Counter(A) - Counter(B), Counter(B) - Counter(A)
        if not only_a and not only_b:
            return None
        if sum(only_a.values()) == 1 and sum(only_b.values()) == 1:
            x, y = next(iter(only_a)), next(iter(only_b))
            if _opposite(x, y):
                return None
            if self.lex.established(x) and self.lex.established(y) and not (_uk_us(x, y) or _plural(x, y)):
                return None
            return f"{x} / {y} (typo?)"
        return f"{ca} / {cb} differ by {_osa(ca, cb, limit)} letter(s) (typo?)"


# =====================================================================================================
# Per-satellite grouping of names into columns
# =====================================================================================================
class Concept:
    """One column of one satellite, with the name each project uses for it."""

    def __init__(self, sat, names, roles, matcher, ctx):
        self.sat = sat
        self.names = names  # code -> name, project order
        self.roles = roles  # code -> role
        self.forms = OrderedDict()  # name -> [codes]
        for code, n in names.items():
            self.forms.setdefault(n, []).append(code)
        self.kinds, self.pair_notes = set(), []
        for x, y in combinations(self.forms, 2):
            r = matcher.relation(x, y, ctx)
            self.kinds |= r.kinds
            self.pair_notes.append(f"{x} / {y}: {r.detail}")
        self.most_used = max(self.forms, key=lambda f: (len(self.forms[f]), "_" in f, f))


def build_concepts(sat_name, sat_defs, matcher, ctx):
    roles = OrderedDict()  # name -> {code: role}
    for code, s in sat_defs.items():
        for c, role in s.cols.items():
            roles.setdefault(c, OrderedDict())[code] = role
    names = sorted(roles)
    parent = {n: n for n in names}
    members = {n: [n] for n in names}
    projs = {n: set(roles[n]) for n in names}

    def find(n):
        while parent[n] != n:
            parent[n] = parent[parent[n]]
            n = parent[n]
        return n

    edges = []
    for a, b in combinations(names, 2):
        if projs[a] & projs[b]:
            continue  # side by side in one project: different columns
        r = matcher.relation(a, b, ctx)
        if r:
            edges.append((rel_rank(r), r.cost, a, b))
    edges.sort()
    for _, _, a, b in edges:
        ra, rb = find(a), find(b)
        if ra == rb or projs[ra] & projs[rb]:
            continue
        if all(matcher.relation(x, y, ctx) for x in members[ra] for y in members[rb]):
            parent[rb] = ra
            members[ra] += members.pop(rb)
            projs[ra] |= projs.pop(rb)
    concepts = []
    for mem in members.values():
        names_by_code, role_by_code = OrderedDict(), OrderedDict()
        for code in sat_defs:
            for n in mem:
                if code in roles[n]:
                    names_by_code[code], role_by_code[code] = n, roles[n][code]
        concepts.append(Concept(sat_name, names_by_code, role_by_code, matcher, ctx))
    concepts.sort(key=lambda c: c.most_used)
    return concepts


def target_name(concept, lob_of, shared_codes):
    """(name to use, codes to rename, note) using the 2026-11-16 team rule.

    Among the allowed names (UPPER_SNAKE, else partner's): the one that the most projects already have or
    reach by changing underscores only; then the one used by more projects; then the one already in the
    shared BGIL_DATA_MODEL table (so the shared table changes least); then more underscores; then A-Z.
    """
    forms = concept.forms
    if len(forms) == 1:
        return concept.most_used, [], ""
    note = ""
    pool = [f for f in forms if "_" in f]
    if not pool:
        pool = [f for f in forms if any(lob_of[c] == "PARTNER" for c in forms[f])]
        note = ("no UPPER_SNAKE name in any project, so partner's name is kept" if pool
                else "no UPPER_SNAKE name and partner does not have it, so the most used name is picked")
        pool = pool or list(forms)

    def same_letters(f):  # projects that would only need underscores changed to reach f
        return sum(len(codes) for g, codes in forms.items() if _compact(g) == _compact(f))

    def rank(f):
        return same_letters(f), len(forms[f]), sum(c in shared_codes for c in forms[f])

    ordered = sorted(pool, key=lambda f: tuple(-x for x in rank(f)) + (-f.count("_"), f))
    target = ordered[0]
    ties = [f for f in ordered if rank(f) == rank(target)]
    if len(ties) > 1:
        note = (note + "; " if note else "") + f"{' and '.join(ties)} are used equally, {target} picked"
    for (sat, name), why in EXCEPTIONS.items():
        if concept.sat == sat and name in forms:
            note = (note + "; " if note else "") + why
    rename = [c for c, n in concept.names.items() if n != target]
    return target, rename, note


# =====================================================================================================
# Findings inside one project (listed at the bottom of the Summary sheet)
# =====================================================================================================
def single_project_findings(projects, defs, lex, matcher):
    rows = []  # (satellite, column, project, problem)
    occurrences = defaultdict(list)  # word -> [(code, sat, col)]
    for p in projects:
        for sat, s in p.sats.items():
            for col in s.cols:
                for t in set(lex.tokens(col)):
                    occurrences[t].append((p.code, sat, col))

    # 1. the same column twice in one satellite, written two ways
    for p in projects:
        for sat, s in p.sats.items():
            groups = defaultdict(list)
            for c in s.cols:
                groups[_compact(c)].append(c)
            for names in groups.values():
                if len(names) > 1:
                    shown = " + ".join(n + (" [cdk]" if "CDK" in s.cols[n] else "") for n in names)
                    rows.append((sat, shown, p.code, "Two columns in one satellite whose names differ only by underscores. Check what each holds: they can be different values (child key vs payload), so renaming one to the other's name would collide"))

    # 2. a rare word one keystroke away from a common word (in 3+ names of 2+ projects)
    common = defaultdict(list)
    for w in lex.words:
        if w.isalpha() and lex.established(w):
            common[len(w)].append(w)
    for t in sorted(occurrences):
        if not t.isalpha() or len(t) < 5 or lex.established(t) or t in ABBR:
            continue
        best = None
        for size in (len(t) - 1, len(t), len(t) + 1):
            for w in common.get(size, ()):
                if (w[0] != t[0] and w[-2:] != t[-2:]) or _osa(t, w, 1) > 1:
                    continue
                how = _typo_pattern(t, w)
                if how and how != "UK/US spelling" and (best is None or lex.freq[w] > lex.freq[best[0]]):
                    best = (w, how)
        if best:
            for code, sat, col in occurrences[t]:
                rows.append((sat, col, code, f"Possible spelling mistake: {t}, the usual word is {best[0]} "
                                             f"({best[1]}; {best[0]} is in {lex.freq[best[0]]} names)"))

    # 3. UK and US spelling of one word both in use
    groups = defaultdict(set)
    for w in occurrences:
        if w.isalpha() and len(w) >= 5:
            groups[_uk_us_norm(w)].add(w)
    for pair in UK_US_PAIRS:
        if all(w in occurrences for w in pair):
            groups["|".join(sorted(pair))] |= set(pair)
    for g in groups.values():
        if len(g) < 2 or any(pair <= g for pair in NOT_UK_US):
            continue
        forms = sorted(g, key=lambda w: (-len(occurrences[w]), w))
        main = forms[0]
        n = len(occurrences[main])
        for w in forms[1:]:
            for code, sat, col in occurrences[w]:
                rows.append((sat, col, code, f"UK/US spelling mix: {w} here, {main} in {n} other "
                                             f"column{'s' if n != 1 else ''}"))

    # 4. short forms (NO, AMT, FLG, ...) where the rest of the repo writes the full word
    short = OrderedDict()  # (sat, code) -> {column: [notes]}
    for p in projects:
        for sat, s in p.sats.items():
            for col in s.cols:
                parts = _parts(col) if "_" in col else []
                for i, t in enumerate(parts):
                    if t not in ABBR or t in ACCEPTED_SHORT:
                        continue
                    if t == "NO" and not (i == len(parts) - 1 or parts[i + 1].isdigit()):
                        continue  # NO_CLAIM_BONUS means "no", not "number"
                    fulls = [f for f in ABBR[t] if lex.freq[f]]
                    if not fulls or max(lex.freq[f] for f in fulls) <= lex.freq[t]:
                        continue
                    short.setdefault((sat, p.code), OrderedDict()).setdefault(col, []).append(
                        f"{t} = {' / '.join(fulls)}")
    for (sat, code), cols in short.items():
        words = OrderedDict.fromkeys(n for notes in cols.values() for n in notes)
        rows.append((sat, ", ".join(cols), code, f"Short form used ({'; '.join(words)}). "
                                                 "Other columns write the full word"))

    # 5. two satellite names that look like one satellite
    by_layer = defaultdict(list)
    for sat, d in defs.items():
        by_layer[next(iter(d.values())).layer].append(sat)
    for group in by_layer.values():
        for a, b in combinations(group, 2):
            if set(defs[a]) & set(defs[b]) or abs(len(a) - len(b)) > 12:
                continue
            r = matcher.relation(a, b)
            if r and EXTRA not in r.kinds:
                rows.append((a, "", ", ".join(defs[a]),
                             f"Satellite name looks like {b} ({', '.join(defs[b])}): {r.detail}. "
                             "No project builds both, so their columns were not compared"))
    return rows


# =====================================================================================================
# Workbook
# =====================================================================================================
Cell = namedtuple("Cell", "value fill")
HDR_FILL = PatternFill("solid", fgColor="1F4E78")
HDR_FONT = Font(bold=True, color="FFFFFF")
TITLE_FONT = Font(bold=True, size=14)
H2_FONT = Font(bold=True, size=12, color="1F4E78")
NOTE_FONT = Font(italic=True, size=10, color="595959")
TOP = Alignment(vertical="top")
WRAP = Alignment(wrap_text=True, vertical="top")
HEAD_ALIGN = Alignment(wrap_text=True, vertical="center")
RED = PatternFill("solid", fgColor="FFC7CE")
GREEN = PatternFill("solid", fgColor="C6EFCE")
AMBER = PatternFill("solid", fgColor="FFEB9C")
GREY = PatternFill("solid", fgColor="D9D9D9")
STATUS_FILL = {"Same name": GREEN, "Different names": RED, "One project only": None}


def put_row(ws, r, values, wrap_cols=()):
    for i, v in enumerate(values, 1):
        fill = None
        if isinstance(v, Cell):
            v, fill = v.value, v.fill
        c = ws.cell(r, i, v)
        if fill:
            c.fill = fill
        c.alignment = WRAP if i in wrap_cols else TOP


def put_header(ws, r, headers):
    for i, h in enumerate(headers, 1):
        c = ws.cell(r, i, h)
        c.fill, c.font, c.alignment = HDR_FILL, HDR_FONT, HEAD_ALIGN


def data_sheet(wb, title, note, headers, rows, widths, freeze, wrap=()):
    ws = wb.create_sheet(title)
    ws.cell(1, 1, note).font = NOTE_FONT
    put_header(ws, 2, headers)
    ws.row_dimensions[2].height = 32
    wrap_cols = {headers.index(h) + 1 for h in wrap}
    for r, row in enumerate(rows, 3):
        put_row(ws, r, row, wrap_cols)
    for i, h in enumerate(headers, 1):  # wide enough for the longest value, within a sensible cap
        longest = max([len(str(v.value if isinstance(v, Cell) else v or "")) for v in (r[i - 1] for r in rows)]
                      or [0])
        ws.column_dimensions[get_column_letter(i)].width = min(max(widths.get(h, 12), longest + 2), 80)
    ws.freeze_panes = freeze
    ws.auto_filter.ref = f"A2:{get_column_letter(len(headers))}{max(2 + len(rows), 3)}"


class Summary:
    def __init__(self, ws):
        self.ws, self.r = ws, 1

    def text(self, value, font=None):
        c = self.ws.cell(self.r, 1, value)
        if font:
            c.font = font
        self.r += 1

    def table(self, title, headers, rows, wrap_cols=()):
        self.text(title, H2_FONT)
        put_header(self.ws, self.r, headers)
        self.ws.row_dimensions[self.r].height = 30
        self.r += 1
        for row in rows:
            put_row(self.ws, self.r, row, wrap_cols)
            lines = 1
            for i in wrap_cols:  # Excel does not grow wrapped rows by itself
                text = row[i - 1].value if isinstance(row[i - 1], Cell) else row[i - 1]
                width = self.ws.column_dimensions[get_column_letter(i)].width or 10
                lines = max(lines, math.ceil(len(str(text or "")) / max(width - 2, 1)))
            if lines > 1:
                self.ws.row_dimensions[self.r].height = 15 * lines
            self.r += 1
        self.r += 1


# =====================================================================================================
# Main
# =====================================================================================================
def main():
    projects, skipped = discover_projects()
    codes = [p.code for p in projects]
    by_code = {p.code: p for p in projects}
    lob_of = {p.code: p.lob for p in projects}
    errors = []
    for p in projects:
        for path in sorted(p.path.glob("models/**/satellites/sat_*.sql")):
            if "dbt_packages" in path.parts or "target" in path.parts:
                continue
            try:
                s = Sat(p, path)
            except Exception as e:  # noqa: BLE001 - listed on the Summary, the run continues
                errors.append(f"{path.relative_to(ROOT)}: {type(e).__name__}: {e}")
                continue
            if s.name in p.sats:
                errors.append(f"{s.file}: {s.name} is also defined in {p.sats[s.name].file}")
                continue
            p.sats[s.name] = s

    sat_names = sorted({n for p in projects for n in p.sats})
    defs = OrderedDict((n, OrderedDict((p.code, p.sats[n]) for p in projects if n in p.sats)) for n in sat_names)
    layer_of = {n: " / ".join(sorted({s.layer for s in d.values()})) for n, d in defs.items()}
    entries = [(p.code, c) for p in projects for s in p.sats.values() for c in list(s.cols) + [s.pk]]
    entries += [(p.code, s.name) for p in projects for s in p.sats.values()]
    lex = Lexicon(entries)
    matcher = Matcher(lex)
    ctx_of = {n: frozenset(t for t in lex.tokens(n) if t not in SAT_NAME_NOISE) for n in defs}
    concepts = OrderedDict((n, build_concepts(n, d, matcher, ctx_of[n])) for n, d in defs.items() if len(d) > 1)

    # ------------------------------------------------------------------ LOB against LOB, OPUS against MAXIMUS
    lobs = [l for l in LOB_ORDER if l in lob_of.values()] + sorted(set(lob_of.values()) - set(LOB_ORDER))
    comparisons = []
    for i, base in enumerate(lobs):
        for other in lobs[i + 1:]:
            comparisons.append((f"{other.title()} vs {base.title()}",
                                [c for c in codes if lob_of[c] == other], [c for c in codes if lob_of[c] == base]))
    for l in lobs:
        maxi = [c for c in codes if lob_of[c] == l and by_code[c].system == "MAXIMUS"]
        opus = [c for c in codes if lob_of[c] == l and by_code[c].system == "OPUS"]
        if maxi and opus:
            comparisons.append((f"{l.title()}: MAXIMUS vs OPUS", maxi, opus))

    lob_stats = OrderedDict((label, Counter()) for label, _, _ in comparisons)
    info = {}
    for sat, ks in concepts.items():
        built = set(defs[sat])
        for label, a, b in comparisons:
            if built & set(a) and built & set(b):
                lob_stats[label]["sats"] += 1
        shared_writers = [c for c in defs[sat] if by_code[c].shared]
        for k in ks:
            differs = []
            for label, a, b in comparisons:
                fa = {k.names[c] for c in a if c in k.names}
                fb = {k.names[c] for c in b if c in k.names}
                if not (fa and fb):
                    continue
                st = lob_stats[label]
                st["both"] += 1
                kinds = set()
                for x in fa:
                    for y in fb:
                        if x != y:
                            kinds |= matcher.relation(x, y, ctx_of[sat]).kinds
                if not kinds:
                    st["same"] += 1
                    continue
                st["diff"] += 1
                st["underscores" if kinds == {UNDERSCORE} else "other"] += 1
                differs.append(label)
            target, rename, note = target_name(k, lob_of, {c for c in codes if by_code[c].shared})
            info[id(k)] = dict(differs=differs, target=target, rename=rename, note=note,
                               split=len({k.names[c] for c in shared_writers if c in k.names}) > 1)

    def status(k):
        if len(k.forms) > 1:
            return "Different names"
        return "One project only" if len(k.names) == 1 else "Same name"

    def name_cells(sat, k, rename):
        out = []
        for c in codes:
            if c not in defs[sat]:
                out.append(Cell(None, GREY))
            elif c in k.names:
                out.append(Cell(k.names[c] + (" [cdk]" if "CDK" in k.roles[c] else ""), RED if c in rename else None))
            else:
                out.append(None)
        return out

    diff_rows, all_rows = [], []
    for sat, ks in concepts.items():
        for k in ks:
            inf, st = info[id(k)], status(k)
            label = kinds_label(k.kinds) if st == "Different names" else ""
            cells = name_cells(sat, k, set(inf["rename"]))
            all_rows.append([sat, layer_of[sat], Cell(st, STATUS_FILL[st]), label] + cells
                            + [f"{len(k.names)} of {len(defs[sat])}",
                               ", ".join(c for c in defs[sat] if c not in k.names)])
            if st != "Different names":
                continue
            decided = any(sat == s and n in k.forms for s, n in EXCEPTIONS)  # team already chose a name
            only_us = k.kinds == {UNDERSCORE} and not decided
            detail = ([] if k.kinds == {UNDERSCORE} else list(k.pair_notes)) + ([inf["note"]] if inf["note"] else [])
            diff_rows.append([sat, layer_of[sat], label] + cells
                             + [inf["target"], ", ".join(inf["rename"]),
                                "Rename" if only_us else "Check, then rename",
                                Cell("Two columns in same table", AMBER) if inf["split"] else "Name only",
                                "; ".join(inf["differs"]), " | ".join(detail)])

    # Finished columns: sat_column_done.json maps SAT -> the Name-differences rows (one per column) as they were
    # before the fix. They are always listed, marked Done. Rows still found in the models are live and open.
    done = json.loads(DONE_FILE.read_text()) if DONE_FILE.exists() else {}
    for r in diff_rows:
        r.append("")
    for rows in done.values():
        diff_rows.extend([list(r) + ["Done"] for r in rows])
    diff_rows.sort(key=lambda r: (r[0], r[-1] != "Done"))
    extra = single_project_findings(projects, defs, lex, matcher)

    # ==================================================================== workbook
    wb = Workbook()
    write_summary(Summary(wb.active), projects, lex, defs, concepts, info, comparisons, lob_stats, extra,
                  errors, skipped)
    wb.active.title = "Summary"
    proj_headers = [p.label for p in projects]
    widths = {"Satellite": 30, "Layer": 10, "Difference": 14, "Status": 16, "Use this name": 16, "Rename in": 11,
              "Action": 12, "Effect": 14, "Differs between": 18, "Detail": 40, "Done": 8, "Defined in": 11,
              "Not defined in": 14, **{h: 18 for h in proj_headers}}
    data_sheet(
        wb, "Name differences",
        "One row per column that does not have the same name everywhere.  Red = rename here.  "
        "Grey = this project does not build the satellite.  Blank = builds it, but has no such column.  "
        "[cdk] = child key.",
        ["Satellite", "Layer", "Difference"] + proj_headers
        + ["Use this name", "Rename in", "Action", "Effect", "Differs between", "Detail", "Done"],
        diff_rows, widths, "D3", wrap=["Differs between"])
    data_sheet(
        wb, "All columns",
        "Every column of every satellite built by 2+ projects, side by side.  Grey = this project does not build "
        "the satellite.  Blank = builds it, but has no such column.  [cdk] = child key.",
        ["Satellite", "Layer", "Status", "Difference"] + proj_headers + ["Defined in", "Not defined in"],
        all_rows, widths, "E3")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    wb.save(OUT)

    print(f"projects: {', '.join(f'{p.code}={p.dir}' for p in projects)}")
    print(f"satellite models: {sum(len(p.sats) for p in projects)}, satellites compared: {len(concepts)}, "
          f"columns compared: {len(all_rows)}, with different names: {len(diff_rows)}")
    for label, st in lob_stats.items():
        print(f"  {label}: {st['diff']} different ({st['underscores']} only underscores) of {st['both']}")
    print(f"single-project findings: {len(extra)}, model errors: {len(errors)}")
    print(f"wrote {OUT}")


def write_summary(sm, projects, lex, defs, concepts, info, comparisons, lob_stats, extra, errors, skipped):
    ws = sm.ws
    for col, w in zip("ABCDEFGH", (62, 44, 12, 12, 12, 14, 26, 24)):
        ws.column_dimensions[col].width = w
    sm.text("Satellite column names: the same in every LOB and source?", TITLE_FONT)
    sm.text(f"Generated {dt.datetime.now():%Y-%m-%d %H:%M} from the satellite models of the {len(projects)} LOB "
            "projects (models/**/satellites/sat_*.sql). No JSON report or older validation tool is used.", NOTE_FONT)
    sm.text("Regenerate: python3 BGIL_DBT/validation/tools/gen_sat_column_consistency.py", NOTE_FONT)
    sm.r += 1

    sm.table("Sheets in this file", ["Sheet", "What it shows"], [
        ["Name differences", "Start here. Every column whose name is not the same in all LOBs and sources, "
                             "the name to use and where to rename it."],
        ["All columns", "Every column of every satellite built by 2+ projects, side by side. Also shows where a "
                        "column is not defined."],
    ])

    rows = []
    for p in projects:
        styles = Counter(lex.style(c) for s in p.sats.values() for c in s.cols)
        snake, squashed = styles["UPPER_SNAKE"], styles["SQUASHED"]
        pct = round(100 * snake / max(snake + squashed, 1))
        style = (f"UPPER_SNAKE ({pct}%)" if pct >= 90 else f"squashed ({100 - pct}%)" if pct <= 10
                 else f"mixed ({pct}% UPPER_SNAKE)")
        cdks = [c for s in p.sats.values() for c in s.cdk]
        rows.append([p.dir, f"{p.lob.title()} {p.system}", p.code, len(p.sats),
                     sum(len(s.cols) for s in p.sats.values()), f"{sum(c.endswith('_CK') for c in cdks)} of {len(cdks)}",
                     style, "shared BGIL_DATA_MODEL" if p.shared else "own schemas"])
    sm.table("Projects compared", ["Project", "LOB and source", "Code", "Satellites", "Columns",
                                   "Child keys ending _CK", "Column name style", "Tables written to"], rows)
    if skipped:
        sm.r -= 1
        sm.text(f"Folders skipped (not a LOB project): {', '.join(skipped)}", NOTE_FONT)
        sm.r += 1

    ks = [k for v in concepts.values() for k in v]
    diff = [k for k in ks if len(k.forms) > 1]
    rows = [
        ["Satellite models read", sum(len(p.sats) for p in projects)],
        ["Satellites built by 2+ projects (compared)", len(concepts)],
        ["Satellites built by one project only (nothing to compare)", len(defs) - len(concepts)],
        ["Columns compared", len(ks)],
        ["   same name in every project that has the column", sum(1 for k in ks if len(k.forms) == 1 and len(k.names) > 1)],
        ["   only one project has the column", sum(1 for k in ks if len(k.names) == 1)],
        [Cell("   different names  (sheet 'Name differences')", RED), Cell(len(diff), RED)],
        ["      only underscores differ", sum(1 for k in diff if k.kinds == {UNDERSCORE})],
    ] + [[f"      {kind} involved", sum(1 for k in diff if kind in k.kinds)]
         for kind in KIND_ORDER if kind != UNDERSCORE] + [
        ["   different names that make two columns in one shared table", sum(1 for k in diff if info[id(k)]["split"])],
    ]
    sm.table("Result", ["What", "Count"], rows)
    sm.r -= 1
    sm.text("A column can have more than one type of difference, so the type counts add up to more than the total.",
            NOTE_FONT)
    sm.r += 1

    rows = []
    for label, _, _ in comparisons:
        st = lob_stats[label]
        rows.append([label, st["sats"], st["both"], Cell(st["same"], GREEN if st["same"] else None),
                     Cell(st["diff"], RED if st["diff"] else None), st["underscores"], st["other"]])
    sm.table("LOB against LOB  (same idea as your Travel vs Partner list; filter 'Differs between' on "
             "'Name differences' to see the rows)",
             ["Comparison", "Satellites both build", "Columns both have", "Same name", "Different name",
              "Only underscores", "Other differences"], rows)

    sm.table("Types of difference", ["Type", "Meaning and example"], [[k, v] for k, v in KIND_HELP.items()])

    sm.text("How the name to use is chosen", H2_FONT)
    for line in (
        "Team rule (.kiro/steering/modeller-learnings.md, 2026-11-16): one attribute = one column name in every LOB.",
        "If any project uses an UPPER_SNAKE name, use it (the most used one if there are two). Otherwise keep "
        "partner's name. Rename in the project that differs, in its satfeed / stage (X as NAME).",
        "Action 'Rename': only underscores differ.  'Check, then rename': the names differ in more than underscores "
        "(confirm they are the same column first), or the team already chose a name (see Detail).",
        "Effect 'Two columns in same table': six projects write BGIL_DATA_MODEL, one table per satellite, with "
        "on_schema_change = append_new_columns, so each name becomes its own column.",
        "For a child key [cdk] the dbt run can also fail ('invalid identifier'). maximus_health writes its own "
        "schemas, so for it the effect is 'Name only'.",
        "A column that one project does not define is not an error by itself: each project declares only what its "
        "sources fill. See 'Not defined in' on 'All columns'.",
    ):
        sm.text("-  " + line)
    sm.r += 1

    if extra:
        sm.table("Other naming problems found (spelling, short forms, UK/US; not a difference between LOBs, "
                 "but worth fixing)",
                 ["Satellite", "Column(s)", "Project", "Problem"],
                 [list(r) for r in sorted(extra, key=lambda r: (r[3].split(":")[0], r[0], r[1]))], wrap_cols=(2,))
    if errors:
        sm.text("Satellite models that could not be read", H2_FONT)
        for e in errors:
            sm.text(e)
    ws.sheet_view.showGridLines = False


if __name__ == "__main__":
    main()
