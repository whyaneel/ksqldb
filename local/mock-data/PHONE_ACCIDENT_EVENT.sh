# shellcheck disable=SC2016

curl -X POST \
  http://0.0.0.0:8082/topics/PHONE_ACCIDENT_EVENT \
  -H 'accept: application/vnd.kafka.v2+json' \
  -H 'content-type: application/vnd.kafka.json.v2+json' \
  --silent --output /dev/null \
  -d '{
    "records": [
      {
        "value": {
          "CUSTOMER_NAME": "Debbie",
          "PHONE_MODEL": "Samsung Note 20",
          "EVENT": "water",
          "STATE": "NSW",
          "LONG": 151.24504,
          "LAT": -33.89640
        }
      }, {
        "value": {
          "CUSTOMER_NAME": "Lindsey",
          "PHONE_MODEL": "iPhone 11 Pro",
          "EVENT": "dropped",
          "STATE": "NSW",
          "LONG": 151.25664,
          "LAT": -33.85995
        }
      }
    ]
  }'