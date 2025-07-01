# dll2025project
Project directory for the Deep Learning Lab

## Pixi

!! Usage only on cluster !!

### Cluster

To enter the environment for use on the cluster, use:
```
pixi shell -e cluster
```
This builds the environment in this directory under `.pixi`.
For now, this environment only includes `zellij` from which you can use `srun` for an interactive shell.
Then, you can enter the `cuda` environment.

This is the command I found most useful
```
srun --nodes=1 --ntasks=1 --ntasks-per-node=1 --cpus-per-task=8 --gpus-per-task=1 -t 60 -p dllabdlc_gpu-rtx2080 --pty /bin/bash
```
