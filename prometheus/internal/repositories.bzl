load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":toolchain.bzl", "prometheus_register_toolchains")

# documented sha/arch pair so i won't have to search for em next time

# 0c631ec66d4abf1be936707dde7b0be37b4e5805fdd21b77093765037dc8e5da  prometheus-2.24.0.darwin-amd64.tar.gz
# fbf48e9f2063ddcd30094b10b799dba7238d8ae44a860b95bf2bfabb41114edb  prometheus-2.24.0.dragonfly-amd64.tar.gz
# 04ecd738edcd5b82310a61251769c8a89926dc9b078499b2ee8a4c546e7b78aa  prometheus-2.24.0.freebsd-386.tar.gz
# 23912892fe50a7f34da820a33c0d79ef309b8687781cbfa0064038db5eecda57  prometheus-2.24.0.freebsd-amd64.tar.gz
# 9206447001cc24ea62fbaeaf7ba0ebe754ab07d4655ee32e5ecd28257eba4710  prometheus-2.24.0.freebsd-armv6.tar.gz
# 137c6ec5635968215c1f3dcf48c542d5d35d360df35a2b3e6f70b8bc860968b5  prometheus-2.24.0.freebsd-armv7.tar.gz
# 83b4b6b9d0465d01c2b5d4a9ad836ecf605795877fab4351b81155f74bf7f727  prometheus-2.24.0.linux-386.tar.gz
# e54c37eb30879f5b6416b11a96217a1dfcff65e0eca1ab5ce7b783b940cfe0eb  prometheus-2.24.0.linux-amd64.tar.gz
# 275bdb4b84fb79d5930f48d27cf94930dff48047fe6400a3cd5e104957a38624  prometheus-2.24.0.linux-arm64.tar.gz
# 3cf37c5b7fcc8826446ad6dc702316a9bafade7ff1d40d65bf8c8bd69cc4e710  prometheus-2.24.0.linux-armv5.tar.gz
# 5d639ab4ca71c91700ddf50454ac3a838e13c1d450ff936f959ea7f360efeb4e  prometheus-2.24.0.linux-armv6.tar.gz
# a85ff3242a70f09213c57377c16c5ffd2f20918d9bbb4ca42fd8ff19b6363610  prometheus-2.24.0.linux-armv7.tar.gz
# 580401c2a03825c835c662a578bc78eb1ed1685bfd328919591013dda7a84051  prometheus-2.24.0.linux-mips64.tar.gz
# 0a2c7f4357573cb4e3674a40885539b588d6f1cb931b1e17dd2faa7233198341  prometheus-2.24.0.linux-mips64le.tar.gz
# 6f1a74eb2d2298b52a2dda1f5582aff7c4ded1f7a32667bf3e46b5c277328225  prometheus-2.24.0.linux-ppc64.tar.gz
# c9b33483a6bf4704ae827e419a76f583013e0aa830eb7fd747410a7be61282cc  prometheus-2.24.0.linux-ppc64le.tar.gz
# 02585882b2f7cb308a9d8fc46928e1c0a336b9a5aff18e0a3bed3abb4df3f94e  prometheus-2.24.0.linux-s390x.tar.gz
# 701be87c8433be1d790599949048bd1d3a829e7728ea8a816a289fa6e0c8ebec  prometheus-2.24.0.netbsd-386.tar.gz
# 1d8829626470386c628d8bf719da523ecb2ea4d7657eecbeb4defcfd78fe2fc9  prometheus-2.24.0.netbsd-amd64.tar.gz
# 52663422c3a34a1f7dabac53bfa4368b99afef0cfee9399a4c101594de95b2e2  prometheus-2.24.0.netbsd-armv6.tar.gz
# a94022bbff274b46c8f82ca774a60b0bce44533914b6bcc9b493fc6c9efa88a1  prometheus-2.24.0.netbsd-armv7.tar.gz
# b74bd125a1d07f9dafbf96aebc9e221aa09d7786505fe3f642cab54551ad077d  prometheus-2.24.0.openbsd-386.tar.gz
# c5c041701aa0d2c85cfa91dfcdd1ae4d9b3e6b8659d8ffe8f594c3f9b440f816  prometheus-2.24.0.openbsd-amd64.tar.gz
# ce855cee94de7e367a32e682e231a024fa558c1d760cbe118ae1668c311ed985  prometheus-2.24.0.openbsd-armv7.tar.gz
# 23de4b41f575aa120e282b0799f19fc7de34095e9d643140a3fdb614371551dd  prometheus-2.24.0.windows-386.tar.gz
# 0c57fad8c70264eda001745e7826d5c18a07ce44f200853cc1990bea0a7b8764  prometheus-2.24.0.windows-386.zip
# df74b5abbf78b4b5f194b67c9696e7c2974ae1288ecaac345838cfa668406be4  prometheus-2.24.0.windows-amd64.tar.gz
# 6b4c5cc0eeb9112ade969f6d7f9441ba26e8a5b4c07c3bb905467f6a2db0c532  prometheus-2.24.0.windows-amd64.zip

