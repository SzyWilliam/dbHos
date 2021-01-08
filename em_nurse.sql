set global log_bin_trust_function_creators=TRUE;

drop function if exists em_add_patient;
drop procedure if exists em_query_patient_in_hospital;


DELIMITER $$
/* 在收治确诊患者时，急诊护士需要导入病人信息(包括个人基础信息、病情评级等等) */

create function em_add_patient(
    patient_name varchar(255),
    age int,
    test_date timestamp,
    test_result varchar(16),
    severity varchar(16)
) returns integer
begin
    declare p_id integer;
    
    insert into patient(patient_name, age) values (patient_name, age);
    set p_id = last_insert_id();
    insert into covid_test(patient_id, test_date, test_result, severity) values(p_id, test_date, test_result, severity);

    return p_id;
end $$  


/* TODO 如果patient没有每日记录，那么以下的query将没有这个patient的信息*/
create procedure em_query_patient_in_hospital(
    region varchar(32),
    severity varchar(16),
    patient_status varchar(32)
) 
begin
    select patient.patient_id, patient_name, age, temperature, take_care.region, severity, patient_status
    from patient natural join patient_condition natural join take_care, covid_test
    where
    (patient_condition.record_date = recent_patient_condition_date(patient.patient_id) or recent_patient_condition_date(patient.patient_id) is null) and
    (recent_covid_test_id(patient.patient_id) = covid_test.test_id) and 
    (take_care.region = region) and 
    (covid_test.severity = severity) and 
    (patient.patient_status = patient_status or (patient_status is null and patient.patient_status is null)) ;

end $$

DELIMITER ;


