/* beggining of pipeline there : https://github.com/tchapgouv/matrix-rageshake-crisp/blob/ad1d3dcdddcf8c63fe13df65ba95a77d31923f3c/src/job_export_crips_conversation_segments_s3.py */

/* Crisp conversation segments
*/
CREATE TABLE IF NOT EXISTS crisp_conversation_segments (
  session_id VARCHAR NOT NULL, /* composed primary key : unique_crisp_conversation_segments_idx */
  segment VARCHAR NOT NULL, /* composed primary key : unique_crisp_conversation_segments_idx */
  state VARCHAR NOT NULL, 
  domain VARCHAR,
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);


CREATE UNIQUE INDEX IF NOT EXISTS unique_crisp_conversation_segments_idx ON crisp_conversation_segments (session_id, segment);
CREATE INDEX IF NOT EXISTS crisp_conversation_segments_idx ON crisp_conversation_segments (session_id);
CREATE INDEX IF NOT EXISTS crisp_conversation_segment_idx ON crisp_conversation_segments (segment);
CREATE INDEX IF NOT EXISTS crisp_conversation_domain_idx ON crisp_conversation_segments (domain);
CREATE INDEX IF NOT EXISTS crisp_conversation_state_idx ON crisp_conversation_segments (state);
CREATE INDEX IF NOT EXISTS crisp_created_at_idx ON crisp_conversation_segments (created_at);


CREATE TEMPORARY TABLE crisp_conversation_segments_temp (
    session_id VARCHAR, 
    state VARCHAR, 
    segment VARCHAR,
    created_at timestamp, 
    updated_at timestamp,
    domain VARCHAR
);


-- CSV file has fields in this order : 
-- If it changes, change this line or it will break.
\copy crisp_conversation_segments_temp(session_id, state, segment, created_at, updated_at, domain) FROM './crisp_conversation_segments.csv' DELIMITER ',' CSV HEADER;


INSERT INTO crisp_conversation_segments (session_id, state, segment, created_at, updated_at, domain)
SELECT DISTINCT ON (session_id, segment)  *
FROM crisp_conversation_segments_temp
ON CONFLICT (session_id, segment) DO update set state=EXCLUDED.state, updated_at=EXCLUDED.updated_at;


