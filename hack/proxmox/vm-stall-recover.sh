#!/usr/bin/env bash
# Ref: https://forum.proxmox.com/threads/is-there-a-way-to-instruct-proxmox-to-automatically-restart-a-vm-after-a-crash.134358/

# pings qemu-agent and restarts VM on ANY error
# First, check uptime so things can start
if [ $(cut -d '.' -f1 /proc/uptime) -gt 600 ]
then
  VM="100 999"

  for VMID in $VM; do
    /usr/sbin/qm agent $VMID ping || (/usr/sbin/qm unlock $VMID; /usr/sbin/qm stop $VMID; /usr/sbin/qm start $VMID)
  done
fi
