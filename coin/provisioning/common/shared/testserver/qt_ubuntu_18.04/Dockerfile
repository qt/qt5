FROM ubuntu:18.04
ARG COIN_RUNS_IN_QT_COMPANY
RUN  test x"$COIN_RUNS_IN_QT_COMPANY" = xtrue  \
  && sed -i 's;\(archive\|security\)\.ubuntu\.com;repo-clones.ci.qt.io/apt-mirror/mirror;' /etc/apt/sources.list \
  || echo "Internal package repository not found. Using public repositories."
