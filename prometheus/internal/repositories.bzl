load("@io_bazel_rules_prometheus//prometheus/internal:defaults.bzl", "DEFAULT_PROMETHEUS_PACKAGE_INFO")
load("@io_bazel_rules_prometheus//prometheus/internal:providers.bzl", "HttpArchiveInfo")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

_PROMETHEUS_BUILD_FILE_CONTENT = """
exports_files([
    "prometheus",
    "promtool",
])
"""

_ALERTMANAGER_BUILD_FILE_CONTENT = """
exports_files([
    "alertmanager",
    "amtool",
])
"""

HTTP_ARCHIVE_EXTENSION = "tar.gz"

def _http_archive_provider_factory(
        binary,
        os,
        cpu,
        version,
        sha256,
        build_file_content,
        archive_extension = HTTP_ARCHIVE_EXTENSION):
    return HttpArchiveInfo(
        name = "{binary}_{os}-{cpu}".format(
            binary = binary,
            os = os,
            cpu = cpu,
        ),
        sha256 = sha256,
        version = version,
        urls = [(
            "https://github.com/prometheus/{binary}/releases/download/".format(
                binary = binary,
            ) +
            "v{version}/{binary}-{version}.{os}-{cpu}.{archive_extension}".format(
                version = version,
                os = os,
                cpu = cpu,
                binary = binary,
                archive_extension = archive_extension,
            )
        )],
        strip_prefix = "{binary}-{version}.{os}-{cpu}".format(
            version = version,
            os = os,
            cpu = cpu,
            binary = binary,
        ),
        build_file_content = build_file_content,
    )

def _http_archive_factory(ctx):
    """build http_archive objects from context"""
    return http_archive(
        name = ctx.name,
        sha256 = ctx.sha256,
        urls = ctx.urls,
        strip_prefix = ctx.strip_prefix,
        build_file_content = ctx.build_file_content,
    )

def _build_http_archives(
        prometheus_package_info,
        http_archive_info = _http_archive_provider_factory,
        http_archive_factory = _http_archive_factory,
        prometheus_build_file_content = _PROMETHEUS_BUILD_FILE_CONTENT,
        alertmanager_build_file_content = _ALERTMANAGER_BUILD_FILE_CONTENT):
    """Factory will build a set of http_archive objects for bazel's toolchain consumption

    Args:
        prometheus_package_info: prometheus package metadata provider
        http_archive_info: factory function which builds HttpArchiveInfo objects
        http_archive_factory: factory function which builds http_archive bazel rules
        prometheus_build_file_content: BUILD file content for resulting bazel repository
        alertmanager_build_file_content: BUILD file content for resulting bazel repository
    """

    for platform in prometheus_package_info.platforms_info.available_platforms:
        http_archive_factory(http_archive_info(
            binary = "prometheus",
            os = getattr(prometheus_package_info.platforms_info.platforms, platform).os,
            cpu = getattr(prometheus_package_info.platforms_info.platforms, platform).cpu,
            version = prometheus_package_info.prometheus_binary_info.version,
            build_file_content = prometheus_build_file_content,
            sha256 = prometheus_package_info.prometheus_binary_info.available_binaries[(
                prometheus_package_info.prometheus_binary_info.version,
                platform,
            )],
        ))
        http_archive_factory(http_archive_info(
            binary = "alertmanager",
            os = getattr(prometheus_package_info.platforms_info.platforms, platform).os,
            cpu = getattr(prometheus_package_info.platforms_info.platforms, platform).cpu,
            version = prometheus_package_info.alertmanager_binary_info.version,
            build_file_content = alertmanager_build_file_content,
            sha256 = prometheus_package_info.alertmanager_binary_info.available_binaries[(
                prometheus_package_info.alertmanager_binary_info.version,
                platform,
            )],
        ))

def _prometheus_repositories_impl(
        http_archives_factory = _build_http_archives,
        _prometheus_package_info = DEFAULT_PROMETHEUS_PACKAGE_INFO):
    """prometheus_repositories main implementation function

    Args:
        http_archives_factory: http_archive(s) factory function
        _prometheus_package_info: pre-built PrometheusPackageInfo provider with info all available os+architectures,
                                  expected versions and available binaries of prometheus and alertmanager
    """

    """Consumers should call this function to download dependencies for rules to work"""

    # maybe = don't download if already present
    # https://docs.bazel.build/versions/main/repo/utils.html#maybe
    # so dependencies are overridable

    maybe(
        http_archive,
        name = "platforms",
        sha256 = "079945598e4b6cc075846f7fd6a9d0857c33a7afc0de868c2ccb96405225135d",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
    )

    http_archives_factory(
        prometheus_package_info = _prometheus_package_info,
    )

def prometheus_repositories():
    """Download dependency tools and initialize toolchains

    Args:
        prometheus_version: Prometheus package version to download from source repositories if supported by reposiory
        alertmanager_version: Alertmanager package version to download from source repositories if supported by reposiory
    """

    # TODO(5h4d0w4rt) add custom version support
    _prometheus_repositories_impl()
