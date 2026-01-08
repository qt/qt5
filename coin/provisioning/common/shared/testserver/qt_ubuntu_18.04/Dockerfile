FROM ubuntu:18.04
ARG COIN_RUNS_IN_QT_COMPANY
RUN test x"$COIN_RUNS_IN_QT_COMPANY" = xtrue \
  && { printf '%s\n' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 bionic-amd64 main restricted universe multiverse' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 bionic-updates-amd64 main restricted universe multiverse' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 bionic-backports-amd64 main restricted universe' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 bionic-security-amd64 main restricted universe multiverse' \
> /etc/apt/sources.list; \
  } \
