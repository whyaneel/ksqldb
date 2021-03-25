# ksqlDB Simulation
A simple use case simulation from https://kafka-tutorials.confluent.io/geo-distance/ksql.html

Just **follow all the steps in sequence** to complete the simulation.

# Use Case
Suppose you work for a company that insures cellphones. The company records events that would result in an insurance claim, such as a customer dropping their phone in water. The company has data about where the event occurred and repair shop lat-long data. It's your job to recommend the repair shop to the customers in kilometers.

# Setup
### local Tab (Terminal Window)
```
cd local
```

### Docker Kafka Environment (local Tab)
```
docker-compose down --remove-orphans --volumes

docker-compose up
```
Wait till the setup is completed

### Kafka Topics Creation (local Tab)
```
docker exec demo-kafka kafka-topics --zookeeper demo-zookeeper:2182 --create --topic REPAIR_CENTER --partitions 1 --replication-factor 1 --if-not-exists

docker exec demo-kafka kafka-topics --zookeeper demo-zookeeper:2182 --create --topic PHONE_ACCIDENT_EVENT --partitions 1 --replication-factor 1 --if-not-exists
```

# ksqlDB
### ksql Tab (Terminal Window)
```
docker exec -it demo-ksqldb-cli ksql http://ksqldb-server:8089
```

### Create Stream (ksql Tab)
```
CREATE STREAM REPAIR_CENTER_STREAM
  (REPAIR_STATE VARCHAR, LONG DOUBLE, LAT DOUBLE)
  WITH (KAFKA_TOPIC='REPAIR_CENTER', VALUE_FORMAT='JSON');
```

### Data Ingestion (local Tab)
Have a look at mock data file to understand the structure of data.
```
./mock-data/REPAIR_CENTER.sh

./mock-data/REPAIR_CENTER.sh
```

### Observe Data from Stream
If this stream shows data, that means successful data ingestion and topic is correctly mapped to stream. As we are ingesting twice we see duplicates in stream.
```
SELECT * FROM REPAIR_CENTER_STREAM EMIT CHANGES;
```

### Create Table (ksql Tab)
```
CREATE TABLE REPAIR_CENTER_MVIEW AS SELECT
  REPAIR_STATE AS ROWKEY,
  LATEST_BY_OFFSET(LONG) AS LONG,
  LATEST_BY_OFFSET(LAT) AS LAT
FROM REPAIR_CENTER_STREAM
GROUP BY REPAIR_STATE
EMIT CHANGES;
```

### Observe Data from Materialized Cache (ksql Tab)
Materialized Cache always return single record based on aggregation, so there's no point of duplicates, it always overrides with new data.
```
SELECT * FROM REPAIR_CENTER_MVIEW WHERE ROWKEY='NSW';
```

### Create Stream (ksql Tab)
```
CREATE STREAM PHONE_ACCIDENT_EVENT_STREAM
  (CUSTOMER_NAME VARCHAR, PHONE_MODEL VARCHAR, EVENT VARCHAR, STATE VARCHAR, LONG DOUBLE, LAT DOUBLE)
  WITH (KAFKA_TOPIC='PHONE_ACCIDENT_EVENT', VALUE_FORMAT='JSON');
```

### Data Ingestion (local Tab)
Have a look at mock data file to understand the structure of data.
```
./mock-data/PHONE_ACCIDENT_EVENT.sh
```

### Observe Data from Stream (ksql Tab)
If this stream shows data, that means successful data ingestion and topic is correctly mapped to stream.
```
SELECT * FROM PHONE_ACCIDENT_EVENT_STREAM EMIT CHANGES;
```

### Create Stream with INNER JOIN (ksql Tab)
Existing data and new event data from stream `continuously` inner joined with repair center cache against the repair state field.

OOTB `GEO_DISTANCE` scalar function is used to calculate distance in `kms`
```
CREATE STREAM RECOMMENDED_CENTERS_TO_CUSTOMER_STREAM AS SELECT
  B.ROWKEY AS ROWKEY,
  A.CUSTOMER_NAME AS CUSTOMER,
  GEO_DISTANCE(A.LAT, A.LONG, B.LAT, B.LONG, 'KM') AS DISTANCE_IN_KM
FROM PHONE_ACCIDENT_EVENT_STREAM A INNER JOIN REPAIR_CENTER_MVIEW B ON A.STATE = B.ROWKEY
EMIT CHANGES;
```

### Data Ingestion (local Tab)
When any Phone Accident Event occurs it suggest the repair center in real time in stream `RECOMMENDED_CENTERS_TO_CUSTOMER_STREAM`, if matched with the repair state where repair center is and accident event occurs.
```
./mock-data/PHONE_ACCIDENT_EVENT.sh
```

### Bonus
- We can even send notification or email from this event data `RECOMMENDED_CENTERS_TO_CUSTOMER_STREAM` (fields like secondary mobile, email need to be captured as needed per use case)
- You can go throw examples listed to get some warmup https://ksqldb.io/examples.html
