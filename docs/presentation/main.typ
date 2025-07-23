#import "@preview/touying:0.6.1": *
#import "themes/UFR.typ": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/muchpdf:0.1.1": muchpdf
#import "@preview/cetz:0.4.0"

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Flexicubes],
    subtitle: [Flexible Isosurface Extraction for Gradient-Based Mesh Optimization],
    author: [Julius Schmitt],
    date: [17.07.2025],
    institution: [Seminar Deep Learning Lab at the Albert Ludwigs University Freiburg],
  ),
)

#pdfpc.config(
  duration-minutes: 15,
  start-time: datetime(hour: 10, minute: 5, second: 0),
  last-minutes: 2,
  note-font-size: 12,
  disable-markdown: false,
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#let note = pdfpc.speaker-note

#let vizfig(content, caption: auto) = {
  figure(
      content,
      caption: caption,
      supplement: [Figure],
      numbering: none,
  )
}

#let marching_cubes_viz = cetz.canvas({
  import cetz.draw: *

  // Draw the square
  let a = (0, 2);
  let b = (2, 2);
  let c = (2, 0);
  let d = (0, 0);
  line(a, b, c, d, a);

  // Grid points
  circle(a, radius: 1.5pt);
  circle(b, radius: 1.5pt);
  circle(c, radius: 1.5pt);
  circle(d, radius: 1.5pt);

  // Surface intersection points
  let p1 = (1, 2);
  let p2 = (2, 1);
  circle(p1, radius: 2pt, fill: red);
  circle(p2, radius: 2pt, fill: red);

  // The generated line segment
  line(p1, p2, stroke: red);

  content(p1, anchor: "south", dy: 0.1, text(10pt, "Vertex on edge"));
})

#let dual_contouring_viz = cetz.canvas({
  import cetz.draw: *

  // Draw the square
  let a = (0, 2);
  let b = (2, 2);
  let c = (2, 0);
  let d = (0, 0);
  line(a, b, c, d, a);

  // Grid points
  circle(a, radius: 1.5pt);
  circle(b, radius: 1.5pt);
  circle(c, radius: 1.5pt);
  circle(d, radius: 1.5pt);

  // Dual vertex inside the cell
  let dv = (1, 1);
  circle(dv, radius: 2pt, fill: blue);

  content(dv, anchor: "south", dy: 0.1, text(10pt, "Dual Vertex"));
})

#let flexicubes_vertex_viz = cetz.canvas({
  import cetz.draw: *

  // Draw the square
  let a = (0, 2);
  let b = (2, 2);
  let c = (2, 0);
  let d = (0, 0);
  line(a, b, c, d, a);

  // Intersection points
  let p1 = (1, 2);
  let p2 = (2, 1);
  let p3 = (0, 1);
  circle(p1, radius: 2pt, fill: red);
  circle(p2, radius: 2pt, fill: red);
  circle(p3, radius: 2pt, fill: red);

  // Show flexible positions with alpha
  line((1, 2), (0.5, 2), mark: "<->");
  content((0.75, 2), anchor: "south", dy: 0.1, text(10pt, $alpha$));

  // Final vertex
  let v = (1, 1);
  circle(v, radius: 2pt, fill: blue);

  // Show beta weights
  line(p1, v, stroke: (dash: "dashed"));
  line(p2, v, stroke: (dash: "dashed"));
  line(p3, v, stroke: (dash: "dashed"));
  content((1, 1.5), text(10pt, $beta_1$));
  content((1.5, 1), text(10pt, $beta_2$));
  content((0.5, 1), text(10pt, $beta_3$));

  content(v, anchor: "west", dx: 0.1, text(10pt, "Final Vertex"));
})

#let flexicubes_quad_viz = cetz.canvas({
  import cetz.draw: *

  // A more general quad
  let q1 = (0, 0);
  let q2 = (3, 1);
  let q3 = (2, -2);
  let q4 = (0, -1);
  line(q1, q2, q3, q4, q1);

  // The two diagonals
  line(q1, q3, stroke: (dash: "dashed"));
  line(q2, q4, stroke: (dash: "dashed"));

  // The midpoints of the diagonals
  let m1 = (1, -1);
  let m2 = (1.5, 0);

  // The interpolated center point
  let center = (1.25, -0.5);
  circle(center, radius: 2pt, fill: green);

  // Arrow showing the interpolation range
  line(m1, m2, mark: "<->");
  content((1.25, -0.2), text(10pt, $gamma$));

  content(center, anchor: "south", dy: 0.1, text(10pt, "Differentiable Split"));
})