# 1d2af6bcebf6de204bca2ed650133883eb2f35844000299248ab9efce77e1b77  alertmanager-0.21.0.darwin-386.tar.gz
# b508eb6f5d1b957abbee92f9c37deb99a3da3311572bed34357ac8acbb75e510  alertmanager-0.21.0.darwin-amd64.tar.gz
# 8531f3b02d788df4fabe333dc75a558cd92c51c4c8280d5a27dbaa0efb390f66  alertmanager-0.21.0.dragonfly-amd64.tar.gz
# bd554804e0240b1cba8d3f9f1bb5cfde6f1c815ec3b77e83e617808ca0983420  alertmanager-0.21.0.freebsd-386.tar.gz
# 1fe3f1fcdebb055d464d24865743f996843166bb7c8f3cea114887f5bb283b2d  alertmanager-0.21.0.freebsd-amd64.tar.gz
# 3cc30810003e21d06f1f5534a284bacf077d04bc8f86e4b82f6b189d45d248df  alertmanager-0.21.0.freebsd-armv6.tar.gz
# dec886a05913e210a8b0f109e713b6f394d2afddb5395da045a8823d2d7f9c83  alertmanager-0.21.0.freebsd-armv7.tar.gz
# cfa6090466b530ea7501fcded4a186516cac22c149cda1f50dd125177badff9d  alertmanager-0.21.0.linux-386.tar.gz
# 9ccd863937436fd6bfe650e22521a7f2e6a727540988eef515dde208f9aef232  alertmanager-0.21.0.linux-amd64.tar.gz
# 1107870a95d51e125881f44aebbc56469e79f5068bd96f9eddff38e7a5ebf423  alertmanager-0.21.0.linux-arm64.tar.gz
# 1778ac52bbbb99a9914b3fb9b0f39c35046cf9a2540568f80ea03efc603b00be  alertmanager-0.21.0.linux-armv5.tar.gz
# 03282900bf3ddce77f236872f4c8e2cf91f7b8b9b7e80eec845841930723a900  alertmanager-0.21.0.linux-armv6.tar.gz
# d7b41a15d90fedf3456969b158ddaea591d7d22d195cc653738af550706302b6  alertmanager-0.21.0.linux-armv7.tar.gz
# caad406dc86ad36b0f282a409757895d66206da47aae721f344ebad3bf257f7a  alertmanager-0.21.0.linux-mips64.tar.gz
# 060f0af52a471bdc2fd017f2752d945ddd47a030d5c94fe3c37d1fb74693906c  alertmanager-0.21.0.linux-mips64le.tar.gz
# adc949faa23a8a34cc5fe5fa64f62777cb35d0055df303804f767b77c662ad3f  alertmanager-0.21.0.linux-ppc64.tar.gz
# afc649eb16299f1957034ff14450fe18507de6d43f7b36383373c678974a09ed  alertmanager-0.21.0.linux-ppc64le.tar.gz
# 5a71fae41f8a2abf6b34825f16a7ea625fede6d2e9679111147d15aa8446ab38  alertmanager-0.21.0.linux-s390x.tar.gz
# e1db656dd4b6b4f9cb16505591ce10b76ca3106582786dd7ea71560a6e4e7a53  alertmanager-0.21.0.netbsd-386.tar.gz
# aa29c15a464ddfdb40dff77e81634a6c81150e8b601ff11c82f05c5b2b4876d4  alertmanager-0.21.0.netbsd-amd64.tar.gz
# 26d68e39479beb3c040bf6ef995d5c58d0b3523688219d84ce10eb9620622611  alertmanager-0.21.0.netbsd-armv6.tar.gz
# d25f311f76df28fa82c01c527fabaa646b24a48120938d57b3116382f4b8cf65  alertmanager-0.21.0.netbsd-armv7.tar.gz
# 6bdb03cd3c36a27b523f411e7370606c84214e53a75b740a2f1e07c77ed7c52a  alertmanager-0.21.0.openbsd-386.tar.gz
# ffd4fde08ff1236d37eabb10a6d1896404f06ebf8c5fd4c15c322b67a628f6a5  alertmanager-0.21.0.openbsd-amd64.tar.gz
# 16797370f99db1d10aec642c4f266eb7d051bfaa874d17caf3041141a64cd26f  alertmanager-0.21.0.windows-386.tar.gz
# 12c9a77d904bd7982e7ceacfbe9106e725e31536913c491e7b2703f9ddff4aa2  alertmanager-0.21.0.windows-amd64.tar.gz

