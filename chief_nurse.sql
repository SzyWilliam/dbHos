drop procedure if exists chief_query_bed;
drop procedure if exists chief_query_ward_nurses;
drop procedure if exists chief_fire_ward_nurse;
drop procedure if exists chief_hire_ward_nurse;
drop procedure if exists chief_query_patient_by_status;
drop procedure if exists chief_query_patient_to_transfer;
drop procedure if exists chief_query_patient_to_leave_hospital;

DELIMITER $$

create procedure chief_query_bed()
begin
    select bed.region, bed.ward_num, bed.bed_num, patient_name, age, patient_status, patient_severity
    from (bed left join take_care on (bed.region = take_care.region and bed.ward_num = take_care.ward_num and bed.bed_num = take_care.bed_num)) left join patient on (patient.patient_id = take_care.patient_id)
    where bed.region = get_personnel_region();
end $$

create procedure chief_query_ward_nurses()
begin
    select personnel_id, personnel_name as ward_nurse, personnel.age, take_care.region, take_care.ward_num, take_care.bed_num, patient_name, patient_status, patient_severity
    from (personnel left join take_care on personnel.personnel_id = take_care.nurse_id) left join patient on patient.patient_id = take_care.patient_id
    where personnel.region = get_personnel_region() and personnel.position = 'ward_nurse';
end $$

create procedure chief_fire_ward_nurse(personnel_id int)
begin
    declare position varchar(32);
    declare region   varchar(16);
    declare username varchar(255);

    select personnel.position into position
    from personnel where personnel.personnel_id = personnel_id;
    select personnel.region into region
    from personnel where personnel.personnel_id = personnel_id;
    select personnel.username into username
    from personnel where personnel.personnel_id = personnel_id;

    if position = 'ward_nurse' and region = get_personnel_region
    and not exists (select * from take_care where nurse_id = personnel_id) then
        call personnel_leave(personnel_id);
    end if;
end $$

create procedure chief_hire_ward_nurse(
    username        varchar(255),
    pwd             varchar(255),
    personnel_name  varchar(255),
    age             int
)
begin
    call personnel_register(personnel_name, username, pwd, age, 'ward_nurse', get_personnel_region());
end $$

create procedure chief_query_patient_by_status(
    patient_status varchar(32)
)
begin
    select patient_id, patient_name, patient.age, patient.patient_status, take_care.region, ward_num, bed_num, personnel_name as ward_nurse, covid_test.severity
    from patient natural join take_care natural join covid_test, personnel
    where take_care.region = get_personnel_region() 
    and (patient.patient_status = patient_status or (patient.patient_status is null and patient_status is null))
    and take_care.nurse_id = personnel.personnel_id
    and covid_test.test_id = recent_covid_test_id(patient_id, now()); 
end $$

create procedure chief_query_patient_to_transfer()
begin
    select patient_id, patient_name, patient.age, patient.patient_status, patient_severity as severity, take_care.region, ward_num, bed_num, personnel_name as ward_nurse
    from patient natural join take_care, personnel
    where take_care.region = get_personnel_region() 
    and take_care.nurse_id = personnel.personnel_id
    and patient_severity <> take_care.region; 
end $$

create procedure chief_query_patient_to_leave_hospital()
begin
    select patient_id, patient_name, patient.age, patient.patient_status, patient_severity as severity, take_care.region, ward_num, bed_num, personnel_name as ward_nurse
    from patient natural join take_care personnel
    where take_care.region = get_personnel_region() 
    and take_care.nurse_id = personnel.personnel_id
    and check_patient_if_recovered(patient_id) = 1; 
end $$

DELIMITER ;