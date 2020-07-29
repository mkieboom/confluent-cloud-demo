docker exec -i ksqldb-cli ksql -u QGL6R5MBMJRHV5GW -p TurUEYo/ELA1nCozFkPUkiIrTZ22Moj8vjD/r/4p2oz43Q9CeSW/FOINakTHXcUK https://pksqlc-42901.europe-west4.gcp.confluent.cloud:443 <<EOF
RUN SCRIPT '/ksqlqueries.sql';
exit
EOF
