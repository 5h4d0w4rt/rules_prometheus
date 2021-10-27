load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load(":toolchain.bzl", "build_toolchains", "prometheus_register_toolchains")

_PROMETHEUS_DEFAULT_VERSION = "2.30.3"
_ALERTMANAGER_DEFAULT_VERSION = "0.23.0"

_DEFAULT_HTTP_ARCHIVE_EXTENSION = "tar.gz"

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

PrometheusBinaryInfo = provider(
    doc = "Provides metadata for prometheus server binary",
    fields = {
        "version": "Current version",
        "available_binaries": "list of available binaries represented as a mapping (version, architecture): sha checksum of binary's archive",
    },
)

AlertmanagerBinaryInfo = provider(
    doc = "Provides metadata for alertmanager binary",
    fields = {
        "version": "Current version",
        "available_binaries": "list of available binaries represented as a mapping (version, architecture): sha checksum of binary's archive",
    },
)

PrometheusPackageInfo = provider(
    doc = "Provides metadata for building http_archive objects",
    fields = {
        "available_architectures": "list of available architectures",
        "prometheus_binary_info": "prometheus binary provider",
        "alertmanager_binary_info": "alertmanager binary provider",
    },
)

HttpArchiveInfo = provider(
    doc = "Blob download info provider",
    fields = {
        "name": "unique name for to-be initialized bazel repository",
        "sha256": "sha256 checksum of the blob",
        "version": "specific version of the binary",
        "arch": "binary architecture",
        "urls": "list of urls to download blob from",
        "strip_prefix": "A directory prefix to strip from the extracted files",
        "build_file_content": "bazel build file content after unpacking",
    },
)

