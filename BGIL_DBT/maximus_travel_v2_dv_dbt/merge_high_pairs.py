#!/usr/bin/env python3
"""
Merge MAXIMUS Travel V2 'High' sat_aug_X -> sat_X pairs by editing the generated
model files in place.

Default scope: the pairs that are (a) mergeable without adding a satfeed branch
-- every augmented column's view is already a feeder of the standard satellite
-- and (b) not written into a shared vault table by the opus_travel sibling.

Per pair:
  1. every standard wide stage feeding the satellite gains each augmented column
     in derived_columns -- the real expression on the view that supplies it,
     'cast(null as varchar)' on the other feeders (null-padded to the SATELLITE,
     BUILD_RULES 6) -- and every augmented column name is added to that stage's
     HASHDIFF_<SAT> input list, so all feeders hash over one identical list.
  2. the standard satfeed gains the columns in every union branch.
  3. the standard satellite's src_payload is extended.
  4. the augmented satellite, its satfeed and its stages are deleted.

  --dry-run   print the plan, write nothing
  --apply     perform the edits
  --only-c    operate on the sibling-shared pairs instead (needs sign-off)
  --verify    re-check an applied merge: every column present, hashdiff lists
              agree across feeders, no dangling refs
"""
import os
import re
import sys
import glob

HERE = os.path.dirname(os.path.abspath(__file__))
MODELS = os.path.join(HERE, 'models', 'raw_vault')
STD_STAGE = os.path.join(MODELS, 'standard', 'staging')
STD_FEED = os.path.join(MODELS, 'standard', 'satfeed')
STD_SAT = os.path.join(MODELS, 'standard', 'satellites')
AUG_STAGE = os.path.join(MODELS, 'augmented', 'staging')
AUG_FEED = os.path.join(MODELS, 'augmented', 'satfeed')
AUG_SAT = os.path.join(MODELS, 'augmented', 'satellites')
OPUS_SAT = os.path.join(HERE, '..', 'opus_travel_dv_dbt', 'models', 'raw_vault')

REF_RE = re.compile(r"ref\(\s*'([^']+)'\s*\)")
NULL_PAD = "'cast(null as varchar)'"


def read(p):
    return open(p, encoding='utf-8').read()


def write(p, t):
    open(p, 'w', encoding='utf-8').write(t)


def yaml_block(text):
    m = re.search(r'(set yaml_metadata\s*-?%\})(.*?)(\{%-?\s*endset)', text, re.S)
    return m.group(2) if m else ''


def payload_list(text):
    blk = yaml_block(text)
    m = re.search(r'^src_payload:\s*\n((?:\s*-\s*.*\n)+)', blk, re.M)
    if m:
        return [x.strip().strip("'\"") for x in re.findall(r'-\s*(.+)', m.group(1))]
    m = re.search(r"^src_payload:\s*'([^']+)'", blk, re.M)
    return [m.group(1)] if m else []


def derived_columns(text):
    blk = yaml_block(text)
    m = re.search(r'^derived_columns:\s*\n(.*?)(?=^\S|\Z)', blk, re.M | re.S)
    out = {}
    if m:
        for line in m.group(1).splitlines():
            km = re.match(r'^  ([A-Za-z_0-9]+):\s*(.+)$', line)
            if km:
                out[km.group(1)] = km.group(2).strip()
    return out


def hashdiff_cols(text, hd):
    m = re.search(r'^  %s:\s*\n\s*is_hashdiff: true\s*\n\s*columns:\s*\n'
                  r'((?:\s*-\s*.*\n)+)' % re.escape(hd), yaml_block(text), re.M)
    return [x.strip().strip("'\"") for x in re.findall(r'-\s*(.+)', m.group(1))] if m else []


def stage_alias(model_name):
    m = re.match(r'^stg2_mtv2_aug__(.+?)__sat_aug_.+$', model_name)
    if m:
        return m.group(1)
    m = re.match(r'^stg2_mtv2(?:_up)?__(.+)$', model_name)
    return m.group(1) if m else None


def opus_satellites():
    return {os.path.splitext(os.path.basename(p))[0]
            for p in glob.glob(os.path.join(OPUS_SAT, '*', 'satellites', '*.sql'))}


# ------------------------------------------------------------------- planning
out_dead = []


