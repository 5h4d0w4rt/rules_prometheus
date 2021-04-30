load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":toolchain.bzl", "prometheus_register_toolchains")

_PROMETHEUS_BUILD_FILE_CONTENTS = """
exports_files([
    "prometheus",
    "promtool",
])
"""

_ALERTMANAGER_BUILD_FILE_CONTENTS = """
exports_files([
    "alertmanager",
    "amtool",
])
"""

_ARCH_LIST = (
    "darwin-amd64",
    "dragonfly-amd64",
    "freebsd-386",
    "freebsd-amd64",
    "freebsd-armv6",
    "freebsd-armv7",
    "linux-386",
    "linux-amd64",
    "linux-arm64",
    "linux-armv5",
    "linux-armv6",
    "linux-armv7",
    "linux-mips64",
    "linux-mips64le",
    "linux-ppc64",
    "linux-ppc64le",
    "linux-s390x",
    "netbsd-386",
    "netbsd-amd64",
    "netbsd-armv6",
    "netbsd-armv7",
    "openbsd-386",
    "openbsd-amd64",
    "windows-386",
    "windows-amd64",
)

_PROMETHEUS_VERSION_ARCH_SHA_MAPPING = {
    ("2.26.0", "darwin-amd64"): "2c6eb33d3d02a8f01e16900121e54e67a427ccfb6fa5a9a712771e6b79c2a466",
    ("2.26.0", "darwin-arm64"): "ee492dea2574d66fac741bac11540c488dddb4cbf45a9bc67ef0598099fbc66e",
    ("2.26.0", "dragonfly-amd64"): "07f2a61e44bea85a27b4149edd926a29e0978f2ac29b5c46e7950f836fd9b9f0",
    ("2.26.0", "freebsd-386"): "25c3b064f3145443ec58fd724a6b3fdf2440603df3923c10e767eac00e40f9b1",
    ("2.26.0", "freebsd-amd64"): "352ec23dc32d111f3c4e4b14975290ac575350039687143910743d802ad334fc",
    ("2.26.0", "freebsd-arm64"): "574b7bcbe2a5a9992019a2167b332c14527b74c764f5496840c8318223a8b296",
    ("2.26.0", "freebsd-armv6"): "3f3f21c7060df3fa69e37e74b84db6f426cf1c1ead8706bda461398837b86513",
    ("2.26.0", "freebsd-armv7"): "21e71a81aa660b0198c24915b7d64ba21dc0e15dea864bfd30ba4beac2d80d3e",
    ("2.26.0", "illumos-amd64"): "24e23ce5d7aaa2e1d473ab206c07847e29740ac1de3bb3da797f7fb84583d28a",
    ("2.26.0", "linux-386"): "0c4decd7fd7aa085a01b03c19325b2ec47ee10336d280156ddf311619473d626",
    ("2.26.0", "linux-amd64"): "8dd6786c338dc62728e8891c13b62eda66c7f28a01398869f2b3712895b441b9",
    ("2.26.0", "linux-arm64"): "dff361ce317462bfc4203f53addcb0185223ec633f7c81a27fc118d04f8a9f47",
    ("2.26.0", "linux-armv5"): "5b1789899a3d3202a9f8d36747c13caf561b088667440e90a13962c59852a4e1",
    ("2.26.0", "linux-armv6"): "cb4b0e203ab9f64931d6725bf43211a9e04e8ccec1ff2ae8ec1b7850fc2d744c",
    ("2.26.0", "linux-armv7"): "523eb3dc7805eb023db8cc23faa4b91707d4765ec77158dbd98cf8db1c7d20a7",
    ("2.26.0", "linux-mips"): "0015cecf9d06e6df918ea0f62351477c66d52d1f6b2f164ab48fe81d1dcdd438",
    ("2.26.0", "linux-mips64"): "a6ad4ca7df5a18e7d26d6bbfa8114ac0e1058b19062c8791a499e215f8f1ef91",
    ("2.26.0", "linux-mips64le"): "00cf7c387db0682ce168a6b33d590183fda12d53bafcd3af87aec67ca688abfa",
    ("2.26.0", "linux-mipsle"): "2629121ce0a9ac1da8ee97dce280cf01b80b796c920bf2713f21cba17b15961a",
    ("2.26.0", "linux-ppc64"): "c33171a95bcdf790feaa93248224402b3b94ef1c69ef6d89d42456097528717e",
    ("2.26.0", "linux-ppc64le"): "c4fb66c28100589ad5f7e7bfbfec7da2f7a47e69574bd07e68a00cf28533ac13",
    ("2.26.0", "linux-s390x"): "dc3fce7b8b01e917eb5b3752e909a8c9979c26ccb428b56851e89ecf2796ff98",
    ("2.26.0", "netbsd-386"): "787a43428680d47d03ea9e5aeecb13769bf473338019d3246eefc1bc92f94c30",
    ("2.26.0", "netbsd-amd64"): "4e5472f8937e30c1e6cd0ac3c42ba8e365fde5970e7a43e3039be0c00e4f4a88",
    ("2.26.0", "netbsd-arm64"): "4da34873c7eb9a8eb5082c878e012e0520938ef308c0fa3367ff79709f160da7",
    ("2.26.0", "netbsd-armv6"): "b080410cb0bb6b62e2dc3dc11c6026f08e3ed10749dbfd54dd82ffc7047e6144",
    ("2.26.0", "netbsd-armv7"): "7175336d07c2dd95685e9014750e9ee44de6e83dd8e3fd2497f6ea9cc6b3ec31",
    ("2.26.0", "openbsd-386"): "00b58e4f251848daf2ff3bf5fd9704ea1e24607f6597fa146689c4841e1f1559",
    ("2.26.0", "openbsd-amd64"): "08f08e0e1612da4fafd159f6f8ecc0d783d2bb4ecc9b2e9523632000670f0dd9",
    ("2.26.0", "openbsd-arm64"): "87253d9cf8b92012e9e8c01806f79c4234f3cfbe1e3a2ee7ac8ce8f0fee208da",
    ("2.26.0", "openbsd-armv7"): "12e0a62cbf37894a2de7174f3bc139a2572fabb1f873eca5e9a841f784cd5a5a",
    ("2.26.0", "windows-386"): "1677dc32cea976d346d5bcffee45dc9864e06dffaaad4a0678ca12b484ac6d5f",
    ("2.26.0", "windows-amd64"): "4e75dc7d72b3006bc718bb2e89930cae058f5f4642a5b75ac9daa565a0a7272e",
}