def _http_archive_provider_factory(
        binary,
        arch,
        version,
        sha256,
        build_file_content,
        archive_extension = _DEFAULT_HTTP_ARCHIVE_EXTENSION):
    return HttpArchiveInfo(
        name = "{binary}_{arch}".format(
            binary = binary,
            arch = arch,
        ),
        sha256 = sha256,
        version = version,
        arch = arch,
        urls = [(
            "https://github.com/prometheus/{binary}/releases/download/".format(
                binary = binary,
            ) +
            "v{version}/{binary}-{version}.{arch}.{archive_extension}".format(
                version = version,
                arch = arch,
                binary = binary,
                archive_extension = archive_extension,
            )
        )],
        strip_prefix = "{binary}-{version}.{arch}".format(
            version = version,
            arch = arch,
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

    for arch in prometheus_package_info.available_architectures:
        http_archive_factory(http_archive_info(
            binary = "prometheus",
            arch = arch,
            version = prometheus_package_info.prometheus_binary_info.version,
            build_file_content = prometheus_build_file_content,
            sha256 = prometheus_package_info.prometheus_binary_info.available_binaries[(
                prometheus_package_info.prometheus_binary_info.version,
                arch,
            )],
        ))
        http_archive_factory(http_archive_info(
            binary = "alertmanager",
            arch = arch,
            version = prometheus_package_info.alertmanager_binary_info.version,
            build_file_content = alertmanager_build_file_content,
            sha256 = prometheus_package_info.alertmanager_binary_info.available_binaries[(
                prometheus_package_info.alertmanager_binary_info.version,
                arch,
            )],
        ))

def _validate_prometheus_package_info(prometheus_package_info):
    if not prometheus_package_info.prometheus_binary_info.version in [key[0] for key in prometheus_package_info.prometheus_binary_info.available_binaries]:
        fail(
            "No %s version in supported prometheus versions" % prometheus_package_info.prometheus_binary_info.version,
        )

    if not prometheus_package_info.alertmanager_binary_info.version in [key[0] for key in prometheus_package_info.alertmanager_binary_info.available_binaries]:
        fail(
            "No %s in supported alertmanager versions" % prometheus_package_info.alertmanager_binary_info.version,
        )

def _prometheus_repositories_impl(
        prometheus_package_info,
        http_archive_factory = _build_http_archives,
        native_toolchains_factory = build_toolchains):
    """prometheus_repositories main implementation function

    Args:
        prometheus_package_info: prometheus package metadata provider
        http_archive_factory: http_archive(s) factory function
        native_toolchains_factory: toolchain linker factory function
    """

    http_archive_factory(
        prometheus_package_info = prometheus_package_info,
    )

    prometheus_register_toolchains(native_toolchains_factory(prometheus_package_info.available_architectures))

def prometheus_repositories(
        prometheus_version = _PROMETHEUS_DEFAULT_VERSION,
        alertmanager_version = _ALERTMANAGER_DEFAULT_VERSION):
    """Download dependency tools and initialize toolchains

    Args:
        prometheus_version: Prometheus package version to download from source repositories if supported by reposiory
        alertmanager_version: Alertmanager package version to download from source repositories if supported by reposiory
    """

    git_repository(
        name = "io_bazel_stardoc",
        commit = "4378e9b6bb2831de7143580594782f538f461180",
        remote = "https://github.com/bazelbuild/stardoc.git",
        shallow_since = "1570829166 -0400",
    )

    prometheus_package_info = PrometheusPackageInfo(
        available_architectures = (
            "darwin-amd64",
            "darwin-arm64",
            "dragonfly-amd64",
            "freebsd-386",
            "freebsd-amd64",
            "freebsd-arm64",
            "freebsd-armv6",
            "freebsd-armv7",
            "illumos-amd64",
            "linux-386",
            "linux-amd64",
            "linux-arm64",
            "linux-armv5",
            "linux-armv6",
            "linux-armv7",
            "linux-mips",
            "linux-mips64",
            "linux-mips64le",
            "linux-mipsle",
            "linux-ppc64",
            "linux-ppc64le",
            "linux-s390x",
            "netbsd-386",
            "netbsd-amd64",
            "netbsd-arm64",
            "netbsd-armv6",
            "netbsd-armv7",
            "openbsd-386",
            "openbsd-amd64",
            "openbsd-arm64",
            "openbsd-armv7",
            "windows-386",
            "windows-amd64",
        ),
        prometheus_binary_info = PrometheusBinaryInfo(
            version = prometheus_version,
            available_binaries = {
                ("2.24.1", "darwin-amd64"): "73c27ba24f5b7beaf78a7bd46a6695966c6ad5f4db02866dc577aaf55b844505",
                ("2.24.1", "dragonfly-amd64"): "e7a1f6c102d6664b74ddd379f29a48125963628a4b6e5228dd95632da61c2537",
                ("2.24.1", "freebsd-386"): "b91c0e3cdaadd237b86444e4384a561db40d6788bf85bc7217fef86f10b1a844",
                ("2.24.1", "freebsd-amd64"): "b983b713e15ff9ba6cc7fcccce67d8d73e40182d818fbf7cb40dbef2b8328d72",
                ("2.24.1", "freebsd-armv6"): "1e1b34d6d1eb5421e91643586162976d39e54fc791939ef73aa268b8a611dd53",
                ("2.24.1", "freebsd-armv7"): "4657c8f82aba0ba9d2ccc4f2a16af020604c49313a44f23ee8e192e83ad6e366",
                ("2.24.1", "linux-386"): "357c8ad6d3a1d38fb30c42b2858830b19acd44cfd3494d4e205222ec4ab2d41e",
                ("2.24.1", "linux-amd64"): "5aec10296624449e83469ef647cb762bd4de2aa12fc91d2375c5e6be9fd049c0",
                ("2.24.1", "linux-arm64"): "8687469d860eb52b67a82ada11591bee7c1446631fe86dcc2bcbeb2ed7810dc3",
                ("2.24.1", "linux-armv5"): "ef8a7a58b29027d230da9c904429375af93b82db5da7067fe5fff3a24a7f5c4c",
                ("2.24.1", "linux-armv6"): "27ca010697f048396b0c63f5522d876d5fb937894f582faff49c9dc4cd815a35",
                ("2.24.1", "linux-armv7"): "7233ca39c740d86a94f8a21a7bf02aa535b20a7ed5efa893b3c7c97dcbddb334",
                ("2.24.1", "linux-mips64"): "5f6d12bd3605e78af623f1ea0bc80b2e6335b403c0a4a637d260eb528686eade",
                ("2.24.1", "linux-mips64le"): "f88196587c122b5cc75fcc8dd5cae0d78357d81407650573e7d4a33e0a091537",
                ("2.24.1", "linux-ppc64"): "7e3e5a184875683f9afc205d43ebd62067211e2811c5a07bbb770a3adc10b408",
                ("2.24.1", "linux-ppc64le"): "96fa5f23f6caf613449091d4bdf38abcab88e801c5c4659f2608ef0d03840dd0",
                ("2.24.1", "linux-s390x"): "1287f2b9c59940f17f3ea05d9a4d2287f567c095f57b1f4aa40c2c1eb54dd03c",
                ("2.24.1", "netbsd-386"): "e3ec99ce88fcf0f9951c69d4c04a0e3031af0fcdb19177efa188ac99260ca742",
                ("2.24.1", "netbsd-amd64"): "73395fa7528a02a54b76361d4f91bb7415b3de70b598d5935eef9afa37254187",
                ("2.24.1", "netbsd-armv6"): "ce66f8e3be723cfb7eebd30608d7284f1d0f58b7373f1299f8fadb9becf303e4",
                ("2.24.1", "netbsd-armv7"): "6ae984c21dd11836132785aba95b712ffa0bea229ca054f442eeb9c7bec6a7ff",
                ("2.24.1", "openbsd-386"): "faf8e685647ca59979d94be7446e56dbd6a15645bce374ea3a556016b4d20d94",
                ("2.24.1", "openbsd-amd64"): "7b02f7accd1caab4ff64fa7f28198e3dfade9309efbbbe4a6fb625e18369db5d",
                ("2.24.1", "openbsd-armv7"): "6c4a9e62ef764dfe2e4e65072436995ad317a7b9da65b38cc9e0fbc9ee696ed2",
                ("2.24.1", "windows-386"): "f8ed11b95c6227e7652270b129f5ed59c23a243825f6ccbb5f26a05d8ee75994",
                ("2.24.1", "windows-amd64"): "434f6931705d9e57f40b696e023a95b7e65c5ca572ad8c0af81f99b3332ae107",
                ("2.25.2", "darwin-amd64"): "c45622d1985e7283c2833a1a90dcede1cac2d5dab04f7c7015262b354f3fb7fb",
                ("2.25.2", "dragonfly-amd64"): "530ece8e0c8b3d5a999864800954ebcea86e274f690159e48f00dd8cd6fee82c",
                ("2.25.2", "freebsd-386"): "82fea4ea99f1a7a626e365fb1f281df18960e77321e46b6f6535d235803cfd2f",
                ("2.25.2", "freebsd-amd64"): "5ca88c416de84741fbdf55377cabe631e0dea4d75924a331df7f1d36f9ddce00",
                ("2.25.2", "freebsd-armv6"): "458f6e443e69d872b7b30ce9e619de9d1747d6e9bc43ddc4b66174cc85936608",
                ("2.25.2", "freebsd-armv7"): "ac8ea1983d58fe8c0d3249dad3b59963fa5c577cbb19fa7a17b185e3535d4db1",
                ("2.25.2", "linux-386"): "8cc41fe5307e9900622ce99c8d8239b883f783f2b191bc56495b844fd8385c78",
                ("2.25.2", "linux-amd64"): "362804a065949bfb03d31783e6522a4d874c40f507a64add6455f95e6c7de33e",
                ("2.25.2", "linux-arm64"): "ac0e38d5210bc8f32d066ecad9ea96b50c98fe2c8c60c85eb2da5cbde7ba6579",
                ("2.25.2", "linux-armv5"): "09d251498d9e558ec3792d400d5048c1e33b4b95fb73636fe763ba0c7211d697",
                ("2.25.2", "linux-armv6"): "bf895483d4e4e16f1c74d2bdbd9a6b27e1caeaa63e5646eed5c80fe2c2851791",
                ("2.25.2", "linux-armv7"): "d4883c2b3d7ce0272671650b6c5b5b9b6b71c272f8b9bbe9a1d8fa295a656a6a",
                ("2.25.2", "linux-mips64"): "3eded05ca21702a3bc10641d6e3ca37f44a7ec9bcbd78eb8d5cdaeaa85184be6",
                ("2.25.2", "linux-mips64le"): "40a09a193e5891c41ac09d88572185cfc722f21117f0d860382d14c3f0a5ff8b",
                ("2.25.2", "linux-ppc64"): "fe1d8c2c3189233a9091403201c69b03ca2300c27ffb0ca388671f0bafadd8f5",
                ("2.25.2", "linux-ppc64le"): "92682b24df2d5e00e291d40367d2bb1900d06b30dfc0b1faca01acd2c824aee2",
                ("2.25.2", "linux-s390x"): "a3c9e3ac48ecd4da4ab0d82fa5e9a67f4a12563ee8413306dcc6745088b11eaf",
                ("2.25.2", "netbsd-386"): "a6451a02b57aeb063804837ef3715595b908488e84c9edffa4879dbfadba6ab6",
                ("2.25.2", "netbsd-amd64"): "ede213bce93e560e225dc50d11828f777a00f4133c573b9603b39366d8c87b81",
                ("2.25.2", "netbsd-armv6"): "c5f4b3dd58a500bf16c6186066c00137a3a5aa76d010ddc9a75211c41aa9ef36",
                ("2.25.2", "netbsd-armv7"): "bf18973a3fc75cf88b0d7fa28f8591d23dad003899657a58f293b15c574a4c06",
                ("2.25.2", "openbsd-386"): "b02c17e5fc373b015eb4dca94cd305286140ae6153dc975682895570971398dd",
                ("2.25.2", "openbsd-amd64"): "7fcba4e2ef78c0e19b2f736edf226bd877073b4bea5e65c45f8dc432dc0d9c8c",
                ("2.25.2", "openbsd-armv7"): "3db8c561c01ef0a3d9010a0cb9a0ea19328a613c1b7cafb344c4e3c33bfeae81",
                ("2.25.2", "windows-386"): "f1b3cd91af89d9ce6e29a7e975a3254070813ecfee2a601b2e952048ea8d8360",
                ("2.25.2", "windows-amd64"): "f4d4a2e460b97f9d7a7f4f6d7ad54a8f9ca1595520c215c383ab90568a65aeb2",
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
                ("2.30.3", "darwin-amd64"): "8d7e0cda867553a01373fd93f24d718d10f74e0bb43c43f7902bc2216894a281",
                ("2.30.3", "darwin-arm64"): "dc52f5042d2606f848847014222b06a7ab243c062c39120e4bacdd058eedf289",
                ("2.30.3", "dragonfly-amd64"): "2acb977702e8f37605fefbd9eff3c7cbaa9e88e4d674362f90d5f728391bd2a5",
                ("2.30.3", "freebsd-386"): "c6cbb68f9d9898e42d01e88827df4b5549e0e661f882e2fd1062db0b196d6a68",
                ("2.30.3", "freebsd-amd64"): "b241d60c79da4504b6c082bd09a47c1164a15552e66bc981e319fdf9f3757e7c",
                ("2.30.3", "freebsd-arm64"): "627688eec5060486fa5d070bc95de0cd005bfa6206d8d657693f54b699971878",
                ("2.30.3", "freebsd-armv6"): "afc76f8e6e6c8cd3964886db10463256988dacb0c533700346495d52035d2edf",
                ("2.30.3", "freebsd-armv7"): "ad0b56c76b342ac1bb02648b13efcc28296d4ca79900ecbbd00bb42972d0a9b9",
                ("2.30.3", "illumos-amd64"): "9d8e4905da66ba4750a2d6e7c06ecf0f46053b5a0c6c6a95677490978b27effc",
                ("2.30.3", "linux-386"): "7a194951fb51bc0f4f5a15d370ba8c60f62d3f6a5e02e0ccc75238e459bfc3a8",
                ("2.30.3", "linux-amd64"): "1ccd386d05f73a98b69aa5e0ed31fffac95cd9dadf7df1540daf2f182c5287e2",
                ("2.30.3", "linux-arm64"): "0bf66e0ab8fcad44ee5041d7909a955017f4587868ee96b76c44c02f500d843e",
                ("2.30.3", "linux-armv5"): "3492153b60c973d0bccd90ea6ff131da7683dbec46565eb5af6901cfddf77b27",
                ("2.30.3", "linux-armv6"): "89d4757507b3d233f1b516c48f362287972eed171b82572f437677c56e915534",
                ("2.30.3", "linux-armv7"): "cb2d8eb3a22d6dbe69449f7d6604f2fa80fa70df4c35dfb412354188047941e7",
                ("2.30.3", "linux-mips"): "13d5acca1fe121b6e4c1f75d5169aeac2da08067f7c1ee3ed39d781946e476a9",
                ("2.30.3", "linux-mips64"): "8e8150e40ab1f67114dcd6091a5a0bbe4ecbe87f2a7aa239e086ec37a985fd33",
                ("2.30.3", "linux-mips64le"): "f8dc62e8938b6226cc6fc7fd82c8d0c65b0f275b2e103266323b2146aec480c8",
                ("2.30.3", "linux-mipsle"): "4122cf9642f099fb5b25ab89fac58e67b3b661c5c61de5377b17d62d032c1b04",
                ("2.30.3", "linux-ppc64"): "57fce3a76f492ecddfcefa0745eadea776eac417ad1d8c0b25073ef672a7f1d1",
                ("2.30.3", "linux-ppc64le"): "002ee190b11a904554e5c00bd1713679894bdcce32067b0de5fae87d4a31dc2c",
                ("2.30.3", "linux-s390x"): "c6a3feaacf85474126b30577a8d85fa075a41497e03c48f7a5486a50fb02ebcd",
                ("2.30.3", "netbsd-386"): "5747b0f539fff5db22a58b532f5be6f450e3da88795f642a0d16f1c40d6dc4e1",
                ("2.30.3", "netbsd-amd64"): "393cd29411094785059f66309359791abd4605d22d6e76197d5e54003168e13c",
                ("2.30.3", "netbsd-arm64"): "d9dad97f671c825ab071fa4eee9aecd5971ec5fb963eeadcb614e3100e9d9658",
                ("2.30.3", "netbsd-armv6"): "3040ece61cbb92a60fb32246fa19dc001398bba4cb2324688cbe071a23f5c9c1",
                ("2.30.3", "netbsd-armv7"): "8bb1c2d03a46294fd1bc4c47b7fdc3be8b7c5bcc589a3472c7776c4adb944e52",
                ("2.30.3", "openbsd-386"): "cd00cb6cc74527162c51bf5f830bc4e800dec88a4b03dbf84f78051e6349f66f",
                ("2.30.3", "openbsd-amd64"): "98609477fd38c3c45bb326f284615f15db05931a013238d308bee9530663697e",
                ("2.30.3", "openbsd-arm64"): "85b01bd03872866852132d325738b59f20bc658c9e33496224e60bcd544d0fee",
                ("2.30.3", "openbsd-armv7"): "d288f631b0db0a80e62dbf8ac1b5262fe85b3751be66c2d46f32463e0a9cb387",
                ("2.30.3", "windows-386"): "90250bd300063ea1e041e82efee579e103b1e435f120bd252e4f597bd0e2f7a8",
                ("2.30.3", "windows-amd64"): "365f8884b92e037f41f59f583b31c5e83fd3b6dbe821e91d3644a701f1001e96",
            },
        ),
        alertmanager_binary_info = AlertmanagerBinaryInfo(
            version = alertmanager_version,
            available_binaries = {
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
                ("0.23.0", "darwin-amd64"): "f8d668f88f8934202aaf646a93a116ac38532144bdaad291319518704a01f2ca",
                ("0.23.0", "darwin-arm64"): "01d47f98b46d92dac2a7ae8f45668e8491f835c57f8c3cab39a3cb6ec8d16ca1",
                ("0.23.0", "dragonfly-amd64"): "d50d3c6f2d524157d1447e7e793c1567f0b7e5c5bd3a8664dcf35f8811e74132",
                ("0.23.0", "freebsd-386"): "b25c51b19e4295159e81c3a94e91f34b6750ad8bb54971263a9296695f267e3a",
                ("0.23.0", "freebsd-amd64"): "59c73c66dc5e103f96d2d54920baf9168d754636e96876b5f4b713effabc8c1c",
                ("0.23.0", "freebsd-arm64"): "875dec9177aa9e1185924773fa478f27368fc7b71b42628dca8db6a5351a99c0",
                ("0.23.0", "freebsd-armv6"): "fd07d75d4823437527fe91736b6fe63aae2e7624a6b1bb84d05a83fc4b6739d0",
                ("0.23.0", "freebsd-armv7"): "0673354936807c12d5f7dd13837524f7d23b177a31af8e8bb5235eb5325c1e7f",
                ("0.23.0", "illumos-amd64"): "93d91f2ff06c4de271b8b3180e6673fd2fe2569dce0da335e860a261a700717b",
                ("0.23.0", "linux-386"): "097abb8b7b676bf1543d9020120f56beedb3935ab2f71a03e4537e17350d3be3",
                ("0.23.0", "linux-amd64"): "77793c4d9bb92be98f7525f8bc50cb8adb8c5de2e944d5500e90ab13918771fc",
                ("0.23.0", "linux-arm64"): "afa44f350797032ceb714598900cfdddbf81d6ef03d2ecbfc0221cc2cb28a6b9",
                ("0.23.0", "linux-armv5"): "11bfd273a0e115f662fc31cb8c818f8857dd5857c3045ad104aa15766ad4fb65",
                ("0.23.0", "linux-armv6"): "9837426d31084aec1e9f55bbce8defc05417e3af2098255a5eebab096dc246cd",
                ("0.23.0", "linux-armv7"): "489c377a04b6097f07fdcc4b532a9643e520739b268be5350c4ffa999956d5c9",
                ("0.23.0", "linux-mips"): "7a0d2690d69df8cb1500568d02d9ad8a990b8e13bb8e3ef383ef09c5fe6fc5d6",
                ("0.23.0", "linux-mips64"): "c3711cd95cde42dfe19c4c6186026555fedc39980449a118cbbb894b6173a1fb",
                ("0.23.0", "linux-mips64le"): "460ebf9f92bac4b0fad1bf554ad9d60dcea65ff80b7d5326fb36e8d15a3b254a",
                ("0.23.0", "linux-mipsle"): "ee2ab5f329e728d57f2f8ae59ad4c10351800c20b69058daa42857d63771c2d0",
                ("0.23.0", "linux-ppc64"): "f79cf779b758d1cda4cf6b9e6708497e1c67e0e619efefadba66d57a7b937f6c",
                ("0.23.0", "linux-ppc64le"): "c047283a61bb99234e8050347c5f1333c6805eb3e5806e73a0e80f6249967831",
                ("0.23.0", "linux-s390x"): "45a9ea7549f8d4242703d9bd66d03c62530e67097010303d3a002a79de7a01aa",
                ("0.23.0", "netbsd-386"): "e43d565eda9132c385b9e06883ce67fc8bc09053e70d5b8e54967d2c384f5778",
                ("0.23.0", "netbsd-amd64"): "6c4983b500fe18d71174e817a31828bda89710ad8a9f1329ed2ff6da08826a48",
                ("0.23.0", "netbsd-arm64"): "15e0b87bfe5bb53d2240af855f66a5d895eec6c324dc0764e8799045543b770d",
                ("0.23.0", "netbsd-armv6"): "814bbb0f1c425d05ce60122726e8a16f2d18ae89255c37622bac1abdb3fe1c11",
                ("0.23.0", "netbsd-armv7"): "9a8fa1ba2c181797013494d74dcb4bbb4aa568a00467cb270f3e393dd8a09c9a",
                ("0.23.0", "openbsd-386"): "ef82fbeb03243eae8c6fede858d8118dad28a4c1f0504451361e02eac2808cdf",
                ("0.23.0", "openbsd-amd64"): "9ed30892abc21fe7b32dd29c11b3ddb0262f0f8e6f80c9265139c92611b95290",
                ("0.23.0", "openbsd-arm64"): "f47ad57dceecae7a40ede243b99f8b56bde5b930ec98d95c14c95d5e398f8fa9",
                ("0.23.0", "openbsd-armv7"): "4afc7974f078bc882cfcead000ffc52ccac9609caec5798d90d4a35eb7a10a8b",
                ("0.23.0", "windows-386"): "b1dd8405de144f4d2e2ae067138fb720fb9eb9fa6234c8de14dfc6c5cb8df155",
                ("0.23.0", "windows-amd64"): "7832aac30f849de0a1a60d961dec083e97933a73dc26673ffaef4809719fcd3c",
            },
        ),
    )

    _validate_prometheus_package_info(
        prometheus_package_info,
    )

    _prometheus_repositories_impl(
        prometheus_package_info = prometheus_package_info,
    )
