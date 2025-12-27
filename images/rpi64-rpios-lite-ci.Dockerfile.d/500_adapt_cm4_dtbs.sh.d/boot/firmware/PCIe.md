# What about crashes on PCIe errors?

Try in /boot/firmware/cmdline.txt this
 * pcie_aspm=off
 * config.txt
   [cm4]
   dtoverlay=cm4-pcie-l1ss.dtso
 * pcie_ports=compat
 * pcie_port_pm=off

# Debugging aid

Use early con
