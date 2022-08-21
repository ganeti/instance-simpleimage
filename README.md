# instance-simpleimage

## Design Guidelines

This OS provider should provide users with an easy way of creating Ganeti Instances from simple blockdevice images using the [Ganeti OS Interface](https://docs.ganeti.org/docs/ganeti/3.0/html/man-ganeti-os-interface.html?highlight=interface).

### Image Sources and Formats

Images should be accessible through a local filesystem path or can be retrieved from HTTP(S) URLs. An OS image is considered to be a bitwise replication of a blockdevice and may contain a partition table with filesystems or just one single filesystem.

The OS provider does not make any assumptions about the content of the image nor does it alter it in any way. 

### Variants

The variants can be used to distinguish the type of image used. This way Ganeti users will be able to derive the type of image used directly from instance details.

### Variant Parameters

* `IMG_SOURCE`: URL to the disk image. Supported schemes will be: `file://`, `http://`, `https://`
* `PROXY`: URL to HTTP(S) proxy. Will be used both for HTTP and HTTPS connections if set

### OS Parameters

No further parameters are required.

### Hooks

The OS provider may implement a hook system which lets users add additional steps to the provisioning process. Hooks may be executed _before_ the image is downloaded/opened or _after_ it has been written to the blockdevice. The documentation should make clear that this should not be used for advanced image/data manipulation. Instead, a different OS provider should be implemented/used. A hook could be any executable file.

### Programming Language

This provider should make use of technologies available on a basic Ganeti node. This would include both Bash and basic Python 3 (e.g. only using the standard library and no external modules).
