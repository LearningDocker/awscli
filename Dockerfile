FROM debian:jessie

MAINTAINER Jimmy Y. Huang <jimmy.huang@duragility.com>

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

ENV PYTHON_VERSION 2.7.8

RUN set -x \
  && installedPackages='bind9-host ca-certificates groff jq less libssl1.0.0 openssh-client' \
  && buildDeps='curl gcc libc6-dev libsqlite3-dev libssl-dev make xz-utils zlib1g-dev' \
  && packages="$installedPackages $buildDeps" \
  && apt-get update && apt-get install -y $packages --no-install-recommends \
  && mkdir -p /usr/src/python \
  && curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" \
  | tar -xJC /usr/src/python --strip-components=1 \
  && cd /usr/src/python \
  && ./configure --enable-shared \
  && make -j$(nproc) \
  && make install \
  && ldconfig \
  && curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python2 \
  && find /usr/local \
    \( -type d -a -name test -o -name tests \) \
    -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    -exec rm -rf '{}' + \
  && pip install awscli \
  && echo 'complete -C /usr/local/bin/aws_completer aws' >> "$HOME/.bashrc" \
  && mkdir -p /root/.ssh \
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf /usr/src/python \
  && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]