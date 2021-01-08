drop function if exists recent_covid_test_id;
drop function if exists recent_patient_condition_date;
drop function if exists get_current_username;
drop function if exists get_personnel_region;
drop function if exists get_patient_region;
drop function if exists get_temperature_by_date;
drop function if exists check_patient_if_recovered;
drop function if exists check_patient_covid_test_passed;
drop procedure if exists find_empty_nurse_and_bed;
drop function if exists get_already_take_care;
drop function if exists get_max_take_care;
drop procedure if exists personnel_register;
drop procedure if exists personnel_leave;

DELIMITER $$


create function recent_covid_test_id(
    patient_id      int,
    recent_date     timestamp
) returns integer
begin
    declare recent_test_id integer;
    set recent_test_id = -1;
    with recent_test(patient_id, test_date) as (
        select patient_id, MAX(test_date)
        from covid_test
        where covid_test.patient_id = patient_id
        and test_date <= recent_date
        group by covid_test.patient_id
    )
    select test_id into recent_test_id
    from recent_test natural join covid_test;

    return recent_test_id;
end $$

create function recent_patient_condition_date(patient_id int) returns date
begin
    declare recent_record_date date default null;
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

create function get_patient_region(
    patient_id int
) returns varchar(32)
begin
    declare patient_region varchar(32);
    
    select region into patient_region
    from patient natural join take_care
    where patient.patient_id = patient_id;
    
    return patient_region;
end $$


create function check_patient_if_recovered(
    patient_id int
) returns integer
begin
    declare res int;
    set res = 0;
    select count(distinct patient_id) into res
    from patient natural join patient_condition
    where patient.patient_id = patient_id
    and patient_status = 'under_treatment'
    and get_temperature_by_date(patient_id, now()) < 37.3
    and get_temperature_by_date(patient_id, date_sub(now(), interval 1 day)) < 37.3
    and get_temperature_by_date(patient_id, date_sub(now(), interval 2 day)) < 37.3
    and check_patient_covid_test_passed(patient_id) = 1;
    return res;
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

create function check_patient_covid_test_passed(
    patient_id int
) returns integer
begin
    declare recent_test_date timestamp default null;
    declare interval_test_date timestamp default null;

    declare all_covid_tests_between int;
    declare all_negative_covid_tests_between int;

    select covid_test.test_date into recent_test_date
    from covid_test
    where test_id = recent_covid_test_id(patient_id, now());

    select covid_test.test_date into interval_test_date
    from covid_test
    where test_id = recent_covid_test_id(patient_id, timestamp(recent_test_date, '-24:00:00'));

    if interval_test_date is null then
        return 0;
    end if;

    select count(test_id) into all_covid_tests_between
    from covid_test
    where covid_test.patient_id = patient_id
    and (test_date >= interval_test_date and test_date <= recent_test_date);

    select count(test_id) into all_negative_covid_tests_between
    from covid_test
    where covid_test.patient_id = patient_id
    and (test_date >= interval_test_date and test_date <= recent_test_date)
    and test_result = 'negative';

    if all_covid_tests_between = all_negative_covid_tests_between then
        return 1;
    end if;

    return 0;
end $$

create procedure find_empty_nurse_and_bed(
    in region       varchar(16),
    out avi         int,
    out nurse_id    int,
    out ward_num    int,
    out bed_num     int
)
begin
    set avi = 0;
    set nurse_id = -1;
    set ward_num = -1;
    set bed_num = -1;

    select min(personnel_id) into nurse_id from personnel
    where personnel.position = 'ward_nurse'
    and personnel.region = region
    and get_already_take_care(personnel.personnel_id) < get_max_take_care(region);

    select min(bed.ward_num) into ward_num
    from bed
    where bed.region = region
    and not exists (
        select * from take_care
        where take_care.region = region
        and take_care.ward_num = bed.ward_num
        and take_care.bed_num = bed.bed_num
    );

    select min(bed.bed_num) into bed_num
    from bed
    where bed.region = region
    and bed.ward_num = ward_num
    and not exists (
        select * from take_care
        where take_care.region = region
        and take_care.ward_num = bed.ward_num
        and take_care.bed_num = bed.bed_num
    );

    if nurse_id > 0 and ward_num > 0 and bed_num > 0 then
        set avi = 1;
    end if;
end $$

create function get_already_take_care(
    nurse_id int
) returns integer
begin
    declare num int default 0;
    select count(patient_id) into num from take_care
    where take_care.nurse_id = nurse_id;
    return num;
end $$

create function get_max_take_care(
    region varchar(16)
) returns integer
begin
    if region = 'mild' then
        return 3;
    elseif region = 'severe' then
        return 2;
    elseif region = 'urgent' then
        return 1;
    else
        return 0;
    end if;
end $$

create procedure personnel_register(
    personnel_name varchar(255),
    username varchar(255),
    pwd      varchar(255),
    age      int,
    position varchar(32),
    region   varchar(16)
)
begin
    set @`sql_stmt` = CONCAT("create user '", username, "' identified by '", pwd, "'");
    PREPARE `stmt` FROM @`sql_stmt`;
    EXECUTE `stmt`;
    set @`sql_stmt` = CONCAT("grant all privileges on hospital.* to '", username, "'@'%' with grant option");
    PREPARE `stmt` FROM @`sql_stmt`;
    EXECUTE `stmt`;
    DEALLOCATE PREPARE `stmt`;
    FLUSH PRIVILEGES;

    insert into personnel (username, personnel_name, age, position, region) 
    values (
        username, personnel_name, age, position, region
    );
end $$

create procedure personnel_leave(
    personnel_id int
)
begin
    declare username varchar(255);
    select personnel.username into username
    from personnel
    where personnel.personnel_id = personnel_id;

    set @`sql_stmt` = CONCAT("drop user '", username, "'@'%'");
    PREPARE `stmt` FROM @`sql_stmt`;
    EXECUTE `stmt`;

    delete from personnel
    where personnel.personnel_id = personnel_id;
end $$

DELIMITER ;