# ICU is already pre-installed on Windows machines, it would be nice to have
# the installation script, but for now let's just export the right variables

# FIXME: do we really want to have it per MSVC version? What about MSVC2015?
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_MSVC2012", "C:\\Utils\\icu_53_1_msvc_2012_64_devel\\icu53_1", "Machine")
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_MSVC2013", "C:\\Utils\\icu_53_1_msvc_2013_64_devel\\icu53_1", "Machine")

# FIXME: do we really want to use the 4.8.2 ICU build?
[Environment]::SetEnvironmentVariable("CI_ICU_PATH_Mingw49", "C:\Utils\icu_53_1_Mingw_builds_4_8_2_posix_seh_64_devel\icu53_1", "Machine")
