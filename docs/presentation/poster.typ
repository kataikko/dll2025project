#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge, shapes
#import "@preview/tableau-icons:0.334.1": *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/muchpdf:0.1.1": muchpdf
#import "@preview/pinit:0.2.2": *

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
  rect(
    width: 100%,
    height: 120mm,
    fill: ufr-blue,
    radius: 8pt,
    inset: (left: 15mm, top: 15mm, right: 15mm, bottom: 10mm),
  )[
    #content
  ]
}

#let content-box(heading, content, height: auto) = {
  [
    #v(10mm)
    #set text(size: 54pt, weight: "bold", fill: ufr-blue)
    #heading
  ]
  line(length: 100%, stroke: light-gray + 5pt)
  content
}

#page(
  margin: (bottom: 0pt),
)[
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
    Mesh Extraction with FlexiCubes \
    \
    #set text(size: 45pt, weight: "bold")
    #columns(2, [
      Vincent Kataikko, Birk Ramin, Julius Schmitt
      #colbreak()
      #align(right)[
        Leonhard Sommer
      ]
    ])
    #set text(size: 36pt, weight: "regular")
    Deep Learning Lab • Albert-Ludwigs-Universität Freiburg • Summer 2025
  ]

  // Abstract section
  #content-box(
    height: auto,
  )[Mesh extraction pipeline][
    #rect(width: 100%, height: 180mm, fill: rgb("#eee"), inset: 15mm)[
      #grid(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        align: center,
        { image("images/perspectives.png", height: 100mm); [*Photos / Video*]; linebreak(); pin(1) },
        diagram({
          node((0, 2), fa-arrow-right(size: 140pt), name: <arrow>)
          node(<arrow.north>, { fa-circle-nodes(size: 70pt); linebreak(); [SDF network]; v(5mm) })
        }),
        image("images/sdf.png", height: 100mm),
        diagram({
          node((0, 2), fa-arrow-right(size: 140pt), name: <arrow>)
          node(<arrow.north>, { fa-border-all(size: 70pt); linebreak(); [Mesh extraction]; v(5mm) })
        }),
        image("images/mesh.png"),
        diagram({
          node((0, 2), fa-arrow-right(size: 140pt), name: <arrow>)
          node(<arrow.north>, { fa-camera(size: 70pt); linebreak(); [Render]; v(5mm) })
        }),
        [#image("images/render.png", height: 100mm)
          .#pin(2)*Rendering*
        ],
      )
    ]

    #pinit-fletcher-edge(fletcher, 1, end: 2, (1, 0), [*Optimize for image mask similarity*], bend: -10deg, "<|-|>", stroke: 6pt)
  ]

  #content-box(height: 150mm)[Deep Marching Tetraeda][
    #grid(columns: (1fr, 1fr, 2fr), column-gutter: 20mm, [
      #image("images/dmc_compare_mc.svg")
      @Shen_2023
      Similar to Dual Marching cubes, flexicubes uses both the dual and primal grid. It does so
      by first sampling the SDF on the primal grid, creating interpolation weights $alpha$ along grid edges.
      A primal mesh is created similar to marching cubes
    ])

  ]

  #content-box(height: auto)[Results][
    #columns(3, [
      #grid(
        columns: (auto, 5em, 5em, 5em),
        rows: (auto, 5em, 5em),
        column-gutter: 2mm,
        row-gutter: 2mm,
        align: (left, center, center, center),
        [],
        [
          Sphere
        ],
        [
          Random
        ],
        [],
        grid.cell(inset: (x: 0pt, y: 2.5em), [
          DMTet
        ]),
        image("images/shape_net_dmtet_32_sphere.png", width: 100%),
        image("images/shape_net_dmtet_32_rand.png", width: 100%),
        grid.cell(rowspan: 2, align: center, inset: (x: 0pt, y: 2.5em), [
          #image("images/shape_net_reference.png", width: 100%)
          Reference
        ]),
        grid.cell(inset: (x: 0pt, y: 2.5em), [
          FlexiCubes
        ]),
        image("images/shape_net_flex_32_sphere.png", width: 100%),
        image("images/shape_net_flex_32_rand.png", width: 100%),
      )

      #figure(image("images/plots/shape_net_val_loss.png", width: 100%))
      #figure(image("images/plots/shape_net_val_iou.png", width: 100%))
      #grid(
        columns: (auto, 5em, 5em, 5em),
        rows: (auto, 5em, 5em),
        column-gutter: 2mm,
        row-gutter: 2mm,
        align: (left, center, center, center),
        [],
        [
          Sphere
        ],
        [
          Random
        ],
        [],
        grid.cell(inset: (x: 0pt, y: 2.5em), [
          DMTet
        ]),
        image("images/co3d_dmtet_32_sphere.png", width: 100%),
        image("images/co3d_dmtet_32_rand.png", width: 100%),
        grid.cell(rowspan: 2, align: center, inset: (x: 0pt, y: 2.5em), [
          #image("images/co3d_reference.png", width: 100%)
          Reference
        ]),
        grid.cell(inset: (x: 0pt, y: 2.5em), [
          FlexiCubes
        ]),
        image("images/co3d_flex_32_sphere.png", width: 100%),
        image("images/co3d_flex_32_rand.png", width: 100%),
      )

      #figure(image("images/plots/shape_net_val_psnr.png", width: 100%))
      #figure(image("images/plots/shape_net_test_psnr_by_init_type.png", width: 100%))
      #figure(image("images/plots/shape_net_test_iou_by_init_type.png", width: 100%))
    ])
  ]

  //#content-box(height: auto)[Conclusion][
  //  TODO
  //]
  #place(bottom, rect(
    width: 100%,
    height: auto,
    fill: ufr-blue,
    inset: (left: 15mm, top: 15mm, right: 15mm, bottom: 15mm),
    radius: (top: 8pt, bottom: 0pt),
  )[
    #set text(size: 18pt, fill: white)
    #bibliography("source.bib")
  ])
]