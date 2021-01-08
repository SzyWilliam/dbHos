drop procedure if exists ward_record_daily_cond;
drop procedure if exists ward_query_patient_in_charge;
DELIMITER $$

create procedure ward_record_daily_cond(
    patient_id      int,
    temperature     numeric(4, 2),
    symptoms        varchar(255),
    record_status   varchar(32)
)
begin
    insert into patient_condition
    values (
        patient_id,
        now(),
        temperature,
        symptoms,
        record_status,
        recent_covid_test_id(patient_id, now())
    );

end $$



create procedure ward_query_patient_in_charge(
    patient_status varchar(32)
)
begin
    with patients_incharge(patient_id) as (
        select patient_id
        from take_care, personnel
        where take_care.nurse_id = personnel_id and personnel_name = get_current_username() and position = 'ward_nurse' 
    )
    select patient.patient_id, patient_name, age, patient_status, temperature
    from patients_incharge natural join patient natural join patient_condition
    where patient_condition.record_date = recent_patient_condition_date(patient.patient_id);

end $$

DELIMITER ;