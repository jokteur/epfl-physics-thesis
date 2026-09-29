// ─── sym-index ───
//
// Two things in one package:
//
//  * `fast-index.typ` — a small, fast index (compared to in-dexter). Drop-in for
//    in-dexter's `index()`
//
//  * `sym-index.typ` — a notation index. Declare a symbol
//    once with `symbol("Collision operator", $C_s$, key: "C_s")`, then write
//    `r("C_s")` everywhere you use it: the symbol renders, links back to its
//    definition, and records a page entry.
//
// See README.md for a worked example.

#import "fast-index.typ": first-letter-up, index, index-main, indextype, make-index, page-list
#import "math-to-sortkey.typ": math-to-sortkey
#import "sym-index.typ": (
  format-index, format-index-symbol, i, sym-nodef, symbol, i-main, nlr, nr, r, rr,
)
