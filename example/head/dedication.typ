// `weak: false` is required: the template sets `pagebreak(weak: true)`
// document-wide, and a weak break is dropped when the current page is still
// empty -- which it is, right after the cover.
#pagebreak(to: "odd", weak: false)

#align(center + horizon)[
  To whatever...
]
