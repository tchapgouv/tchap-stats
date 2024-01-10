

/* Crisp conversation segments
*/
CREATE TABLE IF NOT EXISTS crisp_conversation_segments (
  session_id VARCHAR NOT NULL,
  state VARCHAR NOT NULL,
  segment VARCHAR,
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS unique_crisp_conversation_segments_idx ON crisp_conversation_segments (session_id, segment);
CREATE INDEX IF NOT EXISTS crisp_conversation_segments_idx ON crisp_conversation_segments (session_id);
CREATE INDEX IF NOT EXISTS crisp_conversation_segment_idx ON crisp_conversation_segments (segment);
CREATE INDEX IF NOT EXISTS crisp_conversation_state_idx ON crisp_conversation_segments (state);
CREATE INDEX IF NOT EXISTS crisp_created_at_idx ON crisp_conversation_segments (created_at);

/* Insert data from the csv file into the DB. */
/* If data is already present, update the content field */

CREATE TEMPORARY TABLE crisp_conversation_segments_temp (session_id VARCHAR, state VARCHAR, segment VARCHAR, created_at timestamp, updated_at timestamp);

-- CSV file has fields in this order : 
-- If it changes, change this line or it will break.
\copy crisp_conversation_segments_temp(session_id, state, segment, created_at, updated_at) FROM '/app/crisp_conversation_segments.csv' DELIMITER ',' CSV HEADER;


INSERT INTO crisp_conversation_segments (session_id, state, segment, created_at, updated_at)
SELECT *
FROM crisp_conversation_segments_temp
ON CONFLICT (session_id, segment) DO update set state=EXCLUDED.state, updated_at=EXCLUDED.updated_at;
