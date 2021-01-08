drop function if exists recent_covid_test_id;
drop function if exists recent_patient_condition_date;
drop function if exists get_current_username;
drop function if exists get_personnel_region;


DELIMITER $$

create function recent_covid_test_id(patient_id int) returns integer
begin
    declare recent_test_id integer;
    with recent_test(patient_id, test_date) as (
        select patient_id, MAX(test_date)
        from covid_test
        where covid_test.patient_id = patient_id
        group by covid_test.patient_id
    )
    select test_id into recent_test_id
    from recent_test natural join covid_test;

    return recent_test_id;
end $$

create function recent_patient_condition_date(patient_id int) returns date
begin
    declare recent_record_date date;
    with recent_record(patient_id, record_date) as (
        select patient_id, MAX(record_date)
        from patient_condition
        where patient_condition.patient_id = patient_id
        group by patient_id
    )
    select recent_record.record_date from recent_record into recent_record_date;
    
    return recent_record_date;
end $$

create function get_current_username() returns varchar(255)
begin
    return left(user(), instr(user(), '@') - 1);
end $$


create function get_personnel_region() returns varchar(32)
begin
    declare per_region varchar(32);
    
    select region into per_region
    from personnel
    where username = get_current_username();
    
    return per_region;
end $$

create function check_patient_if_recovered(
    patient_id int
)
begin
    declare res int;
    set res = 0;
    select count(patient_id) into res
    from patient natural join patient_condition
    where patient.patient_id = patient_id
    and get_temperature_by_date(now()) < 37.3
    and get_temperature_by_date(date_sub(now() interval 1 day)) < 37.3
    and get_temperature_by_date(date_sub(now() interval 2 day)) < 37.3
end $$

create function get_temperature_by_date(
    patient_id int,
    record_date  date
) returns numeric(4, 2)
begin
    declare temp numeric(4, 2);
    select temperature into temp
    from patient_condition
    where patient_condition.patient_id = patient_id
    and patient_condition.record_date = record_date; 
    return temp;
end $$

DELIMITER ;