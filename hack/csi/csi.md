# CSI

- Many of the drivers on the SIG listing page are abandoned.
- I don't want to lose the node-local SSD performance.
- The bare SPDK-CSI is incredibly rough.
- SPDK seems to want dedicated cores, no matter if in polling or interrupt mode.
  The overhead of this is 1-2 cores per-engine, which _may_ be one-to-one with PVs.
  Either way this is unacceptable overhead for these scrawny machines.
- Longhorn v2 deprecates strict data locality, and moves to SPDK for the engine, which demands 1 core.
- OpenEBS does NVME-oF/TCP but wants 2 cores.
- NVMe-oF/TCP looks good, but
  A) I can't see anything talking about it over 1GbE
  B) It seems to be more a target of SPDK, which is out.
  C) I'm not sure it comes with any distribution out the box, that seems to need indirection in the data path or replication in the storage engine.
  I think it's great if we had a SAN or something, but I don't.
- It may be possible to set up some underpinning disk replication and build atop that, but I don't like our odds.
- Ideally we want eager caching or pre-warmed nodes, with streaming replication back to the distributed store.
- Looks like block-level exposure allows differential/incremental backup, which is efficient.
  File-level exposure maps nicely to object storage, but I don't think you can "patch" S3 files the same way.
- `ReadWriteMany` type volumes seem uncommon, we can ignore them for now.
  I think most application developers have recognized it's better leave that to ValKey/S3 etc.

## Shortlist

- [JuiceFS](https://juicefs.com/)
- [SeaweedFS](https://seaweedfs.com/)
- [AWS mountpoint S3 driver](https://github.com/awslabs/mountpoint-s3-csi-driver),
  possibly with [local CSI driver](https://github.com/Azure/local-csi-driver)
  providing the caching volumes.

## References

- [NVMe-oF/TCP tuning blog](https://khimananda.com/blog/nvme-over-tcp-basics)
- [SPDK interrupt/poll mode](https://spdk.io/doc/interrupt_mode.html)
