#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge, shapes
#import "@preview/tableau-icons:0.334.1": *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/muchpdf:0.1.1": muchpdf

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
  rect(width: 100%, height: 120mm, fill: ufr-blue, radius: 8pt, inset: (left: 15mm, top: 15mm, right: 15mm, bottom: 10mm))[
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

#page(margin: (bottom: 0pt))[
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
    #columns(2,[
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
  #content-box(height: auto)[Introduction][
    = Mesh extraction pipeline
    #v(10mm)
    //#rect(width: 100%, height: 200mm, fill: light-gray, inset: (left: 15mm, top: 10mm, right: 15mm))[
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
        isosurface
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
      edge((6, 0), "d,l,l,l,l,l,l", "<|-|>", stroke: 2mm)
      node((3.5, 0.5), [
        #text(size: 60pt, weight: "bold", [=])\
        optimize for similarity between photos and renderings
      ])
    })
  ]

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 20mm,
    content-box(height: 150mm)[Deep Marching Tetraeda][
    //  #figure(
    //    muchpdf(read("images/teaser1.pdf", encoding: none))
    //  ) @Shen_2023

       #image("images/mc-dc-dmc-vizualization.png") @Shen_2023
       Similar to Dual Marching cubes, flexicubes uses both the dual and primal grid. It does so
       by first sampling the SDF on the primal grid, creating interpolation weights $alpha$ along grid edges.
       A primal mesh is created similar to marching cubes


    ],
    content-box(height: 150mm)[Flexicubes][
       #muchpdf(read("images/dual_vertex.pdf", encoding: none)) @shen2021deepmarchingtetrahedrahybrid
    ]
  )


  #content-box(height: auto)[Results][
  #columns(3,
  [
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
      grid.cell(
        inset: (x: 0pt, y: 2.5em),
        [
          DMTet
        ]
      ),
      image("images/shape_net_dmtet_32_sphere.png", width: 100%),
      image("images/shape_net_dmtet_32_rand.png", width: 100%),
      grid.cell(
        rowspan: 2,
        align: center,
        inset: (x: 0pt, y: 2.5em),
        [
          #image("images/shape_net_reference.png", width: 100%)
          Reference
        ]
      ),
      grid.cell(
        inset: (x: 0pt, y: 2.5em),
        [
          FlexiCubes
        ]
      ),
      image("images/shape_net_flex_32_sphere.png", width: 100%),
      image("images/shape_net_flex_32_rand.png", width: 100%),
    )

    #figure(
      image("images/plots/shape_net_val_loss.png", width: 100%),
    )
    #figure(
      image("images/plots/shape_net_val_iou.png", width: 100%),
    )
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
      grid.cell(
        inset: (x: 0pt, y: 2.5em),
        [
          DMTet
        ]
      ),
      image("images/co3d_dmtet_32_sphere.png", width: 100%),
      image("images/co3d_dmtet_32_rand.png", width: 100%),
      grid.cell(
        rowspan: 2,
        align: center,
        inset: (x: 0pt, y: 2.5em),
        [
          #image("images/co3d_reference.png", width: 100%)
          Reference
        ]
      ),
      grid.cell(
        inset: (x: 0pt, y: 2.5em),
        [
          FlexiCubes
        ]
      ),
      image("images/co3d_flex_32_sphere.png", width: 100%),
      image("images/co3d_flex_32_rand.png", width: 100%),
    )

    #figure(
      image("images/plots/shape_net_val_psnr.png", width: 100%),
    )
    #figure(
      image("images/plots/shape_net_test_psnr_by_init_type.png", width: 100%),
    )
    #figure(
      image("images/plots/shape_net_test_iou_by_init_type.png", width: 100%),
    )
  ])
  ]

  //#content-box(height: auto)[Conclusion][
  //  TODO
  //]
  #place(
    bottom,
    rect(
      width: 100%, height: auto, fill: ufr-blue,
      inset: (left: 15mm, top: 15mm, right: 15mm, bottom: 15mm),
      radius: (top: 8pt, bottom: 0pt),
    )[
      #set text(size: 18pt, fill: white)
      #bibliography("source.bib")
    ])
]