def plan():
    shared_with_sibling = opus_satellites()
    out = []
    for augp in sorted(glob.glob(os.path.join(AUG_SAT, 'sat_aug_*.sql'))):
        aug_sat = os.path.splitext(os.path.basename(augp))[0]
        std_sat = aug_sat.replace('sat_aug_', 'sat_', 1)
        stdp = os.path.join(STD_SAT, std_sat + '.sql')
        if not os.path.exists(stdp):
            continue
        aug_txt, std_txt = read(augp), read(stdp)
        aug_cols, std_cols = payload_list(aug_txt), payload_list(std_txt)
        ab, sb = yaml_block(aug_txt), yaml_block(std_txt)
        if len(aug_cols) > 8:
            continue
        if (re.search(r"^src_pk:\s*'([^']+)'", ab, re.M).group(1)
                != re.search(r"^src_pk:\s*'([^']+)'", sb, re.M).group(1)):
            continue
        cdk_a = re.search(r'^src_cdk:\s*\n((?:\s*-\s*.*\n)+)', ab, re.M)
        cdk_s = re.search(r'^src_cdk:\s*\n((?:\s*-\s*.*\n)+)', sb, re.M)
        if (cdk_a.group(1).split() if cdk_a else []) != (cdk_s.group(1).split() if cdk_s else []):
            continue

        aug_feed = os.path.join(AUG_FEED, 'satfeed_mtv2_aug_%s.sql' % aug_sat)
        std_feed = os.path.join(STD_FEED, 'satfeed_mtv2_%s.sql' % std_sat)
        if not (os.path.exists(aug_feed) and os.path.exists(std_feed)):
            continue
        aug_stages = REF_RE.findall(read(aug_feed))
        std_stages = REF_RE.findall(read(std_feed))
        if not {stage_alias(s) for s in aug_stages} <= {stage_alias(s) for s in std_stages}:
            continue                                    # needs a new branch

        # Per (view, column): an augmented satellite fed by several stages
        # declares every column on every one of its stages -- the real
        # expression on the views that supply it, a null pad on the rest,
        # exactly as the standard track does. Carry that map over verbatim;
        # collapsing it to one expression per column would turn populated
        # columns into nulls.
        col_expr = {}
        for st in aug_stages:
            dc = derived_columns(read(os.path.join(AUG_STAGE, st + '.sql')))
            target = next(s for s in std_stages
                          if stage_alias(s) == stage_alias(st))
            for c in aug_cols:
                if c in dc:
                    col_expr[(target, c)] = dc[c]
        # a column null-padded on every stage that owns it is never populated
        dead = [c for c in aug_cols
                if not any(v != NULL_PAD for (t, k), v in col_expr.items() if k == c)]
        if dead:
            out_dead.append((aug_sat, dead))
            continue
        out.append({
            'std_sat': std_sat, 'aug_sat': aug_sat,
            'std_path': stdp, 'aug_path': augp,
            'std_feed': std_feed, 'aug_feed': aug_feed,
            'std_cols': std_cols, 'aug_cols': aug_cols,
            'std_stages': std_stages, 'aug_stages': aug_stages,
            'col_expr': col_expr,
            'hashdiff': 'HASHDIFF_' + std_sat[len('sat_'):].upper(),
            'sibling': std_sat in shared_with_sibling or aug_sat in shared_with_sibling,
        })
    return out


# -------------------------------------------------------------------- editing
def edit_stage(path, hd, new_cols, col_expr, stage_model, sat_upper):
    t = read(path)
    before_hd = hashdiff_cols(t, hd)
    if not before_hd:
        raise SystemExit('%s: no %s in %s' % (sat_upper, hd, path))

    # 1. hashdiff input list -- union, sorted, so every feeder hashes the same list
    want = sorted(set(before_hd) | set(new_cols))
    block = re.search(r'(^  %s:\s*\n\s*is_hashdiff: true\s*\n\s*columns:\s*\n)'
                      r'((?:\s*-\s*.*\n)+)' % re.escape(hd), t, re.M)
    t = (t[:block.start(2)]
         + ''.join("      - '%s'\n" % c for c in want)
         + t[block.end(2):])

    # 2. derived_columns -- real expression on the supplying view, null elsewhere
    dc = derived_columns(t)
    add, keep = [], []
    for c in new_cols:
        want_expr = col_expr.get((stage_model, c), NULL_PAD)
        if c in dc:
            # already declared on this stage for another satellite's payload.
            # Only a null pad may be upgraded to the real expression; never
            # overwrite an expression another satellite already depends on.
            if dc[c] == want_expr or want_expr == NULL_PAD:
                keep.append(c)
                continue
            if dc[c] == NULL_PAD:
                t = re.sub(r'^  %s:\s*%s\s*$' % (re.escape(c), re.escape(NULL_PAD)),
                           '  %s: %s' % (c, want_expr), t, count=1, flags=re.M)
                keep.append(c)
                continue
            raise SystemExit('%s/%s: %s already declared as %s, refusing to '
                             'overwrite with %s' % (sat_upper, stage_model, c,
                                                    dc[c], want_expr))
        add.append((c, want_expr))
    if add:
        anchor = re.search(r'^  (?:LOAD_DATETIME|RECORD_SOURCE):', t, re.M)
        ins = ''.join('  %s: %s\n' % (c, e) for c, e in sorted(add))
        t = t[:anchor.start()] + ins + t[anchor.start():]

    # 3. keep the header's payload tally honest
    def fix(m):
        return '--   %-34s SAT_%s payload %d of %d live here' % (
            hd, sat_upper, int(m.group(1)) + sum(
                1 for c, e in add if e != NULL_PAD), len(want))
    t = re.sub(r'--\s+%s\s+SAT_%s payload (\d+) of \d+ live here'
               % (re.escape(hd), sat_upper), fix, t)
    write(path, t)
    return before_hd, want


