FROM alpine:latest AS toolchains
RUN --mount=type=cache,target=/var/cache/apk \
    apk add bash curl patchelf wget xz

RUN --mount=type=tmpfs,target=/tmp \
    --mount=type=bind,source=toolchains,target=/tmp/toolchains \
    bash /tmp/toolchains/setup.sh



FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/lib/apt \
    apt-get update

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y sudo

COPY sudoers /etc/sudoers.d/default

RUN useradd -ms /bin/bash build
RUN usermod -aG sudo build

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y make

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y gcc gcc-multilib

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y autoconf automake autopoint bison gettext binutils flex pkg-config

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y git rsync

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y patch

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y libdevmapper-dev python-is-python3

RUN --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/var/lib/apt \
    apt-get install -y acpica-tools nasm g++ uuid-dev

COPY --link --from=toolchains \
    /opt/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu /opt/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu
COPY --link --from=toolchains \
    /opt/mips-loongson-gcc7.3-2019.06-29-linux-gnu /opt/mips-loongson-gcc7.3-2019.06-29-linux-gnu

ENV AARCH64_TOOLCHAIN="/opt/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu"
ENV MIPS64EL_TOOLCHAIN="/opt/mips-loongson-gcc7.3-2019.06-29-linux-gnu"

ENV PATH="${PATH}:${AARCH64_TOOLCHAIN}/bin:${MIPS64EL_TOOLCHAIN}/bin"

RUN echo '\n\
# SHELL EXTENSIONS IN /etc/bashrc.d\n\
for file in /etc/bashrc.d/*.sh; do\n\
    . "$file"\n\
done\n\
' >> /etc/bash.bashrc

COPY bashrc.d /etc/bashrc.d

USER build

WORKDIR /build

CMD [ "bash", "/build/scripts/from_docker.sh" ]
