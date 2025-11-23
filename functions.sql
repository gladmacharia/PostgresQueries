-- list of all male patients who were born after 1990, including their patient ID, first
name, last name, and date of birth
select PatientID,FirstName,LastName,DateOfBirth from patients
where Gender = 'M' and DateOfBirth > '1990-01-01';

-- the ten most recent appointments in the system, ordered from the newest to the oldest
select * from appointments
order by appointmentDate desc
limit 10;

-- all appointments along with the full names of the patients and doctors involved
select a.appointmentID, concat(p.FirstName,' ',p.LastName),concat(d.FirstName,' ',d.LastName)
from appointments a
join patients p
on a.patientID = p.patientID
join doctors d
on a.DoctorID = d.DoctorID;

-- all patients together with any treatments they have received, ensuring that patients without treatments also appear in the results
select p.patientID,concat(p.FirstName,' ',p.LastName), a.AppointmentID from patients p
full join appointments a
on p.patientID = a.patientID;

-- treatments recorded in the system that do not have a matching appointment
select t.treatmentID,t.treatmenttype,a.appointmentid from treatments t
left join appointments a
on t.appointmentID = a.appointmentID
where a.appointmentID is NULL;

-- appointments each doctor has handled, ordered from the highest to the lowest count
select a.DoctorID,concat(d.FirstName,' ',d.LastName),
count(a.doctorID) as totalcount 
from appointments a
join doctors d
on a.Doctorid = d.DoctorID
group by a.doctorID,d.FirstName,d.LastName
Order by totalcount desc;

--doctors who have handled more than twenty appointments, showing their doctor ID, specialization, and total appointment count. 
select a.DoctorID,concat(d.FirstName,' ',d.LastName) as DocsName, d.specialization,
count(a.doctorID) as totalcount 
from appointments a
join doctors d
on a.Doctorid = d.DoctorID
group by a.doctorID,d.FirstName,d.LastName,d.specialization
having count(a.doctorID) > 20
Order by totalcount desc;

-- patients who have had appointments with doctors whose specialization is “Cardiology.” 
select a.patientID,concat(p.FirstName,' ',p.LastName) as PatientsName,
concat(d.FirstName,' ',d.LastName) as DocsName, d.specialization
from appointments a
join patients p
on a.patientID = p.patientID
join doctors d
on a.doctorid = d.doctorid
where specialization = 'Cardiology';

-- a list of patients who have at least one bill that remains unpaid
select p.patientID,concat(p.FirstName,' ',p.LastName),b.outstandingamount
from patients p
join admissions a 
on p.patientid = a.patientid
join bills b
on a.admissionid = b.admissionid
where b.outstandingamount > 0;

--bills whose total amount is higher than the average total amount for all bills in the system.
select billID,totalamount
from bills
where totalamount > (select avg(totalamount) from bills);

--For each patient in the database, identify their most recent appointment and list it along with the patient’s ID
select a.patientid,concat(p.FirstName,' ',p.lastName) as PatientsName,a.status,a.appointmentdate
from appointments a
join (
	select patientid, max(appointmentdate) as latestdate
	from appointments
	group by patientid
) m
on a.patientid = m.patientid and a.appointmentdate = m.latestdate
join patients p on a.patientid = p.patientid ;

--For every appointment in the system, assign a sequence number that ranks each patient’s appointments from most recent to oldest.
select a.appointmentid, a.patientid, concat(p.Firstname,' ',p.LastName) as PatientsName,a.doctorid,a.nurseid,a.appointmentdate,
row_number()over(
	partition by a.patientid
	order by a.appointmentdate desc
)as appointmentrank
from appointments a
join patients p
on a.patientid = p.patientid
order by appointmentrank desc;

-- number of appointments per day for October 2021, including a running total across the month.
select appointmentday,count(*) as appointmentsperday,
	sum(count(*)) over(order by appointmentday) as runningtotal
	from(
		select appointmentid,date(appointmentdate) as appointmentday
		from appointments
		where appointmentdate >= '2021-10-01' and appointmentdate < '2021-11-01'
	)as sub
	group by appointmentday
	order by appointmentday;

--calculate the average, minimum, and maximum total bill amount, and then return these values in a single result set.
select 
	round(avg(totalamount)::numeric,2) as avgTotalAmount,
	round(min(totalamount)::numeric,2) as minTotalAmount,
	round(max(totalamount)::numeric,2) as maxTotalAmount
from bills;
-- a query that identifies all patients who currently have an outstanding balance, based on information from admissions and billing records
select distinct p.patientid,concat(p.FirstName,' ',p.LastName) as PatientsName,sum(b.outstandingamount) as totaloutstanding
from patients p
join admissions a
on p.patientid = a.patientid
join bills b
on a.admissionid = b.admissionid
where b.outstandingamount > 0
group by p.patientid,FirstName,LastName
order by totaloutstanding desc;

-- a query that generates all dates from January 1 to January 15, 2021, and show how many appointments occurred on each of those dates
with dates as(
	select generate_Series(
		'2021-01-01'::date,
		'2021-01-15'::date,
		interval '1 day'
	)as appointmentdate
)
select d.appointmentdate,count(a.appointmentdate) as appointmentscount
from dates d
left join appointments a
on date(a.appointmentdate) = d.appointmentdate
group by d.appointmentdate
order by d.appointmentdate;

--a new patient record to the Patients table, providing appropriate information for all required fields.
select * from patients
insert into patients(PatientID,	FirstName,	LastName,	Gender,	DateOfBirth, Email, PhoneNumber)
values('P1001','Glad','Macharia','M','1975-07-07','gladmacharia@gmail.com','555-903637');

--Modify the appointments table so that any appointment with a NULL status is updated to show “Scheduled.”
update appointments
set status = 'Scheduled'
where status is NULL;
select * from appointments;

-- Remove all prescription records that belong to appointments marked as “Cancelled.”
delete from prescriptions
where appointmentid in (
	select appointmentid
	from appointments
	where status = 'Cancelled'
);

