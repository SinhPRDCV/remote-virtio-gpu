#!/bin/bash

CARD_LIST=($(ls /dev/dri | grep card))
GL_PID=-1


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
		GL_PID=$!
		echo GL_PID=$GL_PID
		sleep 1
		disown -a
		#jobs -l

		while [ -e /proc/$GL_PID ]
		do
		    sleep .5
		done
		break
	fi
done

if [ -z "$VIR_CARD" ] ; then
    echo "Don't have virtual GPU for running"
    exit 1
fi


