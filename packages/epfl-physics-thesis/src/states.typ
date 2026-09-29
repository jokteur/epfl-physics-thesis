// Document-wide states shared by `lib.typ` and the modules it imports.
// They are in their own file to keep the imports acyclic.

// True while an outline is being laid out. `flex-caption` uses it to print a
// short caption in the list of figures and the long one under the figure.
#let in-outline = state("in-outline", false)

// True once `back-matter` has switched the numbering to "A.1.1". Equation and
// figure numbering read it to decide between "(1.2)" and "(A.2)".
#let in-appendix = state("in-appendix", false)
