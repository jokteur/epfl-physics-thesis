#import "../shared.typ": *

= Notation, equations and figures <chp:notation>

== The notation index <sec:notation>

A symbol is *declared once*, at the place in the text where it is defined:

```typst
the distribution function #symbol("Distribution function", $f_s$, key: "f_s")
```

and used *everywhere else* through its key, with `r("f_s")`. Each use renders the registered symbol, links back to the declaration, and records the page. At the end of the document, @sec:symbol-index lists every symbol with its definition page in bold and its uses in normal font.

So: let #symbol("Distribution function", $f_s$, key: "f_s") $#r("f_s") (vb(x), vb(v), t)$ be the distribution function of a species #symbol("Species label", $s$, key: "s") $#r("s")$, made of particles of mass #symbol("Particle mass", $m_s$, key: "m_s") $#ms("s")$ and charge #symbol("Particle charge", $e_s$, key: "e_s") $#es("s")$. It obeys the kinetic equation
$
  pdv(#r("f_s"), t) + vb(v) dot grad #r("f_s")
    + #es("s") / #ms("s") (vb(E) + vb(v) times #r("B")) dot pdv(#r("f_s"), vb(v))
    = #r("C_s") [#r("f_s")],
$ <eq:kinetic>
where #symbol("Magnetic field", $vb(B)$, key: "B") $#r("B")$ is the magnetic field and #symbol("Collision operator", $C_s$, key: "C_s") $#r("C_s")$ the collision operator.

Here is a reference @eq:kinetic. Write `#nref(<eq:kinetic>)` instead of `@eq:kinetic` when you only want the number alone #nref(<eq:kinetic>).

=== Declaring versus using

- `symbol(description, math, key: "k")` is the *declaration*. It prints nothing on its own. It registers the symbol, drops an anchor for the links to land on, and adds a bold page entry. Put it immediately before the sentence that introduces the symbol. You can also declare a symbol which does not appear in the index, with `register: false` in the arguments. 
- `r("k")` is a *reference* to the symbol. It prints the symbol, links to the declaration, and adds
  a normal page entry. You can change the appearance of a symbol with `display`, example: `#r("n_s", display: $n_s^2$)`: #r("n_s", display: $n_s^2$).
- `nr("k")` links without adding an index entry.
- `nlr("k")` just prints the symbol, without link.

The `key:` argument is optional. Without it, the key is guessed from the math content, but it is preferable to specify the key, as multiple symbols could conflict in a long thesis.

Symbols that appear with varying displays are easier to keep consistent as a function in `shared.typ`:

```typst
#let ns(..args) = r("n_s", display: $n_fmtsub(..args)$)
```

which gives #symbol("Density", $n_s$, key: "n_s") $#ns("s")$, $#ns("e")$ and $#ns("i", 0)$ from one declaration, all three referencing to the same place.

== Aligned equations that share a number <sec:grid-equations>

The moments of $#r("f_s")$ are:
#gridequations(
  <eq:moments>,

  $#ns("s")$, $equiv$, $integral #r("f_s") dd(v, 3) $,
  "Density", <eq:moment-density>,

  $#ns("s") vb(u)_#r("s")$, $equiv$, $integral vb(v) #r("f_s") dd(v, 3) $,
  "Fluid velocity", <eq:moment-velocity>,

  $3 / 2 #ns("s") #Ts("s")$, $equiv$, $integral #ms("s") / 2 abs(vb(v) - vb(u)_#r("s"))^2 #r("f_s") dd(v, 3)$,
  "Temperature", <eq:moment-temperature>,
)
where #symbol("Temperature", $T_s$, key: "T_s") $#Ts("s")$ is the temperature
in energy units. The block is @eq:moments; a single line is
@eq:moment-temperature. Both are links.

The description column can be optional, e.g. `""`, but the five arguments per line are not.

== A figure that references symbols <sec:plots>

At thermal equilibrium the solution of @eq:kinetic with the collision operator alone is the Maxwellian #symbol("Maxwellian distribution", $f_M$, key: "f_M")
$
  #r("f_M") (#r("v")) = #ns("s") (#ms("s") / (2 pi #Ts("s")))^(3 \/ 2)
    exp(- #r("v")^2 / #vths()^2),
$ <eq:maxwellian>
written in terms of the speed #symbol("Speed", $v$, key: "v") $#r("v")$ and of the thermal speed #symbol("Thermal speed", $v_"th"$, key: "v_th") $#vths() = sqrt(2 #Ts("s") \/ #ms("s"))$. A deuterium plasma at $#Ts("D") = qty("10", "keV")$ has $#vths("D") approx qty("9.8e5", "m/s")$.

@fig:example was made by `plots/plot_example.py`. It is *not* an image: matplotlib exported it as Typst markup, which the figure includes.


#figure(
  include "../plots/out/example_plot.typ",
  kind: image,
  // placement: auto,
  caption: [Left: the speed distribution #nr("f_M") of @eq:maxwellian, at two temperatures. Right: some heatmap figure that doesn't slow down pdf readers.
  ],
) <fig:example>

The axis labels are linked to the document. Here I am defining symbols #symbol("Major radius coordinate", $R$), #symbol("Vertical coordinate", $Z$) that are referenced in the figure.

#shh[A note on floats]

One can place a figure such as @fig:example as a float with `placement: auto`, which lets Typst move it to a better place (w.r.t. the text). Typst 0.13 and 0.15 report a float's *source* position rather than the place it is displayed, so a reference to it would point at the wrong page. The template works around this by anchoring on the caption, which is laid out where the figure really is. That is why the template overrides the `ref` and `outline.entry` rules, and why a figure must have a caption for the workaround to work.

If you want `placement: auto` to stay within a sub-section (and not place figures outside their intended section), you can use the following trick:
```typst
// Flush floats before every level-2 heading (subsection boundary)
#show heading.where(level: 2): it => {
  place.flush()
  it
}
```