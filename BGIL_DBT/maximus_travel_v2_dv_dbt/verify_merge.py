#!/usr/bin/env python3
"""
Verify the applied sat_aug_X -> sat_X merge against the pre-merge baseline
recovered from git, i.e. against what the files actually said before the edit --
not against the plan the edit script believed.

Gates:
  G1  every pre-merge standard payload column still present
  G2  every pre-merge augmented payload column now present
  G3  merged payload == union, exactly (no extras invented)
  G4  every feeder stage's HASHDIFF_<SAT> list == merged payload + child key
      (one identical input list across all feeders, so change detection sees
      the carried-over columns)
  G5  per (feeder, carried column) the expression equals what the deleted
      augmented stage declared for that same view -- real expression where the
      view supplies it, null pad where it does not -- and at least one feeder
      carries a real expression
  G6  every satfeed union branch selects the full merged payload
  G7  augmented models retired, with no dangling ref() anywhere in the project
"""
import os
import re
import sys
import glob
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'],
                               cwd=HERE, text=True).strip()
MODELS = os.path.join(HERE, 'models', 'raw_vault')
REL = os.path.relpath(HERE, REPO)
# The pre-merge baseline. NOT a branch name: once the merge lands on main,
# 'main' IS the merged state and every gate would pass over zero pairs -- a
# green light that means nothing. Pass a different commit as argv[1] if needed.
BASE = '5bc9980'

sys.path.insert(0, HERE)
import merge_high_pairs as M  # noqa: E402

REF_RE = re.compile(r"ref\(\s*'([^']+)'\s*\)")


