#import "../shared.typ": *

// The stand-in cover. Replace the whole file with the PDF the service
// académique sends you for the final print.
#cover-page(
  title: [A template for a thesis written in Typst],
  logo: image("../images/Logo_EPFL.svg", width: 75%),
  info: [
    Thèse n. 0000\
    présentée le 26 octobre 2026\
    à la Faculté des Sciences de Base\
    SPC -- Theory\
    programme doctoral en physique\
    École Polytechnique Fédérale de Lausanne\
    #v(1em, weak: true)
    pour l'obtention du grade de Docteur ès Sciences\
    par\
    #h(2cm) Jane Doe\
  ],
  jury: (
    [Prof. A. Président, président du jury],
    [Prof. B. Directrice, directrice de thèse],
    [Dr. C. Rapporteur, rapporteur],
    [Dr. D. Rapporteuse, rapporteuse],
    [Dr. E. Rapporteuse, rapporteur],
  ),
  place-date: [Lausanne, EPFL, 2026],
)
