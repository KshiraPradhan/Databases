CREATE OR REPLACE PROCEDURE bad_abc
AS
  v_what NUMBER;
BEGIN
  v_what := 'abc';
END;
/

BEGIN
  bad_abc;
END;
/
