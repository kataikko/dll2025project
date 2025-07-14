# Precursors
## 3D Morphable Models (3DMM)
- "Templates" of 3D objects with a fixed topology
- We create an instance of such a model, by morphing to it to an approximation of the real object, we see in photo(s)
## DINOv2
- extract semantic features from images (tied to regions of the images?)
## SfM

# Goal
- Learn 3DMMs from videos of objects
- create point clouds from multiple videos of objects of the same category (i.e. couch, car, ...)
- create a "category template"
# Method
- adapt dinov2 features to understand "2D-to-3D correspondences" in the image (which DINOv2 does not do) 
## Components
- **A Differentiable Renderer:** project the 3D model into the 2D image
- **A 3D Morphable Model (3DMM):** represent object's shape and texture.
- Self-Supervised Objective: compare rendered image to the input image in the feature space of a pre-trained neural network
- Backbone (encoder)
	- map input image to latent code.
	- This is the part which builds uppon DINOv2
	- multiple backbones available  in `common3d/src/od3d/models/backbones/`
- head (decoder)
	- `common3d/src/od3d/models/heads/head.py`
- `common3d/src/od3d/models/model.py` (OD3D_Model)
	- contains the backbone and the head
- `common3d/src/od3d/cv/geometry/objects3d/objects3d.py` (OD3D_Objects3D)
	- differentiable mesh representation (gets infered from an SDF?)
- fn `update_dmet_gaussians` to render a mesh from the sdf

## Code entry points
- forward pass through the OD3D_Model: https://github.com/kataikko/dll2025project/blob/edacb33cf11aa85426b43b4d309ca4db167fc1e2/common3d/src/od3d/methods/nemo/method.py#L1067C1-L1067C21
## Notes
- A flexicubes implementation already exists here: [common3d/src/od3d/cv/geometry/objects3d/flexicubes/flexicubes.py](https://github.com/kataikko/dll2025project/blob/edacb33cf11aa85426b43b4d309ca4db167fc1e2/common3d/src/od3d/cv/geometry/objects3d/flexicubes/flexicubes.py#L391)
- https://github.com/kataikko/dll2025project/blob/edacb33cf11aa85426b43b4d309ca4db167fc1e2/common3d/src/od3d/methods/nemo/method.py#L106