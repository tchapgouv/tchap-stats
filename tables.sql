CREATE TABLE IF NOT EXISTS subscriptions_aggregate (subscriptions INTEGER, domain VARCHAR, hour timestamp  with time zone, instance VARCHAR);
-- CREATE UNIQUE INDEX ON subscriptions_aggregate (domain, hour, instance)