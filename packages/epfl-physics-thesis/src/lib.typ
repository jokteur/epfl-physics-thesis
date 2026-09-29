// ─── epfl-physics-thesis ───
//
//   #import "@local/epfl-physics-thesis:0.1.0": *
//   #show: template.with(title: [My thesis], author: "Ada Lovelace")
//
// Commonly used packages are re-exported here, so the import above also
// brings in physica (vectors, derivatives), unify (`qty`, `num`), subpar
// (subfigures), glossy (acronyms) and sym-index (the notation index).

#import "@preview/physica:0.9.8": *
#import "@preview/unify:0.8.1": num, numrange, qty, qtyrange
#import "@preview/subpar:0.2.2"
#import "@preview/glossy:0.9.1": *
#import "@preview/itemize:0.2.0"
#import "@local/sym-index:0.1.0": *

#import "states.typ": in-appendix, in-outline
#import "grideq.typ": gridequations
#import "cover-page.typ": cover-page
#import "cv.typ": *
#import "glossary-theme.typ": theme-thesis

// small helpers

#let fill-line(left-text, right-text) = [#left-text #h(1fr) #right-text]

// Long caption under the figure, short one in the list of figures.
// See https://sitandr.github.io/typst-examples-book/book/snippets/chapters/outlines.html#long-and-short-captions-for-the-outline
#let flex-caption(long, short) = context {
  if in-outline.get() { short } else { long }
}

// An unnumbered, unlisted heading — for the small titles inside a chapter.
#let shh(content, level: 4) = heading(content, level: level, numbering: none, outlined: false)

// Drop the numbering of every heading in `body`.
#let nonumber(body) = {
  set heading(numbering: none)
  body
}

// A display equation without a number.
#let nonum(eq) = math.equation(block: true, numbering: none, eq)

// A reference with no supplement: "(2.4)" instead of "Eq. (2.4)".
#let nref(label) = ref(label, supplement: none)

// A horizontal fraction, a/b, inside a display equation.
#let hf(a, b) = math.frac(a, b, style: "horizontal")

// Chapter-relative numbering, switching to "A.2" inside the appendix.
// Numbering functions are evaluated in a context, so the states can be read
// directly.
#let _chapter-number(n) = {
  let h = counter(heading).get()
  let c = if h.len() > 0 { h.first() } else { 1 }
  numbering(if in-appendix.get() { "A.1" } else { "1.1" }, c, n)
}

// `subpar.grid`, numbered like every other figure: 2.3a, 2.3b, …
#let subfigures = subpar.grid.with(
  numbering: _chapter-number,
  numbering-sub-ref: (..n) => {
    let h = counter(heading).get()
    let c = if h.len() > 0 { h.first() } else { 1 }
    numbering(if in-appendix.get() { "A.1a" } else { "1.1a" }, c, ..n)
  },
)

// document parts

// Roman page numbers, unnumbered headings: abstract, acknowledgements, outline.
//
// Break the page *before* resetting the counter. Chapters start on a recto
// page, so otherwise page 1 could end up on the blank verso before it.
#let front-matter(body) = {
  pagebreak(to: "odd")
  set page(numbering: "i")
  counter(page).update(1)
  set heading(numbering: none)
  show heading.where(level: 1): it => {
    it
    v(6%, weak: true)
  }
  body
}

// Arabic page numbers restarting at 1, numbered chapters: the thesis itself.
#let main-matter(body) = {
  pagebreak(to: "odd")
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    it
    v(12%, weak: true)
  }
  body
}

// Appendices, index, glossary, bibliography, CV. Chapters become A, B, C …
// and `in-appendix` switches equations and figures to A.1, A.2 …
#let back-matter(body) = {
  set heading(numbering: "A.1.1", supplement: [Appendix])
  counter(heading.where(level: 1)).update(0)
  counter(heading).update(0)
  counter(math.equation).update(0)

  in-appendix.update(true)
  body
}

// the template

