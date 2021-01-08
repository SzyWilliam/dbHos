drop trigger if exists patient_insert;
drop trigger if exists patient_severity_changed;
drop trigger if exists take_care_resource_released;

DELIMITER $$

create trigger patient_insert after insert on patient for each row
begin
    declare avi      int default  0;
    declare nurse_id int default -1;
    declare ward_num int default -1;
    declare bed_num  int default -1;

    call find_empty_nurse_and_bed(new.patient_severity, avi, nurse_id, ward_num, bed_num);

    if avi = 1 then
        insert into take_care values (new.patient_id, nurse_id, new.patient_severity, ward_num, bed_num);
    else
        insert into waiting_patient values (new.patient_id, now());
    end if;
end;
$$

create trigger patient_severity_changed after update on patient for each row
begin
    declare avi      int default  0;
    declare nurse_id int default -1;
    declare ward_num int default -1;
    declare bed_num  int default -1;

    if new.patient_severity <> old.patient_severity then
        call find_empty_nurse_and_bed(new.patient_severity, avi, nurse_id, ward_num, bed_num);

        if avi = 1 then
            delete from take_care where take_care.patient_id = new.patient_id;
            insert into take_care values (new.patient_id, nurse_id, new.patient_severity, ward_num, bed_num);
        end if;
    end if;
end;
$$

create trigger take_care_resource_released after delete on take_care for each row
begin
    declare waiting_patient_id int default 0;
    select patient_id into waiting_patient_id
    from patient natural join waiting_patient
    where patient.patient_severity = old.region;

    if waiting_patient_id > 0 then
        insert into take_care values (waiting_patient_id, old.nurse_id, old.region, old.ward_num, old.bed_num);
        delete from waiting_patient where waiting_patient.patient_id = waiting_patient_id;
    else
        select patient_id into waiting_patient_id
        from patient natural join take_care
        where patient_severity = old.region
        and patient_severity <> take_care.region; 

        if waiting_patient_id > 0 then
            delete from take_care where take_care.patient_id = waiting_patient_id;
            insert into take_care values (waiting_patient_id, old.nurse_id, old.region, old.ward_num, old.bed_num);
        end if;

    end if;
end;$$

DELIMITER ;
