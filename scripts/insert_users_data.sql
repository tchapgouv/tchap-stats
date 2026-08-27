
/* start of pipeline
https://github.com/tchapgouv/tchap-infra/blob/master/ansible/roles/matrix-synapse-stats/templates/views/users_views.sql.j2
(user_id, u.creation_ts as hour, u.deactivated, regexp_replace(u.name, '^.+-([^-:]+):.*$', '\1') as domain, u.instance)
*/

CREATE TEMPORARY TABLE users_temp (
    user_id VARCHAR, 
    creation_ts timestamp with time zone, 
    deactivated INTEGER,
    domain VARCHAR,
    instance VARCHAR
);

\copy users_temp(user_id, creation_ts, deactivated, domain, instance) FROM '/app/subscriptions_aggregate.csv' DELIMITER ',' CSV HEADER;

INSERT INTO users
SELECT *
FROM users_temp
ON CONFLICT DO NOTHING
