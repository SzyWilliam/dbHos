set global log_bin_trust_function_creators=TRUE;

drop table if exists patient_condition;
drop table if exists covid_test;
drop table if exists waiting_patient;
drop table if exists take_care;
drop table if exists bed;
drop table if exists personnel;
drop table if exists patient;


create table patient
(
    patient_id   int auto_increment,
    patient_name varchar(255) not null,
    age          int not null,
    patient_status varchar(32) default 'under_treatment',
    patient_severity varchar(16) not null,

    primary key (patient_id),
    check (patient_severity in ('mild', 'severe', 'urgent')),
    check (patient_status in ('recovered', 'under_treatment', 'dead'))
);

create table covid_test
(
    test_id    int auto_increment,
    patient_id int,
    test_date  timestamp not null,
    test_result     varchar(16) not null,
    severity   varchar(16) not null,

    primary key (test_id),
    foreign key (patient_id) references patient(patient_id),
    check (severity in ('mild', 'severe', 'urgent')),
    check (test_result in ('positive', 'negative'))
);

create table personnel
(
    personnel_id    int auto_increment,
    username        varchar(255),
    personnel_name  varchar(255) not null,
    age             int not null,
    position        varchar(32) not null,
    region          varchar(16),
    

    primary key (personnel_id),
    unique (username),
    check (position in ('doctor', 'chief_nurse', 'ward_nurse', 'emergency_nurse')),
    check (region in ('mild', 'severe', 'urgent') or position in ('emergency_nurse'))
);

create table bed
(
    region    varchar(16),
    ward_num  int not null,
    bed_num   int not null,

    primary key (region, ward_num, bed_num),
    check (region in ('mild', 'severe', 'urgent'))
);


create table patient_condition
(
    patient_id      int,
    record_date     date,
    temperature     numeric(4, 2) not null,
    symptoms        varchar(255) not null,
    record_status  varchar(32),
    recent_covid_test int,

    primary key (patient_id, record_date),
    foreign key (patient_id) references patient(patient_id),
    foreign key (recent_covid_test) references covid_test(test_id),
    check (record_status in ('recovered', 'under_treatment', 'dead'))
);

/* TODO Mr.Pan insist to check nurse shit */
create table take_care
(
    patient_id      int,
    nurse_id        int,
    region    varchar(16),
    ward_num  int not null,
    bed_num   int not null,

    primary key (patient_id),
    foreign key (patient_id) references patient(patient_id),
    foreign key (nurse_id) references personnel(personnel_id), 
    foreign key (region, ward_num, bed_num) references bed(region, ward_num, bed_num)
);

create table waiting_patient
(
    patient_id      int,
    start_time      date,

    primary key (patient_id),
    foreign key (patient_id) references patient(patient_id)
)