/// IMPORT THE POSTERS PACKAGE
#import "@preview/peace-of-posters:0.5.5" as pop

// Define overall formatting defaults for the document.
// These settings can be overwritten later on.
#let spacing = 1.2em
#set page("a0", margin: 1.5cm)
#pop.set-poster-layout(pop.layout-a0)
#pop.set-theme(pop.uni-fr)

#set text(font: "Arial", size: pop.layout-a0.at("body-size"))

#let box-spacing = 1.2em
#set columns(gutter: box-spacing)
#set block(spacing: box-spacing)
#pop.update-poster-layout(spacing: box-spacing)

// Define colors as given by coroprate design of uni freiburg
#let uni_dark_blue = rgb("#1d154d")

/// START OF THE DOCUMENT
#pop.title-box(
  [FlexiCubes Integration for 3D Reconstruction - Advancing Differentiable Isosurfacing in Neural 3D Morphable Models],
  authors: "Julius Schmitt¹, Deep Learning Lab Team¹",
  institutes: "¹University of Freiburg - Deep Learning Lab",
  //image("UFR-Siegel-white.png"),
)

#pop.column-box()[
  #set par(justify: true)
  #set align(center)
  3D reconstruction from images requires robust and flexible isosurfacing algorithms to convert implicit representations into triangle meshes.
  Traditional methods like Marching Cubes are rigid, while Dual Contouring suffers from numerical instability during optimization.
  FlexiCubes addresses these limitations by introducing learnable parameters that enable flexible vertex positioning while maintaining topological soundness.
  We integrate FlexiCubes into the common3d framework for learning 3D Morphable Models from video data, replacing DMTet with a more stable and flexible differentiable isosurfacing approach.
]

