load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":toolchain.bzl", "build_toolchains", "prometheus_register_toolchains")
load(":platforms.bzl", "PLATFORMS")

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
        "platforms_info": "metadata providers for os-arch",
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
        "urls": "list of urls to download blob from",
        "strip_prefix": "A directory prefix to strip from the extracted files",
        "build_file_content": "bazel build file content after unpacking",
    },
)

def _http_archive_provider_factory(
        binary,
        os,
        cpu,
        version,
        sha256,
        build_file_content,
        archive_extension = _DEFAULT_HTTP_ARCHIVE_EXTENSION):
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

def _validate_prometheus_package_info(prometheus_package_info):
    if not (
        prometheus_package_info.prometheus_binary_info.version in
        [key[0] for key in prometheus_package_info.prometheus_binary_info.available_binaries]
    ):
        fail(
            "No %s version in supported prometheus versions" % prometheus_package_info.prometheus_binary_info.version,
        )

    if not (
        prometheus_package_info.alertmanager_binary_info.version in
        [key[0] for key in prometheus_package_info.alertmanager_binary_info.available_binaries]
    ):
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

    prometheus_register_toolchains(native_toolchains_factory(prometheus_package_info.platforms_info.available_platforms))

def prometheus_repositories(
        prometheus_version = _PROMETHEUS_DEFAULT_VERSION,
        alertmanager_version = _ALERTMANAGER_DEFAULT_VERSION,
        _platforms_info = PLATFORMS):
    """Download dependency tools and initialize toolchains

    Args:
        prometheus_version: Prometheus package version to download from source repositories if supported by reposiory
        alertmanager_version: Alertmanager package version to download from source repositories if supported by reposiory
        _platforms_info: pre-built PrometheusPlatformInfo provider with info on all available os+architectures
    """

    # TODO(5h4d0w4rt) add custom version support
    prometheus_package_info = PrometheusPackageInfo(
        platforms_info = _platforms_info,
        prometheus_binary_info = PrometheusBinaryInfo(
            version = prometheus_version,
            available_binaries = {
                ("2.28.1", "darwin-amd64"): "3941b102a06ebae9bcfa52d07b84825543f529c1e308f2bd66c6ad55cd4d25a4",
                ("2.28.1", "darwin-arm64"): "1c39922ef27835cf1c68658a20cdfd0323f61ed1efe9424cc1643020bd990a1e",
                ("2.28.1", "dragonfly-amd64"): "cd9d87f861909cfc358324163ecedf030665d89f071b0a973072722bee2fa762",
                ("2.28.1", "freebsd-386"): "746477a3723438d91c123a2dbfb4a4690b6cc2883b7747af43ab70b5abd3067e",
                ("2.28.1", "freebsd-amd64"): "632843a2ff187f955b2c3d3b905375eb461561834a3a3a03faffd74ba56a332b",
                ("2.28.1", "freebsd-arm64"): "e953a02dfa60dc0035645eed24f8c9103dca2c43e204fd5b905f32926588763c",
                ("2.28.1", "freebsd-armv6"): "dca05a532e94d2eae847a9db40fe1bfe3542905a0795936b17ac00dac95d371c",
                ("2.28.1", "freebsd-armv7"): "a8bc3a565e57719aefd5eea9ce6666fec329858bcda0f7ebc71532f58cb8f122",
                ("2.28.1", "illumos-amd64"): "52381975a967db432fadfcf869e6345aa1a34bbe8892cdebcc00771f3856a11d",
                ("2.28.1", "linux-386"): "df70438c909f3bd7d26ae2b38dc6f1782bfa54cd4b99d4f01a1f39171426c60c",
                ("2.28.1", "linux-amd64"): "91dd91e13f30fe520e01175ca1027dd09a458d4421a584ba557ba88b38803f27",
                ("2.28.1", "linux-arm64"): "298e5e32cc2d106f4d886548a535e787871650095fe87b1e8b29f83cbcbddbd1",
                ("2.28.1", "linux-armv5"): "a249704d67d6271894a932fd5c6e91f543549b41acbf8b90acb170de357c0396",
                ("2.28.1", "linux-armv6"): "25456957df9bcfdd54a04cef58689a5cc5ce51ddefc661f59a42e656b5b158f2",
                ("2.28.1", "linux-armv7"): "0ee31e4ee719680143887911dc15e9108ac595fe4345cb1bb959aad5f0281b1a",
                ("2.28.1", "linux-mips"): "8039a41bf80c003a04e927dd1ea974b6f25837a1871ee0a5533269acda1b4e57",
                ("2.28.1", "linux-mips64"): "16f64bc7c9138964a6ce14da2bbe3a6ec19d01c4c6b24d7977d22d5d0c2a6d4e",
                ("2.28.1", "linux-mips64le"): "87845a55567555c39058bd8b7f0377e08ee008b59c8cca1ccd84d2b8770d3ff2",
                ("2.28.1", "linux-mipsle"): "8b36ea48fa4e263fe9f4060ec6105ac3285613c047fad04d5b9c0229b1c83493",
                ("2.28.1", "linux-ppc64"): "b4187b1becc445b17fde05443f737033af3210ae57d1b7921e09350438173454",
                ("2.28.1", "linux-ppc64le"): "1a9c06b997a6698f8b4d1e71df11078eb5dfcd8348bfff8660f3061f26be013f",
                ("2.28.1", "linux-s390x"): "dd75c1cdf01ce7bfde341a7db1cc1b76a16008aaed7522fba08a073270c2b1fa",
                ("2.28.1", "netbsd-386"): "ba7d5adedc068ef0752e385f6b20a82e2479f0cc9eaef4121ef362953df8ad97",
                ("2.28.1", "netbsd-amd64"): "0f57c6f98b103745e3a80d589e8da5b967f6fea473b6ad5685fb5bc84dec5439",
                ("2.28.1", "netbsd-arm64"): "86b50ddff15e316b24553ad236a712feded8a6eba2df6bb0df96255d53acf507",
                ("2.28.1", "netbsd-armv6"): "07bc88f662a5e206b736305fb486fde88895b37a6edcd31a7e0bab46005a97eb",
                ("2.28.1", "netbsd-armv7"): "3f3c677333db8599117fbdf62e773506859553331a66a62eb956ae31410be917",
                ("2.28.1", "openbsd-386"): "47a458b300209b5971a342ecd4efc06c06eb55d63dc3b4e12529cc2d81af7a61",
                ("2.28.1", "openbsd-amd64"): "d7d62a3851069087deebacc3ef0e7f6c58f7c4bbaeb2f02848622a06665703ce",
                ("2.28.1", "openbsd-arm64"): "23e506d00de16fd9904dd38ed9085f64bc3dee2419674785901b89b59b3a0b05",
                ("2.28.1", "openbsd-armv7"): "79bb4b7ec88a9d85654ea334f352a826c046732a6729cb7616921e654aceae61",
                ("2.28.1", "windows-386"): "b8277b3a58faf22ec5d385fbc888b64ab934911d36eea57fe4fe5cce5b2461f3",
                ("2.28.1", "windows-amd64"): "c81cf1e677247263bdbd7158efb8b00afbd1bc7ae155eb86af5cfe90abdb2969",
                ("2.29.2", "darwin-amd64"): "810a94974be44f92d6c3ba1b7604513ef0a2c1a159bd10afc50da25370813302",
                ("2.29.2", "darwin-arm64"): "fc42d62c6b2cb486a14767465c46d72e436ae795be620d01813f20772a264324",
                ("2.29.2", "dragonfly-amd64"): "bb2f52e6d1bd4035679b51b3e1cd02b067cccb867fd596f667f6bd62fcb4bee3",
                ("2.29.2", "freebsd-386"): "fc273ea7e3d8e6ff3f5806ccd2be9c6d07ae615d0ccb43c3272d07f4b2603355",
                ("2.29.2", "freebsd-amd64"): "6a7adf4add15233972b61486f4366036c1f0539d553782fbc3ffbdb15d55a1de",
                ("2.29.2", "freebsd-arm64"): "aa9031cfa0ec88d895e9003a6d2ce8d041bc24b24fb054b865b2d1c8bc791f6e",
                ("2.29.2", "freebsd-armv6"): "9882dbd7f7adf6521e5b90408c1a9fede4ad09b3fee01dea6faf9ca5350de2e4",
                ("2.29.2", "freebsd-armv7"): "32468c0800baef58807f7b151c7572fee876bbe296302e20ea08a0333055cffe",
                ("2.29.2", "illumos-amd64"): "b171568308d8aa73d6438886fe1de197ac3f0bae2874e09a833941d96b65435a",
                ("2.29.2", "linux-386"): "7a19cb2e1d70d60857029ff793de375b1d04ffd270d59d82d5dbaa0ff199acf2",
                ("2.29.2", "linux-amd64"): "51500b603a69cf1ea764b59a7456fe0c4164c4574714aca2a2b6b3d4da893348",
                ("2.29.2", "linux-arm64"): "c2f1ff7338479ef87d3a94b5ddbf5e431e7de6e326bb23c98616dc2ca395c9a6",
                ("2.29.2", "linux-armv5"): "af8692e4f1afc47f28399e187baac347bb6af3caabd5ead27978a9200239a9bf",
                ("2.29.2", "linux-armv6"): "3d45075491a149b013a760b22b99ef32fbceec6d7969bb2e5557c2d7af4f15fd",
                ("2.29.2", "linux-armv7"): "c4e108c997f9afa0a87b6f075e430c7ff2016adb8bf62a97f927f1840fb70ebd",
                ("2.29.2", "linux-mips"): "b5258663c7c3d92ad5117c989b474df61de29f760233a60adf06cb60dd548842",
                ("2.29.2", "linux-mips64"): "3fc4917fb8ff0371473ca987270c66fc89a450b513af4ff932a24fe34b3cb387",
                ("2.29.2", "linux-mips64le"): "87afa73e0e5d3f772eabe874ac0fab29b493654dc7845e69a4c447331bba6cf3",
                ("2.29.2", "linux-mipsle"): "a81c80c1c16ece9f2409ae866ffd7eae180fba732708d4709203271b68eaf5eb",
                ("2.29.2", "linux-ppc64"): "22b133b111626fbbe2c22e0ecf2803b2786ed8d5325a3005e8938c6f8374b39f",
                ("2.29.2", "linux-ppc64le"): "51c977e15dca823dd79da52d0af7182648a7ff5c4c77932540d7905931d073a6",
                ("2.29.2", "linux-s390x"): "39e5fab1821f11f8a89793013f0392a5da9824f0d19870406422ace510e0f640",
                ("2.29.2", "netbsd-386"): "645e143784172c518965721cf067faa4498861d136c8a5e8834627d1fdf401b6",
                ("2.29.2", "netbsd-amd64"): "374e37d12b7a791265416693e4ce058400995c0b746e9c23eba672b0f008bfc1",
                ("2.29.2", "netbsd-arm64"): "334854973a8f7ed65eccaed82e337ecb63fcb94fe9d00d19de66f52bb015e2fc",
                ("2.29.2", "netbsd-armv6"): "3d2c5c42ca372a317136f96758d8ad635fc60d174c7e6958be4ed9201d0b6199",
                ("2.29.2", "netbsd-armv7"): "2d5a86ba651b752bafb9c9e2a625d54e7c28805615a66fb4972c5e657b667947",
                ("2.29.2", "openbsd-386"): "971320e25ec0056a0f1bac83b9313c150ab708513fa52085265a9399cf98b5c1",
                ("2.29.2", "openbsd-amd64"): "294260afe9c59afe8dbed062aba1a0863009a9f67b8fac4937d9fc0b18de10a2",
                ("2.29.2", "openbsd-arm64"): "2914cf1bfcbf4d70838345cc8f333a44fcd99b07189b6a34e9c0c6719b25a695",
                ("2.29.2", "openbsd-armv7"): "bfc5c375b34c07e847b1ce4b8934079156efbfb0cf0699fa89d3dfa9ddd65b30",
                ("2.29.2", "windows-386"): "ed557402f6165b1d85d1281af3d156337ef4fb5677a099d897228e08170bc951",
                ("2.29.2", "windows-amd64"): "924b52ad4f12f8e3b74a8e151c30bc5b7fbb866934c9dfba013509e3f2b38a62",
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
                ("0.22.2", "darwin-amd64"): "2629b6a598e3d16726cfbaec1debdcaf62dcf60ed2b52b2b18bb794e3a5b2e63",
                ("0.22.2", "darwin-arm64"): "76c4b15189ccd9501ac7a3e30cc02447a08f78c8087bed2da17d29334a0c2927",
                ("0.22.2", "dragonfly-amd64"): "c75625695d3afacdb89eff34001f5c0f85d8607502dd4eaeec1c0b8fe5e5218e",
                ("0.22.2", "freebsd-386"): "dccd8a844bb03200d8e7fe42293c083f96fe5d4402b33f39b87133cf2bacea77",
                ("0.22.2", "freebsd-amd64"): "0a7541595c713091dd1bba800281e6e3abe69073dbd1906019c1e285215f7d6a",
                ("0.22.2", "freebsd-arm64"): "149e62254a03b607c860ba8655d9321085c36222a58f97a688f58801fbdd05d9",
                ("0.22.2", "freebsd-armv6"): "7383eb8c630ffa46953cf8599888a8cbff0ca1bcb5f3ef6aa0cb6b03471c50f2",
                ("0.22.2", "freebsd-armv7"): "081f79abf5a953db2b5153ac21df9b39627aad43c54daee1e887b08e9a911895",
                ("0.22.2", "illumos-amd64"): "2522272c404580c5a59634f75315ddb85780a9b2e14894a583093d6d8caf9ecd",
                ("0.22.2", "linux-386"): "d4248d2bb47bbd891de9f092f129a65246ef4cb32538c97824b9fec34b867d40",
                ("0.22.2", "linux-amd64"): "9c3b1cce9c74f5cecb07ec4a636111ca52696c0a088dbaecf338594d6e55cd1a",
                ("0.22.2", "linux-arm64"): "2592ba596b59a69db397987fc2ee1c4a91dddb63b92bada692270203d183e5f1",
                ("0.22.2", "linux-armv5"): "c48a20f14ca4ae6ced976752a115f0687ecd734a873f0393afd6f7ab6159bdbe",
                ("0.22.2", "linux-armv6"): "8d31f59b52f69a77f869bd124e87a5fc9434a9f4fce5325a980d35acd269f71c",
                ("0.22.2", "linux-armv7"): "514e0629fed4594d14e9c1f3466fecb7e38f692a7b63772d7b6826bdbe071665",
                ("0.22.2", "linux-mips"): "11e235fe01dbc5adbfaf355503ac0babbae7b2a00276a2770b8f4a01e9c55915",
                ("0.22.2", "linux-mips64"): "94101a86f2eb99e0b7c98b8154a17b8f1d443911c5e52cd51604ba92e59098d3",
                ("0.22.2", "linux-mips64le"): "c6c06e6468e09297e72af9896bbdb879aebf122a7118f9104243aadc976af350",
                ("0.22.2", "linux-mipsle"): "3df3c3064cc3e88f8bfc7c05b55e717acc21ea8d24517a58be96ef2cb44cb845",
                ("0.22.2", "linux-ppc64"): "dd03dc898aeaadeb29192f56be2da5bf785cc0075a0c4e94892f31c8363de7d5",
                ("0.22.2", "linux-ppc64le"): "0e8c79b4e80a4535ce4e9fae7913884429f55d1725852a43a2964d3b0847b9c8",
                ("0.22.2", "linux-s390x"): "38505aca84989ea3c8089f7d5e0663c826b977ce38dca1003e8b0bf14828d1ce",
                ("0.22.2", "netbsd-386"): "218311641781781871ea2a5699732c771ed76a6f281bd67b3f8a024afa06efa6",
                ("0.22.2", "netbsd-amd64"): "2bfab1d64bff8578e1edc1efde5c692ce03f07c75e0768c785e53066366fdb4a",
                ("0.22.2", "netbsd-arm64"): "94049615dc7a92f959579d4175852385049d2a6ebbe38d6e9bd9d97287c39189",
                ("0.22.2", "netbsd-armv6"): "ab2ca08e6b16100fe52f8c83d53fe33c70e8302488f4389c23b1c70e07e842c7",
                ("0.22.2", "netbsd-armv7"): "88faa3ea904c4be57fc537dc2b7dc492ab7f17817f3d7ebcd7221a7d171036c4",
                ("0.22.2", "openbsd-386"): "b13b00d77248b3b39324ce5ed03ee9a628bb24345d33be3a78b3e0a7c736f4b0",
                ("0.22.2", "openbsd-amd64"): "b40fae31909ada235e213e03a638f25028a8655feaca907a6c7688309a6bb688",
                ("0.22.2", "openbsd-arm64"): "747e05d7d4e1a73cb343db42485753616bbf82605f57cc85735ed5022b67b36e",
                ("0.22.2", "openbsd-armv7"): "7fd037a22b39f9f0f3f4b671059d0ad8881d326d7a5f50d152146799a37c6ebe",
                ("0.22.2", "windows-386"): "78e45056b359c78b3e67b443e127d6c25a8fc6b7776c64aea82ad6f386cf98bf",
                ("0.22.2", "windows-amd64"): "98b8b66ff8818c64452a54041c1d388af2f0be124dc3bac801ce095744e6e66b",
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
