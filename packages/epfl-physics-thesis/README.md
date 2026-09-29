# epfl-physics-thesis

The thesis template. All styling is applied through `#show: template.with(…)`.

```typst
#import "@local/epfl-physics-thesis:0.1.0": *

#show: template.with(
  title: [A thesis],
  author: "Jane Doe",
  date: datetime(year: 2026, month: 10, day: 26),
)
```

It also re-exports a few commonly used packages, so you only need one import: [physica](https://typst.app/universe/package/physica) (`vb`, `pdv`, `dd`), [unify](https://typst.app/universe/package/unify) (`qty`, `num`), [subpar](https://typst.app/universe/package/subpar), [glossy](https://typst.app/universe/package/glossy) (`init-glossary`, `glossary`) and [sym-index](../sym-index) (`symbol`, `r`, `make-index`).

## template

| argument | default | |
| --- | --- | --- |
| `title` | `[Your Title]` | document metadata; the cover is separate |
| `author` | `"Author"` | |
| `paper-size` | `"a4"` | |
| `date` | `none` | a `datetime`, or `none` for today |
| `date-format` | long English | |
| `lang` | `"en"` | |
| `body-font` | Utopia, Libertinus Serif, New Computer Modern | first installed one wins |
| `body-size` | `11pt` | |
| `raw-font` | Iosevka, Fira Mono, DejaVu Sans Mono | |

## Document parts

`front-matter` — roman page numbers restarting at 1, headings unnumbered.
`main-matter` — arabic page numbers restarting at 1, chapters numbered.
`back-matter` — chapters become A, B, C…, equations and figures follow.

Applied as show rules, in order:

```typst
#show: front-matter
… acknowledgements, abstract, #outline() …
#show: main-matter
… chapters …
#show: back-matter
… appendices, index, glossary, bibliography, CV …
```

## cover-page

The EPFL cover. `logo` takes content such as `image(…)`, not a file path, because a path given to a package is resolved relative to the package, not to your document:

```typst
#cover-page(
  title: [A thesis],
  logo: image("../images/Logo_EPFL.svg", width: 75%),
  info: [Thèse n. 0000\ présentée le … \ … \ par\ #h(2cm) Jane Doe],
  jury: ([Prof. A, président du jury], [Prof. B, directrice de thèse]),
  place-date: [Lausanne, EPFL, 2026],
  notice: none,          // hides the "temporary title page" notice
)
```

## gridequations

One number for a block of aligned equations, one sub-number per line, both referenceable. Five positional arguments per line, and a label for the block:

```typst
#gridequations(
  <eq:mhd>,
  $rho$,   $equiv$, $n_e m_e + n_i m_i$, "Mass density",   <eq:mass>,
  $vb(u)$, $equiv$, $1 / rho (dots)$,    "Fluid velocity", <eq:velocity>,
)
```

`breakable: false` by default, like LaTeX's `align`. Pass `true` for a block
too long to fit on a page.

## curriculum-vitae

```typst
#show: curriculum-vitae.with(
  first-name: "Jane", family-name: "Doe",
  details: ("1015 Lausanne", link("mailto:jane@epfl.ch", "jane@epfl.ch")),
  heading-label: <sec:cv>,   // so the text can say "see @sec:cv"
)

#cv-section[Studies]
#cv-entry([2022 -- 2026], [PhD in physics], org: [EPFL], place: [Lausanne],
  body: [Thesis title])
```

Also `cv-project`, `cv-item`, `cv-reference`, `cv-note`, `cv-url`, `cv-ordinal`
and the colours `cv-accent`, `cv-muted`, `cv-ink`.

## Helpers

| | |
| --- | --- |
| `nref(<label>)` | a reference with no supplement: "(2.1)" |
| `nonum($…$)` | a display equation with no number |
| `nonumber(body)` | drops the numbering of every heading in `body` |
| `shh[Title]` | an unnumbered, unlisted level-4 heading |
| `subfigures` | `subpar.grid`, numbered 2.3a, 2.3b, … |
| `flex-caption(long, short)` | long under the figure, short in the list of figures |
| `fill-line(l, r)` | left and right on one line |
| `hf(a, b)` | a horizontal fraction inside a display |
| `theme-thesis` | a glossy theme whose entries are paragraphs, with merged page ranges |
| `in-appendix`, `in-outline` | states used internally to switch numbering in the appendix / outline |

## Known limitations

* references to a float (`placement: auto`) are resolved through the caption, because Typst reports a float's source position ([typst#4359](https://github.com/typst/typst/issues/4359)). A float without a caption will point to the wrong page;
* `pagebreak()` is weak document-wide; write `pagebreak(weak: false)` where a break must happen on an empty page.

## License

MIT. The page layout, chapter styling and matter functions are taken from [epfl-thesis-typst](https://github.com/augustebaum/epfl-thesis-typst) by Auguste Baum.
