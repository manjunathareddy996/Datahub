CREATE OR REPLACE PROCEDURE demo14444("INPUT" VARCHAR(16297716))
RETURNS VARCHAR(1736)
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

 
