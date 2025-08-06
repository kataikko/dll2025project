#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge, shapes
#import "@preview/tableau-icons:0.334.1": *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/muchpdf:0.1.1": muchpdf
#import "@preview/pinit:0.2.2": *
#import "@preview/wrap-it:0.1.1": *

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
    inset: (left: 15mm, top: 20mm, right: 15mm, bottom: 10mm),
  )[
    #content
  ]
}

#let content-box(heading, content, height: auto) = {
  [
    #v(5mm)
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
    #v(20mm)
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
        columns: (1fr, .8fr, 1fr, .8fr, 1fr, .8fr, 1fr),
        align: center,
        { image("images/perspectives.png", height: 100mm); [*Photos / Video*]; linebreak(); pin(1) },
        [
          #fa-circle-nodes(size: 70pt)
          #linebreak()
          SDF network
          #linebreak()
          #fa-arrow-right(size: 140pt)
        ],
        image("images/sdf.png", height: 100mm),
        [
          #fa-border-all(size: 70pt)
          #linebreak()
          Mesh extraction
          #linebreak()
          #fa-arrow-right(size: 140pt)
        ],
        image("images/mesh.png"),
        [
          #fa-camera(size: 70pt)
          #linebreak()
          Render
          #linebreak()
          #fa-arrow-right(size: 140pt)
        ],
        [#image("images/render.png", height: 100mm)
          .#pin(2) *Rendering*
        ],
      )
    ]

    #pinit-fletcher-edge(fletcher, 1, end: 2, (1, 0), [*Optimize for image mask similarity*], bend: -5deg, "<|-|>", stroke: 6pt)
  ]
  #grid(
    columns: (2fr, 1fr),
    column-gutter: 20mm, 
    [
      #content-box(height: auto)[
        #grid(columns: (2fr, 1fr, 1fr),
          align(left)[Deep Marching Tetraeda @shen2021deepmarchingtetrahedrahybrid],
          align(center)[$<-->$],
          align(right)[Flexicubes @Shen_2023],
        )
        ][
          #grid(columns: (1fr, 1fr, 1fr), 
          align: (left, left, left), 
          column-gutter: 5mm, 
          row-gutter: 10mm,
          [
            = Primal mesh
            #image("images/dmc_compare_mc.svg", height: 80mm)
            #align(left,[
              - vertices along grid edges
              - mesh restricted
              - cannot capture sharp features
            ])
          ], [
            = Dual mesh extraction
            #image("images/dmc_compare_dc.svg", height: 80mm)
            #align(left, [
              - vertices within grid cells
              - captures sharp features
              - difficulties differential optimisation
            ])
          ], [
            = Primal + Dual mesh
            #image("images/dmc_compare_dmc.svg", height: 80mm)
            #align(left, [
              - vertices within grid cells
              - dual connectivity of mesh
              - differentiable
            ]
            )
          ], 
          grid.cell(
            colspan: 3,
            align: left,
            inset: (x:0pt, y:20pt),
            [
              = Flexicubes
              #grid(
                columns: (1fr, 1fr),
                align: (left, left),
                image("images/dual_vertex.svg", height: 80mm),
                [
                  #align(left, [
                  - differentiable and robust
                  - additional optimisable parameters
                  - garuantees 2-manifold mesh
                  ])
                ]
              )
            ]
          )
          )
      ]],[
      #content-box(height: auto)[
        #grid(
          columns: (1fr),
          align(right)[Mesh Prior]
        )
        ][
        #grid(
          columns: (1fr),
          rows: (13em, 13em) ,
          [
            = Sphere @sommer2025common3dselfsupervisedlearning3d
            #grid(
              columns: (1fr, 1.5fr),
              image("images/sphere.png", width: 100%),
              [
                - $"sdf"_"train"$ is initialised with random noise
                - $"sdf" = "sdf"_"sphere" + "sdf"_"train"$
                - SDF is trained as difference to sphere
              ]
            )
          ],
          [
            = Random
            #grid(
              columns: (1fr, 1.5fr),
              image("images/noise.png", width: 100%),
              [
                - $"sdf"_"train"$ is initialised with random noise
                - $"sdf" = "sdf"_"train"$
                - SDF is trained directly
              ]
            )
          ]
        )
      ]
    ]
  )

  #content-box(height: 500mm)[Results][
  #grid(
    columns: 3,
    rows: 2,
    column-gutter: 2mm,
    row-gutter: 2mm,
    figure(
      caption: [Rendered Meshes on Test Set with Reference (ShapeNet)],
      grid(
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
          inset: (x: 0.5em, y: 2.5em),
          [
            DMTet
          ]),
          image("images/shape_net_dmtet_32_sphere.png", width: 100%),
          image("images/shape_net_dmtet_32_rand.png", width: 100%),
          grid.cell(rowspan: 2, align: center, inset: (x: 0pt, y: 2.5em), [
            #image("images/shape_net_reference.png", width: 100%)
            Reference
          ]
        ),
        grid.cell(
          inset: (x: 0.5em, y: 2.5em),
          [
            FlexiCubes
          ]
        ),
        image("images/shape_net_flex_32_sphere.png", width: 100%),
        image("images/shape_net_flex_32_rand.png", width: 100%),
      )
    ),
    figure(
      caption: [
        IoU at Test time (ShapeNet)
      ],
      image("images/plots/shape_net_test_iou_by_init_type.svg", width: 100%)
    ),
    figure(
      caption: [
        IoU on Validation Set during Training (ShapeNet)
      ],
      image("images/plots/shape_net_val_iou.svg", width: 100%)
    ),
    figure(
      caption: [Rendered Meshes on Test Set with Reference (CO3D)],
      grid(
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
          inset: (x: 0.5em, y: 2.5em),
          [
            DMTet
          ]),
          image("images/co3d_dmtet_32_sphere.png", width: 100%),
          image("images/co3d_dmtet_32_rand.png", width: 100%),
          grid.cell(rowspan: 2, align: center, inset: (x: 0pt, y: 2.5em), [
            #image("images/co3d_reference.png", width: 100%)
            Reference
          ]
        ),
        grid.cell(
          inset: (x: 0.5em, y: 2.5em),
          [
            FlexiCubes
          ]
        ),
        image("images/co3d_flex_32_sphere.png", width: 100%),
        image("images/co3d_flex_32_rand.png", width: 100%),
      )
    ),
    figure(
      caption: [
        PSNR at Test time (ShapeNet)
      ],
      image("images/plots/shape_net_test_psnr_by_init_type.svg", width: 100%)
    ),
    figure(
      caption: [
        PSNR on Validation Set during Training (ShapeNet)
      ],
      image("images/plots/shape_net_val_psnr.svg", width: 100%)
    ),
  )
  ]

//#content-box(height: auto)[Conclusion][
//  TODO
//]
#place(bottom, rect(
  width: 100%,
  height: auto,
  fill: ufr-blue,
  inset: (left: 15mm, top: 7mm, right: 15mm, bottom: 7mm),
  radius: (top: 8pt, bottom: 0pt),
)[
  #set text(size: 18pt, fill: white)
  #bibliography("source.bib")
])
]