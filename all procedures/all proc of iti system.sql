
--1)
--genrate exam
create proc genrate_exam  @st_id int,@crs_name varchar(50)
as
declare @exam_id int 
select @exam_id =datediff(second,'1997-07-10',getdate())
declare @crs_id int 
set @crs_id =(select crs_id from Courses where Crs_name=@crs_name)
if not exists(select exam_id from Exam where exam_id=@exam_id ) 
begin
   insert into Exam (exam_id,Exam_Crs_id,Exam_date)
   values(@exam_id,@crs_id,GETDATE())
end
else 
   print('try again please ')

   --genrate random T/F quetions and insert into taken exam:
   begin try
   insert into Taken_exam(Question_id,iti_st_id,exam_id)
   select top(2)Ques_id,@st_id,@exam_id  from Question
   where Ques_Type='tf'and Ques_Crs_id=@crs_id
   order by newid()
   end try
   begin catch
   print ('cannot genrate T/F questions')
   end catch
      --genrate random MCQ quetions and insert into taken exam:
   begin try
   insert into Taken_exam(Question_id,iti_st_id,exam_id)
   select top(3)ques_id,@st_id,@exam_id  from Question
   where Ques_Type='MCQ'and Ques_Crs_id=@crs_id
   order by newid()
   end try
   begin catch
   print ('cannot genrate MCQ questions')
   end catch
   --
      -- veiw exam
   select ques_content,choice1,choice2,choice3,choice4 from question,taken_exam
   where ques_id=question_id and exam_id=@exam_id
	go

	--------
	genrate_exam 40034 ,excel
===========================================================================================


--2)-- veiw exam with exam_id
create proc veiw_exam @exam_id int
as
begin try
   select ques_content,choice1,choice2,choice3,choice4 from question,taken_exam
   where ques_id=question_id and exam_id=@exam_id
end try
begin catch
print ('an error occured during veiw exam')
end catch
--------------
veiw_exam 817784995
==================================================================================================

--3)-- veiw exam with exam_id with student answer
create proc veiw_answered_exam @exam_id int
as
begin try
   select ques_content,choice1,choice2,choice3,choice4,answer from question,taken_exam
   where ques_id=question_id and exam_id=@exam_id
end try
begin catch
   print ('an error occured during veiw exam')
end catch
--------------
veiw_answered_exam 817785032
========================================================================================

--4)-- delete exam with exam_id
create proc delete_exam @exam_id int
as
begin try
delete from taken_exam where exam_id=@exam_id 
end try
begin catch
print ('an error accured during delete exam')
end catch

-------------
del_exam 817873950
=====================================================================================================


------------------------------------------------------
--5)
   --show chooses of question use question_id
   create proc show_choices @question_id int
   as 
   begin try
   select choice1,choice2,choice3,choice4 from Question
   where Ques_id=@question_id
   end try
   begin catch
   print('error occour in question')
   end catch

      ---------------------------------
===================================================================================================
--6)
   -- save and correct student answer
   go
   create proc st_answer @iti_id int ,@exam_id int,@Question_id int,@st_answer varchar(500)
   as
		begin try
			   update taken_exam 
			   set answer=@st_answer
			   where iti_st_id=@iti_id and exam_id =@exam_id and Question_id=@Question_id 
		end try
		begin catch
			   print ('error occur during insert student ans into table')
		end catch

		if @st_answer= (select Ques_right_answer from Question where Ques_id=@Question_id)
			begin
				update taken_exam
				set score=1
				where iti_st_id=@iti_id and exam_id =@exam_id and Question_id=@Question_id 
			end

		else
			begin
				update taken_exam
				set score=0
				where iti_st_id=@iti_id and exam_id =@exam_id and Question_id=@Question_id 
			end
go
========================================================================
=======================================================================================


----------------------------------------------
--8)
	--calculate all exams score
create view [RowNumExam] as
	  select * from(
				    select *,ROW_NUMBER() over (order by exam_id)as RN 
				    from exam) as nev
					
go
create proc exams_score
as
declare @maxRN int
Declare @counter int =1
begin try
	set @maxRN=(select MAX(RN) from RowNumExam)
	while @counter <= @maxRN
	  begin
		update exam
		set Exam_Total_Score= (select sum(score) from taken_exam	t
		                  where t.exam_id=(select exam_id from RowNumExam where RN=@counter))
		where exam_id=(select exam_id from RowNumExam where RN=@counter)
		set @counter=@counter+1
	 end
end try
begin catch
print ('error in exams_score')
end catch

go

==============================================================================================


-----------------------------------------------
--9)
	-- proc to show result of exams of all student in each track
