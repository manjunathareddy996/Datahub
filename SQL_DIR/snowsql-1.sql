CREATE OR REPLACE PROCEDURE demo05122025("INPUT" VARCHAR(16297716))
RETURNS VARCHAR(1736)
LANGUAGE SQL
EC
AS '
DECLARE out VARCHAR;
BEGIN
    -- using for tracking
    out := ''Your Input parameter from  : '' || input;
    RETURN out;
END;
';

 