_ALERTMANAGER_VERSION_ARCH_SHA_MAPPING = {
    ("0.21.0", "darwin-amd64"): "b508eb6f5d1b957abbee92f9c37deb99a3da3311572bed34357ac8acbb75e510",
    ("0.21.0", "dragonfly-amd64"): "8531f3b02d788df4fabe333dc75a558cd92c51c4c8280d5a27dbaa0efb390f66",
    ("0.21.0", "freebsd-386"): "bd554804e0240b1cba8d3f9f1bb5cfde6f1c815ec3b77e83e617808ca0983420",
    ("0.21.0", "freebsd-amd64"): "1fe3f1fcdebb055d464d24865743f996843166bb7c8f3cea114887f5bb283b2d",
    ("0.21.0", "freebsd-armv6"): "3cc30810003e21d06f1f5534a284bacf077d04bc8f86e4b82f6b189d45d248df",
    ("0.21.0", "freebsd-armv7"): "dec886a05913e210a8b0f109e713b6f394d2afddb5395da045a8823d2d7f9c83",
    ("0.21.0", "linux-386"): "cfa6090466b530ea7501fcded4a186516cac22c149cda1f50dd125177badff9d",
    ("0.21.0", "linux-amd64"): "9ccd863937436fd6bfe650e22521a7f2e6a727540988eef515dde208f9aef232",
    ("0.21.0", "linux-arm64"): "1107870a95d51e125881f44aebbc56469e79f5068bd96f9eddff38e7a5ebf423",
    ("0.21.0", "linux-armv5"): "1778ac52bbbb99a9914b3fb9b0f39c35046cf9a2540568f80ea03efc603b00be",
    ("0.21.0", "linux-armv6"): "03282900bf3ddce77f236872f4c8e2cf91f7b8b9b7e80eec845841930723a900",
    ("0.21.0", "linux-armv7"): "d7b41a15d90fedf3456969b158ddaea591d7d22d195cc653738af550706302b6",
    ("0.21.0", "linux-mips64"): "caad406dc86ad36b0f282a409757895d66206da47aae721f344ebad3bf257f7a",
    ("0.21.0", "linux-mips64le"): "060f0af52a471bdc2fd017f2752d945ddd47a030d5c94fe3c37d1fb74693906c",
    ("0.21.0", "linux-ppc64"): "adc949faa23a8a34cc5fe5fa64f62777cb35d0055df303804f767b77c662ad3f",
    ("0.21.0", "linux-ppc64le"): "afc649eb16299f1957034ff14450fe18507de6d43f7b36383373c678974a09ed",
    ("0.21.0", "linux-s390x"): "5a71fae41f8a2abf6b34825f16a7ea625fede6d2e9679111147d15aa8446ab38",
    ("0.21.0", "netbsd-386"): "e1db656dd4b6b4f9cb16505591ce10b76ca3106582786dd7ea71560a6e4e7a53",
    ("0.21.0", "netbsd-amd64"): "aa29c15a464ddfdb40dff77e81634a6c81150e8b601ff11c82f05c5b2b4876d4",
    ("0.21.0", "netbsd-armv6"): "26d68e39479beb3c040bf6ef995d5c58d0b3523688219d84ce10eb9620622611",
    ("0.21.0", "netbsd-armv7"): "d25f311f76df28fa82c01c527fabaa646b24a48120938d57b3116382f4b8cf65",
    ("0.21.0", "openbsd-386"): "6bdb03cd3c36a27b523f411e7370606c84214e53a75b740a2f1e07c77ed7c52a",
    ("0.21.0", "openbsd-amd64"): "ffd4fde08ff1236d37eabb10a6d1896404f06ebf8c5fd4c15c322b67a628f6a5",
    ("0.21.0", "windows-386"): "16797370f99db1d10aec642c4f266eb7d051bfaa874d17caf3041141a64cd26f",
    ("0.21.0", "windows-amd64"): "12c9a77d904bd7982e7ceacfbe9106e725e31536913c491e7b2703f9ddff4aa2",
}

