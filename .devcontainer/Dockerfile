FROM ubuntu:22.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG POSTGRES_USER=pguser
ARG POSTGRES_PASSWORD=pgpass
ARG POSTGRES_DB=pgdb

# Set up the environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Set environment variables for NVIDIA GPU access
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# add basic libraries, Python3, PostgreSQL and other dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
   && apt-get install -y --no-install-recommends ca-certificates sudo gcc make gnupg curl git bash vim \
   wget build-essential libc-dev libssl-dev libpq-dev libsqlite3-dev nodejs \
   postgresql postgresql-contrib \
   && mkdir /var/lib/postgresql/data \
   && rm -rf /var/lib/apt/lists/*

# Switch to non-root user
RUN groupadd --gid $USER_GID $USERNAME \
   && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
   && mkdir -p /etc/sudoers.d/ \
   && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
   && chmod 0440 /etc/sudoers.d/$USERNAME

# Create the PostgreSQL configuration file in the container
RUN echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf \
   && echo "max_connections = 100" >> /etc/postgresql/14/main/postgresql.conf \
   && echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/14/main/pg_hba.conf \
   && service postgresql start \
   && su postgres -c "psql -c \"CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';\"" \
   && su postgres -c "createdb -O $POSTGRES_USER $POSTGRES_DB" \
   && service postgresql stop

# Expose the PostgreSQL port
EXPOSE 5432

USER $USERNAME
WORKDIR $HOME

COPY .devcontainer/requirements.txt /tmp/

# Install Miniconda and Python libraries from requirements.txt
RUN curl -sSL https://repo.anaconda.com/miniconda/Miniconda3-py310_23.1.0-1-Linux-x86_64.sh -o /tmp/miniconda.sh \
   && bash /tmp/miniconda.sh -b -p $HOME/miniconda \
   && rm /tmp/miniconda.sh \
   && $HOME/miniconda/bin/pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/requirements.txt \
   && sudo rm -rf /tmp/* && $HOME/miniconda/bin/conda clean --all -y \
   && $HOME/miniconda/bin/jupyter notebook --generate-config \
   && echo "c.NotebookApp.allow_origin = '*'" >> ~/.jupyter/jupyter_notebook_config.py \
   && echo "PATH=~/miniconda/bin:$PATH" >> ~/.bashrc
   
# Rust installation
RUN mkdir -p $HOME/.cargo \
   && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
   && $HOME/.cargo/bin/rustup update \
   && $HOME/.cargo/bin/rustup default stable \
   && $HOME/.cargo/bin/rustup component add rust-analysis rust-src \
   && echo "source $HOME/.cargo/env" >> $HOME/.bashrc \
   && sudo apt-get autoremove -y && sudo apt-get clean -y && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add cargo/bin to path
ENV PATH="${HOME}/.cargo/bin:${PATH}"
