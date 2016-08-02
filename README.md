**Application**

[Squid](http://www.squid-cache.org/)

**Description**

Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, and more. It reduces bandwidth and improves response times by caching and reusing frequently-requested web pages. Squid has extensive access controls and makes a great server accelerator. It runs on most available operating systems, including Windows and is licensed under the GNU GPL.

**Build notes**

Latest stable Squid release from Arch Linux repo.

**Usage**
```
docker run -d \
    -p <access port>:3128 \
    --name=<container name> \
    -v <path for cache files>:/cache \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    -e PIPEWORK_WAIT=yes \ # <-- optional
    jdelkins/arch-squid
```
Please replace all user variables in the above command defined by <> with the correct values.
If you set the environment variable `PIPEWORK_WAIT`, then the container's
startup script will wait for the network interface eth1 to come up. This is
useful in cases where the container is run with an IP on the LAN. Due to
limitations imposed currently by Docker, the container needs to be configured
with `--net=none` and then have the interface configured using netns. The
[pipework](https://github.com/jpetazzo/pipework) script handles this nicely.

**Access application**<br>

There squid has no gui configuration, edit the configuraiton by hand and then
point your web browser to use the cache. On Linux, you might do that by setting
the environment variable `http_proxy`, e.g. `export http_proxy=http://<host ip>:3128`

Note that the squid disk cache will need to be initialized (if used). To do
that, remove the file `REMOVE_TO_INITIALIZE_SWAP`, located in the config
directory after the first run, then restart the container.

**Example**
```
docker run -d \
    -p 3128:3128 \
    --name=squid \
    -v /srv/squid/cache:/cache \
    -v /srv/squid/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e PUID=0 \
    -e PGID=0 \
    jdelkins/arch-squid
```

**Notes**<br>

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:-

```
id <username>
```

