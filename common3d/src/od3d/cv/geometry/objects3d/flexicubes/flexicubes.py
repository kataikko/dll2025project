import torch

from omegaconf import DictConfig
from typing import List, Union


from od3d.cv.geometry.objects3d.meshes.meshes import Meshes, RASTERIZER, FACE_BLEND_TYPE
from od3d.cv.geometry.objects3d.objects3d import FEATS_DISTR, FEATS_ACTIVATION


class Flexicubes(Meshes):
    def __init__(
        self,
        verts: List[torch.Tensor],
        faces: List[torch.Tensor],
        feat_dim=128,
        objects_count=0,
        feats_objects: Union[bool, torch.Tensor] = False,
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
        sdf_symmetric=True,
        harmonic_functions_count=8,
        init_radius=1.0,
        voxel_grid_res=16,
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
        )

        self.init_radius = init_radius

        self.sdf_coordmlps = torch.nn.ModuleList()
        self.feat_coordmlps = torch.nn.ModuleList()

        sdf_coord_mlp_cfg = DictConfig(
            {
                "num_layers": 5,
                "hidden_dim": 256,
                "out_dim": 1,
                "dropout": 0,
                "activation": None,  # None
                "symmetrize": sdf_symmetric,
            },
        )

        feat_coord_mlp_cfg = DictConfig(
            {
                "num_layers": 5,
                "hidden_dim": 256,
                "out_dim": feat_dim,
                "dropout": 0,
                "activation": None,  # feats_activation
                "symmetrize": False,
            },
        )

        # note: import on-the-fly to avoid circular import
        from od3d.models.heads.coordmlp import CoordMLP

        for m in range(self.meshes_count):
            # grid_scale = self.get_ranges()[m]
            # embedder_scalar = 2 * np.pi / grid_scale * 0.9  # originally (-0.5*s, 0.5*s) rescale to (-pi, pi) * 0.9
            self.sdf_coordmlps.append(
                CoordMLP(
                    in_dims=[0],
                    in_upsample_scales=[],
                    config=sdf_coord_mlp_cfg,
                    n_harmonic_functions=harmonic_functions_count,
                    embed_concat_pts=True,
                ).to(device, dtype),
            )

            self.feat_coordmlps.append(
                CoordMLP(
                    in_dims=[0],
                    in_upsample_scales=[],
                    config=feat_coord_mlp_cfg,
                    n_harmonic_functions=harmonic_functions_count,
                    embed_concat_pts=True,
                ).to(device, dtype),
            )

        if not verts_requires_grad:
            for param in self.sdf_coordmlps.parameters():
                param.requires_grad = False
        if not feats_requires_grad:
            for param in self.feat_coordmlps.parameters():
                param.requires_grad = False
        
        # init Flexicubes
        self.create_new_flexicubes(device=device)
        

        self.voxel_grid_res = voxel_grid_res
        self.voxel_scale = 2 * self.init_radius # eqivalent of tet_scale in DMTet

        # create the non-deformed voxel grid whose positions will be used to sample for FlexiCubes
        self.x_nx3, self.cube_fx8 = self.flexicubes.construct_voxel_grid(voxel_grid_res)
        self.x_nx3 *= self.voxel_scale # scale up the grid so that it's larger than the target object

        # init mesh-specific weights for Flexicubes - but separate (i.e. betas, alphas, gammas) for better unserstanding
        self.betas = torch.zeros((self.cube_fx8.shape[0], 12), dtype=torch.float, device=device)
        self.betas = torch.nn.Parameter(self.betas.clone().detach(), requires_grad=True)

        self.alphas = torch.zeros((self.cube_fx8.shape[0], 8), dtype=torch.float, device=device)
        self.alphas = torch.nn.Parameter(self.alphas.clone().detach(), requires_grad=True)

        self.gammas = torch.zeros((self.cube_fx8.shape[0], 1), dtype=torch.float, device=device)
        self.gammas = torch.nn.Parameter(self.gammas.clone().detach(), requires_grad=True)

        self.deform = torch.nn.Parameter(torch.zeros_like(self.x_nx3), requires_grad=True)

        self.update_flexicubes(device=device, dtype=dtype, require_grad=False)

    def set_verts_requires_grad(self, verts_requires_grad):
        ## Do we need this? I assume we need at least something like this, so this should be taken as reminder TODO
        self.verts_requires_grad = verts_requires_grad
        for param in self.sdf_coordmlps.parameters():
            param.requires_grad = verts_requires_grad

    def create_new_flexicubes(self, device):
        from kaolin.non_commercial import FlexiCubes
        self.flexicubes = FlexiCubes(device=device)

    def to(self, *args, **kwargs):
        super().to(*args, **kwargs)

        # These should be set, since they are torch Parameters / ModuleLists:
        # self.alphas = self.alphas.to(*args, **kwargs)
        # self.betas = self.betas.to(*args, **kwargs)
        # self.gammas = self.gammas.to(*args, **kwargs)
        # self.feat_coordmlps = self.feat_coordmlps.to(*args, **kwargs)
        # self.sdf_coordmlps = self.sdf_coordmlps.to(*args, **kwargs)

        self.x_nx3 = self.x_nx3.to(*args, **kwargs)
        self.cube_fx8 = self.cube_fx8.to(*args, **kwargs)

        # Since self.device is set in Meshes.to(), we can use its value here
        self.create_new_flexicubes(device=self.device)

    def cuda(self, *args, **kwargs):
        super().cuda(*args, **kwargs)

        # These should be set, since they are torch Parameters / ModuleLists:
        # self.alphas = self.alphas.cuda(*args, **kwargs)
        # self.betas = self.betas.cuda(*args, **kwargs)
        # self.gammas = self.gammas.cuda(*args, **kwargs)
        # self.feat_coordmlps = self.feat_coordmlps.cuda(*args, **kwargs)
        # self.sdf_coordmlps = self.sdf_coordmlps.cuda(*args, **kwargs)

        self.x_nx3 = self.x_nx3.cuda(*args, **kwargs)
        self.cube_fx8 = self.cube_fx8.cuda(*args, **kwargs)

        # Since self.device is set in Meshes.cuda(), we can use its value here
        self.create_new_flexicubes(device=self.device)

    def eval(self, *args, **kwargs):
        super().eval(*args, **kwargs)
        self.update_verts(require_grad=False)

    def update_verts(self, require_grad=True):
        self.update_flexicubes(require_grad=require_grad)  # similar in dmtet_x_gaussians.py

    def update_flexicubes(
        self,
        device=None,
        dtype=None,
        require_grad=None,
        require_feats_grad=None,
        require_weights_grad=None,
    ):
        # This part of the code is heavily inspired by the update_dmtet() function in DMTet_x_Gausians 
        if require_grad is None:
            require_grad = self.verts_requires_grad
        if require_feats_grad is None:
            require_feats_grad = require_grad
        if require_weights_grad is None:
            require_weights_grad = require_grad
        
        verts = []
        faces = []
        feats = []
        if device is None:
            device = self.device
        if dtype is None:
            dtype = torch.get_default_dtype()

        # For each object in the scene compute a mesh with features
        for m in range(self.meshes_count):
            if require_grad:
                # Get SDF for current object with the grid points
                sdf = self.get_sdf(self.x_nx3, m)
                grid_verts = self.x_nx3 + (2-1e-8) / (self.voxel_grid_res * 2) * torch.tanh(self.deform)

                # Compute Vertices and Faces using flexicubes
                _verts, _faces, v_reg_loss = self.flexicubes(
                    grid_verts, 
                    sdf.view(-1),
                    self.cube_fx8,
                    self.voxel_grid_res,
                    beta=self.betas,
                    alpha=self.alphas,
                    gamma_f=self.gammas.view(-1),
                    training=True
                )
            else:
                with torch.no_grad():
                    sdf = self.get_sdf(self.x_nx3, m)
                    grid_verts = self.x_nx3 + (2-1e-8) / (self.voxel_grid_res * 2) * torch.tanh(self.deform)

                    _verts, _faces, v_reg_loss = self.flexicubes(
                        grid_verts, 
                        sdf.view(-1),
                        self.cube_fx8,
                        self.voxel_grid_res,
                        beta=self.betas,
                        alpha=self.alphas,
                        gamma_f=self.gammas.view(-1),
                        training=False
                    )

            # Compute Features of _verts points to later compute color and material
            if require_feats_grad:
                _feats = self.get_feats(pts=_verts.detach(), object_id=m)
            else:
                with torch.no_grad():
                    _feats = self.get_feats(pts=_verts.detach(), object_id=m)


            verts.append(_verts)
            faces.append(_faces)
            feats.append(_feats)

        factory_kwargs = {"device": device, "dtype": dtype}

        self.verts_counts = [_verts.shape[0] for _verts in verts]
        self.verts_counts_max = max(self.verts_counts)

        # TODO: What is feat_clutter?
        if not self.feat_clutter_requires_param:
            if require_feats_grad:
                # logger.info(m)
                # logger.info(_verts.shape)
                _feat_clutter = self.get_feats(
                    pts=(torch.ones_like(_verts[0:1])).detach()
                    * (self.voxel_scale / 2.0),
                    object_id=0,
                )[0]
            else:
                with torch.no_grad():
                    _feat_clutter = self.get_feats(
                        pts=(torch.ones_like(_verts[0:1])).detach()
                        * (self.voxel_scale / 2.0),
                        object_id=0,
                    )[0]
            self.feat_clutter = _feat_clutter.to(**factory_kwargs)

        self.verts = torch.cat([_verts for _verts in verts], dim=0).to(**factory_kwargs)
        self.feats_objects = torch.cat([_feats for _feats in feats], dim=0).to(
            **factory_kwargs,
        )
        self.faces = torch.cat([_faces for _faces in faces], dim=0).to(device=device)

        self.faces_counts = [_faces.shape[0] for _faces in faces]
        self.verts_counts_acc_from_0 = [0] + [
            sum(self.verts_counts[: i + 1]) for i in range(self.meshes_count)
        ]
        self.faces_counts_acc_from_0 = [0] + [
            sum(self.faces_counts[: i + 1]) for i in range(self.meshes_count)
        ]

        self.verts_count = self.verts_counts_acc_from_0[-1]
        self.faces_counts_max = max(self.faces_counts)

        self.mask_verts_not_padded = torch.ones(
            size=[len(self), self.verts_counts_max],
            dtype=torch.bool,
            device=device,
        )

        for i in range(len(self)):
            self.mask_verts_not_padded[i, self.verts_counts[i] :] = False

        import matplotlib.pyplot as plt

        color_ = plt.get_cmap("tab20", len(self))
        self.feats_rgb_object_id = []
        for i in range(len(self)):
            self.feats_rgb_object_id.extend([color_(i)] * self.verts_counts[i])

        self.update_verts_coarse()

    def get_sdf(self, pts, object_id):
        """
        Args:
            pts (torch.Tensor): BxNx3
        Returns:
            sdf (torch.Tensor): BxN
        """

        sdf_init = pts.detach().norm(dim=-1, keepdim=True) - self.init_radius
        from od3d.data.batch_datatypes import OD3D_ModelData

        sdf_delta = self.sdf_coordmlps[object_id](
            OD3D_ModelData(pts3d=pts[None,]),
        ).feat[0]
        sdf_vals = sdf_init + sdf_delta
        return sdf_vals

    def get_feats(self, pts, object_id):
        from od3d.data.batch_datatypes import OD3D_ModelData

        feats = self.feat_coordmlps[object_id](OD3D_ModelData(pts3d=pts[None,])).feat[0]
        return feats

    def get_sdf_gradient(self, object_id):
        # TODO: This is only copied code (replaced tet_scale with voxel_scale)!
        num_samples = 5000
        sample_points = (
            torch.rand(num_samples, 3, device=self.verts.device) - 0.5
        ) * self.voxel_scale

        mesh_verts = self.get_verts_with_mesh_id(mesh_id=object_id, clone=True)

        rand_idx = torch.randperm(len(mesh_verts), device=mesh_verts.device)[:5000]
        mesh_verts = mesh_verts[rand_idx]
        sample_points = torch.cat([sample_points, mesh_verts], 0)
        sample_points.requires_grad = True
        y = self.get_sdf(pts=sample_points, object_id=object_id)
        d_output = torch.ones_like(y, requires_grad=False, device=y.device)
        try:
            gradients = torch.autograd.grad(
                outputs=[y],
                inputs=sample_points,
                grad_outputs=d_output,
                create_graph=True,
                retain_graph=True,
                only_inputs=True,
            )[0]
        except RuntimeError:  # For validation, we have disabled gradient calculation.
            return torch.zeros_like(sample_points)
        return gradients