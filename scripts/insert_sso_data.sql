/* Insert data from the csv file into the DB. */
/* total_users	domain	instance	users_legacy	users_both_authentication	users_proconnect */
/* import workflow : https://github.com/tchapgouv/tchap-infra/blob/master/ansible/roles/matrix-synapse-stats/files/export_sso_stats */

CREATE TEMPORARY TABLE sso_aggregate_temp (
total_users INTEGER,
domain VARCHAR,
instance VARCHAR,
users_legacy INTEGER,
users_both_authentication INTEGER,
users_proconnect INTEGER
);

-- CSV file has fields in this order : total_users	domain	instance	users_legacy	users_both_authentication	users_proconnect
-- If it changes, change this line or it will break.
\copy sso_aggregate_temp(total_users, domain, instance, users_legacy, users_both_authentication, users_proconnect) FROM '/app/sso.csv' DELIMITER ',' CSV HEADER;


INSERT INTO sso_aggregate
SELECT *
FROM sso_aggregate_temp
ON CONFLICT DO NOTHING;