// This function gets your whole document as its `body` and formats it.
#let template(
  // The title for your work.
  title: [Your Title],
  // Author's name.
  author: "Author",
  // The paper size to use.
  paper-size: "a4",
  // Date that will be displayed on cover page.
  // The value needs to be of the 'datetime' type.
  // More info: https://typst.app/docs/reference/foundations/datetime/
  // Example: datetime(year: 2026, month: 03, day: 17)
  date: none,
  // Format in which the date will be displayed on cover page.
  // More info: https://typst.app/docs/reference/foundations/datetime/#format
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  // Main language of the document.
  lang: "en",
  // Body font. If a font is not installed, the next one in the list is used.
  body-font: ("Utopia LaTeX", "Libertinus Serif", "New Computer Modern"),
  body-size: 11pt,
  // Font for `raw` (code) blocks.
  raw-font: ("Iosevka", "Fira Mono", "DejaVu Sans Mono"),
  // The content of your work.
  body,
) = {
  // Set the document's metadata.
  set document(
    title: title,
    author: author,
    date: if date != none { date } else { auto },
  )

  set text(font: body-font, size: body-size, lang: lang)

  // Modify this if you want to change how much the text hyphenates
  set text(costs: (hyphenation: 100%))

  // Configure page size and margins. The *inside* margin (the gutter, towards
  // the binding) is the wide one.
  set page(
    paper: paper-size,
    margin: (
      bottom: 42mm,
      top: 28mm,
      inside: 37mm,
      outside: 26.2mm,
    ),
    // No page numbers until `front-matter` turns them on: the cover and
    // dedication have no page number.
    numbering: none,
    // Page number goes on the outside edge: right on odd (recto) pages,
    // left on even (verso) ones. Done via `footer` rather than `number-align`,
    // which cannot depend on the page parity.
    footer: context {
      let num = page.numbering
      if num == none { return }
      set align(if calc.even(here().page()) { left } else { right })
      numbering(num, ..counter(page).get())
    },
  )

  // Configure paragraph properties. Default leading is 0.65em, spacing 1.2em.
  set par(leading: 0.7em, justify: true, linebreaks: "optimized")
  set par(spacing: 1.35em)

  // Every `pagebreak()` in the document becomes a weak one, so a break that
  // lands on an already empty page is dropped instead of producing a blank
  // sheet. Beware: this also drops the breaks you *want* on an empty page —
  // write `pagebreak(weak: false)` there (see head/dedication.typ).
  set pagebreak(weak: true)

  show heading: it => {
    v(2.5em, weak: true)
    it
    v(1.5em, weak: true)
  }
  show heading: set text(hyphenate: false)
  show pagebreak.where(to: "odd"): set page(header: none, footer: none)

  // Style chapter headings: a black tab extending into the inner margin, with
  // the chapter number in white.
  show heading.where(level: 1): it => {
    set text(size: 22pt)
    set heading(supplement: [Chapter])

    let black_rectangle = place(
      dx: -page.margin.inside,
      dy: -1em,
      rect(fill: black, width: page.margin.inside - 5pt, height: 2em),
    )

    let heading_number = if it.numbering == none { [] } else {
      counter(heading.where(level: 1)).display(it.numbering)
    }
    let white_heading_number = place(dx: -1em, text(fill: white, heading_number))

    // Start chapters on odd (recto, right-hand) pages.
    pagebreak(to: "odd")

    v(16%)
    rect(
      stroke: none,
      inset: 0em,
      black_rectangle + white_heading_number + it.body,
    )
  }

  // Equations and figures are numbered per chapter, so their counters have to
  // be reset when a new chapter starts.
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }

  set heading(numbering: "1.1")

  // Running header: chapter number and title, mirrored on verso pages, and
  // nothing on a page where a chapter starts.
  set page(
    header-ascent: 30%,
    header: context {
      let page-number = here().page()

      let target = heading.where(level: 1)
      if query(target).any(it => it.location().page() == page-number) {
        return []
      }

      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()

        let chapter-title = current.body
        let chapter-number = counter(heading.where(level: 1)).display()
        let chapter-number-text = [Chapter #chapter-number]

        if current.numbering != none {
          let (left-text, right-text) = if calc.odd(page-number) {
            (chapter-number-text, chapter-title)
          } else {
            (chapter-title, chapter-number-text)
          }
          text(weight: "bold", fill-line(left-text, right-text))
          v(-1em)
          line(length: 100%, stroke: 0.5pt)
        }
      }
    },
  )

  // ── Outline ──

  show outline: it => {
    in-outline.update(true)
    // Show the table of contents, list of figures, etc. in the table of contents
    set heading(outlined: true)
    it
    in-outline.update(false)
  }

  set outline(indent: auto)
  set outline.entry(fill: repeat([#h(2.5pt) . #h(2.5pt)]))

  show outline.entry: it => {
    // Only style the table of contents, not the list of figures or tables.
    if it.element.func() == heading {
      if it.level == 1 {
        v(1.5em, weak: true)
        strong(it)
      } else {
        it
      }
    } else {
      it
    }
  }

  // ── Equations ──

  set math.equation(numbering: n => {
    let h = counter(heading).get()
    let c = if h.len() > 0 { h.first() } else { 1 }
    numbering(if in-appendix.get() { "(A.1)" } else { "(1.1)" }, c, n)
  })

  show math.equation.where(block: true): it => {
    set align(left)
    pad(left: 2em, it)
  }

  // ── Figures and tables ──

  set place(clearance: 2em)

  set figure(numbering: _chapter-number, gap: 1.5em)
  set figure.caption(separator: [ -- ])
  show figure.caption: it => align(left, it)

  show figure.where(kind: table): it => {
    set figure.caption(position: bottom)
    set block(breakable: false)
    it
  }
  show table.cell.where(y: 0): set text(style: "normal", weight: "bold")
  set table(stroke: (_, y) => if y == 0 { (bottom: 1pt) })

  // ── Code ──

  show raw: set text(font: raw-font)

  // Inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: luma(250).darken(2%),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )
  show raw.where(block: true): block.with(inset: (x: 5pt))

  // ── Lists ──

  set list(marker: [--])
  show list: it => block(above: 1em, it)
  show: itemize.default-enum-list.with(
    enum-margin: 4em,
    indent: 1em,
    body-indent: 1em,
    enum-spacing: (above: 1em, below: auto),
  )

  // ── References ──
  //
  // Three rules, and they must stay in this order: each returns the reference
  // unchanged if it doesn't apply, so the next rule can handle it.
  // 1. Headings: "Chapter 3", "Section 3.2", "Appendix B".
  show ref.where(form: "normal"): it => {
    let el = it.element
    if el != none and el.func() == heading {
      // An unnumbered heading (abstract, index, CV …) has nothing to count:
      // link to it by its title.
      if el.numbering == none {
        return link(el.location(), el.body)
      }
      let in-app = el.numbering == "A.1.1"
      let supp = if in-app {
        "Appendix"
      } else if el.level != 1 {
        "Section"
      } else {
        "Chapter"
      }
      link(
        el.location(),
        supp
          + sym.space.nobreak
          + numbering(
            el.numbering,
            ..counter(heading).at(el.location()),
          ),
      )
    } else {
      // Leave glossary refs, equation refs, etc. to the other show rules.
      it
    }
  }

  // 2. Equations: "Eq. (3.4)", with the chapter number taken at the equation,
  //    not at the place that cites it.
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      let supp = if it.supplement == auto {
        "Eq."
      } else if it.supplement == "" {
        none
      } else {
        it.supplement
      }

      let loc = el.location()
      let eq-num = counter(math.equation).at(loc).first()
      let h1-num = counter(heading.where(level: 1)).at(loc).first()
      let in-app = in-appendix.at(loc)

      link(el.location(), {
        supp
        if supp != none { sym.space.nobreak }
        numbering(if in-app { "(A.1)" } else { "(1.1)" }, h1-num, eq-num)
      })
    } else { it }
  }

  // 3. Floating figures. Workaround for typst/typst#4359 — floats report their
  //    source location, so @refs and outline entries point where the figure was
  //    written, not where it floated to. The caption is placed at the real
  //    position, so we put an anchor there and point references to it.
  //
  //    Two things:
  //     - The key must include the chapter: the level-1 heading rule above
  //       resets counter(figure.where(kind: ...)) per chapter, so numbers alone
  //       collide (Figure 6.7 and Figure 4.7 would share a key).
  //     - The anchor carries the number the caption printed, and the ref reuses
  //       it verbatim. Recomputing it with numbering(el.numbering, ..) is wrong:
  //       the numbering function reads counter(heading), which inside the ref's
  //       own context resolves at the *citing* chapter.
  let chap(nums) = if nums.len() > 0 { nums.first() } else { 0 }

  let fkey(kind, ch, n) = label(
    "floatanchor--" + repr(kind) + "--" + str(ch) + "--" + str(n),
  )

  let float-info(el) = {
    if el == none or el.func() != figure or el.placement == none { return none }
    let ch = chap(counter(heading).at(el.location()))
    let hits = query(fkey(el.kind, ch, el.counter.at(el.location()).first()))
    if hits.len() != 1 or hits.first().value == none { return none } // never guess
    (loc: hits.first().location(), num: hits.first().value)
  }

  show figure.caption: it => context {
    let n = it.counter.get()
    let shown = if it.numbering == none { none } else { numbering(it.numbering, ..n) }
    [#metadata(shown)#fkey(it.kind, chap(counter(heading).get()), n.first())]
    it
  }

  show ref: it => context {
    let el = it.element
    let info = float-info(el)
    if info == none or it.form != "normal" { return it }
    let sup = if it.supplement == auto { el.supplement } else { it.supplement }
    if sup == none or sup == [] { return link(info.loc, info.num) }
    link(info.loc)[#sup~#info.num]
  }

  // Same retargeting for a list of figures / tables.
  show outline.entry: it => context {
    let info = float-info(it.element)
    if info == none { return it }
    let pn = info.loc.page-numbering()
    if pn == none { pn = "1" }
    let pg = numbering(pn, ..counter(page).at(info.loc))
    it.indented(
      it.prefix(),
      link(info.loc, it.body()) + box(width: 1fr, it.fill) + link(info.loc, pg),
    )
  }

  body
}
