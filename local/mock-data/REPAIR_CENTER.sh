# shellcheck disable=SC2016

curl -X POST \
  http://0.0.0.0:8082/topics/REPAIR_CENTER \
  -H 'accept: application/vnd.kafka.v2+json' \
  -H 'content-type: application/vnd.kafka.json.v2+json' \
  --silent --output /dev/null \
  -d '{
    "records": [
      {
        "value": {
          "repair_state": "NSW",
          "long": 151.1169,
          "lat": -33.863
        }
      }, {
        "value": {
          "repair_state": "VIC",
          "LONG": 145.1549,
          "LAT": -37.9389
        }
      }
    ]
  }'