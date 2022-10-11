#!/bin/bash
sudo su <<EOF
modprobe virtio-gpu
modprobe virtio_lo
rm -rf /run/user/0
mkdir -p /run/user/0
export XDG_RUNTIME_DIR=/run/user/0
export LD_LIBRARY_PATH=/usr/lib/mesa-virtio:/usr/local/lib/
sudo /home/nghia/actions-runner/_work/remote-virtio-gpu/remote-virtio-gpu/build/src/rvgpu-proxy/rvgpu-proxy -s 800x600@0,0 -n 127.0.0.1:55667 -f 5 &
#disown -a

EOF
