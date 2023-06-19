CREATE TABLE Instructor (
  [Inst_id] INT PRIMARY KEY,
  [Inst_name] VARCHAR(50) not null,
  [Inst_Salary] DECIMAL(7,2),
  [Inst_email] VARCHAR(50) not null,
  [Inst_Password] VARCHAR(50) not null,
  [Inst_city] VARCHAR(50),
  [Inst_phone] VARCHAR(15),
  [Inst_Sex] VARCHAR(6),
  [inst_hiredate] date
);

CREATE TABLE Tracks (
  [Trac_id] INT PRIMARY KEY,
  [Trac_Inst_id] INT,
  [Trac_name] VARCHAR(150) not null,
  [Trac_Duration] VARCHAR(50) default '3 months',
  [Trac_Capacity] INT not null,
  [Trac_Location] VARCHAR(50),
	 CONSTRAINT fk_Inst_id FOREIGN KEY ([Trac_Inst_id]) REFERENCES Instructor ([Inst_id])
				ON DELETE SET NULL  ON UPDATE CASCADE
);


CREATE TABLE Students (
  [ST_id] INT PRIMARY KEY,
  [ST_Trac_id] INT,
  [ST_name] VARCHAR(50) not null,
  [ST_city] VARCHAR(50)not null,
  [ST_Bdate] DATE not null,
  [ST_age] AS YEAR(GETDATE()) - YEAR([ST_Bdate]),
  [ST_Gpa] DECIMAL(5,2) not null,
  [ST_score] DECIMAL(6,2) not null,
  [ST_major] VARCHAR(50),
  [ST_Facboook] VARCHAR(255),
  [ST_Sex] VARCHAR(10)not null,
  [ST_Status] VARCHAR(10),
  [ST_phone] VARCHAR(15),
  [ST_email] VARCHAR(50)not null,
  [ST_Faculty] VARCHAR(50)not null,
  [ST_Password] varchar(50) not null,
  [ST_startdate] date,
  CONSTRAINT fk_Track_id FOREIGN KEY ([ST_Trac_id]) REFERENCES Tracks([Trac_ID])
  );


  CREATE TABLE Topics (
  [Topic_id] INT PRIMARY KEY,
  [Topic_name] VARCHAR(50)
  );

  CREATE TABLE Courses (
  [Crs_id] INT PRIMARY KEY,
  [Crs_Topic_id] INT,
  [Crs_name] VARCHAR(100) not null,
  [Crs_Duration] VARCHAR(10) not null,
  [Crs_Status] VARCHAR(10) not null,
  CONSTRAINT fk_Topic_id FOREIGN KEY ([Crs_Topic_id]) REFERENCES Topics ([Topic_id])
       ON DELETE SET NULL  ON UPDATE CASCADE

);

CREATE TABLE ITI_Student (
  [iti_st_id] INT PRIMARY KEY,
  [iti_st_Company_id] INT,
  [iti_st_Card_id] INT,
  [iti_st_Grad_Status] VARCHAR(50),
  CONSTRAINT fk_iti_st_id FOREIGN KEY ([iti_st_id]) REFERENCES Students ([st_id])
       
);

CREATE TABLE Work (
  [job_id] int  PRIMARY KEY,
  [Company_name] VARCHAR(50),
  [position] VARCHAR(50),
  [Hire_date] DATE,
  [Salary] INT,
  [iti_st_id] INT

  CONSTRAINT fk_iti_st_id_job FOREIGN KEY ([iti_st_id]) REFERENCES ITI_Student ([iti_st_id])
       ON DELETE SET NULL  ON UPDATE CASCADE
);

CREATE TABLE Question (
  [Ques_id] INT PRIMARY KEY,
  [Ques_Crs_id] INT,
  [Ques_content] VARCHAR(500)not null,
  [Ques_Type] VARCHAR(6)not null,
  [choice1] VARCHAR(250)not null,
  [choice2] VARCHAR(250)not null,
  [choice3] VARCHAR(250),
  [choice4] VARCHAR(250),
  [Ques_right_answer] VARCHAR(250)not null,
  CONSTRAINT fk_Crs_id FOREIGN KEY ([Ques_Crs_id]) REFERENCES Courses ([Crs_id])
       ON DELETE SET NULL  ON UPDATE CASCADE
);

CREATE TABLE Exam (
  [Exam_id] INT PRIMARY KEY,
  [Exam_Crs_id] INT,
  [Exam_Total_Score] INT,
  [Exam_date] date default getdate(),
  CONSTRAINT fk_Crs_id_exam FOREIGN KEY ([Exam_Crs_id]) REFERENCES Courses ([Crs_id])
       ON DELETE SET NULL  ON UPDATE CASCADE
);

