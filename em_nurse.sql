drop function if exists em_add_patient;
drop procedure if exists em_query_patient_in_hospital;
drop procedure if exists em_query_waiting_patient;

DELIMITER $$
/* 在收治确诊患者时，急诊护士需要导入病人信息(包括个人基础信息、病情评级等等) */

create function em_add_patient(
    p_name varchar(255),
    p_age int,
    test_date timestamp,
    test_result varchar(16),
    severity varchar(16)
) returns integer
begin
    declare p_id integer default 0;
    insert into patient(patient_name, age, patient_severity) values(p_name, p_age, severity);
    set p_id = last_insert_id();
    insert into covid_test(patient_id, test_date, test_result, severity) values(p_id, test_date, test_result, severity);
    return p_id;

end $$  


create procedure em_query_patient_in_hospital(
    region varchar(16),
    severity varchar(16),
    patient_status varchar(32)
) 
begin
    select patient.patient_id, patient_name, age, temperature, take_care.region, patient_severity, patient_status
    from (patient left join patient_condition on (patient.patient_id = patient_condition.patient_id)) natural join take_care
    where (patient_condition.record_date = recent_patient_condition_date(patient.patient_id) or recent_patient_condition_date(patient.patient_id) is null)
    and take_care.region = region
    and patient.patient_severity = severity
    and patient.patient_status = patient_status;

end $$

create procedure em_query_waiting_patient()
begin
    select * from patient natural join waiting_patient;
end $$

DELIMITER ;