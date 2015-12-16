--Step 1 � Create some tables

CREATE TABLE EMPLOYEE
(
   EID     NUMBER,
   ENAME   VARCHAR2 (40)
);
 
CREATE TABLE DEPARTMENT
(
   DID     NUMBER,
   DNAME   VARCHAR2 (40)
);
 
CREATE TABLE SALARY
(
   EID      NUMBER,
   SALARY   NUMBER
);

--Step 2 � Create an exclude table

CREATE TABLE EXAUDIT
(
   TNAME VARCHAR2 (30) NOT NULL
);

INSERT INTO EXAUDIT (TNAME) VALUES ('DEPARTMENT');

--Step 3 � Create audit tables

CREATE OR REPLACE PROCEDURE create_audit_tables (table_owner VARCHAR2)
IS
   CURSOR c_tables (
      table_owner VARCHAR2)
   IS
SELECT ot.owner AS owner, ot.table_name AS table_name
        FROM all_tables ot
       WHERE     ot.owner = table_owner
             AND ot.table_name NOT LIKE 'AUDIT_%'
             AND ot.table_name <> 'EXAUDIT'
             AND NOT EXISTS
                    (SELECT 1
                       FROM EXAUDIT efa
                      WHERE ot.table_name = efa.tname)
             AND NOT EXISTS
                        (SELECT 1
                           FROM all_tables at
                          WHERE at.table_name = 'AUDIT_'||ot.table_name);
 
   v_sql     VARCHAR2 (8000);
   v_count   NUMBER := 0;
   v_aud     VARCHAR2 (30);
BEGIN
   FOR r_table IN c_tables (table_owner)
   LOOP
      BEGIN
         v_aud := 'AUDIT_'||r_table.table_name;
         v_sql :=
               'create table '
            || v_aud
            || ' as select * from '
            || r_table.owner
            || '.'
            || r_table.table_name
            || ' where 0 = 1';
 
         DBMS_OUTPUT.put_line ('Info: ' || v_sql);
 
         EXECUTE IMMEDIATE v_sql;
 
         v_sql :=
               'alter table '
            || v_aud
            || ' add ( AUDIT_ACTION char(1), AUDIT_BY varchar2(50), AUDIT_AT TIMESTAMP)';
 
         EXECUTE IMMEDIATE v_sql;
 
         v_count := c_tables%ROWCOUNT;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
                  'Failed to create table '
               || v_aud
               || ' due to '
               || SQLERRM);
      END;
   END LOOP;
 
   IF v_count = 0
   THEN
      DBMS_OUTPUT.put_line ('No audit tables created');
   ELSE
      DBMS_OUTPUT.put_line (v_count || ' audit tables created.');
   END IF;
END;
/

execute create_audit_tables('GANESH');

--Step 4 � Create audit triggers

create or replace FUNCTION get_columns_for_table (
     table_owner   VARCHAR2,
     t_name   VARCHAR2,
     prefix  VARCHAR2
  ) RETURN  CLOB
  IS
     v_text CLOB;
  BEGIN
     FOR getrec IN (SELECT column_name
                      FROM all_tab_columns
                     WHERE table_name = t_name
        AND owner = table_owner
        AND data_type<>'BLOB')
     LOOP
       v_text := v_text
          || ','
          || prefix
          || getrec.column_name
          || CHR (10)
          || '                             ';
     END LOOP;
 
     RETURN ltrim(v_text,',');
  END;
/

-- helper function

create or replace function get_column_comparasion (
     table_owner   VARCHAR2,
     t_name   VARCHAR2
  ) RETURN CLOB
  IS
    v_text CLOB;
  BEGIN
    FOR getrec IN (SELECT column_name
                     FROM all_tab_columns
                    WHERE table_name = t_name
                      AND owner = table_owner
                      AND data_type<>'BLOB')
   LOOP
      v_text := v_text
         || ' or( (:old.'
         || getrec.column_name
         || ' <> :new.'
         || getrec.column_name
         || ') or (:old.'
         || getrec.column_name
         || ' IS NULL and  :new.'
         || getrec.column_name
         || ' IS NOT NULL)  or (:old.'
         || getrec.column_name
         || ' IS NOT NULL and  :new.'
         || getrec.column_name
         || ' IS NULL))'
         || CHR (10)
         || '                ';
   END LOOP;
 
   v_text := LTRIM (v_text, ' or');
   RETURN v_text;
  END;
/

--create our audit triggers

