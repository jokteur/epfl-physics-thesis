# A Typst physics thesis template (EPFL)

A Typst template for a physics thesis at EPFL. Besides styling close to LaTeX, it adds: a **notation index** that links each symbol to the page where it is defined, **aligned equation blocks** with sub-numbers (like LaTeX's `subequations`), **matplotlib figures exported as Typst**, so labels can reference equations and symbols, and a **CV** for the end of the thesis.

```
epfl-physics-thesis/
├── install.sh              installs the two packages locally
├── packages/
│   ├── epfl-physics-thesis/        the template: styling, refs, CV, equation grids
│   └── sym-index/          the notation index (usable on its own)
└── example/                a small thesis using all of it
```

This template works really well with TinyMist: https://github.com/Myriad-Dreamin/tinymist. Use this for real-time compilation features. You have to open the root of the project for this extension to work properly (here would be `example/`).

## Quick start

```sh
./install.sh                     # symlinks both packages into @local
cd example
typst watch main.typ             # or: typst compile main.typ
```

This produces `example/main.pdf`, which also serves as documentation: every feature is shown and explained in it.

To start your own thesis, copy `example/` somewhere and delete the placeholder text. 

`install.sh` symlinks by default, so editing `packages/*/src/*.typ` takes effect on the next compile. Use `--copy` to install a fixed copy instead.

### Fonts

The body uses Utopia, chapter headings and the cover use Latin Modern Sans, and code uses Iosevka. Each option takes a list of fonts, and if one isn't installed, the next one is used:

```typst
#show: template.with(
  body-font: ("Libertinus Serif", "New Computer Modern"),
  raw-font: ("Fira Mono",),
)
```

`typst fonts` lists what is installed.

## What the template does

A single `#show: template.with(title: …, author: …)` sets up everything:
* **the page**, A4 with the usual EPFL margins (the inner margin is wider, for binding);
* **chapters** opening on a recto page, with a black tab extending into the inner margin and the number in white;
* **running headers** with the chapter number and title, mirrored on verso pages, absent on the page where a chapter opens;
* **numbering per chapter** for equations, figures and tables, switching to A.1, A.2 … inside the appendix;
* **references**: `@sec:foo` gives "Section 2.3", `@eq:bar` gives "Eq. (2.1)", `@fig:baz` gives "Figure 2.1", and an unnumbered  heading is linked by its title. `#nref(<eq:bar>)` gives "(2.1)" alone;
* three document parts: `front-matter` (roman numbers, unnumbered headings), `main-matter` (arabic, restarting at 1) and `back-matter` (appendices).

## Neat little additions

### 1. The notation index

Declare a symbol once, where the text defines it:

```typst
the distribution function #symbol("Distribution function", $f_s$, key: "f_s")
```

and write `#r("f_s")` everywhere else. Every use renders the symbol, links back to the declaration and records the page; `make-index()` prints the result, with the defining page in bold. See `example/main/ch2_notation.typ` and `example/tail/index.typ`, and `packages/sym-index/README.md` for the full library.

It is a separate package, `@local/sym-index:0.1.0`, usable without the rest.

### 2. Aligned equation grids

LaTeX's `subequations` inside an `align`: one number for the block, one sub-number per line, both referenceable.

```typst
#gridequations(
  <eq:moments>,
  $n_s$,        $equiv$, $integral dd(vb(v), 3) f_s$,      "Density",  <eq:density>,
  $n_s vb(u)_s$, $equiv$, $integral dd(vb(v), 3) vb(v) f_s$, "Velocity", <eq:velocity>,
)
```

Five arguments per line -- left-hand side, relation, right-hand side, description, label -- and a label for the block. Every line needs a label, even if you never reference it.

### 3. Figures from matplotlib, as markup

This is useful if you want perfect figures, that use the thesis font, and inside which you can reference symbols and equations. Have a look at `example/plots` to see how to do it. The script `plot_example.py` builds a figure with matplotlib, saves it as a `.typ` file through [mpl-typst](https://github.com/daskol/mpl-typst).

```sh
cd example/plots
pip install -r requirements.txt
python plot_example.py           # writes out/example_plot.typ
```

An axis label written as `'$rr("v_th")$'` renders the same symbol as the text, links to its definition and appears in the notation index; an annotation written as `"@eq:maxwellian"` becomes a normal reference, so it stays correct if the equation number changes.

Things to know:
* matplotlib sizes labels from their source text, so `$rr("T_s")$` gets space for 12 characters even though the rendered symbol is much shorter. You may have to manually set the width of legends and colorbars. 
* `config.py` has a second mode, `Config(typ=False)`, which renders the same script through LaTeX to a PDF. Useful for non-typst usage.

### 4. The CV

EPFL wants a CV at the end. See `example/tail/cv.typ` how to seamlessly integrate it with the rest of the thesis.

## Other things to know

* **Chapters start on odd pages**, so a blank verso before a chapter is deliberate, not a bug.
* **All page breaks are weak.** To force a blank page, use `pagebreak(weak: false)`.
* **References to floats point at the wrong page** in Typst 0.13 and 0.15 ([typst#4359](https://github.com/typst/typst/issues/4359)): a float reports its position in the source, not where it ends up on the page. The template works around this by using the caption's position instead, so floating figures need a caption for their references to be correct.
* **`r` is not usable in math mode**, where a simple `r` is the variable *r*. Use `rr` or `#r`.

## Versions

Built against Typst 0.15, and against these packages, all of which Typst will fetch on the first compile: physica 0.9.8, unify 0.8.1, subpar 0.2.2, glossy 0.9.1, itemize 0.2.0, and based 0.1.0 (pulled in by the generated figures).

## Credit

The page layout, the chapter styling and the front/main/back matter come from [epfl-thesis-typst](https://github.com/augustebaum/epfl-thesis-typst) by Auguste Baum. MIT licensed, see `LICENSE`.