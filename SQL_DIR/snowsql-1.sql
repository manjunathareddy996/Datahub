CREATE OR REPLACE PROCEDURE demo14444("INPUT" VARCHAR(16716))
RETURNS VARCHAR(17578)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE out VARCHAR;
BEGIN
    -- using for tracking
    out := ''Your Input parameter from  : '' || input;
    RETURN out;
END;
';

 