_ALERTMANAGER_BUILD_FILE_CONTENTS = """
exports_files([
    "alertmanager",
    "amtool",
])
"""

_PROMETHEUS_BUILD_FILE_CONTENTS = """
exports_files([
    "prometheus",
    "promtool",
])
"""

_PROMETHEUS_BINARIES_PLATFORMS_MAP = {
    "darwin-amd64": {
        "prometheus": {
            "sha256": "0c631ec66d4abf1be936707dde7b0be37b4e5805fdd21b77093765037dc8e5da",
            "url": (
                "https://github.com/prometheus/prometheus/releases/download/" +
                "v{version}/prometheus-{version}.darwin-amd64.tar.gz"
            ),
        },
        "alertmanager": {
            "sha256": "b508eb6f5d1b957abbee92f9c37deb99a3da3311572bed34357ac8acbb75e510",
            "url": (
                "https://github.com/prometheus/alertmanager/releases/download/" +
                "v{version}/alertmanager-{version}.darwin-amd64.tar.gz"
            ),
        },
    },
}

def prometheus_repositories(prometheus_version = "2.24.0", alertmanager_version = "0.21.0"):
    """Download dependency tools and initialize toolchains

    Args:
        prometheus_version: Prometheus package version to download from source repositories
        alertmanager_version: Alertmanager package version to download from source repositories
    """

    metadata = dict(_PROMETHEUS_BINARIES_PLATFORMS_MAP)

    for arch in metadata:
        http_archive(
            name = "prometheus_%s" % arch,
            sha256 = metadata[arch]["prometheus"]["sha256"],
            urls = [metadata[arch]["prometheus"]["url"].format(version = prometheus_version)],
            strip_prefix = "prometheus-{version}.{arch}".format(
                version = prometheus_version,
                arch = arch,
            ),
            build_file_content = _PROMETHEUS_BUILD_FILE_CONTENTS,
        )
        http_archive(
            name = "alertmanager_%s" % arch,
            sha256 = metadata[arch]["alertmanager"]["sha256"],
            urls = [metadata[arch]["alertmanager"]["url"].format(version = alertmanager_version)],
            strip_prefix = "alertmanager-{version}.{arch}".format(
                version = alertmanager_version,
                arch = arch,
            ),
            build_file_content = _ALERTMANAGER_BUILD_FILE_CONTENTS,
        )

    prometheus_register_toolchains()
