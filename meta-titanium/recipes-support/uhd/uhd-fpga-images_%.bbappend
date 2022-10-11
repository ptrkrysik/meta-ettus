inherit uhd_images_downloader

UHD_BASE_URL_ni-titanium ??= "http://localhost:9900/files.ettus.com/binaries/cache/"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_ni-titanium = " \
    file://set-symlinks.py \
    "

EXTRA_PACKAGES_ni-titanium ?= " \
    ${PN}-x411 \
    ${PN}-inventory \
    "

PACKAGES_append_ni-titanium = " \
    ${EXTRA_PACKAGES} \
    ${PN}-x411-firmware \
    "
RDEPENDS_${PN}_ni-titanium = "${EXTRA_PACKAGES}"
RDEPENDS_${PN}-firmware_append_ni-titanium = " \
    ${PN}-x411-firmware \
    "

RPROVIDES_${PN}-x411 = "${PN}-titanium"
RPROVIDES_${PN}-x411-firmware = "${PN}-titanium-firmware"

DEFAULT_BITFILE_NAME_ni-titanium = "usrp_x411_fpga_X4_200"

FILES_${PN}-x411 = " \
    ${UHD_IMAGES_INSTALL_PATH}/usrp_x411_fpga*.* \
    "
FILES_${PN}-inventory = "${UHD_IMAGES_INSTALL_PATH}/inventory.json"
FILES_${PN}-x411-firmware = " \
    /lib/firmware/x411.bin \
    /lib/firmware/x411.dtbo \
    "

UHD_IMAGES_TO_DOWNLOAD_ni-titanium ?= " \
    ${@ '' if d.getVar('EXTERNALSRC') else 'x4xx_x411_fpga_default'} \
    "

UHD_FPGA_IMAGES_IN_FIRMWARE_ni-titanium ?= "${DEFAULT_BITFILE_NAME}"

UHD_IMAGES_DOWNLOAD_DIR_ni-titanium ?= "${WORKDIR}/uhd-images"
FPGA_SUBDIRECTORY ??= ""

do_download_uhd_images_append_ni-titanium() {
    if [ -n "${EXTERNALSRC}" ]; then
        ln -sf "${S}/${FPGA_SUBDIRECTORY}/${DEFAULT_BITFILE_NAME}.bit" "${UHD_IMAGES_DOWNLOAD_DIR}/${DEFAULT_BITFILE_NAME}.bit"
        ln -sf "${S}/${FPGA_SUBDIRECTORY}/${DEFAULT_BITFILE_NAME}.dts" "${UHD_IMAGES_DOWNLOAD_DIR}/${DEFAULT_BITFILE_NAME}.dts"
    else
        python3 ${WORKDIR}/set-symlinks.py -i ${UHD_IMAGES_DOWNLOAD_DIR} -d ${UHD_IMAGES_DOWNLOAD_DIR}
    fi
}

do_install_append_ni-titanium() {
    install -d ${D}/${UHD_IMAGES_INSTALL_PATH}
    install -m 0644 ${UHD_IMAGES_DOWNLOAD_DIR}/usrp_x411_fpga*.* ${D}/${UHD_IMAGES_INSTALL_PATH}
    install -m 0644 ${UHD_IMAGES_DOWNLOAD_DIR}/inventory.json    ${D}/${UHD_IMAGES_INSTALL_PATH}

    mv ${D}/lib/firmware/${DEFAULT_BITFILE_NAME}.bin ${D}/lib/firmware/x411.bin
    mv ${D}/lib/firmware/${DEFAULT_BITFILE_NAME}.dtbo ${D}/lib/firmware/x411.dtbo
}
