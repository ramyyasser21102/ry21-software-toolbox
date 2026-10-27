# Fetch from upstream, never mirror

The toolbox never stores third-party binaries. Each software entry is downloaded on demand from its upstream source, and the download is refused unless the published checksum (where one exists) and the Authenticode signer both verify. Mirroring was rejected because it risks breaking redistribution licenses, bloats the repo, and goes stale, which defeats the point of staying up to date.