def git_show(relpath):
    try:
        return subprocess.check_output(['git', 'show', '%s:%s' % (BASE, relpath)],
                                       cwd=REPO, text=True, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return None


def rp(abspath):
    return os.path.relpath(abspath, REPO)


def main():
    global BASE
    args = [a for a in sys.argv[1:] if not a.startswith('-')]
    if args:
        BASE = args[0]
    fails, checked = [], 0
    pre_aug = {}
    pre_std = {}
    # recover the pre-merge truth from git
    for f in subprocess.check_output(
            ['git', 'diff', '--name-status', BASE], cwd=REPO, text=True).splitlines():
        parts = f.split('\t')
        if parts[0] == 'D' and '/augmented/satellites/sat_aug_' in parts[1]:
            name = os.path.splitext(os.path.basename(parts[1]))[0]
            pre_aug[name] = M.payload_list(git_show(parts[1]))

    pairs = []
    for aug_sat, aug_cols in sorted(pre_aug.items()):
        std_sat = aug_sat.replace('sat_aug_', 'sat_', 1)
        stdp = os.path.join(MODELS, 'standard', 'satellites', std_sat + '.sql')
        base_txt = git_show(rp(stdp))
        if base_txt is None:
            fails.append('%s: standard satellite missing at %s' % (std_sat, BASE))
            continue
        pre_std[std_sat] = M.payload_list(base_txt)
        pairs.append((std_sat, aug_sat, aug_cols))

    if not pairs:
        print('NOTHING VERIFIED: no merged pair found between %s and the working '
              'tree. Check the baseline commit.' % BASE)
        return 1
    print('pairs verified against %s: %d' % (BASE, len(pairs)))

    for std_sat, aug_sat, aug_cols in pairs:
        sat_upper = std_sat[len('sat_'):].upper()
        hd = 'HASHDIFF_' + sat_upper
        stdp = os.path.join(MODELS, 'standard', 'satellites', std_sat + '.sql')
        feedp = os.path.join(MODELS, 'standard', 'satfeed',
                             'satfeed_mtv2_%s.sql' % std_sat)
        now = M.payload_list(M.read(stdp))
        want = sorted(set(pre_std[std_sat]) | set(aug_cols))

        missing_std = [c for c in pre_std[std_sat] if c not in now]
        missing_aug = [c for c in aug_cols if c not in now]
        extra = [c for c in now if c not in want]
        if missing_std:
            fails.append('G1 %s: lost standard column(s) %s' % (std_sat, missing_std))
        if missing_aug:
            fails.append('G2 %s: augmented column(s) not carried %s'
                         % (std_sat, missing_aug))
        if extra:
            fails.append('G3 %s: unexpected column(s) %s' % (std_sat, extra))
        checked += len(pre_std[std_sat]) + len(aug_cols)

        # what the deleted augmented stages said, per (view alias, column)
        base_expr = {}
        base_feed = git_show(rp(os.path.join(MODELS, 'augmented', 'satfeed',
                                             'satfeed_mtv2_aug_%s.sql' % aug_sat)))
        for st in REF_RE.findall(base_feed or ''):
            stxt = git_show(rp(os.path.join(MODELS, 'augmented', 'staging',
                                            st + '.sql')))
            dc = M.derived_columns(stxt or '')
            for c in aug_cols:
                if c in dc:
                    base_expr[(M.stage_alias(st), c)] = dc[c]
        if not base_expr:
            fails.append('G5 %s: could not recover augmented expressions from %s'
                         % (aug_sat, BASE))

        blk = M.yaml_block(M.read(stdp))
        mcdk = re.search(r'^src_cdk:\s*\n((?:\s*-\s*.*\n)+)', blk, re.M)
        cdk = re.findall(r"-\s*'([^']+)'", mcdk.group(1)) if mcdk else []

        feed_txt = M.read(feedp)
        feeders = REF_RE.findall(feed_txt)
        real = {c: [] for c in aug_cols}
        for st in feeders:
            sp = glob.glob(os.path.join(MODELS, '*', '*', st + '.sql'))
            if not sp:
                fails.append('G7 %s: feeder %s does not exist' % (std_sat, st))
                continue
            stxt = M.read(sp[0])
            # a wide stage serving several satellites suffixes a shared column
            # name as <COL>__SAT_<NAME>; the satfeed aliases it back. Normalise
            # before comparing, otherwise the convention looks like a defect.
            hcols = [re.sub(r'__SAT_%s$' % re.escape(sat_upper), '', c)
                     for c in M.hashdiff_cols(stxt, hd)]
            if sorted(hcols) != sorted(set(want) | set(cdk)):
                fails.append('G4 %s/%s: hashdiff %s != payload+cdk %s'
                             % (std_sat, st, len(hcols), len(set(want) | set(cdk))))
            dc = M.derived_columns(stxt)
            dc = {re.sub(r'__SAT_%s$' % re.escape(sat_upper), '', k): v
                  for k, v in dc.items()}
            basetxt = git_show(rp(sp[0])) or ''
            base_dc = M.derived_columns(basetxt)
            for c in aug_cols:
                if c not in dc:
                    fails.append('G5 %s/%s: %s not declared' % (std_sat, st, c))
                    continue
                expect = base_expr.get((M.stage_alias(st), c), M.NULL_PAD)
                if c in base_dc and base_dc[c] != M.NULL_PAD:
                    expect = base_dc[c]   # pre-existing, must not be overwritten
                if dc[c] != expect:
                    fails.append('G5 %s/%s: %s is %s, expected %s'
                                 % (std_sat, st, c, dc[c], expect))
                if dc[c] != M.NULL_PAD:
                    real[c].append(st)
        for c, where in real.items():
            if not where:
                fails.append('G5 %s: %s is null on every feeder -- column lost'
                             % (std_sat, c))

        branches = feed_txt.split('union all')
        for i, b in enumerate(branches):
            for c in want:
                if not re.search(r'\b%s\b' % re.escape(c), b):
                    fails.append('G6 %s: branch %d missing %s' % (std_sat, i + 1, c))

        for leftover in (os.path.join(MODELS, 'augmented', 'satellites',
                                      aug_sat + '.sql'),
                         os.path.join(MODELS, 'augmented', 'satfeed',
                                      'satfeed_mtv2_aug_%s.sql' % aug_sat)):
            if os.path.exists(leftover):
                fails.append('G7 %s: %s still present' % (std_sat,
                                                          os.path.basename(leftover)))

    # G7 -- no dangling refs anywhere in the project
    present = {os.path.splitext(os.path.basename(p))[0]
               for p in glob.glob(os.path.join(HERE, 'models', '**', '*.sql'),
                                  recursive=True)}
    for p in glob.glob(os.path.join(HERE, 'models', '**', '*.sql'), recursive=True):
        txt = M.read(p)
        for r in set(REF_RE.findall(txt)) | set(
                re.findall(r"^source_model:\s*'([^']+)'", M.yaml_block(txt), re.M)):
            if r not in present and not r.startswith(('stg_mtv2__', 'resolved_mtv2__')):
                fails.append('G7 %s refs missing model %s'
                             % (os.path.basename(p), r))

    print('payload columns accounted for: %d' % checked)
    if fails:
        print('\nFAILURES (%d):' % len(fails))
        for f in fails:
            print('  ' + f)
        return 1
    print('\nall gates pass: G1 G2 G3 G4 G5 G6 G7')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
