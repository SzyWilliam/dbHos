/* Bed */
insert into bed values ('urgent', 1, 1);
insert into bed values ('urgent', 2, 1);
insert into bed values ('severe', 1, 1);
insert into bed values ('severe', 1, 2);
insert into bed values ('severe', 2, 1);
insert into bed values ('severe', 2, 2);
insert into bed values ('mild', 1, 1);
insert into bed values ('mild', 1, 2);
insert into bed values ('mild', 1, 3);
insert into bed values ('mild', 1, 4);
insert into bed values ('mild', 2, 1);
insert into bed values ('mild', 2, 2);
insert into bed values ('mild', 2, 3);
insert into bed values ('mild', 2, 4);

/* Doctors */
call personnel_register('Chen Rong', 'DrChen', '_Pass123456', 42, 'doctor', 'mild');
call personnel_register('Yan Hua', 'DrYan', '_Pass123456', 20, 'doctor', 'severe');
call personnel_register('Liao Rong Shang', 'DrLiao', '_Pass123456', 20, 'doctor', 'urgent');

/* Chief Nurses */
call personnel_register('Chen Yuan Yuan', 'CNChen', '_Pass123456', 42, 'chief_nurse', 'mild');
call personnel_register('Mrs.Yan', 'CNYan', '_Pass123456', 20, 'chief_nurse', 'severe');
call personnel_register('Mrs.Liao', 'CNLiao', '_Pass123456', 20, 'chief_nurse', 'urgent');

/* Emergency Nurses */
call personnel_register('Dasiy', 'ENDasiy', '_Pass123456', 34, 'emergency_nurse', null);
call personnel_register('Emma', 'ENEmma', '_Pass123456', 34, 'emergency_nurse', null);

/* Ward Nurses */
call personnel_register('Fiona', 'WNFiona', '_Pass123456', 27, 'ward_nurse', 'mild');
call personnel_register('Grace', 'WNGrace', '_Pass123456', 32, 'ward_nurse', 'severe');
call personnel_register('Helen', 'WNHelon', '_Pass123456', 50, 'ward_nurse', 'severe');
call personnel_register('Ilene', 'WNIlene', '_Pass123456', 35, 'ward_nurse', 'urgent');
call personnel_register('Jerry', 'WNJerry', '_Pass123456', 44, 'ward_nurse', 'urgent');
call personnel_register('Kim', 'WNKim', '_Pass123456', 43, 'ward_nurse', 'urgent');

set @`first_patient_id` = em_add_patient('Alice', 18, '2021-01-01 14:12:23', 'positive', 'mild');
set @`second_patient_id` =  em_add_patient('Bob', 38, '2021-01-06 09:53:23', 'positive', 'severe');
set @`third_patient_id` = em_add_patient('Crystal', 58, '2021-01-07 15:32:23', 'positive', 'urgent');

/* Patient Condition */
call ward_record_daily_cond(@`first_patient_id`, 38.9, 'somewhat not good', 'under_treatment', '2021-01-01');
call ward_record_daily_cond(@`first_patient_id`, 38.7, 'somewhat not good', 'under_treatment', '2021-01-02');
call ward_record_daily_cond(@`first_patient_id`, 38.5, 'somewhat not good', 'under_treatment', '2021-01-03');
call ward_record_daily_cond(@`first_patient_id`, 38.3, 'somewhat not good', 'under_treatment', '2021-01-04');
call ward_record_daily_cond(@`first_patient_id`, 38.1, 'somewhat not good', 'under_treatment', '2021-01-05');
call ward_record_daily_cond(@`first_patient_id`, 37.2, 'somewhat good', 'under_treatment', '2021-01-06');
call ward_record_daily_cond(@`first_patient_id`, 37.1, 'somewhat good', 'under_treatment', '2021-01-07');
call ward_record_daily_cond(@`first_patient_id`, 36.9, 'somewhat good', 'under_treatment', '2021-01-08');

call ward_record_daily_cond(@`second_patient_id`, 39.1, 'somewhat  urgent', 'under_treatment', '2021-01-06');
call ward_record_daily_cond(@`second_patient_id`, 38.9, 'not very good', 'under_treatment', '2021-01-07');
call ward_record_daily_cond(@`second_patient_id`, 39.3, 'almost dead', 'under_treatment', '2021-01-08');

call ward_record_daily_cond(@`third_patient_id`, 37.1, 'become more bad', 'under_treatment', '2021-01-07');
call ward_record_daily_cond(@`third_patient_id`, 37.2, 'somewhat severe', 'under_treatment', '2021-01-08');