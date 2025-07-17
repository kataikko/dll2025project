#import "@preview/touying:0.6.1": *
#import "themes/UFR.typ": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/muchpdf:0.1.1": muchpdf

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution
)

#pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 10, minute: 5, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,

)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#let note = pdfpc.speaker-note
#let vizfig(content) = {
  figure(
      content,
      caption: text(size: 15pt)[Illustration by Müller et. al.],
      supplement: [Architecture],
      numbering: none,
  )
}
#let pdf(path, scale: 2.0) = {
  muchpdf(scale: scale, read(path, encoding: none))
}

= Precursor Methods
== Isosurfacing
The goal of these methods, called isosurfacing algorithms, is to create a triangle mesh from a 3D grid of scalar values, such as a Signed Distance Function (SDF).

#image("../resources/mc-dc-dmc-vizualization.png")
== Marching Cubes (MC)

Marching Cubes is a classic algorithm that processes the 3D grid one cube at a time

- **Process**:
    1. For a single cube in the grid, it checks the scalar value at each of its 8 corners to see if it's inside or outside the surface (e.g., negative or positive SDF value).
    2. This 8-corner on/off pattern creates one of 256 possible configurations. This configuration is used as an index into a pre-computed look-up table.
    3. The table specifies which edges of the cube the surface intersects. For each intersected edge, the exact vertex position is calculated using linear interpolation between the two corner values.
    4. The table also dictates how to connect these new vertices to form one or more triangles inside the cube3.

- **Limitation**: The generated mesh vertices can **only lie on the edges of the grid**. This lack of freedom means MC struggles to represent sharp features that aren't aligned with the grid axes, often creating "stair-step" artifacts.


== Dual Contouring (DC)

Dual Contouring was created to address the rigidity of MC and better capture sharp features.
#image("../resources/../resources/mc-dc-dmc-vizualization.png")
- **Process**:
    1. Like MC, it identifies where the surface intersects the edges of each cube.
    2. However, instead of placing vertices on the edges, it generates a **single vertex somewhere inside the cube**.
    3. To find the optimal position for this internal "dual" vertex, DC minimizes a **Quadratic Error Function (QEF)**. The QEF tries to find a single point that best respects the tangent planes at all the edge-intersection points. The mesh is then formed by connecting these dual vertices from adjacent cubes.

- **Limitation**: While flexible, the QEF is numerically unstable for gradient-based optimization. If the surface is relatively flat within a cube, the gradients are co-planar, and the QEF solution can "explode," placing the vertex far outside its cell. This causes self-intersections and makes optimization fail. The method can also produce non-manifold geometry.


== Dual Marching Cubes (DMC)

DMC is a hybrid approach that tries to get the best of both MC and DC12.

- **Process**: It guarantees a topologically sound (manifold) mesh by using the connectivity from MC's dual graph. Instead of just one vertex per cube, it generates one dual vertex for each polygon that MC would have created. This means a cube can contain multiple, separate vertices if needed.
- **Limitation**: For positioning these vertices, DMC faces the same dilemma as its predecessors. If it uses a QEF, it inherits the instability of DC. If it uses a simpler method, like placing the vertex at the **centroid** of the MC polygon's vertices, it becomes rigid and loses the ability to capture sharp features.


---
== How FLEXICUBES Works

FLEXICUBES starts with the robust topological foundation of Dual Marching Cubes (DMC) and makes it flexible for optimization by introducing new, learnable parameters. It avoids the unstable QEF entirely.

The core process involves four main components that are all differentiable and optimized together:

1. **Flexible Dual Vertex Positioning (The Main Contribution)**: This is how FLEXICUBES gets its flexibility without instability.

    - It introduces a set of learnable **interpolation weights (α)** for each of the 8 corners in a grid cell. These weights modify the standard linear interpolation formula, allowing the zero-crossing points on the grid edges to shift their positions.
    - It then introduces a second set of learnable **edge weights (β)** for each of the 12 edges in a grid cell. The final dual vertex is calculated as a **weighted average** of the (now flexible) zero-crossing points, using these `β` weights.
    - **The key insight** is that this entire process is a series of convex combinations. This mathematically guarantees that the final vertex will always remain inside its local cell, preventing the explosion problem of DC and ensuring stable optimization. These 20 parameters (`8 α + 12 β`) per cell are what the optimizer learns to shape the mesh.

2. **Flexible Quad Splitting**:

    - DMC produces quadrilateral faces, which must be triangulated. The choice of which diagonal to split along is a discrete decision that is problematic for gradient descent.

    - FLEXICUBES makes this choice continuous by introducing a learnable **splitting weight (γ)** for each cell.

    - During optimization, each quad is temporarily split into four triangles by adding a central vertex. The position of this vertex is smoothly interpolated between the two diagonal midpoints, controlled by the learned `γ` parameter. This allows the optimizer to favor the triangulation that best reduces the overall loss.

3. **Flexible Grid Deformation**:

    - This is a technique borrowed from prior work. It allows the vertices of the underlying 3D grid to move slightly according to learnable **deformation vectors (δ)**. This helps the grid itself conform to thin or curved parts of the target geometry, adding another layer of flexibility.

4. **Regularizers**:

    - Because the representation has so many parameters, the paper introduces two regularization terms to encourage good-quality meshes.

    - One term encourages the dual vertex to stay near the center of its primal face, which gives it room to move during optimization.

    - Another penalizes unnecessary sign changes in the SDF to remove spurious internal surfaces.

=focus-slide[Thank you for your attention!]