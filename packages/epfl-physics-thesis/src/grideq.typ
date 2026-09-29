// ─── grideq.typ ───
//
// A block of aligned equations that share one number, plus a sub-number for
// each line — the LaTeX `subequations` + `align` combination:
//
//   (2.3a)  rho  equiv  n_e m_e + n_i m_i     Mass density
//   (2.3b)  u    equiv  …                     Centre of mass velocity
//
// The whole block can be referenced ("Eqs. 2.3"), and so can every line
// ("Eq. 2.3a").
//
// Adapted from https://github.com/typst/typst/issues/380#issuecomment-4273864385
#import "states.typ": in-appendix

// Each row is five positional arguments:
//   left-hand side, relation, right-hand side, description, label
//
//   #gridequations(
//     <eq:mhd>,
//     $rho$, $equiv$, $n_e m_e + n_i m_i$, "Mass density", <eq:mass-density>,
//     $vb(u)$, $equiv$, $1 / rho (dots)$,  "Fluid velocity", <eq:velocity>,
//   )
//
// `main-label` labels the block as a whole. A row whose label is not needed
// still takes one; use a throwaway such as `<eq:mhd-2>`.
//
// `breakable: false` (the default, and what LaTeX's `align` does) keeps the
// block on one page. Pass `true` for a block too long to fit on one page.
#let gridequations(main-label, breakable: false, ..cells) = block(breakable: breakable)[
  #counter(math.equation).step()
  #counter("subeq").update(0)

  // 1. Place an invisible figure carrying the block label, so `@eq:mhd` gives
  //    "Eqs. 2.3". It has to be a figure, because only figures have a
  //    supplement and a numbering that can be referenced.
  #context {
    let app = in-appendix.get()
    let h = counter(heading.where(level: 1)).get()
    let c = if h.len() > 0 { h.first() } else { 1 }
    let e = counter(math.equation).get().first()
    let num-str = if app {
      numbering("(A.1)", c, e)
    } else {
      numbering("(1.1)", c, e)
    }

    place(hide([
      #figure(
        kind: "equations",
        supplement: [Eqs.],
        numbering: _ => num-str,
        outlined: false,
        [],
      )#main-label
    ]))
  }

  // 2. Force display mode
  #show math.equation: math.display

  // 3. Process the cells to intercept labels
  #let processed-cells = (
    cells
      .pos()
      .map(c => {
        if type(c) == label {
          [
            #counter("subeq").step()
            #context {
              let app = in-appendix.get()
              let h = counter(heading.where(level: 1)).get()
              let ch = if h.len() > 0 { h.first() } else { 1 }
              let eq = counter(math.equation).get().first()
              let sub = counter("subeq").get().first()
              let num-str = if app {
                numbering("(A.1a)", ch, eq, sub)
              } else {
                numbering("(1.1a)", ch, eq, sub)
              }

              math.equation(num-str)
              place(hide([
                #figure(
                  kind: "subequation",
                  supplement: [Eq.],
                  numbering: _ => num-str,
                  outlined: false,
                  [],
                )#c
              ]))
            }
          ]
        } else {
          c
        }
      })
  )

  // 4. Align baselines: an invisible copy of the row in a zero-width box gives
  //    every cell the same baseline without changing the column widths.
  #let final-cells = (
    processed-cells
      .chunks(5)
      .map(row => {
        let strut = box(
          width: 0pt,
          clip: true,
          box(
            width: 1000pt,
            hide($#row.at(0) #row.at(1) #row.at(2) #row.at(3)$),
          ),
        )

        return (
          [],
          [#strut #row.at(0)],
          [#strut #row.at(1)],
          [#strut #row.at(2)],
          [#strut #row.at(3)],
          row.at(4),
        )
      })
      .flatten()
  )

  // 5. Build the grid
  #grid(
    columns: (2em, auto, auto, auto, auto, 1fr),
    align: (left, right, center, left, left, right + horizon),
    row-gutter: 1.2em,
    column-gutter: (0pt, 0.28em, 0.28em, 2em, 0pt),
    ..final-cells
  )
]
