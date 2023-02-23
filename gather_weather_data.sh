#!/bin/bash

WORKDIR=./work

POINTS=$(cat << EOS
大阪,34.698227,135.500565,0
伊賀,34.775296,136.130061,65
亀山,34.878701,136.520213,112
名古屋,35.122292,136.906316,165
豊橋,34.792976,137.370853,215
浜松,34.708081,137.741744,250
静岡,34.971360,138.385696,330
沼津,35.124038,138.792482,375
小田原,35.263137,139.181438,450
東京,35.684021,139.774521,520
EOS
)

STARTDATE=$(date --date '2 days ago' --utc --iso-8601)
ENDDATE=$(date --date '8 days' --utc --iso-8601)

mkdir -p ${WORKDIR}

for i in $POINTS; do
  #echo $i
  NAME=$(echo $i | cut -d',' -f1)
  LAT=$(echo $i | cut -d',' -f2)
  LON=$(echo $i | cut -d',' -f3)
  DIST=$(echo $i | cut -d',' -f4)

  URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&hourly=temperature_2m,precipitation,rain,showers,snowfall,weathercode,windspeed_10m,winddirection_10m&windspeed_unit=ms&start_date=${STARTDATE}&end_date=${ENDDATE}"
  while true; do
    wget "${URL}" --no-check-certificate --timeout 10 -t 30 -nv -O ${WORKDIR}/${NAME}_weather.json && break
  done
  echo '{"name":"'${NAME}'","dist":'${DIST}'}' > ${WORKDIR}/${NAME}_add.json
  jq -s add ${WORKDIR}/${NAME}_weather.json ${WORKDIR}/${NAME}_add.json > ${WORKDIR}/${NAME}_join.json

done

jq -s '' -c ${WORKDIR}/*_join.json | jq -s 'add' -c > weather-data.json
