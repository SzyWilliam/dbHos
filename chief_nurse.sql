drop procedure if exists chief_query_bed;
drop procedure if exists chief_query_ward_nurses;
drop procedure if exists chief_fire_ward_nurse;
drop procedure if exists chief_hire_ward_nurse;
drop procedure if exists chief_query_patient_by_status;
drop procedure if exists chief_query_patient_to_transfer;

DELIMITER $$

create procedure chief_query_bed()
begin
    select bed.region, bed.ward_num, bed.bed_num, patient_name, age, patient_status
    from (bed left join take_care on (bed.region = take_care.region and bed.ward_num = take_care.ward_num and bed.bed_num = take_care.bed_num)) left join patient on (patient.patient_id = take_care.patient_id)
    where bed.region = get_personnel_region();
end $$

create procedure chief_query_ward_nurses()
begin
    select personnel_id, personnel_name, personnel.age, take_care.region, take_care.ward_num, take_care.bed_num, patient_name, patient_status
    from (personnel left join take_care on personnel.personnel_id = take_care.nurse_id) left join patient on patient.patient_id = take_care.patient_id
    where personnel.region = get_personnel_region() and personnel.position = 'ward_nurse';
end $$

create procedure chief_fire_ward_nurse(personnel_id int)
begin
    declare username varchar(255);
    select personnel.username into username
    from personnel
    where personnel.personnel_id = personnel_id;

    set @`sql_stmt` = CONCAT("drop user '", username, "'@'%'");
    PREPARE `stmt` FROM @`sql_stmt`;
    EXECUTE `stmt`;

    delete
    from personnel
    where personnel.personnel_id = personnel_id and personnel.position = 'ward_nurse' and personnel.region = get_personnel_region() and not exists (
        select * from take_care where nurse_id = personnel_id
    );
end $$

create procedure chief_hire_ward_nurse(
    username        varchar(255),
    pwd             varchar(255),
    personnel_name  varchar(255),
    age             int
)
begin

    insert into personnel (username, personnel_name, age, position, region) 
    values (
        username, personnel_name, age, 'ward_nurse', get_personnel_region()
    );

    set @`sql_stmt` = CONCAT("create user '", username, "' identified by '", pwd, "'");
    PREPARE `stmt` FROM @`sql_stmt`;
    EXECUTE `stmt`;
    set @`sql_stmt` = CONCAT("grant all privileges on hospital.* to '", username, "'@'%'");
    PREPARE `stmt` FROM @`sql_stmt`;
    EXECUTE `stmt`;
    DEALLOCATE PREPARE `stmt`;
    FLUSH PRIVILEGES;

end $$

create procedure chief_query_patient_by_status(
    patient_status varchar(32)
)
begin
    select patient_id, patient_name, patient.age, patient.patient_status, take_care.region, ward_num, bed_num, personnel_name, covid_test.severity
    from patient natural join take_care natural join covid_test, personnel
    where take_care.region = get_personnel_region() 
    and (patient.patient_status = patient_status or (patient.patient_status is null and patient_status is null))
    and take_care.nurse_id = personnel.personnel_id
    and covid_test.test_id = recent_covid_test_id(patient_id); 
end $$

create procedure chief_query_patient_to_transfer()
begin
    select patient_id patient_name, patient.age, patient.patient_status, take_care.region, ward_num, bed_num, personnel_name, covid_test.severity
    from patient natural join take_care natural join covid_test, personnel
    where take_care.region = get_personnel_region() 
    and take_care.nurse_id = personnel.personnel_id
    and covid_test.test_id = recent_covid_test_id(patient_id)
    and covid_test.severity <> take_care.region; 

end $$

DELIMITER ;