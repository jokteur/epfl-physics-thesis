#import "../shared.typ": *

// EPFL asks for a CV at the end of the thesis.
#show: curriculum-vitae.with(
  heading-label: <sec:cv>,
  first-name: "Jane",
  family-name: "Doe",
  // photo: image("../images/photo.jpg", height: 26mm),
  details: (
    "1015 Lausanne, Switzerland",
    link("mailto:jane.doe@epfl.ch", "jane.doe@epfl.ch"),
    "Nationality: Something",
  ),
)

#cv-section[Studies]

#cv-entry(
  [2022 -- 2026],
  [PhD in plasma physics],
  org: [EPFL],
  place: [Lausanne],
  body: [A template for a thesis written in Typst],
)
#cv-entry(
  [2018 -- 2021],
  [Master in physics],
  org: [EPFL],
  place: [Lausanne],
  body: [Master project on kinetic theory. Overall grade: 6 / 6],
)

#cv-section[Conference contributions]

#cv-entry(
  [July 2026],
  [#cv-ordinal(1000, [th]) EPS Conference on Plasma Physics],
  org: [Poster],
  place: [The Moon],
  body: [One line on what the poster showed],
)

#cv-section[Work experience]

#cv-entry(
  [2022 -- 2026],
  [Doctoral assistant],
  org: [SPC Theory, EPFL],
  place: [Lausanne],
  body: [Research, drinking, and tours of the facilities for visitors],
)

#cv-section[Notable projects]

#cv-project(
  [2022 -- 2026],
  [EXAMPLE-CODE],
  [What the code does, in two lines, and where it lives.
    #linebreak()
    #cv-url("https://github.com/example/example-code")],
)

#cv-section[General knowledge]

#cv-item([Plasma physics], [Kinetic theory, post-neoclassic transport, magnetohydrodynamics voodoo.])
#cv-item([Parallel computing], [OpenMP, PhD Graduate descent])

#cv-section[Programming]

#cv-item([Advanced], [C++, Python, Fortran, git])
#cv-item([Intermediate], [Matlab, Klingon])

#cv-section[Languages]

#cv-item([Native], [Romansch])
#cv-item([Fluent], [English (C1), Linkedin Speak (B2)])
