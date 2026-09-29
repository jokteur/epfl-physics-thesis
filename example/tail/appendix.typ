#import "../shared.typ": *

= Incredible appendix <app:integrals>

Reference: @app:integrals. Equation below: @eq:gaussian.

Equation:
$
  integral_0^infinity dd(x) x^n e^(-x^2)
    = 1 / 2 Gamma((n + 1) / 2), quad n > -1,
$ <eq:gaussian>
which for the moments of @eq:moments gives the normalisation of #nr("f_M"),
#nonum($
integral dd(vb(v), 3) #r("f_M") = #ns("s"). 
$)

That one is written with `nonum`.