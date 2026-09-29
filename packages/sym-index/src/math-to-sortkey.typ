// All math functions that simply wrap a `body`
#let math-wrappers = (
  math.bold, math.upright, math.italic,
  math.cal,  math.scr,    math.bb,
  math.frak, math.sans,   math.mono, math.serif,
)

#let is-greek(ch) = {
  let cp = ch.to-unicode()
  (cp >= 0x0370 and cp <= 0x03FF) or (cp >= 0x1F00 and cp <= 0x1FFF)
}

#let is-terminal(s) = {
  s.len() == 1 and (
    s == upper(s) or s == lower(s) or
    s.match(regex("[0-9]")) != none or
    is-greek(s)
  )
}

#let math-to-sortkey(content) = {
  let f = content.func()

  if content.has("text") {
    let t = if type(content.text) == str { content.text }
            else { repr(content.text) }
    t
  }
  else if math-wrappers.contains(f) {
    math-to-sortkey(content.body)
  }
  // Subscript / superscript: base + subscript + superscript
  else if f == math.attach {
    let base-key = math-to-sortkey(content.base)
    let sub-key  = if content.has("b") and content.b != none {
      "_" + math-to-sortkey(content.b)
    } else { "" }
    let sup-key  = if content.has("t") and content.t != none {
      "^" + math-to-sortkey(content.t)
    } else { "" }
    base-key + sub-key + sup-key
  }
  else if f == math.accent {
    math-to-sortkey(content.base)
  }
  else if f == math.lr {
    if content.body.has("children") {
      let inner = content.body.children
      let mid = inner.slice(1, inner.len() - 1)
      let results = mid
        .map(math-to-sortkey)
        .filter(x => x != none and x != "")
      if results.len() > 0 { results.first() } else { none }
    } else {
      math-to-sortkey(content.body)
    }
  }
  else if f == math.limits {
    math-to-sortkey(content.body)
  }
  else if f == math.equation {
    math-to-sortkey(content.body)
  }
  else if content.has("child") {
    math-to-sortkey(content.child)
  }
  else if content.has("children") {
    let results = content.children
      .map(math-to-sortkey)
      .filter(x => x != none and x != "")
    if results.len() > 0 { results.first() } else { none }
  }
  else if content.has("body") {
    math-to-sortkey(content.body)
  }
  else {
    repr(content)
  }
}