alter proc scoresPERtrack @track_name varchar(50),@location varchar(50)
as
select exam_id,crs_name,exam_total_score,exam_date from exam,courses
where crs_id=exam_crs_id and Exam_Crs_id in(
select tc.crs_id from Tracks t,Track_Courses tc 
where t.Trac_id=tc.Trac_id and t.Trac_name=@track_name and t.trac_location=@location)
go


-------------
scoresPERtrack bi,cairo
================================================================================================

----------------------------------------------------
--10)
	----proc to show result of student in all courses exams with iti_st_id
create proc student_result @iti_st_id int
as
begin try
	select c.crs_name,e.exam_Total_Score from exam e,Courses c
	where e.exam_Crs_id=c.Crs_id and exam_id in (
			select distinct exam_id from Taken_exam
			where ITI_st_Id=@iti_st_id)
end try
begin catch
print ('this student didnot have any exams')
end catch
go
---------------------------------------------------
--#####################################################           oprations question table           ##########################################


-----------------------------------
--11)
	--proc to show(select) questions with course name and questions type(t/f,mcq,all)
create proc show_course_ques @crs_id int,@ques_type varchar(10)
as

begin try
if @ques_type='TF'
begin
select * from Question q
where Ques_Type='TF' and q.Ques_Crs_id =@crs_id
end
else if @ques_type='MCQ'
		begin
		select * from Question q
		where Ques_Type='MCQ' and q.Ques_Crs_id =@crs_id
		end
else if @ques_type='all'
		begin
		select * from Question q
		where q.Ques_Crs_id =@crs_id
		end
else
print('error ')
end try
begin catch
print('there is no questoins for this course') 
end catch


go
-----------
exec show_course_ques 101,'tf'
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--12)
	--insert new question
go
create proc insert_ques @crs_name varchar(50),@ques_id int ,@ques varchar(250),@ques_type varchar(10),
            @ch1 varchar(150),@ch2 varchar(150),@ch3 varchar(150),@ch4 varchar(150),@right_ans varchar(50)
as
begin try
declare @crs_id int
set @crs_id=(select crs_id from Courses where Crs_name=@crs_name)
insert into Question(Ques_id,Ques_Crs_id,Ques_content,Ques_Type,choice1,choice2,choice3,choice4,Ques_right_answer)   
values(@ques_id,@crs_id,@ques,@ques_type,@ch1,@ch2,@ch3,@ch4,@right_ans)
end try
begin catch
print('an error in your input')
end catch
-------------
exec insert_ques 'sql',91,' 1+1=3','tf','true','false','' ,'' ,'false'
exec insert_ques 'sql',90,' 1+1=3','tf','true','false','' ,'' ,'false'
go
-------------------------------------------------------				 ------------------------------
---------------------------------------------------------------------------------------------------
--13)
--delete question 
create proc del_question @Question_id int
as
begin try
delete from Question where Ques_id=@Question_id
end try 
begin catch
print('error in del_question')
end catch
---------
exec del_question 92
------------------------------------------------------------------
go---------------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
--15)
--veiw courses of topic with topic nameselect crs_id,crs_name from courses
alter proc topic_courses @topic_name varchar(100)
as
select crs_id,crs_name from courses
where crs_topic_id= (select Topic_id from topics
where topic_name='Programming')

go
-----------
topic_courses 'web'
---------------------------------------
================================================================================
--16)
-- veiw courses of instructor and count of student in these courses 
CREATE PROCEDURE Instructor_Courses  @InstructorId INT
AS
BEGIN
  SELECT C.Crs_name AS Course_Name, COUNT(I.ITI_st_Id) AS ITI_Student_Count
  FROM Courses C
  INNER JOIN Teaching T ON C.Crs_id = T.Crs_id
  INNER JOIN ITI_st_courses IC ON C.Crs_id = IC.Crs_id
  INNER JOIN ITI_Student I ON IC.iti_st_id = I.iti_st_id
  WHERE T.Inst_id = @InstructorId
  GROUP BY C.Crs_name;
END;
------------------
Instructor_Courses @InstructorId = 1020
---------------------------------------------------------
================================================================================
--17)
--veiw info of student in each track by track id
alter PROCEDURE GetITIStudentsByTrack
  @TrackId INT
AS
BEGIN
  SELECT S.ST_id, S.ST_name, S.ST_city, S.ST_Bdate, S.ST_age, S.ST_Gpa, S.ST_Sex, S.ST_email, S.st_Faculty
  FROM ITI_Student isu
  INNER JOIN Students S ON isu.ITI_st_id = S.st_id
  WHERE S.ST_Trac_id = @TrackId;
