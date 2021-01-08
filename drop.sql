drop USER 'DrChen'@'%';
drop USER 'DrYan'@'%';
drop USER 'DrLiao'@'%';
drop USER 'CNChen'@'%';
drop USER 'CNYan'@'%';
drop USER 'CNLiao'@'%';
drop USER 'ENDasiy'@'%';
drop USER 'ENEmma'@'%';
drop USER 'WNFiona'@'%';
drop USER 'WNGrace'@'%';
drop USER 'WNHelon'@'%';
drop USER 'WNIlene'@'%';
drop USER 'WNJerry'@'%';
drop USER 'WNKim'@'%';

drop trigger if exists patient_insert;
drop trigger if exists patient_severity_changed;
drop trigger if exists take_care_resource_released;

delete from take_care;
delete from patient_condition;
delete from waiting_patient;
delete from covid_test;
delete from bed;
delete from patient;
delete from personnel;