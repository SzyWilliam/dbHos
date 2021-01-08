drop procedure if exists ward_record_daily_cond;
drop procedure if exists ward_query_patient_in_charge;
DELIMITER $$

create procedure ward_record_daily_cond(
    patient_id      int,
    temperature     numeric(4, 2),
    symptoms        varchar(255),
    record_status   varchar(32),
    record_date     date
)
begin
    if record_date is null then
        set record_date = now();
    end if;

    insert into patient_condition
    values (
        patient_id,
        record_date,
        temperature,
        symptoms,
        record_status,
        recent_covid_test_id(patient_id, date_add(record_date, interval 1 day))
    );

end $$



create procedure ward_query_patient_in_charge(
    patient_status varchar(32)
)
begin
    with patients_incharge(patient_id) as (
        select patient_id
        from take_care, personnel
        where take_care.nurse_id = personnel_id and username = get_current_username() and position = 'ward_nurse' 
    )
    select patient.patient_id, patient_name, age, patient_status, temperature
    from patients_incharge natural join patient left join patient_condition on (patients_incharge.patient_id = patient_condition.patient_id)
    where (patient_condition.record_date = recent_patient_condition_date(patient.patient_id) or patient_condition.record_date is null)
    and (patient.patient_status = patient_status or (patient_status is null and patient.patient_status is null));

end $$

DELIMITER ;