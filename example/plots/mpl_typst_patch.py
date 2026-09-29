"""Fixes for mpl-typst 0.3.1: renderer metrics and QuadMesh rendering.

``TypstRenderer.points_to_pixels`` is the identity, i.e. the renderer claims one
point is one pixel (72 dpi) while every coordinate it is handed lives in the
figure's own dpi. Matplotlib sizes everything that has to fit around text --
legend boxes, ``tight_layout`` margins, marker sizes -- from those metrics, so at
the default dpi of 100 they come out 72/100 too small (legend frames flatter than
their contents) and the mismatch grows linearly with ``savefig(dpi=...)``.

``TypstRenderer.draw_quad_mesh`` is broken in two further ways:

* it tests ``if edgecolors:`` on the RGBA array matplotlib hands it, which raises
  ``ValueError: The truth value of an empty array is ambiguous`` for the empty
  array that ``edgecolors="none"`` (the ``pcolormesh``/``hist2d`` default)
  produces;
* it picks the face colour with ``facecolors[i]``, i.e. one colour per mesh *row*
  instead of one per cell, so a mesh that survived the first bug would be drawn
  with the wrong colours anyway.

Importing this module replaces both methods. Remove it once
https://github.com/daskol/mpl-typst is fixed upstream.
"""

import numpy as np
from mpl_typst.backend import TypstRenderer
from mpl_typst.typst import Array, Call, Scalar

# Adjacent cells leave a thin gap of background between them. When no edge
# colour is set, we stroke each cell with its own fill colour to hide the gaps.
SEAM_THICKNESS_PT = 0.1


def points_to_pixels(self, points):
    # The renderer does have a dpi, and the coordinates it receives are in it.
    return points * self.dpi / 72


def _rgb(color) -> Call:
    return Call('rgb', *[Scalar(c * 100, '%') for c in color])


def draw_quad_mesh(self, gc, master_transform, meshWidth, meshHeight,
                   coordinates, offsets, offsetTrans, facecolors,
                   antialiased, edgecolors):
    # TODO(@daskol): Apply offset transformation.
    coords = np.asarray(coordinates, dtype=float)
    vertices = master_transform.transform(coords.reshape(-1, 2))
    vertices = vertices.reshape(coords.shape)
    vertices /= self.dpi  # Points to inches.
    vertices[..., 1] = self.height - vertices[..., 1]  # Inverted Oy axis.

    # Matplotlib flattens both colour arrays to (n * m, 4), but collapses them
    # to a single row when the colour is uniform and to an empty array when it
    # is "none".
    facecolors = np.asarray(facecolors, dtype=float).reshape(-1, 4)
    edgecolors = np.asarray(edgecolors, dtype=float).reshape(-1, 4)
    if facecolors.size == 0:
        return
    linewidth = gc.get_linewidth()
    stroke_edges = edgecolors.size > 0 and linewidth > 0

    for i in range(meshHeight):
        for j in range(meshWidth):
            k = i * meshWidth + j
            facecolor = facecolors[k % len(facecolors)]
            if facecolor[3] == 0 and not stroke_edges:
                continue
            fill = _rgb(facecolor)

            if stroke_edges:
                edgecolor = edgecolors[k % len(edgecolors)]
                stroke = Call('stroke', paint=_rgb(edgecolor),
                              thickness=Scalar(linewidth, 'pt'))
            else:
                stroke = Call('stroke', paint=fill,
                              thickness=Scalar(SEAM_THICKNESS_PT, 'pt'))

            # TODO(@daskol): Take into account joints, dashes, and hatches.

            # Select quad and walk over it anti-clockwise.
            quad = vertices[i:i + 2, j:j + 2].reshape(4, 2)[[2, 3, 1, 0]]
            points = [Array([Scalar(el, 'in') for el in point])
                      for point in quad]
            ops = [Call('curve.move', points[0])]
            ops += [Call('curve.line', point) for point in points[1:]]
            ops += [Call('curve.close', mode='"straight"')]
            curve = Call('curve', *ops, fill=fill, stroke=stroke)

            # Put on canvas with respect of the origin.
            place = Call('place', 'top + left', curve,
                         dx=Scalar(0, 'in'), dy=Scalar(0, 'in'))
            self._append(gc, place)


TypstRenderer.points_to_pixels = points_to_pixels
TypstRenderer.draw_quad_mesh = draw_quad_mesh