END;

Exec GetITIStudentsByTrack 400;

-------------------------------------------------------------------------
-----------------------------------------------------------------------
---PROC GENRATE RANDOM ANSWERS  FOR QUESTION EXAM
create view row_n as
			select *, ROW_NUMBER() over(order by iti_st_id,question_id,exam_id)as Rn
			from taken_exam
			go
			alter proc random_ans 
			as
			declare @x int=1 
			declare @y int
			declare @Q_id int
			declare @exam_id int
			while @x< (select count(rn) from row_n)
			begin
			set @Q_id =(select question_id from row_n where rn=@x)
			set @y =ABS(CHECKSUM(NEWID())) % 4 + 1
			set @exam_id=(select exam_id from row_n where rn=@x)
			select @exam_id
			if @y =1
			update Taken_exam set answer=(select choice1 from Question where ques_id=@Q_id)where @exam_id=exam_id and Question_id=@Q_id
			else if @y =2
			update Taken_exam set answer=(select choice2 from Question where ques_id=@Q_id)where @exam_id=exam_id and Question_id=@Q_id
			else if @y =3
			update Taken_exam set answer=(select choice3 from Question where ques_id=@Q_id)where @exam_id=exam_id and Question_id=@Q_id
			else if @y =4
			update Taken_exam set answer=(select choice4 from Question where ques_id=@Q_id)where @exam_id=exam_id and Question_id=@Q_id
			else
			begin
			select 'nochioce'
			end
			set @x+=1
			end




--select  from certification
create proc show_st_certification @column_name varchar(100),@value varchar(100)
as
exec ('select * from certifications where '+ @column_name+' = ' +' '' '+@value +' '' ')

--------------
		show_st_certification cert_id , 1415
		go
		show_st_certification cert_iti_id , '10000'
		go
		show_st_certification cert_hours , '27'
		go
		show_st_certification cert_name ,'datawarhouse'
		go
		
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--insert into certification

create proc insert_certification  @certificate_id int ,
								  @iti_st_id int ,
								  @platform varchar(50),
								  @cert_name varchar(50),
								  @cer_hours varchar(10)
as
insert into certifications 
values(@certificate_id,@iti_st_id,@platform,@cert_name,@cer_hours)

------------
        go
		insert_certification 1423,18002,datacamp,' datawarhouse',' 27'
		go
		insert_certification 1424,40000,udemy,' dataanalysis',' 19'
		go
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--delete from certification

create proc del_certification @column_name varchar(50),@value varchar(50)
as
exec('delete from certifications where '+  @column_name+' = '+' '' '+ @value+' '' ')

-----------
        go
		del_certification cert_id,1415
		go
		del_certification cert_iti_id,10000
		go
		del_certification cert_hours,66
		go
		del_certification cert_name,'python'
		go

----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--update certification


create proc update_certification @column_name varchar(50),
								 @value varchar(50),
								 @condition_column varchar(50),
								 @condition_value varchar(50)
as
exec('UPDATE certifications SET '+@column_name+' = '+' '' '+ @value+' '' ' +'WHERE '+ @condition_column+' = '+' '' '+@condition_value+' '' ')

update_certification cert_name,'database1',cert_id,1421
go
update_certification cert_hours,66,cert_name,'python'
go
update_certification cert_name,'sql',cert_id,1415






go
--===============================================================courses=======================================================================
--============================================================--(select ,insert,update,delete)proc==============================================
--select  from courses
create proc show_course @column_name varchar(100),@value varchar(100)
as
exec ('select * from courses where '+ @column_name+' = ' +' '' '+@value +' '' ')

--------------
        go
		show_course crs_id , 103
		go
		show_course crs_topic_id , '2'
		go
		show_course crs_name , 'pandas'
		go
		show_course crs_status ,'offline'
		go
		
		
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--insert into courses

create proc insert_course  @crs_id int ,
								  @crs_topic_id int ,
								  @crs_name varchar(100),
								  @crs_duration varchar(10),
								  @crs_status varchar(10)
as
insert into Courses
values(@crs_id,@crs_topic_id,@crs_name, @crs_duration,@crs_status)

------------
        go
		insert_course 124 , 1 , ' pandas' , ' 15' , ' online'
		go
		insert_course 123 , 2 , ' azure'  , ' 99' , ' offline'
		go
		
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--delete from courses

create proc del_course @column_name varchar(50),@value varchar(50)
as
exec('delete from courses where '+  @column_name+' = '+' '' '+ @value+' '' ')

-----------
		del_course crs_id,123
		go
		del_course crs_topic_id,7
		go
		del_course crs_duration,99
		go
		del_course crs_name,'azure'
		go