#title-slide()

= Introduction: The Challenge of Isosurfacing

#slide(title: "What is Isosurfacing?")[
  #note(```
    "Good morning, everyone. Today, I'm going to talk about Flexicubes, a new method for extracting high-quality triangle meshes from 3D scalar fields, like Signed Distance Functions.\n\nThe main goal of any isosurfacing algorithm is to take a 3D grid of values and generate a 3D model that represents the surface where those values are zero."
  ```)
  #align(center)[
    #text(size: 24pt)[
      Goal: Create a triangle mesh from a 3D grid of scalar values (e.g., a Signed Distance Function).
    ]
  ]
  #v(2em)
  #vizfig(
    image("images/mc-dc-dmc-vizualization.png", width: 80%),
    caption: "From left to right: Marching Cubes, Dual Contouring, and Dual Marching Cubes"
  )
]

== A Quick Recap of Precursor Methods

#slide(title: "1. Marching Cubes (MC)", composer: (1fr, 1fr))[
  #note(```
    "Let's start with the classic: Marching Cubes. It processes the grid cube by cube, looks up the corner configuration in a table, and places vertices on the cube edges.\n\nThe biggest problem with Marching Cubes is its rigidity. Vertices are locked to the grid edges, which creates these blocky, stair-step artifacts, especially on sharp features that don't align with the grid."
  ```)
  - *Process*:
    - Checks 8 corner values of a cube (inside/outside).
    - Uses a lookup table to determine triangle topology.
    - Places vertices on cube edges via linear interpolation.
  - *Limitation*:
    - Vertices are restricted to grid edges.
    - Creates "stair-step" artifacts.
    - Poor at representing sharp, off-axis features.
][
  #vizfig(marching_cubes_viz, caption: "Marching Cubes places vertices on the edges of the grid.")
]

#slide(title: "2. Dual Contouring (DC)", composer: (1fr, 1fr))[
  #note(```
    "To fix this, Dual Contouring was introduced. Instead of placing vertices on the edges, it generates a single, more flexible vertex *inside* the cube. It tries to find the optimal position for this vertex by minimizing a Quadratic Error Function, or QEF.\n\nHowever, this flexibility comes at a cost. The QEF is numerically unstable. If the surface inside a cube is flat, the math breaks down, and the vertex can be placed far outside the cube, causing self-intersections and making it useless for gradient-based optimization."
  ```)
  - *Process*:
    - Generates a single vertex *inside* each cube.
    - Position is optimized by minimizing a Quadratic Error Function (QEF).
  - *Limitation*:
    - QEF is numerically unstable, especially on flat surfaces.
    - Can lead to vertices "exploding" and self-intersections.
    - Unsuitable for gradient-based optimization.
][
  #vizfig(dual_contouring_viz, caption: "Dual Contouring generates a single vertex inside the cell.")
]

#slide(title: "3. Dual Marching Cubes (DMC)")[
  #note(```
    "Dual Marching Cubes is a hybrid. It uses the reliable connectivity of Marching Cubes but allows for more flexible vertex placement like Dual Contouring.\n\nBut it faces the same dilemma. If it uses the unstable QEF, it fails. If it uses a simpler method like placing the vertex at the center of the MC polygon, it becomes rigid again and loses the ability to capture sharp features. This is the problem Flexicubes solves."
  ```)
  - *Process*:
    - Hybrid of MC and DC.
    - Uses MC's topology for manifold meshes.
    - Generates one dual vertex per MC polygon.
  - *Limitation*:
    - Inherits the same vertex placement dilemma:
      - QEF -> Unstable
      - Centroid -> Rigid, loses sharp features.
]

= Flexicubes: The Best of Both Worlds

#slide(title: "How Flexicubes Works")[
  #note(```
    "So, how does Flexicubes achieve both flexibility and stability? It starts with the robust topology of Dual Marching Cubes and introduces new, learnable parameters, completely avoiding the unstable QEF.\n\nThere are four key components that are optimized together."
  ```)
  Starts with the robust topology of DMC and introduces learnable parameters to make it flexible for gradient-based optimization, avoiding the unstable QEF.

  #align(center)[
    *Flexibility + Stability = High-Quality Meshes*
  ]
]

== The Four Core Components

#slide(title: "1. Flexible Dual Vertex Positioning", composer: (1fr, 1fr))[
  #note(```
    "First, and most importantly, is the flexible vertex positioning. This is the core contribution. Instead of a QEF, Flexicubes uses two sets of learnable weights.\n\nFirst, 'alpha' weights shift the zero-crossing points along the cube edges. Then, 'beta' weights compute the final vertex position as a weighted average of these shifted points.\n\nThe key here is that this is a series of convex combinations. This mathematically guarantees that the vertex stays inside its local cell, preventing the explosion problem of DC and ensuring stable optimization."
  ```)
  - *Main Contribution*: Replaces unstable QEF with learnable weights.
  - *Learnable Weights (α)*: Modify interpolation to shift zero-crossing points on edges.
  - *Learnable Edge Weights (β)*: Calculate the dual vertex as a weighted average of the flexible zero-crossing points.
  - *Key Insight*: Convex combinations guarantee the vertex remains within its local cell, ensuring stability.
][
  #vizfig(flexicubes_vertex_viz, caption: "Flexicubes uses learnable weights (α, β) for stable vertex positioning.")
]

#slide(title: "2. Flexible Quad Splitting", composer: (1fr, 1fr))[
  #note(```
    "Second, DMC produces quads, which need to be triangulated. Deciding which diagonal to split is a discrete choice, which is bad for gradient descent.\n\nFlexicubes makes this differentiable by introducing a learnable 'gamma' weight. During optimization, it temporarily splits the quad into four triangles and uses the learned gamma parameter to smoothly interpolate towards the better triangulation."
  ```)
  - *Problem*: Triangulating quads is a discrete, non-differentiable choice.
  - *Solution*: Introduces a learnable *splitting weight (γ)*.
  - *Process*: Temporarily splits each quad into four triangles and uses γ to smoothly choose the optimal triangulation for reducing loss.
][
  #vizfig(flexicubes_quad_viz, caption: "Flexicubes uses a learnable weight (γ) for differentiable quad triangulation.")
]

#slide(title: "3. Flexible Grid Deformation")[
  #note(```
    "Third, it uses a technique from prior work to allow the grid itself to deform slightly. Learnable deformation vectors allow the grid points to move, helping the mesh conform to thin or curved parts of the target shape."
  ```)
  - Borrows from prior work.
  - Allows the 3D grid vertices to move via learnable *deformation vectors (δ)*.
  - Helps the grid conform to thin or curved geometry.
]

#slide(title: "4. Regularizers")[
  #note(```
    "Finally, because this model has so many parameters, it uses two regularizers to encourage good mesh quality. One keeps the dual vertex near the center of its face, and the other penalizes random sign changes in the SDF to prevent internal surfaces."
  ```)
  - *Purpose*: Encourage high-quality mesh geometry.
  - *Two Regularizers*:
    1. Encourages the dual vertex to stay near the center of its primal face.
    2. Penalizes spurious sign changes in the SDF to remove internal surfaces.
]

= Conclusion

#slide(title: "Key Takeaways")[
  #note(```
    "In conclusion, Flexicubes presents a novel way to extract isosurfaces that is both flexible enough to capture sharp details and stable enough for gradient-based optimization. It achieves this by replacing the problematic QEF with a set of learnable, convex weights, making it a powerful tool for generating high-quality 3D models.\n\nThank you for your attention."
  ```)
  - Flexicubes offers a *stable and flexible* alternative to traditional isosurfacing methods.
  - It replaces the unstable *QEF* with a set of *learnable, convex weights*.
  - This allows for *gradient-based optimization* of the mesh geometry.
  - The result is *high-quality meshes* that can capture sharp features without artifacts or instability.
]

#focus-slide[Thank you for your attention!]
