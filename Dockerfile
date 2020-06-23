# Start from python container
FROM python:3.8.2

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Non-root user with sudo access
ARG USERNAME=default
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Gem5
ARG GEM_REPO=https://github.com/NicolasDenoyelle/gem5.git
ARG GEM_BRANCH=numa
ARG GEM_ISA=X86

# Configure apt
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Install apt deps
    && apt-get -y install \
    sudo \
    git \
    iproute2 \
    procps \
    lsb-release \
    build-essential \
    m4 \
    scons \
    zlib1g \
    zlib1g-dev \
    libprotobuf-dev \
    python-six \
    protobuf-compiler \
    libprotoc-dev \
    libgoogle-perftools-dev \
    python-dev \
    libboost-all-dev \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    #
    # Install pip deps
    && pip --disable-pip-version-check --no-cache-dir install \
    pylint \
    autopep8 \
    #
    # Create a non-root user to use if preferred
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Build gem5
    && git clone --single-branch --branch $GEM_BRANCH $GEM_REPO \
    && cd gem5 && scons -j$(nproc) build/${GEM_ISA}/gem5.opt \
    && mv build/${GEM_ISA}/gem5.opt /usr/local/bin \
    && cd .. && rm -rf gem5

# Copy code in the container
COPY ./ /home/$USERNAME/gem5-sandbox/
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/gem5-sandbox/

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# Set working directory
WORKDIR /home/$USERNAME/gem5-sandbox/