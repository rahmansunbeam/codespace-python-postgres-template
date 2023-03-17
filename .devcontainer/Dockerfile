ARG VARIANT=22.04
FROM ubuntu:${VARIANT}

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG POSTGRES_USER=pguser
ARG POSTGRES_PASSWORD=pgpass
ARG POSTGRES_DB=pgdb

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
   && apt-get install -y --no-install-recommends ca-certificates sudo gcc make gnupg curl git bash \
   wget build-essential libc-dev libssl-dev libpq-dev libsqlite3-dev nodejs \
   python3 python3-pip python3-dev python3-setuptools python3-wheel \
   postgresql postgresql-contrib \
   && rm -rf /var/lib/apt/lists/*

# Install Rust (with alternate channel if one fails), Jupyterlab and postgresql data
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
   && pip3 --disable-pip-version-check --no-cache-dir install jupyterlab \
   && mkdir /var/lib/postgresql/data
   
# Install additional Python libraries from requirements.txt
COPY .devcontainer/requirements.txt /tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/requirements.txt && rm /tmp/requirements.txt

# Create the PostgreSQL configuration file in the container
RUN echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf \
   && echo "max_connections = 100" >> /etc/postgresql/14/main/postgresql.conf \
   && echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/14/main/pg_hba.conf \
   && service postgresql start \
   && sudo -u postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';" \
   && sudo -u postgres createdb -O $POSTGRES_USER $POSTGRES_DB \
   && service postgresql stop

# Expose the PostgreSQL port
# EXPOSE 5432

# Set up the environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Set environment variables for NVIDIA GPU access
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# add cargo/bin to path
ENV PATH="/root/.cargo/bin:${PATH}"

# Switch to non-root user
RUN groupadd --gid $USER_GID $USERNAME \
   && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
   && mkdir -p /etc/sudoers.d/ \
   && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
   && chmod 0440 /etc/sudoers.d/$USERNAME \
   && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY .devcontainer/jupyter_config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/jupyter_config.sh \
    && /usr/local/bin/jupyter_config.sh \
    && rm /usr/local/bin/jupyter_config.sh
