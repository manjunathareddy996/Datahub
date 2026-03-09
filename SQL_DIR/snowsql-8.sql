CREATE OR REPLACE PROCEDURE demoronith("INPUT" VARCHAR(1616))
RETURNS VARCHAR(17578)
LANGUAGE SQL
XECUTE AS CALLER
AS '
DECLARE out VARCHAR;
BEGIN
    -- using for tracking
    out := ''Your Input parameter from  : '' || input;
    RETURN out;
END;
';

 
