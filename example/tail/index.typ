#import "../shared.typ": *

// The index is not an appendix: drop the "B" that `back-matter` would give it.
#show: nonumber

= Index of symbols <sec:symbol-index>

Every symbol used in more than one place, with the page that *defines* it in
bold and the pages that use it in normal weight. Runs of consecutive pages are
merged into a range. All of it is generated -- the list below is exactly the set
of `symbol` declarations and `r` uses in the document.

#set text(size: 10pt)

== Ordered by name

#columns(2)[
  #make-index(
    indexes: ("Default",),
    use-page-counter: true,
    gap: 1em,
  )
]

== Ordered by symbol

#columns(2)[
  #make-index(
    indexes: ("Symbols",),
    use-page-counter: true,
    gap: 1em,
  )
]
