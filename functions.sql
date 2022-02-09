CREATE OR REPLACE FUNCTION merge_tables (table_name varchar, temp_table_name varchar) RETURNS boolean AS $$
   BEGIN
    --MERGE temp_table_name
    --INTO table_name;
    EXECUTE format('
        MERGE INTO %1$s main
        USING %2$s temp
        ON main.hour = temp.hour
        WHEN MATCHED THEN
            DO NOTHING
        WHEN NOT MATCHED THEN
            INSERT VALUES ()
    ')
   RETURN true;
   END;
$$ language plpgsql VOLATILE;