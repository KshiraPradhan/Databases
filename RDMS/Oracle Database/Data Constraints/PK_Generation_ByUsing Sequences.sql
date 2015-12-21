---Student tabe
drop table students;
create table students (
student_no varchar2(10) PRIMARY KEY,
student_name varchar2(25),
age number(10)
);

--Now Creating the sequences
drop sequence sqstudents;
CREATE SEQUENCE sqStudents INCREMENT BY 1 START WITH 1;

SELECT sqStudents.CURRVAL FROM Dual;

--creating the Trigger GenerateStudentNo that uses the sequences named sqStudents
--sqStudents to generate a student identity number as S<runningno>

create or replace trigger GStudentno
  BEFORE INSERT ON students
 FOR EACH ROW
 DECLARE
  varStudentNo varchar2(10);
begin
  select 'S' || to_char(sqStudents.NextVal) into varStudentNo from dual;
  :NEW.student_no := varStudentNo;
end;
/

/*
--this trigger fires every time a record is being inserted in the students table
--the record is inserted where studentno is generated by sequence
--the trigger fetches the next value available in this sequences and preceds it will "S"
*/

select * from students;
--insert the data
INSERT INTO Students(student_name,age) values('ganesh', 22); --now the trigger fires the StudentNo Column value can be using :NEW StudentNo
INSERT INTO Students(student_name,age) values('vedha', 20);
INSERT INTO Students(student_name,age) values('kalyani', 40);
INSERT INTO Students(student_name,age) values('gajenthiran', 50);

 