# instance-simpleimage

This OS provider allows users to easily create Ganeti Instances from simple blockdevice images using the [Ganeti OS Interface](https://docs.ganeti.org/docs/ganeti/3.0/html/man-ganeti-os-interface.html).

**instance-simpleimage is early alpha-stage code and has not seen a release yet. It is not yet meant for production use!**

## Image Sources and Formats

Images need to be accessible through a local filesystem path or can be retrieved from HTTP(S) URLs. An OS image is considered to be a bitwise replication of a blockdevice and may contain a partition table with filesystems or just one single filesystem. The OS provider also supports qcow2 images but requires `qemu-img` to be present on the system.

The OS provider does not make any assumptions about the content of the image nor does it alter it in any way (but the latter _can_ be achieved using custom hook scripts).

## Variants

This OS provider uses variants to offer different configurations. The actual image source and image type will be defined through OS parameters with each instance. 

## Variant Parameters

You can overwrite any of the following settings in the config file `/etc/ganeti/instance-simpleimage/$variant/config` per variant:

* `PROXY`: URL to HTTP(S) proxy. Will be used both for HTTP and HTTPS connections if set - default: no proxy used
* `CUSTOM_CURL_OPTS`: Extend curl commandline with custom parameters (e.g. `-k` to ignore TLS certificate errors) - default: no extra options passed
* `IMAGE_STORAGE`: Where to store downloaded images - default: /tmp/ganeti-instance-simpleimage
* `DOWNLOAD_CACHE_MAX_DAYS`: Images will be cached for the specified amount of days, after that they will be discarded and downloaded again - default: 7 days

## OS Parameters

* `image`: This can either be a locally accessible path or an HTTP(s) URL starting with `http://` or `https://`
* `image_type`: Indicates the type of image. Currently supported image types are:
 * `raw`: a bitwise replication of a blockdevice
 * `raw+bzip2`, `raw+gz`, `raw+xz`: a bitwise replication of a blockdevice but compressed with bzip2/gz/xz
 * `qcow2`: a qcow2-type image (requires `qemu-img` to be present)

## Hooks

Each variant does have its own hooks folder (`/etc/ganeti/instance-simpleimage/$VARIANT/hooks`). Hooks can be any executable file and should follow the conventions of the `run-parts`(8) command to be executed. Hooks will be run _after_ the image has been written to the disk. All os provider parameters will be visible to the hooks as environmennt variables (e.g. `DISK_X_*`, `DISK_COUNT`, `NIC_X_*`, `NIC_COUNT`, `INSTANCE_HV_*`, `OSP_*`) and can be looked up in the OS provider interface documentation. Additionaly, the variable `TARGET_DISK_DEVICE` will always contain a blockdevice reference to the first instance disk. If the storage is file based, this will contain a `/dev/loopX` device, already set up by the OS provider. You do not need to take care of that in your hook. Please take a look at the `example-hooks` folder to find usable boilerplate code or inspiration for custom hooks.

## Installation

This OS provider is in an early stage and has not seen an official release yet. If you want to give it a try, follow these steps:

```shell
cd /usr/share/ganeti/os
git clone git@github.com:ganeti/instance-simpleimage simpleimage
mkdir -p /etc/ganeti/instance-simpleimage/default/hooks
touch /etc/ganeti/instance-simpleimage/default/config
```

If you want to add more variants, edit `/usr/share/ganeti/os/simpleimage/variants.list` and create the required folder and (empty) config file in `/etc/ganeti/instance-simpleimage/$variant`. You may add any configuration directive from the above documentation to the `config` file. You may also add as many hook scripts to the hook folder as you wish.

## Usage

**Use the official Debian "nocloud" image**:
```shell
gnt-instance add -t plain --disk=0:size=4g \
                 -B minmem=1G,maxmem=1G,vcpus=2 \
                 -o simpleimage+default \
                 -O image=https://cloud.debian.org/images/cloud/bullseye/daily/latest/debian-11-nocloud-amd64-daily.raw,image_type=raw \
                 debian-nocloud.example.org
```

**Use a local image, compressed with xz**:
```shell
gnt-instance add -t plain --disk=0:size=4g \
                 -B minmem=1G,maxmem=1G,vcpus=2 \
                 -o simpleimage+default \
                 -O image=/data/images/linux.img.xz,image_type=raw+xz \
                 machine.example.org
```

**Use a qcow2 image**:
```shell
gnt-instance add -t plain --disk=0:size=4g \
                 -B minmem=1G,maxmem=1G,vcpus=2 \
                 -o simpleimage+default \
                 -O image=https://cloud.debian.org/images/cloud/bullseye/daily/latest/debian-11-genericcloud-amd64-daily.qcow2,image_type=qcow2 \
                 debian-genericcloud.example.org
```