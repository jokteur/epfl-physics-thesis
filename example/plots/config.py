"""Shared setup for every plot script.

matplotlib lays out the figure, but it is exported as Typst code instead of an image.
Labels are then normal Typst content: they use the document's fonts and math and can contain references.
For example, ``rr("v_th")`` in an axis label links to the notation index.

Two output modes, so the same script can serve a thesis and a paper:

    Config(typ=True)    ->  out/name.typ,  included with #include
    Config(typ=False)   ->  out/name.pdf,  LaTeX-rendered, for a journal

``Config.t(typst, latex)`` picks the right label for the current mode.
"""

import re

import matplotlib.pyplot as plt
import mpl_typst 
import mpl_typst_patch # (fixes renderer metrics + QuadMesh, see the module)

# Prepended to every generated .typ file. `/shared.typ` is resolved against the
# Typst root, i.e. the directory holding main.typ, so the figures see exactly
# the same symbols and shortcuts as the chapters.
TYPST_PREAMBLE = """
#import "/shared.typ": *
"""


def has_unmatched_quote(s):
    """True if `s` has an odd number of unescaped double quotes.

    A label such as '$rr("v_th)$' would otherwise produce a .typ file that does
    not compile, with an error pointing at the generated file rather than at the
    script that wrote it.
    """
    cleaned = re.sub(r'\\"', "", s)
    return cleaned.count('"') % 2 != 0


def fix_file(filename):
    """Post-process the generated markup.

    matplotlib writes tick labels of a log axis as `$\\mathdefault{10^{-3}}$`;
    strip the LaTeX wrapper and turn it into Typst math.
    """
    with open(filename, "r") as f:
        content = f.read()
    content = re.sub(r"\$\\mathdefault\{(\d+)\^\{(-?\d+)\}}\$", r"$\1^(\2)$", content)
    with open(filename, "w") as f:
        f.write(content)


class Config:
    """Figure sizes, rc params and saving, for both output modes.

    Args:
        typ: export Typst markup (True) or a LaTeX-rendered PDF (False).
        t_figsize: figure size used in Typst mode, in inches.
        l_figsize: figure size used in LaTeX mode, in inches.
    """

    def __init__(self, typ: bool = True, t_figsize: tuple = (5.5, 2.6), l_figsize: tuple = (8, 6)):
        self.typ = typ
        if typ:
            # Sizes are relative: the text size comes from the Typst document,
            # so "medium" everywhere keeps the figure consistent with the body.
            plt.rcParams.update(
                {
                    "legend.fontsize": "medium",
                    "axes.labelsize": "medium",
                    "axes.titlesize": "medium",
                    "xtick.labelsize": "medium",
                    "ytick.labelsize": "medium",
                }
            )
        else:
            plt.rcParams.update(
                {
                    "text.usetex": True,
                    "font.family": "serif",
                    "font.serif": ["Computer Modern Roman"],
                    "font.size": 12,
                }
            )
        self.header = TYPST_PREAMBLE
        self.l_figsize = l_figsize
        self.t_figsize = t_figsize

    def set_figsize(self, t_figsize: tuple, l_figsize: tuple = None):
        self.t_figsize = t_figsize
        if l_figsize is not None:
            self.l_figsize = l_figsize

    def s(self):
        """Figure size for the current mode."""
        return self.t_figsize if self.typ else self.l_figsize

    def t(self, t: str, l: str = None) -> str:
        """Pick a label: Typst markup in Typst mode, LaTeX otherwise.

            ax.set_xlabel(cf.t('$rr("v") slash rr("v_th")$', r"$v / v_{th}$"))

        In Typst mode the `$` are escaped so that matplotlib does not try to
        parse them as mathtext; they come back as plain `$` in the .typ file,
        where Typst reads them as math delimiters.
        """
        if self.typ:
            if has_unmatched_quote(t):
                raise ValueError(f"Unmatched quote in string: {t}")
            return t.replace("$", r"\$")
        return t if l is None else l

    def save(self, filename: str, fig=None, **kwargs):
        """Save to `filename`, with the extension replaced by the mode's."""
        if fig is None:
            fig = plt.gcf()
        stem = filename.rsplit(".", 1)[0]
        if self.typ:
            # dpi only affects the elements that are rasterised (2D histograms
            # and the like); everything else stays vectorial.
            kwargs.setdefault("dpi", 400)
            out = stem + ".typ"
            fig.savefig(out, **kwargs, typst_preamble=self.header)
            fix_file(out)
        else:
            out = stem + ".pdf"
            fig.savefig(out, **kwargs)
        print(f"wrote {out}")
