// ─── cover-page.typ ───
//
// The EPFL doctoral thesis cover.

#let cover-page(
  // The thesis title.
  title: [Title],
  // Placed under the title, in grey.
  notice: [
    THIS IS A TEMPORARY TITLE PAGE

    It will be replaced for the final print by a version\
    provided by the service académique.
  ],
  // The institution logo, as content - a path would be resolved relative to
  // the package, not to your document:
  //   logo: image("../images/Logo_EPFL.svg", width: 75%)
  logo: none,
  // The block of lines to the right of the logo: thesis number, date of the
  // defence, faculty, doctoral programme, author.
  info: [],
  // Jury members, one entry per line.
  jury: (),
  // Closing line, e.g. [Lausanne, EPFL, 2026].
  place-date: none,
  // Cover font. If a font is not installed, the next one in the list is used.
  font: ("Latin Modern Sans", "Helvetica Neue", "Arial"),
) = page(numbering: none, margin: (y: 6cm), {
  set text(font: font)

  let v-skip = v(1em, weak: true)
  let v-space = v(2em, weak: true)

  align(center, {
    text(size: 18pt, title)

    if notice != none {
      v-space
      text(fill: gray, notice)
    }

    v-space
    v(1fr)

    grid(
      columns: (1fr, 60%),
      align(horizon, logo),
      align(left, {
        info
        if jury.len() > 0 {
          v-space
          [acceptée sur proposition du jury:\ ]
          v-skip
          jury.join([\ ])
        }
        if place-date != none {
          v-space
          place-date
        }
      }),
    )
  })
})
