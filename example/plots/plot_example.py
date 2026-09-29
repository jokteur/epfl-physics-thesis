"""The figure of chapter 2, generated from Python, rendered by Typst.

Run it from this directory:

    python plot_example.py          # writes out/example_plot.typ
"""

import matplotlib.pyplot as plt
import numpy as np
from config import Config

cf = Config(typ=True, t_figsize=(5.4, 2.3))

x = np.linspace(1e-2, 3.2, 400)


def maxwellian(v, t=1.0):
    """Speed distribution of a Maxwellian, normalised to one particle."""
    return 4 / np.sqrt(np.pi) * v**2 / t**1.5 * np.exp(-(v**2) / t)


def attach_colorbar(fig, ax, mappable, label=None, pad=0.012, width=0.015, fraction=1.0):
    fig.canvas.draw()
    bb = ax.get_position()
    height = bb.height * fraction
    cax = fig.add_axes([bb.x1 + pad, bb.y0 + 0.5 * (bb.height - height), width, height])
    cbar = fig.colorbar(mappable, cax=cax)
    if label is not None:
        cbar.ax.get_yaxis().labelpad = 5
        cbar.set_label(label, rotation=90)
    return cbar


nu = (1 + x**3) ** -1

fig, axs = plt.subplots(1, 2, figsize=cf.s())

speed = cf.t('$rr("v") slash rr("v_th")$', r"$v / v_\mathrm{th}$")

axs[0].plot(x, maxwellian(x), "-k", label=cf.t('$rr("T_s")$', r"$T_s$"))
axs[0].plot(x, maxwellian(x, 2.0), "--k", label=cf.t('$2 rr("T_s")$', r"$2 T_s$"))
axs[0].set_xlabel(speed)
axs[0].set_ylabel(cf.t('$rr("f_M")$', r"$f_M$"))
axs[0].set_title(cf.t("Speed distribution", "Speed distribution"))
axs[0].set_ylim(0, 1.25)
# It may be useful sometimes to set the legend size manually with bbox_to_anchor, if the text
# does not fit in the default box (matplotlib does not know about typst symbols, and may 
# miscalculate the legend width).
# An example would be:
axs[0].legend(
    loc="upper left",
    fontsize="small",
    mode="expand",
    borderaxespad=0.0,
    bbox_to_anchor=(0.44, 0.5, 0.3, 0.4),
)
# axs[0].legend(loc="upper right")
# A reference to an equation of the text, from inside the figure.
axs[0].text(
    0.95,
    0.55,
    cf.t("@eq:maxwellian", "Eq. (2.1)"),
    transform=axs[0].transAxes,
    ha="right",
    va="top",
)

# Heat map
nbins = 100
R, Z = np.meshgrid(np.linspace(-3, 3, nbins), np.linspace(-3, 3, nbins))
R = R.flatten()
Z = Z.flatten()
weight = np.exp(-R**2 - Z**2)
h, xedges, yedges, image = axs[1].hist2d(R, Z, bins=nbins, weights=weight, cmap="plasma")
# A nbins x nbins mesh is drawn as one raster image instead of nbins^2
# vector cells: with nbins=100 the Typst output goes from ~11 MB to ~40 kB
# (and the PDF path gets the same treatment). cf.save() sets the dpi.
# Use this to avoid huge Typst files when plotting large 2D arrays.
image.set_rasterized(True)
axs[1].set_xlabel(cf.t('$rr("R")$ ($qty("", "m")$)'))
axs[1].set_ylabel(cf.t('$rr("Z")$ ($qty("", "m")$)'))

axs[1].set_aspect("equal")
cbar_label = cf.t('$ns(W)$ ($qty("", "m^-3")$)')
colorbar = [0.92, 0.26, 0.02, 0.59]
cax = fig.add_axes(colorbar)
cbar = fig.colorbar(image, cax=cax)
cbar.ax.get_yaxis().labelpad = 5
cbar.set_label(cbar_label, rotation=90)
# attach_colorbar(fig, axs[1], image, label=cbar_label)

fig.tight_layout()
cf.save("out/example_plot.typ")

plt.show()
