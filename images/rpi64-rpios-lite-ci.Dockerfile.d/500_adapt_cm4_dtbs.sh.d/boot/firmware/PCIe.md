# What about crashes on PCIe errors?

Try in /boot/firmware/cmdline.txt this
 * 1st: pcie_aspm=off
 * 2nd: pcie_ports=compat
 * 3rd: pcie_port_pm=off
