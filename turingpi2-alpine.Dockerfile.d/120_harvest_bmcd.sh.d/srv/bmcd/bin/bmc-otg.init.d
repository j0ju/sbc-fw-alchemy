#!/sbin/openrc-run

name="${RC_SVCNAME}"

depend() {
    need sysfs dev
    use logger
    after firewall
}

name="bmc-otg"
udc=$(ls /sys/class/udc 2>/dev/null)
usb_gadget="/sys/kernel/config/usb_gadget/g1"
udc_config="${usb_gadget}/UDC"
serial=$(cat /proc/device-tree/serial-number)
model=$(cat /proc/device-tree/model)
acm_configured="/tmp/.bmc-otg-configured"

update_udc() {
    current_udc=$(cat $udc_config)
    new_udc=$1
    if [ "$current_udc" != "$new_udc" ]; then
        echo "$1" > $udc_config
    fi

    result=$?
    if [ "$result" -eq 0 ]; then
        echo "OK"
    else
        echo "FAIL"
    fi
}

setup_configuration() {
    mount -t configfs none /sys/kernel/config > /dev/null 2>&1
    mkdir -p $usb_gadget
    cd $usb_gadget

    echo "0x08DE" > idVendor
    echo "0x1234" > idProduct
    mkdir -p strings/0x409
    echo "$serial" > strings/0x409/serialnumber
    echo "Turing Machines" > strings/0x409/manufacturer
    echo "$model" > strings/0x409/product
    mkdir -p functions/acm.usb0
    mkdir -p configs/c.1
    mkdir -p configs/c.1/strings/0x409
    echo "$name" > configs/c.1/strings/0x409/configuration
    ln -s functions/acm.usb0 configs/c.1
}

start() {
    if [ ! -e "${acm_configured}" ]; then
       setup_configuration && touch "$acm_configured"
    fi
    update_udc "$udc"
}
stop() {
    update_udc ""
}
