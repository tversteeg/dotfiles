rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.usb-Audient_Audient_iD4-00" },
    },
  },
  apply_properties = {
    ["node.nick"] = "Audient",
  },
}
table.insert(alsa_monitor.rules, rule)

rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.usb-046d_HD_Webcam_C525_9D9C2AD0-00" },
    },
  },
  apply_properties = {
    ["node.nick"] = "Webcam",
  },
}
table.insert(alsa_monitor.rules, rule)

rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.usb-046d_HD_Webcam_C525_9D9C2AD0-00" },
    },
  },
  apply_properties = {
    ["node.nick"] = "Webcam",
  },
}
table.insert(alsa_monitor.rules, rule)

rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.pci-0000_2d_00.1" },
    },
  },
  apply_properties = {
    ["node.nick"] = "NVidia",
  },
}
table.insert(alsa_monitor.rules, rule)

rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.pci-0000_25_00.0" },
    },
  },
  apply_properties = {
    ["node.nick"] = "Soundcard",
  },
}
table.insert(alsa_monitor.rules, rule)

rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.pci-0000_2f_00.4" },
    },
  },
  apply_properties = {
    ["node.nick"] = "Motherboard",
  },
}
table.insert(alsa_monitor.rules, rule)