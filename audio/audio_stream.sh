#!/bin/bash

function run_forever() {
    while 'true'
    do
      echo "Execute '$@'"
      "$@"
      sleep 1
    done
}

case "$AUDIO_TYPE" in
    "opus")
         echo "Starting OPUS WS Audio"
         uwsgi --http-socket :6082 --gevent 4 --wsgi-file /app/audio_proxy.py
         ;;
    "raw")
         echo "Starting PCM WS Audio"
         run_forever /app/ffmpeg -re -f pulse -i default -ac 1 -ab 64k -ar 44100 -listen 1 -f u8 tcp://0.0.0.0:4720 > /tmp/ffmpeg.log 2>&1 &
         ;;
    "webrtc")
         echo "Starting WebRTC Audio"
         OTHER_ARGS=""
         if [ -n "${WEBRTC_STUN_SERVER}" ]; then
           OTHER_ARGS="${OTHER_ARGS} --stun-server ${WEBRTC_STUN_SERVER}"
         fi
         if [ -n "${WEBRTC_TURN_SERVER}" ]; then
           OTHER_ARGS="${OTHER_ARGS} --turn-server ${WEBRTC_TURN_SERVER}"
         fi
         run_forever /app/webrtc-send-webrecorder --signaling-server $WEBRTC_SIGNALING_SERVER --peer-id $REQUEST_ID ${OTHER_ARGS}
         ;;
esac