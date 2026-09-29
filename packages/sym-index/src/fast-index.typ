//─ fast-index.typ─
// Minimal, fast replacement for in-dexter. Drop-in for `index()`.
//
// Differences with in-dexter:
//  - index markers don't store page numbers, so the layout settles in fewer
//    passes
//  - consecutive pages are merged into ranges automatically
//  - a page listed both as definition (fmt) and as usage appears once, in bold
//  - no nested entries, no f./ff. continuations

#let indextype = (Cardinal: "Cardinal", Start: "Start", End: "End")

#let _as-text(it) = {
  let t = type(it)
  if it == none or it == auto { "" }
  else if t == str { it }
  else if t == int { str(it) }
  else if t == label { repr(it) }
  else if t == content {
    if it.has("text") {
      if type(it.text) == str { it.text } else { repr(it.text) }
    } else if it.has("children") {
      let c = it.children
      if c.len() == 0 { "" } else { c.map(_as-text).join("") }
    } else if it.has("body") { _as-text(it.body) }
    else { " " }
  }
  else { "" }
}

#let first-letter-up(s) = {
  if type(s) == str and s.len() > 0 {
    let f = s.first()
    upper(f) + s.slice(f.len())
  } else { s }
}

// index: marker. Only the last positional argument is the key.
#let index(
  fmt: none,
  index-type: indextype.Cardinal,
  initial: none,
  index: "Default",
  display: auto,
  ..entry,
) = {
  let pos = entry.pos()
  let key = if pos.len() == 0 { "" } else { _as-text(pos.last()) }
  [#metadata((
    name: index,
    key: key,
    display: display,
    initial: initial,
    kind: index-type,
    fmt: fmt,
  ))<fast-index>]
}

#let index-main = index.with(fmt: strong)

// Collection

#let _collect(names, use-page-counter) = {
  let reg = (:)
  let pcache = (:)
  let pending = (:)

  for e in query(<fast-index>) {
    let v = e.value
    if names != auto and not names.contains(v.name) { continue }

    let loc = e.location()
    let pp = loc.page()
    let pk = str(pp)
    let pi = pcache.at(pk, default: none)
    if pi == none {
      pi = if use-page-counter {
        let pat = loc.page-numbering()
        (n: counter(page).at(loc).first(), pat: if pat == none { "1" } else { pat })
      } else {
        (n: pp, pat: "1")
      }
      pcache.insert(pk, pi)
    }

    let ent = reg.at(v.key, default: (display: auto, initial: none, recs: ()))
    if ent.display == auto { ent.display = v.display }
    if ent.initial == none { ent.initial = v.initial }

    let rec = (a: pi.n, b: pi.n, pa: pp, pat: pi.pat, main: v.fmt != none, fmt: v.fmt, ex: false)

    if v.kind == indextype.Start {
      rec.ex = true
      ent.recs.push(rec)
      pending.insert(v.key, ent.recs.len() - 1)
    } else if v.kind == indextype.End and v.key in pending {
      let i = pending.remove(v.key)
      ent.recs.at(i).b = pi.n
    } else {
      ent.recs.push(rec)
    }
    reg.insert(v.key, ent)
  }
  reg
}

// Page list: dedup, cover ranges, merge consecutive runs

#let _groups(recs) = {
  let ranges = recs.filter(r => r.ex)
  let singles = recs.filter(r => not r.ex)

  let byp = (:)
  for r in singles {
    let k = repr(r.pat) + "#" + str(r.a)
    let prev = byp.at(k, default: none)
    if prev == none or (r.main and not prev.main) { byp.insert(k, r) }
  }
  singles = byp.values()

  if ranges.len() > 0 {
    singles = singles.filter(r => (
      r.main or not ranges.any(g => g.pat == r.pat and r.a >= g.a and r.a <= g.b)
    ))
  }

  let groups = ()
  for r in (ranges + singles).sorted(key: r => r.pa) {
    let merged = false
    if groups.len() > 0 {
      let g = groups.last()
      if not r.ex and not g.ex and g.pat == r.pat and g.main == r.main and r.a == g.b + 1 {
        g.b = r.a
        g.items.push(r)
        groups.last() = g
        merged = true
      }
    }
    if not merged { groups.push(r + (items: (r,))) }
  }
  groups
}

#let _link(rec, body) = link((page: rec.pa, x: 0pt, y: 0pt), body)

#let _num(rec, delimiter) = {
  let f = if rec.fmt == none { it => it } else { rec.fmt }
  let a = numbering(rec.pat, rec.a)
  f(if rec.a == rec.b { a } else { a + delimiter + numbering(rec.pat, rec.b) })
}

#let _render-pages(groups, delimiter, min-range) = {
  groups
    .map(g => {
      if g.ex or g.items.len() >= min-range {
        _link(g, _num(g, delimiter))
      } else {
        g.items.map(r => _link(r, _num(r, delimiter))).join(", ")
      }
    })
    .join(", ")
}

// page-list: merged, linked page numbers for a set of locations
// Useful to give another package (e.g. a glossary) the same page ranges.
#let page-list(locs, use-page-counter: true, range-delimiter: [--], min-range: 3) = context {
  let recs = locs.map(loc => {
    let pat = loc.page-numbering()
    let n = if use-page-counter { counter(page).at(loc).first() } else { loc.page() }
    (
      a: n,
      b: n,
      pa: loc.page(),
      pat: if use-page-counter and pat != none { pat } else { "1" },
      main: false,
      fmt: none,
      ex: false,
    )
  })
  _render-pages(_groups(recs), range-delimiter, min-range)
}

// make-index
//
//   indexes         : name (or array of names) of the indexes to render
//   use-page-counter: use the printed page number instead of the physical one
//   gap             : minimum space between the entry and its page numbers
//   entry-indent    : hanging indent of wrapped entries
//   entry-spacing   : vertical space between entries
//   min-range       : shortest run of consecutive pages written as a range (a run
//                     of two stays "91, 92")
#let make-index(
  indexes: auto,
  use-page-counter: false,
  sort-order: k => upper(k),
  entry-casing: k => first-letter-up(k),
  range-delimiter: [--],
  min-range: 3,
  gap: 1em,
  entry-indent: 1em,
  entry-spacing: 0.65em,
  section-title: (letter, counter) => heading(level: 2, numbering: none, outlined: false, letter),
) = context {
  set par(first-line-indent: 0pt, spacing: entry-spacing, hanging-indent: entry-indent)

  let reg = _collect(indexes, use-page-counter)

  let sections = (:)
  for (key, ent) in reg {
    let letter = if ent.initial != none {
      sort-order(ent.initial).first()
    } else {
      let s = sort-order(key)
      if s.len() > 0 { s.first() } else { "?" }
    }
    let bucket = sections.at(letter, default: ())
    bucket.push((key: key, ent: ent))
    sections.insert(letter, bucket)
  }

  let n = 0
  for letter in sections.keys().sorted() {
    section-title(letter, n)
    n += 1
    for it in sections.at(letter).sorted(key: it => sort-order(it.key)) {
      let disp = if it.ent.display == auto { entry-casing(it.key) } else { it.ent.display }
      disp
      h(gap)
      box(width: 1fr)
      _render-pages(_groups(it.ent.recs), range-delimiter, min-range)
      parbreak()
    }
  }
}
