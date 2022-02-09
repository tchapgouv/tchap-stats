CREATE OR REPLACE FUNCTION merge_tables (table_name varchar, temp_table_name varchar) RETURNS boolean AS $$
   BEGIN
    --MERGE temp_table_name
    --INTO table_name;
   RETURN true;
   END;
$$ language plpgsql VOLATILE;