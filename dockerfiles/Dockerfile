FROM python:3.9.16

# Allow environment variables to be passed as build time arguments
ARG FREQUENCY=50

# This GID should be the same as the group_id of the Node_Exporter group. This will allow this docker to write to the node_exporter textfile folder.
#  As this is an ARG, you can override it from the build command with the correct value
ARG GID=997

# Set environment variables to build arguments
ENV FREQUENCY=$FREQUENCY

# Create the group and a fc user to run as - so we don't have to run as root.
RUN groupadd -g ${GID} -r fc; \
    useradd -r -g fc fc;

# Copy lotus-farcaster program and shell script that invokes it to the container
COPY lotus-exporter-farcaster/lotus-exporter-farcaster.py /usr/local/bin/
COPY dockerfiles/docker_run_script.sh /usr/local/bin/

## We don't want to copy here else we need to rebuild for each miner.  Rather volume mount it
#COPY lotus-exporter-farcaster/config.toml ~/.lotus-exporter-farcaster/
#COPY lotus-exporter-farcaster/addresses.toml ~/.lotus-exporter-farcaster/

# Create /data which will hold the output of the lotus-farcaster and
#  create /etc/farcaster that will be volume mounted to the outside world for access to config.toml and addresses.toml.  << this makes this build image re-usable without have to build again for a new config each time.
RUN mkdir -p /data; \
    mkdir -p /etc/farcaster; \
    chown -R fc:fc /data;

# Map volume mount like  /seal/ssd-000/calibnet/farcaster:/etc/farcaster    and   /var/lib/node_exporter:/data
VOLUME /data
VOLUME /etc/farcaster

# Allow scripts to be run
RUN chmod 0775 /usr/local/bin/lotus-exporter-farcaster.py
RUN chmod 0775 /usr/local/bin/docker_run_script.sh

# Make a link from python3.9 to python3
RUN rm -f /usr/bin/python3
RUN ln -sv /usr/local/bin/python3.9 /usr/bin/python3


# Add the lib of python
RUN python3 -m pip install aiohttp toml py-multibase gql

# Run the container on an unprivileged user XXX not implemented yet // need rights to store files to prometheus folder
#RUN useradd -r -u 424242 -U farcaster
#USER farcaster

# Run the container on an unprivileded user. This users's group_id allows storing files to prometheus folder.
USER fc

ENTRYPOINT ["/usr/local/bin/docker_run_script.sh"]
