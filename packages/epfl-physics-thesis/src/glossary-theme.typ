// ─── glossary-theme.typ ───
//
// A theme for `@preview/glossy`. Like its `theme-academic`, but each entry is
// one paragraph instead of a `grid(columns: (1fr, auto))`, so a long list of
// pages can't squeeze the term column down to one character per line, which
// happens with `theme-academic`.
#import "@local/sym-index:0.1.0": page-list

#let theme-thesis = (
  section: (title, body) => {
    heading(level: 1, title)
    v(1em)
    body
  },
  group: (name, index, total, body) => body,
  entry: (entry, index, total) => {
    block(below: 1em, par(first-line-indent: 0pt, hanging-indent: 1em, text(
      size: 0.95em,
      {
        text(weight: "bold", entry.short)
        entry.label
        if entry.long != none [. #entry.long]
        if entry.description != none [. #entry.description]
        h(1em)
        box(width: 1fr)
        text(fill: rgb("#666666"), page-list(entry.pages.map(p => p.dest)))
      },
    )))
  },
)
