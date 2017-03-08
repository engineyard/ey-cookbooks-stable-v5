# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Modified by EngineYard to install under /opt

EAPI=6

DESCRIPTION="Fast, reliable, and secure node dependency management"
HOMEPAGE="https://yarnpkg.com"
SRC_URI="https://github.com/yarnpkg/yarn/releases/download/v${PV}/yarn-v${PV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="!dev-util/cmdtest
        net-libs/nodejs"
DEPEND="${RDEPEND}"

S="${WORKDIR}/dist"

src_install() {
    local install_dir="/opt/yarn/${PV}"
    local current_dir="/opt/yarn/current"
    insinto "${install_dir}"
    doins -r .
    dosym "${install_dir}" "${current_dir}"
    dosym "${current_dir}/bin/yarn" "/usr/bin/yarn"
    fperms a+x "${install_dir}/bin/yarn"
    dosym "${current_dir}/bin/yarnpkg" "/usr/bin/yarnpkg"
    fperms a+x "${install_dir}/bin/yarnpkg"
}
