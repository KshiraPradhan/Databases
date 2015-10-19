create or replace
PROCEDURE bad_abc
AS
  v_what NUMBER;

BEGIN
  BEGIN
    --v_what := 'abc';
    RAISE_APPLICATION_ERROR(-20001, 'Weird Error');
  EXCEPTION
    WHEN OTHERS
    THEN
      IF SQLCODE = -20001
      THEN
        v_what := 123;
      ELSE
        RAISE;
      END IF;
  END;
  
  dbms_output.put_line(v_what);
END;
/