PrometheusMetadataInfo = provider(
    doc = "Provides metadata for building http_archive objects",
    fields = {
        "available_architectures": "list of available architectures",
        "prometheus": "prometheus metadata",
        "alertmanager": "alertmanager metadata",
    },
)

PrometheusHttpArchiveInfo = provider(
    doc = "Prometheus binary download info provider",
    fields = {
        "sha256": "sha256 checksum of prometheus binary",
        "version": "specific version of prometheus binary",
        "arch": "binary architecture",
        "build_file_contents": "bazel build file contents after unpacking",
    },
)

AlertmanagerHttpArchiveInfo = provider(
    doc = "Alertmanager binary download info provider",
    fields = {
        "sha256": "sha256 checksum of alertmanager binary",
        "version": "specific version of alertmanager binary",
        "arch": "binary architecture",
        "build_file_contents": "bazel build file contents after unpacking",
    },
)

PrometheusPackageHttpArchiveInfo = provider(
    doc = "Unified binary download info provider",
    fields = {
        "prometheus": "Prometheus download provider",
        "alertmanager": "Alertmanager download provider",
    },
)

def _build_http_archive_factory(
        arch,
        prometheus_version,
        alertmanager_version,
        prometheus_sha256,
        alertmanager_sha256,
        prometheus_build_file_contents,
        alertmanager_build_file_contents):
    return PrometheusPackageHttpArchiveInfo(
        prometheus = PrometheusHttpArchiveInfo(
            sha256 = prometheus_sha256,
            version = prometheus_version,
            arch = arch,
            build_file_contents = prometheus_build_file_contents,
        ),
        alertmanager = AlertmanagerHttpArchiveInfo(
            sha256 = alertmanager_sha256,
            version = alertmanager_version,
            arch = arch,
            build_file_contents = alertmanager_build_file_contents,
        ),
    )