CREATE TABLE certifications (
  [cert_id] INT PRIMARY KEY,
  [cert_ITI_Id] INT,
  [cert_platform] VARCHAR(100),
  [cert_name] VARCHAR(100),
  [cert_Hours] VARCHAR(10),
  CONSTRAINT fk_ITI_Id_certifications FOREIGN KEY ([cert_ITI_Id]) REFERENCES ITI_Student([iti_st_id])
   ON DELETE SET NULL  ON UPDATE CASCADE
  );

     CREATE TABLE Freelancing (
  [Freelanc_id] INT PRIMARY KEY,
  [Freelanc_ITI_Id] INT,
  [Freelanc_Type] VARCHAR(50),
  [Freelanc_earn] DECIMAL(5,2)not null,
  [Freelanc_platform] VARCHAR(50) not null,
  CONSTRAINT fk_ITI_Id_freelancing FOREIGN KEY ([Freelanc_ITI_Id]) REFERENCES ITI_Student ([iti_st_id])
       ON DELETE SET NULL  ON UPDATE CASCADE
);


CREATE TABLE Waiting (
  [Waiting_id] INT PRIMARY KEY,
  [Ranking] INT,
  [activation_time] int default 14,
    CONSTRAINT fk_waiting_st_id FOREIGN KEY ([Waiting_id]) REFERENCES Students ([st_id])
       
);


CREATE TABLE Track_Instructor (
  [Trac_id] INT,
  [Inst_id] INT,
  CONSTRAINT pk_Instructor_of_Tracks PRIMARY KEY (Trac_id, Inst_id),
  CONSTRAINT fk_Track_id_Instructor_of_Tracks FOREIGN KEY ([Trac_id]) REFERENCES Tracks ([Trac_id]),
  CONSTRAINT fk_Ins_id_Instructor_of_Tracks FOREIGN KEY ([Inst_id]) REFERENCES Instructor ([Inst_id])
);

CREATE TABLE Teaching (
  [Inst_id] INT,
  [Crs_id] INT,
  CONSTRAINT pk_Teaching PRIMARY KEY (Inst_id, Crs_id),
  CONSTRAINT fk_Crs_id_Teaching FOREIGN KEY ([Crs_id]) REFERENCES Courses ([Crs_id]),
  CONSTRAINT fk_Ins_id_Teaching FOREIGN KEY ([Inst_id]) REFERENCES Instructor ([Inst_id])
);

CREATE TABLE Track_Courses (
  [Trac_id] INT,
  [Crs_id] INT,
  CONSTRAINT pk_Track_Courses PRIMARY KEY (Trac_id, Crs_id),
  CONSTRAINT fk_Crs_id_Track_Courses FOREIGN KEY ([Crs_id]) REFERENCES Courses ([Crs_id]),
  CONSTRAINT fk_Track_id_Track_Courses FOREIGN KEY ([Trac_id]) REFERENCES Tracks ([Trac_id])
);

CREATE TABLE ITI_st_courses (
  [iti_st_id] INT,
  [Crs_id] INT,
  CONSTRAINT pk_ITI_course PRIMARY KEY (iti_st_id, Crs_id),
  CONSTRAINT fk_Crs_id_ITI_course FOREIGN KEY ([Crs_id]) REFERENCES Courses ([Crs_id]),
  CONSTRAINT fk_ITI_Id_ITI_course FOREIGN KEY ([iti_st_id]) REFERENCES ITI_Student ([iti_st_id])
);

CREATE TABLE Taken_exam (
  [iti_st_id] INT not null,
  [Question_id] INT not null,
  [exam_id] INT not null,
  [score] int,
  [answer] VARCHAR(250),
  CONSTRAINT pk_taken_exam PRIMARY KEY (iti_st_id,Question_id,exam_id),
  CONSTRAINT fk_ITI_Id_Taken_exam FOREIGN KEY ([iti_st_id]) REFERENCES ITI_Student ([iti_st_id]),
  CONSTRAINT fk_Question_id_Taken_exam FOREIGN KEY ([Question_id]) REFERENCES Question ([Ques_id]),
  CONSTRAINT fk_exam_id_Taken_exam FOREIGN KEY ([exam_id]) REFERENCES Exam ([exam_id])
)

CREATE TABLE waiting_list (
  [ITI_Id] INT,
  [Waiting_id] INT,
  CONSTRAINT pk_waiting_list PRIMARY KEY (ITI_Id, Waiting_id),
  CONSTRAINT fk_ITI_Id_waiting_list FOREIGN KEY ([ITI_Id]) REFERENCES ITI_Student ([iti_st_id]),
  CONSTRAINT fk_Waiting_id_waiting_list FOREIGN KEY ([Waiting_id]) REFERENCES Waiting ([Waiting_id])
);

