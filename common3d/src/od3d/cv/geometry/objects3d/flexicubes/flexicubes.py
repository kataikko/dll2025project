import torch
import numpy as np
import kaolin as kal

from omegaconf import DictConfig
from typing import List, Union


from common3d.src.od3d.cv.geometry.objects3d.meshes.meshes import Meshes, RASTERIZER, FACE_BLEND_TYPE
from common3d.src.od3d.cv.geometry.objects3d.objects3d import FEATS_DISTR, FEATS_ACTIVATION


class Flexicubes(Meshes):
    def __init__(
        self,
        verts: List[torch.Tensor],
        faces: List[torch.Tensor],
        feat_dim=128,
        objects_count=0,
  #      feats_objects: Union[bool, torch.Tensor] = False,
        feat_clutter_requires_param: Union[bool, torch.Tensor] = False,
        verts_uvs: List[torch.Tensor] = None,
        verts_coarse_count: int = 150,
        verts_coarse_prob_sigma: float = 0.01,
        feats_requires_grad=True,
        feat_clutter=False,
        feats_distribution=FEATS_DISTR.VON_MISES_FISHER,
        feats_activation=FEATS_ACTIVATION.NORM_DETACH,
        rgb: List[torch.Tensor] = None,
        verts_requires_grad=False,
        geodesic_prob_sigma=0.2,
        gaussian_splat_enabled=False,
        gaussian_splat_opacity=0.7,
        gaussian_splat_pts3d_size_rel_to_neighbor_dist=0.5,
        pt3d_raster_perspective_correct=False,
        device=None,
        dtype=None,
        rasterizer=RASTERIZER.NVDIFFRAST,
        face_blend_type=FACE_BLEND_TYPE.SOFT_SIGMOID_NORMALIZED,
        face_blend_count=2,
        face_opacity=1.0,
        face_opacity_face_sdf_sigma=1e-4,
        face_opacity_face_sdf_gamma=1e-4,
        instance_deform_net_config: DictConfig = None,
        voxel_grid_res=16,
  #     gs_top_k=3,
  #     gs_scale=0.05,
  #     gs_opacity_requires_grad=False,
  #     gs_scale_requires_grad=False,
  #     gs_rotation_requires_grad=False,
  #     tet_res=16,
  #     sdf_symmetric=True,
  #     harmonic_functions_count=8,
  #     init_radius=1.0,
        **kwargs,
    ):
        super().__init__(
            verts=verts,
            faces=faces,
            feat_dim=feat_dim,
            objects_count=objects_count,
            feats_objects=None,
            verts_uvs=verts_uvs,
            feats_requires_grad=feats_requires_grad,
            feats_objects_requires_param=False,
            feat_clutter_requires_param=feat_clutter_requires_param,
            feat_clutter=feat_clutter,
            feats_distribution=feats_distribution,
            feats_activation=feats_activation,
            rgb=rgb,
            verts_requires_grad=verts_requires_grad,
            verts_requires_param=False,
            verts_coarse_count=verts_coarse_count,
            verts_coarse_prob_sigma=verts_coarse_prob_sigma,
            geodesic_prob_sigma=geodesic_prob_sigma,
            gaussian_splat_enabled=gaussian_splat_enabled,
            gaussian_splat_opacity=gaussian_splat_opacity,
            gaussian_splat_pts3d_size_rel_to_neighbor_dist=gaussian_splat_pts3d_size_rel_to_neighbor_dist,
            pt3d_raster_perspective_correct=pt3d_raster_perspective_correct,
            device=device,
            dtype=dtype,
            rasterizer=rasterizer,
            face_blend_type=face_blend_type,
            face_blend_count=face_blend_count,
            face_opacity=face_opacity,
            face_opacity_face_sdf_sigma=face_opacity_face_sdf_sigma,
            face_opacity_face_sdf_gamma=face_opacity_face_sdf_gamma,
            instance_deform_net_config=instance_deform_net_config,
   #         gs_top_k=gs_top_k,
   #         gs_scale=gs_scale,
   #         gs_opacity_requires_grad=gs_opacity_requires_grad,
   #         gs_scale_requires_grad=gs_scale_requires_grad,
   #         gs_rotation_requires_grad=gs_rotation_requires_grad,
        )

        # init Flexicubes
        self.voxel_grid_res = voxel_grid_res
        self.flexicubes = kal.ops.conversions.FlexiCubes(device)
        # create the non-deformed voxel grid whose positions will be used to sample for FlexiCubes
        x_nx3, cube_fx8 = self.flexicubes.construct_voxel_grid(voxel_grid_res)
        x_nx3 *= 2 # scale up the grid so that it's larger than the target object
        # init mesh-specific weights for Flexicubes
        self.weight = torch.zeros((cube_fx8.shape[0], 21), dtype=torch.float, device=device)
        self.weight = torch.nn.Parameter(self.weight.clone().detach(), requires_grad=True)



    def update_verts(self, require_grad=True):
        self.update_dmtet(require_grad=require_grad)  # similar in dmtet_x_gaussians.py
        pass

    def update_dmtet(
        self,
        device=None,
        dtype=None,
        require_grad=None,
        require_feats_grad=None,
    ):
        """
        This should not update the dmtet, as we are in Felxicubes. However, this function is called in nemo/methode
        """
        pass
