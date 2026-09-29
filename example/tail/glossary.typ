#import "../shared.typ": *

// Not an appendix either - the heading comes from the theme below.
#show: nonumber

// `theme-thesis` (from the template) is glossy's `theme-academic` with one
// paragraph per entry, and page ranges formatted like the symbol index.
#glossary(
  title: "List of acronyms",
  theme: theme-thesis,
  sort: true,
  ignore-case: false,
  show-all: true,
)
