#!/bin/bash

CARD_LIST=($(ls /dev/dri | grep card))

exit_script() {
    echo "Received signal: $1"
    sudo pkill glmark2-es2-drm
	
    # Do stuff to clean up
}


#for i in 1 2 3 5 9 15 19
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
do
    trap 'exit_script $i' $i
done

if !($(loginctl seat-status seat_virtual >> /dev/null)) ; then
	echo "seat_virtual isn't exist"
	exit 1
fi

STR=$(loginctl seat-status seat_virtual)

f() { CARD_LIST=("${BASH_ARGV[@]}"); }

shopt -s extdebug
f "${CARD_LIST[@]}"
shopt -u extdebug


VIR_CARD=""

for CARD in ${CARD_LIST[@]}
do
	CARD=${CARD//$'\n'/}
	DRM_CARD="drm:$CARD"
	if [[ "$STR" == *"$DRM_CARD"* ]]; then
		echo "$CARD is newest virtual card"
		VIR_CARD="/dev/dri/$CARD"
		echo Run glmark2 command
		sudo LD_LIBRARY_PATH=/usr/lib/mesa-virtio ~/AGL/glmark2/build/src/glmark2-es2-drm --device-path=$VIR_CARD -s 800x600 --visual-config red=8 --expected-fps=5 &
		wait $!
		#disown -a
		break
	fi
done

if [ -z "$VIR_CARD" ] ; then
    echo "Don't have virtual GPU for running"
    exit 1
fi