CREATE OR REPLACE PROCEDURE create_audit_triggers (table_owner VARCHAR2)
IS
   CURSOR c_tab_inc (
      table_owner VARCHAR2)
   IS
      SELECT ot.owner AS owner, ot.table_name AS table_name
        FROM all_tables ot
       WHERE     ot.owner = table_owner
             AND ot.table_name NOT LIKE 'AUDIT_%'
             AND ot.table_name <> 'EXAUDIT'
             AND ot.table_name NOT IN (SELECT tname FROM EXAUDIT);
 
   v_query   VARCHAR2 (32767);
   v_count   NUMBER := 0;
BEGIN
   FOR r_tab_inc IN c_tab_inc (table_owner)
   LOOP
      BEGIN
 
         v_query :=
               'CREATE OR REPLACE TRIGGER TRIGGER_'
            || r_tab_inc.table_name
            || ' AFTER INSERT OR UPDATE OR DELETE ON '
            || r_tab_inc.owner
            || '.'
            || r_tab_inc.table_name
            || ' FOR EACH ROW'
            || CHR (10)
            || 'DECLARE '
            || CHR (10)
            || ' v_user varchar2(30):=null;'
            || CHR (10)
            || ' v_action varchar2(15);'
            || CHR (10)
            || 'BEGIN'
            || CHR (10)
            || '   SELECT SYS_CONTEXT (''USERENV'', ''session_user'') session_user'
            || CHR (10)
            || '   INTO v_user'
            || CHR (10)
            || '   FROM DUAL;'
            || CHR (10)
            || ' if inserting then '
            || CHR (10)
            || ' v_action:=''INSERT'';'
            || CHR (10)
            || '      insert into AUDIT_'
            || r_tab_inc.table_name
            || '('
            || get_columns_for_table (r_tab_inc.owner,
                                      r_tab_inc.table_name,
                                      NULL)
            || '      ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)'
            || CHR (10)
            || '      values ('
            || get_columns_for_table (r_tab_inc.owner,
                                      r_tab_inc.table_name,
                                      ':new.')
            || '      ,''I'',v_user,SYSDATE);'
            || CHR (10)
            || ' elsif updating then '
            || CHR (10)
            || ' v_action:=''UPDATE'';'
            || CHR (10)
            || '   if '
            || get_column_comparasion (r_tab_inc.owner, r_tab_inc.table_name)
            || ' then '
            || CHR (10)
            || '      insert into AUDIT_'
            || r_tab_inc.table_name
            || '('
            || get_columns_for_table (r_tab_inc.owner,
                                      r_tab_inc.table_name,
                                      NULL)
            || '      ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)'
            || CHR (10)
            || '      values ('
            || get_columns_for_table (r_tab_inc.owner,
                                      r_tab_inc.table_name,
                                      ':new.')
            || '      ,''U'',v_user,SYSDATE);'
            || CHR (10)
            || '   end if;'
            || ' elsif deleting then'
            || CHR (10)
            || ' v_action:=''DELETING'';'
            || CHR (10)
            || '      insert into AUDIT_'
            || r_tab_inc.table_name
            || '('
            || get_columns_for_table (r_tab_inc.owner,
                                      r_tab_inc.table_name,
                                      NULL)
            || '      ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)'
            || CHR (10)
            || '      values ('
            || get_columns_for_table (r_tab_inc.owner,
                                      r_tab_inc.table_name,
                                      ':old.')
            || '      ,''D'',v_user,SYSDATE);'
            || CHR (10)
            || '   end if;'
            || CHR (10)
            || 'END;';
 
         DBMS_OUTPUT.put_line (
               'CREATE TRIGGER '
            || REPLACE (r_tab_inc.table_name, 'TABLE_', 'TRIGGER_'));
 
         EXECUTE IMMEDIATE v_query;
 
         DBMS_OUTPUT.put_line (
               'Audit trigger '
            || REPLACE (r_tab_inc.table_name, 'TABLE_', 'TRIGGER_')
            || ' created.');
 
         v_count := c_tab_inc%ROWCOUNT;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
                  'Failed to create audit trigger for '
               || r_tab_inc.owner
               || '.'
               || r_tab_inc.table_name
               || ' due to '
               || SQLERRM);
      END;
   END LOOP;
 
   IF v_count = 0
   THEN
      DBMS_OUTPUT.put_line ('No audit triggers created');
   END IF;
END;
/

EXECUTE CREATE_AUDIT_TRIGGERS('GANESH');

select * from all_tables where owner='GANESH';

--Step 5 � Test the auditing
insert into employee values(1,'John'); 
insert into employee values(2,'Smith'); 
insert into department values(1,'Sales'); 
insert into department values(2,'Purchase'); 
insert into salary values(1,5000); 
insert into salary values(2,10000); 
delete from employee where eid = 1; 
update employee set ename = 'Raj' where eid = 2;

select * from department;
select * from employee;
select * from salary;
select * from exaudit;
select * from audit_department;
select * from audit_employee;
select * from audit_salary;



