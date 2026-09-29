// main.typ
//
//
//   typst compile main.typ        (or `typst watch main.typ` while writing)
//
// The template and the index library have to be installed first:
//
//   ../install.sh
// 
// You can also use TinyMist extension for writing

#import "shared.typ": *

#show: template.with(
  title: [A template for a thesis written in Typst],
  author: "Jane Doe",
  date: datetime(year: 2026, month: 10, day: 26),
)

// Acronyms
//
// Used as `@MCF` in the text: the first occurrence expands to the long form,
// the following ones stay short, and tail/glossary.typ prints the list with
// the pages where each one appears. `description:` is optional and shows up in
// that list only.
#let acronyms = (
  MCF: (short: "MCF", long: "magnetic confinement fusion"),
  HPC: (short: "HPC", long: "high performance computing"),
  MHD: (
    short: "MHD",
    long: "magnetohydrodynamics",
    description: "Single-fluid model of a plasma",
  ),
  ITER: (short: "ITER", long: "International Thermonuclear Experimental Reactor"),
  JET: (short: "JET", long: "Joint European Torus"),
  LCFS: (short: "LCFS", long: "last closed flux surface"),
)
#show: init-glossary.with(acronyms)

// Front matter

#include "head/cover-page.typ"
#include "head/dedication.typ"

#show: front-matter

#include "head/acknowledgements.typ"
#include "head/abstract.typ"

#outline(title: "Contents")
// #outline(title: "List of Figures", target: figure.where(kind: image))
// #outline(title: "List of Tables", target: figure.where(kind: table))

// The thesis

#show: main-matter

#include "main/ch1_introduction.typ"
#include "main/ch2_notation.typ"
#include "main/conclusion.typ"

// Back matter─

#show: back-matter

#include "tail/appendix.typ"
#include "tail/index.typ"
#include "tail/glossary.typ"
#include "tail/biblio.typ"
#include "tail/postface.typ"
#include "tail/cv.typ"
