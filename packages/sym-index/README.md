# sym-index

A **notation index**: a list of every symbol used in a document, each one linking back to the page where it was
defined.

I wrote it for my thesis, which has several hundred symbols. With `in-dexter`, every compile needed five layout passes, which made it very slow.

## Install

```sh
./install.sh            # from the repository root, symlinks into @local
```

```typst
#import "@local/sym-index:0.1.0": *
```

## Quick start

Declare a symbol once, where the text defines it:

```typst
The collision operator #symbol("Collision operator", $C_s$, key: "C_s") acts on …
```

Use it everywhere else through its key:

```typst
The operator #r("C_s") conserves particles.        // markup mode
$ pdv(#r("f_s"), t) = #r("C_s") [#r("f_s")] $       // math mode
```

Each `r()` prints the symbol, links to its definition, and adds the current
page to the index. Print the index at the back of the document:

```typst
= Index of symbols

== Ordered by name
#columns(2, make-index(indexes: ("Default",), use-page-counter: true))

== Ordered by symbol
#columns(2, make-index(indexes: ("Symbols",), use-page-counter: true))
```

The definition page is printed in **bold**, usage pages in normal weight.

### Why a key?

Without `key:`, the key is guessed from the math content with `math-to-sortkey`, which transforms `$C_s$` to `"C_s"`. Two visually different symbols can automatically get the same key. I recommend using the `key` argument regardless, to avoid collisions and to make it easier to change the math later.

### Referencing without indexing

`nr("C_s")` links without adding a page entry; `nlr("C_s")` renders the symbol alone.

## The plain index

`index()` is the low-level marker and works without any symbol machinery:

```typst
Tokamaks #index("tokamak") confine a plasma #index("plasma") with magnetic fields.
```

| argument | meaning |
| --- | --- |
| `index:` | which index the entry belongs to (default `"Default"`) — `make-index` selects on this |
| `display:` | content to print instead of the key |
| `initial:` | letter to file the entry under, when it differs from the key |
| `fmt:` | formatting of the page number, e.g. `strong` for a definition |
| `index-type:` | `indextype.Start` / `indextype.End` to open and close a page range |

`make-index()` takes `indexes`, `use-page-counter` (printed page number rather
than the physical one), `sort-order`, `entry-casing`, `range-delimiter`,
`min-range` (shortest run written as a range; a run of two stays `91, 92`),
`gap`, `entry-indent`, `entry-spacing` and `section-title`.

## page-list

`page-list(locations)` renders a set of locations as the same merged, linked page list the index uses. Useful for getting the same formatting elsewhere, e.g. in a glossary:

```typst
#import "@preview/glossy:0.9.1": *
#import "@local/sym-index:0.1.0": page-list

#let theme = (
  // …
  entry: (entry, index, total) => [
    *#entry.short* #entry.label. #entry.long
    #h(1em) #box(width: 1fr)
    #page-list(entry.pages.map(p => p.dest))
  ],
)
```

## Differences with in-dexter

* index markers don't store page numbers, so the layout settles in fewer passes (in-dexter always needs 5)
* consecutive pages are merged into ranges automatically
* a page listed both as definition (`fmt`) and as usage appears once, in bold
* no nested entries, no `f.`/`ff.` continuations

## License

MIT.
