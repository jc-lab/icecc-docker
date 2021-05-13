#!/bin/bash

set -e

[ -z "${ICECC_MODE}" ] && ICECC_MODE=daemon || true
ICECC_MODE=${ICECC_MODE,,}
USE_TMPFS=${USE_TMPFS,,}

echo "ICECC_MODE=${ICECC_MODE}"

if [ "${ICECC_MODE}" == "daemon" ]; then
	if [ "x${USE_TMPFS}" = "xy" ]; then
		mount -t tmpfs -o "${TMPFS_MOUNT_OPTIONS}" tmpfs /var/tmp
	fi
	iceccd -m ${JOBS} $@
elif [ "${ICECC_MODE}" = "scheduler" ]; then
	icecc-scheduler --port ${ICECC_SCHEDULER_PORT} $@
else
	>&2 echo "Unknown mode: ${ICECC_MODE}"
	exit 1
fi

