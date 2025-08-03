#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge, shapes
#import "@preview/tableau-icons:0.334.1": *
#import "@preview/fontawesome:0.6.0": *

// Page setup for A0 poster size (approximately matching SVG dimensions)
#set page(
  width: 841mm,
  height: 1189mm,
  margin: (x: 15mm, y: 15mm),
)

// Color definitions from SVG template
#let ufr-blue = rgb("#354a9a")
#let light-gray = rgb("#9e9e9e")
#let medium-gray = rgb("#c0c0c0")

// Typography setup
#set text(
  font: "Arial",
  size: 31pt,
  fill: black,
)

#set heading(
  numbering: none,
)

// Helper functions for layout
#let header-box(content) = {
  rect(
    width: 100%,
    height: 120mm,
    fill: ufr-blue,
    radius: 8pt,
    inset: (left: 15mm, top: 10mm),
  )[
    #content
  ]
}

#let content-box(heading, content, height: auto) = {
  [
    #set text(size: 54pt, weight: "bold", fill: ufr-blue)
    #heading
  ]
  rect(
    width: 100%,
    height: height,
    fill: white,
    stroke: light-gray + 4pt,
    radius: 4pt,
    inset: 15mm,
  )[
    #content
  ]
}

#let two-column-layout(left, right) = {
  grid(
    columns: (1fr, 1fr),
    column-gutter: 20mm,
    left,
    right
  )
}

// Main poster content
#page[
  // Header with title
#grid(
    columns: (1fr, 1fr),
    align: (left, right),
    image("images/ufr_logo.png", height: 20mm),
    text(size: 36pt, fill: ufr-blue)[
        #link("github.com/kataikko/dll2025project")
    ]
    )
  #header-box[
     #set text(fill: white, size: 86pt, weight: "bold")
    #[Mesh Extraction with FlexiCubes]

    #set text(size: 45pt, weight: "bold")
    Vincent Kataikko, Birk Ramin, Julius Schmitt

    #set text(size: 36pt, weight: "regular")
    Deep Learning Lab • Albert-Ludwigs-Universität Freiburg • Summer 2025
  ]

  // Abstract section
  #content-box(height: 220mm)[Introduction][
    = Mesh extraction pipeline
    #v(10mm)
    #set text(size: 16pt)
    #diagram({
        node((0, 0), image("images/perspectives.png", height: 100mm), name: <perspectives>)
        edge((0, 0), (2, 0), "-|>", stroke: 2mm)
        node((1, -.3), [
            #fa-circle-nodes(size: 50pt)\
            #v(1mm)
            SDF extraction network
            #v(3mm)
        ])
        node((2, 0), image("images/sdf.png", height: 100mm))
        edge((2, 0), (4, 0), "-|>", stroke: 2mm)
        node((3, -.3), [
            #fa-border-all(size: 50pt)\
            #v(1mm)
            isosurface algorithm
            #v(3mm)
        ])

        node((4, 0), image("images/mesh.png"), height: 100mm)
        edge((4, 0), (6, 0), "-|>", stroke: 2mm)
        node((5, -.3), [
            #fa-camera(size: 50pt)\
            #v(1mm)
            differentiable render
            #v(3mm)
        ])
        node((6, 0), image("images/render.png", height: 100mm), name: <render>)
        edge((6, 0),"d,d,l,l,l,l,l,l,u", "-|>", stroke: 2mm)
        node((3.5, 1), [
        #text(size: 60pt, weight: "bold", [=])\
        optimize for similarity between photos and renderings
         ])
    })
  ]

  #v(15mm)

  // Two-column layout for main content
  #two-column-layout[
    // Left column - Method Overview
    #content-box(height: 400mm)[Method][
      #set text(size: 16pt)
      = Method Overview
      
      #set text(size: 14pt)
      
      == Traditional Approaches
      
      *Marching Cubes (MC):*
      - Vertices constrained to grid edges
      - Creates "stair-step" artifacts
      - Limited representation of sharp features
      
      *Dual Contouring (DC):*
      - Places vertices inside cells using QEF
      - Numerically unstable for optimization
      - Can produce non-manifold geometry
      
      == FlexiCubes Innovation
      
      *Flexible Dual Vertex Positioning:*
      - Learnable interpolation weights α modify zero-crossing positions
      - Edge weights β determine final vertex as weighted average
      - Convex combinations guarantee stability
      
      *Mathematical Formulation:*
      ```
      v_dual = Σ(β_i * p_i)
      where p_i = (1-α_i)*v_i + α_i*v_j
      ```
      
      *Flexible Quad Splitting:*
      - Continuous splitting decision via γ weights
      - Smooth interpolation between diagonal choices
      - Enables gradient-based triangulation optimization
      
      *Grid Deformation:*
      - Deformation vectors δ allow grid adaptation
      - Helps capture thin or curved geometry
      - Additional layer of geometric flexibility
    ]
  ][
    // Right column - Implementation & Results
    #content-box(height: 400mm)[Details][
      #set text(size: 16pt)
      = Implementation Details
      
      #set text(size: 14pt)
      
      == Architecture
      
      Our FlexiCubes implementation extends the base `Meshes` class with:
      - Tetrahedral mesh integration (DMTet)
      - SDF computation and gradient calculation
      - Gaussian splatting support
      - Deformation network integration
      
      == Key Components
      
      *Core Parameters (per cell):*
      - 8 α weights for vertex interpolation
      - 12 β weights for edge weighting
      - 1 γ weight for quad splitting
      - 3 δ components for grid deformation
      
      *Regularization:*
      - Dual vertex centering loss
      - SDF sign change penalty
      - Geometric quality preservation
      
      == Technical Features
      
      *Differentiable Pipeline:*
      - End-to-end gradient flow
      - PyTorch integration
      - CUDA acceleration support
      
      *Stability Guarantees:*
      - Convex combination constraints
      - Bounded vertex positions
      - Manifold mesh generation
      
      == Applications
      
      - 3D reconstruction from images
      - Neural implicit surface extraction
      - Mesh optimization for rendering
      - Shape generation and editing
    ]
  ]
  
  #v(15mm)
  
  // Bottom section - Results and Conclusion
  #content-box(height: 200mm)[Results][
    #set text(size: 16pt)
    = Results & Impact
    
    #set text(size: 14pt)
    
    #two-column-layout[
      *Advantages over Traditional Methods:*
      - Stable gradient-based optimization
      - Better preservation of sharp features
      - Flexible topology adaptation
      - Reduced mesh artifacts
      - Differentiable mesh generation
      
      *Performance Characteristics:*
      - Maintains topological soundness
      - Efficient GPU implementation
      - Scalable to high-resolution grids
      - Compatible with existing pipelines
    ][
      *Future Directions:*
      - Integration with neural radiance fields
      - Real-time mesh deformation
      - Multi-scale representation learning
      - Advanced regularization techniques
      
      *Conclusion:*
      FlexiCubes represents a significant advancement in differentiable mesh extraction, combining the stability of traditional methods with the flexibility required for modern gradient-based optimization workflows.
    ]
  ]
  
  #v(10mm)
  
  // Footer
  #align(center)[
    #set text(size: 12pt, fill: medium-gray)
    Deep Learning Lab 2025 • University of Freiburg • Contact: julius.schmitt\@uni-freiburg.de
  ]
]
