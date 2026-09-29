// ─── shared.typ ───
//
// Common imports and shortcuts for the whole thesis. Each chapter starts with
//
//   #import "../shared.typ": *
//
// The generated plot files import it too (see plots/config.py), which is how
// axis labels can reference symbols.

#import "@local/epfl-physics-thesis:0.1.0": *

// Joins the arguments of a subscript: `ns(e)` → n_e, `ns(i, 0)` → n_(i,0).
#let fmtsub(..args) = args.pos().map(a => [#a]).join([,])

#let ns(..args) = r("n_s", display: $n_fmtsub(..args)$)
#let Ts(..args) = r("T_s", display: $T_fmtsub(..args)$)
#let ms(..args) = r("m_s", display: $m_fmtsub(..args)$)
#let es(..args) = r("e_s", display: $e_fmtsub(..args)$)
#let nus(..args) = r("nu_s", display: $nu_fmtsub(..args)$)
// A subscript that may or may not have a species after it: v_th, v_(th,D).
#let _sub-after(base, ..args) = {
  if args.pos().len() == 0 { base } else { $base,fmtsub(..args)$ }
}
#let fM(..args) = r("f_M", display: $f_#_sub-after($M$, ..args)$)
#let vths(..args) = r("v_th", display: $v_#_sub-after($"th"$, ..args)$)

#let code-name = `EXAMPLE-CODE`
