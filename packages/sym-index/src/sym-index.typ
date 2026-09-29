//─ sym-index.typ─
//
// A notation index: every symbol is declared once at its definition site with
// `symbol`, and every later use is written as `r("key")`. A use renders the
// registered math content, links back to the definition, and adds a page entry
// to the index. `make-index` (from fast-index.typ) then prints the index.
//
// Two indexes are filled at once:
//   "Default" — sorted by the description  ("Collision operator  C_s")
//   "Symbols" — sorted by the symbol       ("C_s - Collision operator")
//
#import "fast-index.typ": first-letter-up, index, indextype, make-index
#import "math-to-sortkey.typ": math-to-sortkey

// Internal helpers

// State storing key -> display-content for all registered symbols
#let _sym-registry = state("sym-registry", (:))
#let _sym-registry-text = state("sym-registry-text", (:))
#let _sym-registry-show = state("sym-registry-show", (:))

// Convert a string key like "C_s" into a valid Typst label name "sym-C_s"
#let _sym-label(key) = label("sym-" + key)

// Derive the registry key: an explicit `key:` always wins, otherwise the key is
// guessed from the math content (`$C_s$` -> "C_s").
#let _key-of(key, mathonly, expr) = {
  if key != none { key } else if mathonly != none { math-to-sortkey(mathonly) } else if type(expr) == str { expr } else { repr(expr) }
}

#let format-index(expr, math) = {
  first-letter-up(expr) + " " + math
}
#let format-index-symbol(expr, math) = {
  math + " - " + first-letter-up(expr)
}

// sym-nodef: declaring a symbol without defining it on this page (can be useful if a symbol is not written yet in the thesis).
//   expr     : text description, e.g. "Collisional operator"
//   mathonly : math content,     e.g. $C_s$
//   key      : string identifier used for linking, e.g. "C_s"
//              Defaults to math-to-sortkey(mathonly) if not provided (less robust).
//   register : Internal use, if false does not register the key
//   idx      : Display in index
#let sym-nodef(expr, mathonly, key: none, register: true, idx: true, ..args) = {
  if mathonly == none {
    if idx { index(expr, ..args) }
  } else {
    let k = _key-of(key, mathonly, expr)

    if register {
      _sym-registry.update(reg => { reg.insert(k, mathonly); reg })
      _sym-registry-text.update(reg => { reg.insert(k, expr); reg })
    }

    if idx {
      let disp = format-index(expr, mathonly)
      index(display: disp, disp, ..args)
      index(display: format-index-symbol(expr, mathonly), k + expr, index: "Symbols", ..args)
    }
  }
}

// symbol: definition function — registers symbol and places anchor label
//
//   expr     : text description, e.g. "Collisional operator"
//   mathonly : math content,     e.g. $C_s$
//   key      : string identifier used for linking, e.g. "C_s"
//              Defaults to math-to-sortkey(mathonly) if not provided (less robust).
//   register : Internal use, if false does not register the key
//   idx      : Display in index
#let symbol(expr, mathonly, key: none, register: true, idx: true, ..args) = {
  // Determine the registry key
  let k = _key-of(key, mathonly, expr)

  if register {
    _sym-registry-show.update(reg => {
      reg.insert(k, idx)
      reg
    })
  }

  // Place the anchor label immediately after the index marker.
  // The label attaches to the nearest preceding element.
  sym-nodef(expr, mathonly, key: k, register: register, idx: idx, fmt: strong, ..args)
  [#metadata(k)#_sym-label(k)]
}

// r: reference a symbol — clickable link + index usage entry
//
//   key      : same string used in symbol, e.g. "C_s"
//   display  : optional override for the rendered math content.
//              If omitted, uses the content registered by symbol.
//
#let r(key, display: none, use-link: true) = {
  context {
    let reg = _sym-registry.final()
    let expr-reg = _sym-registry-text.final()
    let show-reg = _sym-registry-show.final()

    let math-content = if key in reg {
      reg.at(key)
    } else {
      raw(key)
    }

    let expr = if key in reg {
      expr-reg.at(key)
    } else {
      none
    }

    let idx = if key in show-reg {
      show-reg.at(key)
    } else {
      true
    }

    sym-nodef(expr, math-content, key: key, register: false, idx: idx)

    // In case the user wanted a custom display
    let disp = if display != none {
      display
    } else if key in reg {
      reg.at(key)
    } else {
      raw(key)
    }

    // Only link if the label exists in the document
    let target-label = _sym-label(key)
    let label-exists = query(target-label).len() > 0
    // Wrap in a link pointing to the definition anchor
    if use-link and label-exists {
      link(_sym-label(key), disp)
    } else {
      disp
    }
  }
}

// Another definition for r (useful for figures labels)
#let rr = r

// nr: reference a symbol — clickable link only, no index entry
#let nr(key, display: none, use-link: true) = {
  context {
    let reg = _sym-registry.final()
    let math-content = if display != none {
      display
    } else if key in reg {
      reg.at(key)
    } else {
      raw(key)
    }
    if use-link and query(_sym-label(key)).len() > 0 {
      link(_sym-label(key), math-content)
    } else {
      math-content
    }
  }
}

// nlr: render the symbol, no link and no index entry
#let nlr(key, display: none) = nr(key, display: display, use-link: false)

// Text-only index entries (no symbol attached)
#let i(expr, ..args) = sym-nodef(expr, none, ..args)
#let i-main(expr, ..args) = index(expr, fmt: strong, ..args)
