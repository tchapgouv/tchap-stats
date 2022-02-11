CREATE TABLE IF NOT EXISTS subscriptions_aggregate (
  subscriptions INTEGER NOT NULL,
  domain VARCHAR NOT NULL,
  hour timestamp with time zone NOT NULL,
  instance VARCHAR NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_stats ON subscriptions_aggregate (domain, hour, instance);

CREATE TABLE IF NOT EXISTS events_aggregate (
  events INTEGER NOT NULL,
  type VARCHAR NOT NULL,
  domain VARCHAR NOT NULL,
  hour timestamp with time zone NOT NULL,
  instance VARCHAR NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_stats ON subscriptions_aggregate (domain, hour, instance, type);
