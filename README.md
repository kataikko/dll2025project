# dll2025project
Project directory for the Deep Learning Lab

This project's codebase came from [Common3d](https://github.com/GenIntel/common3d), which was further modified by us.

## Pixi

!! Usage only on cluster !!

### Cluster

To enter the environment for use on the cluster, use:
```
pixi shell -e cluster
```
This builds the environment in this directory under `.pixi`.

This is the command I found most useful (excluding 04 because of missing CUDA; excluding 07 because of missing GPU)
```
srun --nodes=1 --ntasks=1 --ntasks-per-node=1 --cpus-per-task=8 --gpus-per-task=1 -t 180 -p dllabdlc_gpu-rtx2080 --exclude=dlcgpu[04,07] --pty /bin/bash
```

You can run the Benchmark CO3D with:
```
sbatch --nodes=1 --ntasks=1 --ntasks-per-node=1 --cpus-per-task=8 --gpus-per-task=1 -t 24:00:00 -p dllabdlc_gpu-rtx2080 --exclude=dlcgpu[04,07] ./co3d.sh
```