#columns(2, gutter: spacing)[
	#pop.column-box(
		heading: [FlexiCubes Features],
	)[
		#columns(2, gutter: 0.5*spacing)[
			- Flexible dual vertex positioning with learnable parameters
			- Stable optimization without QEF instability
			- Differentiable quad splitting for gradient-based learning
			- Topologically sound mesh generation

			#colbreak()
			- Grid deformation for thin geometry adaptation
			- Integrated regularization for mesh quality
			- Compatible with existing PyTorch pipelines
			- Seamless integration with common3d framework

		]
	]

	#pop.column-box(heading: "FlexiCubes Method")[
		FlexiCubes introduces four key differentiable components:
		
		*1. Flexible Dual Vertex Positioning:*
		- Learnable interpolation weights (α) for 8 cube corners
		- Learnable edge weights (β) for 12 cube edges
		- Convex combinations ensure vertices stay within cells
		
		*2. Flexible Quad Splitting:*
		- Learnable splitting weight (γ) for continuous triangulation
		- Smooth interpolation between diagonal choices
		
		*3. Grid Deformation:*
		- Learnable deformation vectors (δ) for grid adaptation
		
		*4. Regularization:*
		- Dual vertex centering and SDF sign change penalties
	]

	#pop.column-box(heading: [Integration with common3d Framework])[
		FlexiCubes seamlessly integrates into the existing 3D reconstruction pipeline:
		
		*Pipeline Components:*
		- *DINOv2 Backbone:* Extracts semantic features from input images
		- *3D Morphable Model:* Learns category-specific shape representations
		- *FlexiCubes Isosurfacing:* Converts SDF to differentiable meshes
		- *Differentiable Renderer:* Projects 3D models to 2D for supervision
		
		*Key Integration Points:*
		```python
		class Flexicubes(Meshes):
		    def update_dmtet(self, device=None, dtype=None):
		        # Convert SDF to mesh using FlexiCubes
		        
		    def get_sdf(self, pts, object_id):
		        # Query SDF values at 3D points
		        
		    def get_geo_sdf_reg_loss(self, objects_ids):
		        # Regularization for mesh quality
		```
	]

	#pop.column-box(
		heading: [Future Work & Applications],
		stretch-to-next: true,
	)[#columns(2)[
		- Multi-resolution FlexiCubes for complex geometries
		- Adaptive grid refinement strategies
		- Integration with neural radiance fields
		- Real-time reconstruction applications
		#colbreak()
		- Category-specific shape priors optimization
		- Texture and material property learning
		- Large-scale dataset evaluation
		- Performance optimization for mobile devices
	]]

	#colbreak()

	#pop.column-box(heading: [FlexiCubes vs. Traditional Methods])[
		#figure(stack(dir: ltr,
			box([
                #place(top+left, dx: 10pt, dy: 10pt, rect(text("MC", fill: white), fill: uni_dark_blue, inset: 10pt))
            ]),
            box(width: 1%),
			box([
                #place(top+left, dx: 10pt, dy: 10pt, rect(text("FlexiCubes", fill: white), fill: uni_dark_blue, inset: 10pt))
            ])
		), caption: [
            Comparison of mesh quality: Marching Cubes (MC) produces rigid, stair-stepped artifacts, while FlexiCubes generates smooth, high-quality meshes with learnable vertex positioning.
			FlexiCubes maintains topological soundness while enabling gradient-based optimization.
		])
	]

	#pop.column-box(heading: "3D Reconstruction Results")[
		#figure(stack(dir: ltr,
			box([
                #place(top+left, dx: 10pt, dy: 10pt, rect(text("Input", fill: white), fill: uni_dark_blue, inset: 10pt))
            ]),
            box(width: 1%),
			box([
                #place(top+left, dx: 10pt, dy: 10pt, rect(text("FlexiCubes", fill: white), fill: uni_dark_blue, inset: 10pt))
            ]),
		),
		caption: [
			3D reconstruction from multi-view images using FlexiCubes isosurfacing.
			Input images (left) are processed through the common3d pipeline to generate high-quality 3D meshes (right) with learned category-specific shape priors.
		])
	]

	#pop.column-box(heading: [Optimization Stability])[
		#figure(stack(dir: ltr,
			box([
				#place(top+left, dx: 10pt, dy: 10pt, rect(text("DC", fill: uni_dark_blue), fill: white, inset: 10pt))
			]),
			box(width: 1%),
			box([
				#place(top+left, dx: 10pt, dy: 10pt, rect(text("FlexiCubes", fill: uni_dark_blue), fill: white, inset: 10pt))
			])
		),
		caption: [
			Optimization stability comparison: Dual Contouring (DC) suffers from QEF instability with vertices exploding outside cells, while FlexiCubes uses convex combinations to guarantee vertices remain within their cells, enabling stable gradient-based optimization.
		])
	]

	#pop.column-box(heading: "Key References", stretch-to-next: true)[
          #set text(size: 20pt)
          • Shen et al. "Flexible Isosurface Extraction for Gradient-Based Mesh Optimization" (SIGGRAPH 2023)
          
          • Lorensen & Cline "Marching Cubes: A High Resolution 3D Surface Construction Algorithm" (1987)
          
          • Ju et al. "Dual Contouring of Hermite Data" (SIGGRAPH 2002)
          
          • Schaefer & Warren "Dual Marching Cubes: Primal Contouring of Dual Grids" (2004)
        ]
]

#pop.bottom-box(
	stack(dir: ltr,
		box(width: 20.5%, [
            #set text(size: 30pt)
			Deep Learning Lab
			#linebreak()
			July 30, 2025 - Freiburg
		]),
		box(width: 29.75%, height: 1.25em, align(center+horizon)[
			#set text(size: 35pt)
			FlexiCubes Integration Project
		]),
		box(width: 26.75%, height: 1.25em, align(center+horizon, [
			#set text(size: 35pt)
			University of Freiburg
		])),
	),
	text-relative-width: 80%,
    logo: stack(dir: ltr,
        h(0.5*spacing),
        // University logo would go here
        // image(width: 0.7*(100% - 0.5*spacing - 80%), "UFR-Schriftzug-white.png", fit: "contain"),
    )
)
