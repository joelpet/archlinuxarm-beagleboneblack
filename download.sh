#!/bin/bash

readonly WORKDIR="$(mktemp --directory --suffix=alarm_bbb)"
readonly GPG_KEY_ID=68B3537F39A313B3E574D06777193F152BDBE6A6

readonly E_CD_WORKDIR=2

main() {
    curl_files
    check_md5
    receive_gpg_key
    verify_signature
}

curl_files() {
    (
        cd "${WORKDIR}" || exit "${E_CD_WORKDIR}"
        curl --location --remote-name http://os.archlinuxarm.org/os/ArchLinuxARM-am33x-latest.tar.gz
        curl --location --remote-name http://os.archlinuxarm.org/os/ArchLinuxARM-am33x-latest.tar.gz.md5
        curl --location --remote-name http://os.archlinuxarm.org/os/ArchLinuxARM-am33x-latest.tar.gz.sig
    )
}

check_md5() {
    (
        cd "${WORKDIR}" || exit "${E_CD_WORKDIR}"
        md5sum --check ArchLinuxARM-am33x-latest.tar.gz.md5
    )
}

receive_gpg_key() {
    gpg --receive-keys "${GPG_KEY_ID}"
}

verify_signature() {
    (
        cd "${WORKDIR}" || exit "${E_CD_WORKDIR}"
        gpg --verify ArchLinuxARM-am33x-latest.tar.gz.sig
    )
}

main
