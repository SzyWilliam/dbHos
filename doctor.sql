drop procedure if exists doctor_query_chief_nurse;
drop procedure if exists doctor_query_ward_nurses;
drop procedure if exists doctor_query_patient_by_status;
drop procedure if exists doctor_query_patient_to_transfer;
drop procedure if exists doctor_query_patient_to_leave_hospital;
drop procedure if exists doctor_modify_patient_status;
drop procedure if exists doctor_modify_patient_severity;
drop procedure if exists doctor_do_covid_test;
drop procedure if exists doctor_drop_patient;

DELIMITER $$

create procedure doctor_query_chief_nurse()
begin
    select * from personnel
    where position = 'chief_nurse'
    and region = get_personnel_region();
end $$

create procedure doctor_query_ward_nurses()
begin
    select personnel_id, personnel_name as ward_nurse, personnel.age, take_care.region, take_care.ward_num, take_care.bed_num, patient_name, patient_status
    from (personnel left join take_care on personnel.personnel_id = take_care.nurse_id) left join patient on patient.patient_id = take_care.patient_id
    where personnel.region = get_personnel_region() and personnel.position = 'ward_nurse';
end $$

create procedure doctor_query_patient_by_status(
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

create procedure doctor_query_patient_to_transfer()
begin
    select patient_id, patient_name, patient.age, patient.patient_status, patient_severity as severity, take_care.region, ward_num, bed_num, personnel_name as ward_nurse
    from patient natural join take_care, personnel
    where take_care.region = get_personnel_region() 
    and take_care.nurse_id = personnel.personnel_id
    and patient_severity <> take_care.region; 
end $$

create procedure doctor_modify_patient_status(
    patient_id int,
    patient_status varchar(32)
)
begin
    update patient set patient.patient_status = patient_status
    where patient.patient_id = patient_id
    and get_patient_region(patient_id) = get_personnel_region();
end $$

create procedure doctor_modify_patient_severity(
    patient_id int,
    severity varchar(16)
)
begin
    update patient set patient_severity = severity
    where patient.patient_id = patient_id
    and get_patient_region(patient_id) = get_personnel_region();
end $$

create procedure doctor_do_covid_test(
    patient_id  int,
    test_result varchar(16),
    severity    varchar(16)
)
begin
    insert into covid_test (patient_id, test_date, test_result, severity)
    values (patient_id, now(), test_result, severity);
    
    call doctor_modify_patient_severity(severity);
end $$

create procedure doctor_query_patient_to_leave_hospital()
begin
    select patient_id, patient_name, patient.age, patient.patient_status, patient_severity as severity, take_care.region, ward_num, bed_num, personnel_name as ward_nurse
    from patient natural join take_care personnel
    where take_care.region = get_personnel_region() 
    and take_care.nurse_id = personnel.personnel_id
    and check_patient_if_recovered(patient_id) = 1; 
end $$

create procedure doctor_drop_patient(
    patient_id int
)
begin
    if check_patient_if_recovered(patient_id) = 1 then
        call doctor_modify_patient_status(patient_id, 'recovered');
        delete from take_care where take_care.patient_id = patient_id;
    end if;
end $$


DELIMITER ;