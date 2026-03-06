CREATE OR REPLACE PROCEDURE demo05122025("INPUT" VARCHAR(16716))
RETURNS VARCHAR(17324346)
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

 
