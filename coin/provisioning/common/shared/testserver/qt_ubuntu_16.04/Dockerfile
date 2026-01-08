FROM ubuntu:16.04
ARG COIN_RUNS_IN_QT_COMPANY
RUN test x"$COIN_RUNS_IN_QT_COMPANY" = xtrue \
  && { printf '%s\n' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 xenial-amd64 main restricted universe multiverse' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 xenial-updates-amd64 main restricted universe multiverse' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 xenial-backports-amd64 main restricted universe' \
  'deb [arch=amd64 trusted=yes] http://repo-clones-apt.ci.qt.io:8080 xenial-security-amd64 main restricted universe multiverse' \
> /etc/apt/sources.list; \
  } \
