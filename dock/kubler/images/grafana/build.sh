#
# Kubler phase 1 config, pick installed packages and/or customize the build
#
_packages=""
_grafana_version="4.2.0"

configure_bob()
{
    # grafana 4.2.x requires go 1.8
    update_keywords 'dev-lang/go' '+~amd64'
    emerge -v net-libs/nodejs dev-lang/go
    export DISTRIBUTION_DIR=/go/src/github.com/grafana/grafana
    mkdir -p "${DISTRIBUTION_DIR}"
    export GOPATH=/go
    export PATH="${PATH}:/go/bin"
    git clone https://github.com/grafana/grafana.git "${DISTRIBUTION_DIR}"
    cd "${DISTRIBUTION_DIR}"
    git checkout "tags/v${_grafana_version}"
    echo "building grafana.."
    go run build.go build

    npm install
    npm install -g grunt-cli gyp
    #TODO: release fails due to not being able to execute phantomjs tests, figure out how to skip those for release target
    #grunt release
    grunt --force

    mkdir -p "${_EMERGE_ROOT}"/opt/grafana/{bin,conf,data}
    cp -rp "${DISTRIBUTION_DIR}"/public_gen "${_EMERGE_ROOT}"/opt/grafana/
    cp "${DISTRIBUTION_DIR}"/conf/defaults.ini "${_EMERGE_ROOT}"/opt/grafana/conf/
    cp "${DISTRIBUTION_DIR}"/conf/sample.ini "${_EMERGE_ROOT}"/opt/grafana/conf/custom.ini
    cp "${DISTRIBUTION_DIR}"/bin/* "${_EMERGE_ROOT}"/opt/grafana/bin
}

#
# This hook is called just before starting the build of the root fs
#
configure_rootfs_build()
{
    init_docs "kubler/grafana"
}

#
# This hook is called just before packaging the root fs tar ball, ideal for any post-install tasks, clean up, etc
#
finish_rootfs_build()
{
    log_as_installed "manual install" "grafana-${_grafana_version}" "https://github.com/grafana/grafana/"
}
