# P4PROXY-DOCKER
[![](https://images.microbadger.com/badges/image/dbhagen/p4proxy-docker.svg)](https://microbadger.com/images/dbhagen/p4proxy-docker "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/dbhagen/p4proxy-docker.svg)](https://microbadger.com/images/dbhagen/p4proxy-docker "Get your own version badge on microbadger.com")

## Minimal setup:
The minimal set of environment variables to set are:

`P4PPORT`: the port the proxy should listen on. If you want to host over an SSL connection, this should be prepended with `ssl:`. Examples: `localhost:1666`, `ssl:localhost:1666`, `ssl::1666`

`P4PTARGET`: the Helix Perforce server target the proxy should attached to. If the string begins with `ssl:`, the remote certificate will automatically be added to the `p4trust` file, allowing ssl access. Examples: `myp4.example.com:2666`, `ssl:myp4.example.com:2666`

## Volumes

Ultimately, this container could run without any bound volumes and be purely ephemeral. Traditionally, the intended deployment means keeping the cache and it's database between launches. As such, the following Volume should bind to a persistant volume:

`/p4/cache`: P4 Proxy cache location, example `-v /path/to/local/cache/dir:/p4/cache` <sup> *** Security risk, raw data files will be placed in this location, make sure this is either an encrypted and/or secured data location. *** </sup>

`/p4/logs`: Output logs from the Proxy Service. A new log will be placed in this location every time the service starts. <sup>* Log rotation to be implimented</sup>

`/p4/config`: The location of `.p4trust` and `.p4tickets` (in the case of precaching).

`/p4/ssl`: Location of `certificate.txt` and `privatekey.txt`. If these files do not exist in this location at boot and `ssl:` has been prepended to the `P4PPORT` variable, a self-signed certificate will be generated and stored here.

## Building:

The `package.json` file contains scripts to build and run the docker image during dev.

`yarn build`: Build the container image, tagged as the `package.json` name attribute, with the default of `p4proxy-docker`, and the `package.json` version number. Example: `p4proxy-docker:1.0.0`

`yarn start`: Run the built container image.

`yarn dev`: Run the built container and jump into a `/bin/bash` shell session

You can build and run or debug the container with the combined scripts, `yarn build:start` and `yarn build:dev`

To build a specific version of P4P (the 2020.1 release has only been tested so far), you can run `yarn build --build-arg P4P_VER=r19.2`

## Optional variables:

`P4USER`: Perforce user to be used for pre-caching depots <sup>* To be implimented</sup>

`P4PFSIZE`: Minimum file size eligable for caching. Helpful for only keeping large files in cache. [Doc reference.](https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.proxy.html?Highlight=p4pfsize) Default `P4PFSIZE=0`, example: `P4PFSIZE=1073741824`, files of 10GiB or larger

`P4DEBUG`: Perforce Proxy Debug Log level. Default `P4DEBUG=0`, example: `P4DEBUG=9`

`P4PCOMPRESS`: Default: `P4PCOMPRESS=TRUE`, example `P4PCOMPRESS=FALSE`

Default Environment variables:
```Dockerfile
ARG P4P_VER=r20.1
ENV P4P_VER=${P4P_VER}
    P4USER=p4proxy
    P4PPORT=localhost:1666
    P4PTARGET=localhost:1666
    P4PFSIZE=0
    P4DEBUG=0
    P4PCOMPRESS=TRUE
```