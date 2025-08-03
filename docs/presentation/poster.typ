#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge, shapes
#import "@preview/tableau-icons:0.334.1": *
#import "@preview/fontawesome:0.6.0": *

// Page setup for A0 poster size (approximately matching SVG dimensions)
#set page(width: 841mm, height: 1189mm, margin: (x: 15mm, y: 15mm))

// Color definitions from SVG template
#let ufr-blue = rgb("#354a9a")
#let light-gray = rgb("#9e9e9e")
#let medium-gray = rgb("#c0c0c0")

// Typography setup
#set text(font: "Arial", size: 31pt, fill: black)

#set heading(numbering: none)
#set block(spacing: 10mm)

// Helper functions for layout
#let header-box(content) = {
  rect(width: 100%, height: 120mm, fill: ufr-blue, radius: 8pt, inset: (left: 15mm, top: 10mm))[
    #content
  ]
}

#let content-box(heading, content, height: auto) = {
  [
    #v(10mm)
    #set text(size: 54pt, weight: "bold", fill: ufr-blue)
    #heading
  ]
  rect(width: 100%, height: height, fill: white, stroke: light-gray + 4pt, radius: 4pt, inset: 15mm)[
    #set text(size: 20pt)
    #content
  ]
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
    ],
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
    #diagram({
      node((0, 0), image("images/perspectives.png", height: 100mm), name: <perspectives>)
      edge((0, 0), (2, 0), "-|>", stroke: 2mm)
      node((1, -.3), [
        #fa-circle-nodes(size: 50pt)\
        #v(1mm)
        SDF sampler
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
        render
        #v(3mm)
      ])
      node((6, 0), image("images/render.png", height: 100mm), name: <render>)
      edge((6, 0), "d,d,l,l,l,l,l,l,u", "<|-|>", stroke: 2mm)
      node((3.5, 1), [
        #text(size: 60pt, weight: "bold", [=])\
        optimize for similarity between photos and renderings
      ])
    })
  ]
  #content-box(height: 150mm)[Method][
    #set text(size: 16pt)
    = Method Overview

    #set text(size: 14pt)
    *Marching Cubes (MC):*
    - Vertices constrained to grid edges
    - Creates "stair-step" artifacts
    - Limited representation of sharp features

    == FlexiCubes Innovation

    *Flexible Dual Vertex Positioning:*
    - Learnable interpolation weights α modify zero-crossing positions
    - Edge weights β determine final vertex as weighted average
    - Convex combinations guarantee stability

  ]

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 20mm,
    content-box(height: 500mm)[Qualitative Results][
      #set text(size: 16pt)
      = Implementation Details

      #set text(size: 14pt)
      test

      #figure(
        image("images/dmtet_32_sphere.png", height: 20%),
      )
      #figure(
        image("images/flex_32_sphere.png", height: 20%),
      )

      #figure(
        image("images/flex_32_rand.png", height: 20%),
      )

      #figure(
        image("images/dmtet_32_rand.png", height: 20%),
      )

    ],
    // Bottom section - Results and Conclusion
    content-box(height: 500mm)[Quantitative Results][
      #set text(size: 16pt)
      = Results & Impact

      #figure(
        image("images/plots/val_loss.png", width: 60%),
      )
      #figure(
        image("images/plots/val_iou.png", width: 60%),
      )
      #figure(
        image("images/plots/val_psnr.png", width: 60%),
      )

      #set text(size: 14pt)
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
    ],
  )
]