// ─── cv.typ ───
//
// A compact one-column CV
//
//   #show: curriculum-vitae.with(
//     first-name: "Ada", family-name: "Lovelace",
//     details: ("London", link("mailto:ada@example.org", "ada@example.org")),
//   )
//
//   #cv-section[Studies]
//   #cv-entry([2022 -- 2026], [PhD in plasma physics], org: [EPFL], place: [Lausanne],
//     body: [Thesis title])

#let cv-accent = rgb("#f28c26")
#let cv-muted = rgb("#5a5a5a")
#let cv-ink = rgb("#1f1f1f")
#let cv-sans = ("Helvetica Neue", "Helvetica", "Arial")

// Width of the left "hint" column (dates, categories) and the gap after it.
#let cv-hint-width = 30mm
#let cv-gutter = 4mm
#let cv-small = 9pt

#let cv-style(body) = {
  set text(font: cv-sans, size: 9.5pt, fill: cv-ink, hyphenate: false)
  set par(justify: false, leading: 0.62em, spacing: 0.7em)
  show link: set text(fill: cv-accent.darken(30%))
  body
}

// 52#super[nd] — `#cv-ordinal(52, [nd])`
#let cv-ordinal(number, suffix) = [#number#text(size: 0.62em, baseline: -0.32em, suffix)]

// Name banner with the contact details on the right and an optional photo.
#let cv-title(first-name: "", family-name: "", details: (), photo: none) = block(below: 1.4em, {
  set text(weight: "regular")
  let name-box = text(size: 25pt, fill: cv-ink, {
    text(weight: "light", first-name)
    h(0.35em)
    text(weight: "bold", family-name)
  })
  let details-box = align(
    right,
    text(size: 8.8pt, fill: cv-muted, details.join(linebreak())),
  )
  let columns = if photo == none { (1fr, auto) } else { (1fr, auto, auto) }
  let cells = (align(bottom, name-box), align(bottom, details-box))
  if photo != none {
    // `photo` is content, not a path: a path would be resolved relative to the
    // package. Pass `image("../images/photo.jpg", height: 26mm)`.
    cells.push(align(bottom, block(
      clip: true,
      radius: 2pt,
      stroke: 0.4pt + cv-muted,
      photo,
    )))
  }
  grid(columns: columns, column-gutter: 8mm, ..cells)
  v(0.5em)
  line(length: 100%, stroke: 1pt + cv-accent)
})

#let cv-section(title) = block(above: 1.6em, below: 0.9em, sticky: true, grid(
  columns: (cv-hint-width, 1fr),
  column-gutter: cv-gutter,
  align(horizon, line(length: 100%, stroke: 0.9pt + cv-accent)),
  text(size: 13pt, weight: "bold", fill: cv-accent, title),
))

// The building block of every entry: a right-aligned hint and a body.
#let cv-item(hint, body) = block(below: 0.8em, breakable: false, grid(
  columns: (cv-hint-width, 1fr),
  column-gutter: cv-gutter,
  align(right, text(size: cv-small, weight: "bold", fill: cv-accent, hint)),
  body,
))

#let cv-note(body) = text(size: cv-small, fill: cv-muted, body)

#let cv-entry(period, title, org: none, place: none, note: none, body: none) = cv-item(period, {
  strong(title)
  if org != none [, #emph(org)]
  if place != none [, #place]
  if note != none [, #note]
  if body != none {
    linebreak()
    cv-note(body)
  }
})

#let cv-project(period, name, body) = cv-item(period, {
  strong(name)
  linebreak()
  cv-note(body)
})

#let cv-reference(role, name, email, affiliation) = cv-item(role, {
  strong(name)
  h(0.7em)
  text(size: cv-small, link("mailto:" + email, email))
  linebreak()
  cv-note(emph(affiliation))
})

#let cv-url(url, label: none) = link(
  url,
  if label == none { url.replace(regex("^https?://(www\.)?"), "") } else { label },
)

// Wraps the whole CV and sets its styling.
#let curriculum-vitae(
  first-name: "",
  family-name: "",
  details: (),
  photo: none,
  // Title used in the table of contents.
  title: "Curriculum Vitae",
  // Optional label on that heading, so the text can say "see @sec:cv".
  heading-label: none,
  body,
) = {
  show: cv-style
  show heading.where(level: 1): _ => cv-title(
    first-name: first-name,
    family-name: family-name,
    details: details,
    photo: photo,
  )

  pagebreak(to: "even", weak: true)
  set page(header: none)

  let h = heading(title, numbering: none)
  if heading-label == none { h } else { [#h#heading-label] }
  body
}
