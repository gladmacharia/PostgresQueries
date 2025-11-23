select * from doctors
-- a stored procedure that adds a new record to the Doctors table
create or replace procedure AddDoctor(
	in p_doctorid varchar(50),
	in p_firstname varchar(50),
	in p_lastname varchar(50),
	in p_specialization varchar(50),
	in p_email varchar(50),
	in p_phone varchar(50)
)
language plpgsql
as $$
begin 
	insert into doctors(DoctorID,FirstName,LastName,Specialization,Email,PhoneNumber)
	values(p_doctorid,p_firstname,p_lastname,p_specialization,p_email,p_phone);

end;
$$;
select * from appointments;
call AddDoctor(
'D1001','Steve','Mwangi','Cardiology','stevemwangi@gmail.com','555-93648'
);

create or replace procedure AddAppointment(
	in p_appointmentid varchar(50),
	in p_patientid varchar(50),
	in p_doctorid varchar(50),
	in p_appointmentdate date,
	in p_status varchar(50),
	in p_nurseid varchar(50)
)
language plpgsql
as $$
declare 
	patientExists int;
	doctorExists int;
begin
	--1. check if patient exists
	select count(*) into patientExists
	from patients
	where patientid = p_patientid;

	if patientExists = 0 then
		raise exception 'Error: Patient with ID % does not exist',p_patientid;
	end if;

	--2 check if doctor exists
	select count(*) into doctorExists
	from doctors
	where doctorid = p_doctorid;

	if doctorExists = 0 then
		raise exception 'Error: Doctor with ID % does not exist',p_doctorid;

	end if;
	--3. inserting appointments
	insert into appointments(appointmentID,patientID,doctorID,appointmentdate,Status,nurseID)
	values(p_appointmentid,p_patientid,p_doctorid,p_appointmentdate,p_status,p_nurseid);

end;
$$;

call AddAppointment('A1001','P1001','D1001','2025-07-07','Scheduled','N10001');

select * from appointments;
call AddAppointment('A1002','P1001','D1001','2025-07-07','Scheduled','N10001');