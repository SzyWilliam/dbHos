delete from take_care;
delete from bed;
delete from patient_condition;
delete from waiting_patient;
delete from personnel;
delete from covid_test;
delete from patient;

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
drop USER 'WNHelen'@'%';
drop USER 'WNIlene'@'%';
drop USER 'WNJerry'@'%';
drop USER 'WNKim'@'%';

CREATE USER 'DrChen' IDENTIFIED BY "_Pass123456";
CREATE USER 'DrYan' IDENTIFIED BY "_Pass123456";
CREATE USER 'DrLiao' IDENTIFIED BY "_Pass123456";
CREATE USER 'CNChen' IDENTIFIED BY "_Pass123456";
CREATE USER 'CNYan' IDENTIFIED BY "_Pass123456";
CREATE USER 'CNLiao' IDENTIFIED BY "_Pass123456";
CREATE USER 'ENDasiy' IDENTIFIED BY "_Pass123456";
CREATE USER 'ENEmma' IDENTIFIED BY "_Pass123456";
CREATE USER 'WNFiona' IDENTIFIED BY "_Pass123456";
CREATE USER 'WNGrace' IDENTIFIED BY "_Pass123456";
CREATE USER 'WNHelen' IDENTIFIED BY "_Pass123456";
CREATE USER 'WNIlene' IDENTIFIED BY "_Pass123456";
CREATE USER 'WNJerry' IDENTIFIED BY "_Pass123456";
CREATE USER 'WNKim' IDENTIFIED BY "_Pass123456";

grant all privileges on hospital.* to 'DrChen'@'%';
grant all privileges on hospital.* to 'DrYan'@'%';
grant all privileges on hospital.* to 'DrLiao'@'%';

grant all privileges on hospital.* to 'CNChen'@'%';
grant all privileges on hospital.* to 'CNYan'@'%';
grant all privileges on hospital.* to 'CNLiao'@'%';

/* Patients */
insert into patient values ('1', 'Alice', '18', null);
insert into patient values ('2', 'Bob', '78', null);
insert into patient values ('3', 'Crystal', '48', null);

/* Doctors */
insert into personnel values ('1', 'DrChen', 'Chen Rong', '42', 'doctor', 'mild');
insert into personnel values ('2', 'DrYan', 'Yan Hua', '20', 'doctor', 'severe');
insert into personnel values ('3', 'DrLiao', 'Liao Rong Shang', '20', 'doctor', 'urgent');

/* Chief Nurses */
insert into personnel values ('4', 'CNChen', 'Chen Yuan Yuan', '24', 'chief_nurse', 'mild');
insert into personnel values ('5', 'CNYan', 'Mrs.Yan', '20', 'chief_nurse', 'severe');
insert into personnel values ('6', 'CNLiao', 'Mrs.Liao', '20', 'chief_nurse', 'urgent');

/* Emergency Nurses */
insert into personnel values ('7', 'ENDasiy', 'Dasiy', '34', 'emergency_nurse', null);
insert into personnel values ('8', 'ENEmma', 'Emma', '20', 'emergency_nurse', null);

/* Ward Nurses */
insert into personnel values ('9', 'WNFiona', 'Fiona', '27', 'ward_nurse', 'mild');
insert into personnel values ('10', 'WNGrace', 'Grace', '32', 'ward_nurse', 'severe');
insert into personnel values ('11', 'WNHelen', 'Helen', '50', 'ward_nurse', 'severe');
insert into personnel values ('12', 'WNIlene', 'Ilene', '35', 'ward_nurse', 'urgent');
insert into personnel values ('13', 'WNJerry', 'Jerry', '44', 'ward_nurse', 'urgent');
insert into personnel values ('14', 'WNKim', 'Kim', '43', 'ward_nurse', 'urgent');

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

/* Covid Test */
insert into covid_test values (1, 1, '2020-12-12 13:43:23', 'positive', 'mild');
insert into covid_test values (2, 2, '2019-10-22 23:15:46', 'positive', 'severe');
insert into covid_test values (3, 2, '2019-10-24 11:48:15', 'positive', 'urgent');
insert into covid_test values (4, 3, '2020-04-15 03:39:56', 'positive', 'urgent');

/* Patient Condition */
insert into patient_condition values (1, '2020-12-12', '38.9', 'almost recovered', 'under_treatment', 1);
insert into patient_condition values (1, '2020-12-13', '37.4', 'already recoverd', 'recovered', 1);

insert into patient_condition values (2, '2019-10-22', '38.3', 'somehow severe', 'under_treatment', 2);
insert into patient_condition values (2, '2019-10-23', '38.9', 'somehow become more terrible', 'under_treatment', 2);
insert into patient_condition values (2, '2019-10-24', '39.3', 'already urgent', 'under_treatment', 3);
insert into patient_condition values (2, '2019-10-25', '39.1', 'no hope', 'dead', 3);

insert into patient_condition values (3, '2020-04-15', '39.4', 'seem not good', 'under_treatment', 4);
insert into patient_condition values (3, '2020-04-16', '37.4', 'recover exetremely quick', 'recovered', 4);

/* Take Care */
insert into take_care values(1, 7, 'mild', 1, 1);
insert into take_care values(2, 12, 'urgent', 1, 1);
insert into take_care values(3, 13, 'urgent', 2, 1);

/* Waiting Patient */