def _prometheus_repositories_impl(
        prometheus_version,
        alertmanager_version,
        http_archive_provider_factory = _build_http_archive_factory,
        prometheus_package_metadata = PrometheusMetadataInfo(
            available_architectures = _ARCH_LIST,
            prometheus = _PROMETHEUS_VERSION_ARCH_SHA_MAPPING,
            alertmanager = _ALERTMANAGER_VERSION_ARCH_SHA_MAPPING,
        )):
    """prometheus_repositories main implementation function

    """

    for arch in prometheus_package_metadata.available_architectures:
        prometheus_sha256 = prometheus_package_metadata.prometheus[(prometheus_version, arch)]
        alertmanager_sha256 = prometheus_package_metadata.alertmanager[(alertmanager_version, arch)]

        http_archive_info = http_archive_provider_factory(
            arch = arch,
            prometheus_version = prometheus_version,
            alertmanager_version = alertmanager_version,
            prometheus_sha256 = prometheus_sha256,
            alertmanager_sha256 = alertmanager_sha256,
            prometheus_build_file_contents = _PROMETHEUS_BUILD_FILE_CONTENTS,
            alertmanager_build_file_contents = _ALERTMANAGER_BUILD_FILE_CONTENTS,
        )

        http_archive(
            name = "prometheus_%s" % arch,
            sha256 = prometheus_sha256,
            urls = [(
                "https://github.com/prometheus/prometheus/releases/download/" +
                "v{version}/prometheus-{version}.{arch}.tar.gz".format(
                    version = prometheus_version,
                    arch = arch,
                )
            )],
            strip_prefix = "prometheus-{version}.{arch}".format(
                version = prometheus_version,
                arch = arch,
            ),
            build_file_content = http_archive_info.prometheus.build_file_contents,
        )

        http_archive(
            name = "alertmanager_%s" % arch,
            sha256 = alertmanager_sha256,
            urls = [(
                "https://github.com/prometheus/alertmanager/releases/download/" +
                "v{version}/alertmanager-{version}.{arch}.tar.gz".format(
                    version = alertmanager_version,
                    arch = arch,
                )
            )],
            strip_prefix = "alertmanager-{version}.{arch}".format(
                version = alertmanager_version,
                arch = arch,
            ),
            build_file_content = http_archive_info.alertmanager.build_file_contents,
        )

    prometheus_register_toolchains()

def prometheus_repositories(
        prometheus_version = "2.26.0",
        alertmanager_version = "0.21.0"):
    """Download dependency tools and initialize toolchains

    Args:
        prometheus_version: Prometheus package version to download from source repositories
        alertmanager_version: Alertmanager package version to download from source repositories
    """

    # https://github.com/prometheus/prometheus/releases/download/ v{version}/prometheus-{version}.darwin-amd64.tar.gz
    # "alertmanager": {
    #     "sha256": "b508eb6f5d1b957abbee92f9c37deb99a3da3311572bed34357ac8acbb75e510",
    #     "url": (
    #         "https://github.com/prometheus/alertmanager/releases/download/" +
    #         "v{version}/alertmanager-{version}.darwin-amd64.tar.gz"

    _prometheus_repositories_impl(
        prometheus_version = prometheus_version,
        alertmanager_version = alertmanager_version,
    )
