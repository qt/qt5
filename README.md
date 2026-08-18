# Qt 6

This repository, `qt5.git`, is the Qt super-repository. It records a git
submodule pointer to each Qt module repository, such as `qtbase` and
`qtdeclarative`, along with the build system, the `configure` scripts, and the
continuous integration configuration that build those modules as a single tree.

Each submodule points at a specific revision. The combination of revisions that
a branch records is a snapshot that has passed Qt's continuous integration.
Clone this repository first and let it select the module revisions for you. If
you move a submodule to a different revision, you are building a combination
that nobody has tested.

> Despite the name `qt5.git`, the `dev` and `6.x` branches contain Qt 6.

To use Qt rather than build it from sources, see
[Get and Install Qt](https://doc.qt.io/qt-6/get-and-install-qt.html).

## Repository layout

Each Qt module lives in its own directory, such as `qtbase` or
`qtdeclarative`. Those directories are git submodules.

The other top-level entries are:

| Entry | Purpose |
| ----- | ------- |
|`.gitmodules`| Lists modules for the current branch.|
| `CMakeLists.txt` | Entry point for the top-level build of all modules. |
| `configure`, `configure.bat` | Wrappers that configure that build. |
| `init-repository` | Checks out the submodules. Git clones only. |
| `cmake/` | CMake modules shared by the top-level build. |
| `coin/` | Continuous integration configuration and provisioning. |
| `LICENSES/`, `REUSE.toml` | License texts and per-file licensing metadata. |

## Get the sources

For instructions, see [Getting Qt Sources from the Git repository](https://doc.qt.io/qt-6/getting-sources-from-git.html).

## Build Qt

For instructions, see [Build from sources](https://doc.qt.io/qt-6/build-sources.html).

## Documentation

The [Qt 6 documentation](https://doc.qt.io/qt-6/index.html) covers the
framework itself.

## Report an issue

Report bugs at [bugreports.qt.io](https://bugreports.qt.io/), following
[these steps](https://doc.qt.io/qt-6/bughowto.html).

## Security

To report a security vulnerability in Qt, and to read what the Qt Project
commits to in response, see [SECURITY.md](SECURITY.md).

## Contribute to Qt

The Qt Project does not accept pull requests on GitHub. Every contribution goes
through [Gerrit](https://codereview.qt-project.org), so read
[how to contribute](CONTRIBUTING.md) before you push a change. All
participation in the project is subject to our
[code of conduct](CODE_OF_CONDUCT.md). To learn who decides what, and how
someone becomes an approver or a maintainer, see
[how the project is governed](GOVERNANCE.md).
Development discussions happens in the open on the
[Qt Project mailing lists](https://lists.qt-project.org/).

## License

Qt is available under both commercial and open source licenses, and the terms
depend on the module you use. [LICENSE](LICENSE) explains how licensing is
declared across the Qt repositories and where to find the terms that apply to
a given module.

For the full picture, see the
[Qt licensing overview](https://doc.qt.io/qt-6/licensing.html) and
[qt.io/licensing](https://www.qt.io/licensing/).