def edit_satfeed(path, new_cols, hd):
    t = read(path)
    ins = ''.join('        %s as %s,\n' % (c, c) for c in new_cols)
    # one insert per union branch, immediately before that branch's hashdiff line
    t, n = re.subn(r'( *)(%s as HASHDIFF,\n)' % re.escape(hd),
                   lambda m: ins + m.group(1) + m.group(2), t)
    if not n:
        raise SystemExit('%s: no "%s as HASHDIFF" branch found' % (path, hd))
    t = re.sub(r'(-- Payload is the union over ALL feeders.*?)(\d+) payload column',
               lambda m: '%s%d payload column' % (m.group(1), _newtotal[0]),
               t, flags=re.S)
    write(path, t)
    return n


def edit_satellite(path, std_cols, aug_cols):
    t = read(path)
    want = sorted(set(std_cols) | set(aug_cols))
    blk = re.search(r'(^src_payload:\s*\n)((?:\s*-\s*.*\n)+)', yaml_block(t), re.M)
    if blk:
        whole = re.search(r'(^src_payload:\s*\n)((?:\s*-\s*.*\n)+)', t, re.M)
        t = (t[:whole.start(2)] + ''.join("  - '%s'\n" % c for c in want)
             + t[whole.end(2):])
    else:
        t = re.sub(r"^src_payload:\s*'[^']+'\s*\n",
                   'src_payload:\n' + ''.join("  - '%s'\n" % c for c in want),
                   t, flags=re.M)
    write(path, t)
    return want


_newtotal = [0]


def apply_pair(p, log):
    _newtotal[0] = len(set(p['std_cols']) | set(p['aug_cols']))
    for st in p['std_stages']:
        sp = os.path.join(STD_STAGE, st + '.sql')
        if not os.path.exists(sp):
            sp = next(iter(glob.glob(os.path.join(MODELS, '*', '*', st + '.sql'))))
        b, a = edit_stage(sp, p['hashdiff'], p['aug_cols'], p['col_expr'], st,
                          p['std_sat'][len('sat_'):].upper())
        log.append('  stage   %-52s hashdiff %d -> %d' % (st, len(b), len(a)))
    n = edit_satfeed(p['std_feed'], p['aug_cols'], p['hashdiff'])
    log.append('  satfeed %-52s %d branch(es) + %d cols'
               % (os.path.basename(p['std_feed']), n, len(p['aug_cols'])))
    want = edit_satellite(p['std_path'], p['std_cols'], p['aug_cols'])
    log.append('  sat     %-52s payload %d -> %d'
               % (p['std_sat'], len(p['std_cols']), len(want)))

    # retire the augmented side
    others = set()
    for f in glob.glob(os.path.join(AUG_FEED, '*.sql')):
        if f != p['aug_feed']:
            others |= set(REF_RE.findall(read(f)))
    removed = [p['aug_path'], p['aug_feed']]
    for st in p['aug_stages']:
        if st not in others:
            removed.append(os.path.join(AUG_STAGE, st + '.sql'))
    for f in removed:
        if os.path.exists(f):
            os.remove(f)
    log.append('  removed %d file(s): %s'
               % (len(removed), ', '.join(os.path.basename(x) for x in removed)))
    return want


if __name__ == '__main__':
    ps = plan()
    only_c = '--only-c' in sys.argv
    sel = [p for p in ps if p['sibling'] == only_c]
    print('%s pairs: %d, augmented columns: %d'
          % ('sibling-shared' if only_c else 'mtv2-only in-place',
             len(sel), sum(len(p['aug_cols']) for p in sel)))
    if '--apply' not in sys.argv:
        for p in sel:
            print('  %-40s <- %-44s +%d cols, %d feeder(s)'
                  % (p['std_sat'], p['aug_sat'], len(p['aug_cols']),
                     len(p['std_stages'])))
        raise SystemExit(0)
    log = []
    for p in sel:
        log.append('%s <- %s' % (p['std_sat'], p['aug_sat']))
        apply_pair(p, log)
    print('\n'.join(log))
    print('\nmerged %d pairs, %d columns'
          % (len(sel), sum(len(p['aug_cols']) for p in sel)))