----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--update course


create proc update_course @column_name varchar(50),
								 @value varchar(50),
								 @condition_column varchar(50),
								 @condition_value varchar(50)
as
exec('UPDATE courses SET '+@column_name+' = '+' '' '+ @value+' '' ' +'WHERE '+ @condition_column+' = '+' '' '+@condition_value+' '' ')

update_course crs_topic_id,1,crs_id,123
go
update_course crs_duration,19,crs_name,'python'
go
update_course crs_status,'online',crs_name,'azure'
go




--===============================================================         EXAM TABLE   ==========================================================

--============================================================--(select ,insert,update,delete)proc==============================================


--select  from exam
create proc show_exam @column_name varchar(100),@value varchar(100)
as
if @column_name='all'
	exec ('select * from exam')
else
	exec ('select * from exam where '+ @column_name+' = ' +' '' '+@value +' '' ')

--------------
        go
		show_exam exam_id , 817784847
		go
		show_exam exam_crs_id , 104
		go
		show_exam exam_total_score , 5
		go
		show_exam exam_date ,'06-09-2023'
		go
		
		
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--insert into exam

create proc insert_EXAM  @EXAM_id int ,
								  @EXAM_crs_id int ,
								  @EXAM_TOTAL_SCORE int,
								  @EXAM_DATE date
								  
as
insert into EXAM
values(@EXAM_id,@EXAM_crs_id,@EXAM_TOTAL_SCORE, @EXAM_DATE)

------------
        go
		insert_EXAM 124125 , 106 , 4 , '10-25-2020'
		go
		insert_EXAM 123125 , 107 , 3  , ' 8-29-2022'
		go
		insert_EXAM 123126 , 109 , 3  , ' 8-15-2022'
		go
		
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--delete from exam

create proc del_exam @column_name varchar(50),@value varchar(50)
as
exec('delete from exam where '+  @column_name+' = '+' '' '+ @value+' '' ')

-----------
	    go
		del_exam exam_id,123125
		go
		del_exam exam_crs_id,109
		go
		del_exam exam_date,'10-25-2020'
		go
		

----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--update exam


create proc update_exam @column_name varchar(50),
								 @value varchar(50),
								 @condition_column varchar(50),
								 @condition_value varchar(50)
as
exec('UPDATE exam SET '+@column_name+' = '+' '' '+ @value+' '' ' +'WHERE '+ @condition_column+' = '+' '' '+@condition_value+' '' ')

update_exam exam_id,123123,exam_date,'10-25-2020'
go
update_exam exam_crs_id,110,exam_id,123123
go
update_exam exam_date,'1-1-2022',exam_crs_id,110
go




--===============================================================         freelancing TABLE   ==========================================================

--============================================================--(select ,insert,update,delete)proc==============================================


--select  from freelancing

create proc show_freelancing @column_name varchar(100),@value varchar(100)
as
if @column_name='all'
	exec ('select * from Freelancing')
else
	exec ('select * from Freelancing where '+ @column_name+' = ' +' '' '+@value +' '' ')

--------------
        go
		show_Freelancing Freelanc_id , 123130
		go
		show_Freelancing Freelanc_ITI_Id , 18002
		go
		show_Freelancing Freelanc_type , 'bi'
		go
		show_Freelancing Freelanc_platform ,'06-09-2023'
		go
		
		
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--insert into freelancing

create proc insert_Freelancing    @Freelanc_id int ,
								  @Freelanc_ITI_Id int ,
                                   @Freelanc_type varchar(50),								
								  @Freelanc_earn decimal,
								  @Freelanc_platform varchar(50)
								  
as
insert into Freelancing
values(@Freelanc_id  ,  @Freelanc_ITI_Id   ,@Freelanc_type, @Freelanc_earn , @Freelanc_platform )

------------
        go
		insert_Freelancing 124133 , 18002,' excel' ,65 , ' fiver'
		go
		insert_Freelancing 123134 ,40000 , ' vis', 44 , ' Freelancing'
		go
		insert_Freelancing 123135 ,18002, ' ui' , 60 , ' mostaql'
		go
		
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--delete from freelancing

create proc del_Freelancing @column_name varchar(50),@value varchar(50)
as
exec('delete from Freelancing where '+  @column_name+' = '+' '' '+ @value+' '' ')

-----------
	    go
		del_Freelancing Freelanc_id,123125
		go
		del_Freelancing Freelanc_iti_id,10000
		go
		del_Freelancing Freelanc_platform,'fiver'
		go
		

----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--update freelancing


create proc update_Freelancing @column_name varchar(50),
								 @value varchar(50),
								 @condition_column varchar(50),
								 @condition_value varchar(50)
as
exec('UPDATE Freelancing SET '+@column_name+' = '+' '' '+ @value+' '' ' +'WHERE '+ @condition_column+' = '+' '' '+@condition_value+' '' ')

update_Freelancing Freelanc_id,123123,Freelanc_id,123130
go
update_Freelancing Freelanc_iti_id,18002,Freelanc_id,123123
go
update_Freelancing Freelanc_earn,150,Freelanc_iti_id,18002
go




--===============================================================         Instructor TABLE   ==========================================================

--============================================================--(select ,insert,update,delete)proc==============================================


--select  from Instructor

create proc show_Instructor @column_name varchar(100),@value varchar(100)
as
if @column_name='all'
	exec ('select * from Instructor')
else
	exec ('select * from Instructor where '+ @column_name+' = ' +' '' '+@value +' '' ')

--------------
        go
		show_Instructor Inst_id , 1005
		go
		show_Instructor Inst_name , 'Mohamed Ali'
		go
		show_Instructor Inst_city , 'Mansoura'
		go
		show_Instructor Inst_sex ,Male
		go
		
		
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--insert into Instructor
create proc insert_Instructor    @Inst_id int ,
								  @Inst_name varchar(100) ,
                                   @Inst_salary int,								
								  @Inst_email varchar,
								  @Inst_password varchar(50)
								  
as
insert into Instructor (Inst_id,Inst_name,Inst_Salary,Inst_email,Inst_Password)
values( @Inst_id ,@Inst_name  ,@Inst_salary , @Inst_email , @Inst_password  )

------------
        go
		insert_Instructor 1041 , ' amar ali',5000 ,'amarali125@gmail.com' , ' kl@12'
		go
		insert_Instructor 1042 ,' yussuf khaled' , 6000, 'yussuy12345@gmail.com' , ' opm1251'
		go
		insert_Instructor 1043 ,' mohamed salah', 15000 , 'mosalah897@gmail.com' , ' 15@hh#'
		go
		
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--delete from Instructor

create proc del_Instructor @column_name varchar(50),@value varchar(50)
as
exec('delete from Instructor where '+  @column_name+' = '+' '' '+ @value+' '' ')

-----------
	    go
		del_Instructor Inst_id,1043
		go
		del_Instructor Inst_name,'yussuf khaled'
		go
	
		

----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--update Instructor


create proc update_Instructor @column_name varchar(50),
								 @value varchar(50),
								 @condition_column varchar(50),
								 @condition_value varchar(50)
as
exec('UPDATE Instructor SET '+@column_name+' = '+' '' '+ @value+' '' ' +'WHERE '+ @condition_column+' = '+' '' '+@condition_value+' '' ')
go
update_Instructor Inst_id,1042,Inst_id,1041
go
update_Instructor Inst_name,' omar ali',Inst_id,1042
go
update_Instructor Inst_salary,50500,Inst_name,' omar ali'
go

--===============================================================         genral  ==========================================================

--============================================================--(select ,update,delete)proc==============================================
--genral del
create proc del_from_table @table_name varchar(20),
                           @column_name varchar(50),
						   @value varchar(50)
as
if @column_name='all'

	exec('delete from '+ @table_name)
else

	exec('delete from '+ @table_name+ ' where '+ @column_name+' = '+' '' '+ @value+' '' ')
	exec('select * from '+@table_name)

del_from_table topics,topic_name,db

select * from certifications

------------------------------------


go
create proc select_from_table @table_name varchar(20),
                             @column_name varchar(100),
							 @value varchar(100)
as
if @column_name='all'
	exec ('select * from '+@table_name)
else
exec ('select * from '+ @table_name +' where '+ @column_name +' = ' +' '' '+@value +' '' ')



select_from_table topics ,topic_id,2
---------------------------------------------------


go

create proc update_tables        @table_name varchar(50),
								 @column_name varchar(50),
								 @value varchar(50),
								 @condition_column varchar(50),
								 @condition_value varchar(50)
as
exec('UPDATE '+ @table_name +' SET '+@column_name+' = '+' '' '+ @value+' '' ' +'WHERE '+ @condition_column+' = '+' '' '+@condition_value+' '' ')
exec('select * from '+@table_name)



-------------
update_tables courses ,crs_duration,102,crs_name,'python'
go
update_tables courses ,crs_status,online,crs_name, azure
go
update_tables certifications ,cERT_HOURS, 12,cert_platform, UDMY



go
select* from certifications
where cert_platform= 'datacamp'


