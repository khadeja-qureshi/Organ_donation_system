begin
    execute immediate 'DROP TABLE HOSPITAL_NOTIFICATION CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE ACCEPTED_MATCH CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE POTENTIAL_MATCH CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE EMERGENCY_CONTACT CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE ADD_LOCATION CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE HOSPITAL_ADMIN CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE RECIPIENT CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE ORGAN CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE DONOR CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE HOSPITAL CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/
begin
    execute immediate 'DROP TABLE ADMIN CASCADE CONSTRAINTS PURGE';
exception when others then null; end;
/

create table admin (
    admin_id      number generated always as identity primary key,
    name          varchar2(100) not null,
    email         varchar2(100) unique not null,
    phone_contact varchar2(20),
    role          varchar(50),
    department    varchar2(50),
    address       varchar2(200)
);


create table emergency_contact (
    contact_id      number generated always as identity primary key,
    contact_name    varchar2(100) not null,
    contact_number  varchar2(20) not null,
    relationship    varchar2(50)
);

create table add_location (
    location_id      number generated always as identity primary key,
    address    varchar2(200) not null,
    area       varchar2(100) not null,
    district    varchar2(100) not null,
    city         varchar2(100) not null,
    province    varchar2(100) not null
);




create table donor (
    donor_id       number generated always as identity primary key,
    name           varchar2(100) not null,
    age            number(3) not null check (age between 18 and 75),
    weight         number(7,2) check (weight > 0),
    phone_contact  varchar2(20),
    email          varchar2(100) unique,
    registration_date date default sysdate not null,
    blood_type     varchar2(3) not null check (blood_type in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    last_checkup   date,
    medical_condition  clob,
    status         varchar2(20) default 'Active' check (status in ('Active','Inactive','Deceased','Suspended')),
    is_verified    char(1) default 'N' check (is_verified in ('Y','N')),
    verified_by    number,
    contact_id     number not null,
    location_id     number not null,
    constraint fk_emergency_contact foreign key (contact_id) references emergency_contact(contact_id) on delete cascade,
    constraint fk_location foreign key (location_id) references add_location(location_id) on delete cascade,
    constraint fk_d_verfied_by foreign key (verified_by) references admin(admin_id)
);

create index idx_donor_blood_type on donor(blood_type);
create index idx_donor_status on donor(status);

create table organ (
    organ_id     number generated always as identity primary key,
    donor_id     number not null,
    organ_type   varchar2(20) not null check (organ_type in ('Heart','Kidney','Liver','Lung','Pancreas','Intestine','Cornea')),
    status       varchar2(20) default 'Available' check (status in ('Available','Unavailable','Matched','Transplanted','Expired')),
    registration_date date default sysdate not null,
    organ_size         varchar2(20),
    organ_condition    varchar2(500),
    constraint fk_organ_donor foreign key (donor_id) references donor(donor_id) on delete cascade
);

create index idx_organ_status on organ(status);
create index idx_organ_type on organ(organ_type);
create index idx_organ_donor on organ(donor_id);

create table hospital (
    hospital_id       number generated always as identity primary key,
    name              varchar2(150) not null,
    license_number    varchar2(50) unique not null,
    contact_info      varchar2(20),
    email             varchar2(100) unique,
    transplant_facility char(1) default 'N' check (transplant_facility in ('Y','N')),
    status            varchar2(20) default 'Active' check (status in ('Active','Inactive','Suspended')),
    is_verified       char(1) default 'N' check (is_verified in ('Y','N')),
    verified_by    number,
    registration_date date default sysdate not null,
    location_id number not null,
    constraint fk_h_location foreign key (location_id) references add_location(location_id) on delete cascade,
    constraint fk_h_verfied_by foreign key (verified_by) references admin(admin_id)
);

create index idx_hospital_status on hospital(status);
create index idx_hospital_transplant on hospital(transplant_facility);

create table hospital_admin (
    hospital_admin_id number generated always as identity primary key,
    hospital_id       number not null,
    admin_name        varchar2(200),
    contact_no        varchar2(20),
    role              varchar2(50),
    constraint fk_ha_hospital foreign key (hospital_id) references hospital(hospital_id) on delete cascade
);

create index idx_hospital_admin_hospital on hospital_admin(hospital_id);
create index idx_hospital_admin_admin on hospital_admin(admin_name);

create table recipient (
    recipient_id    number generated always as identity primary key,
    hospital_id     number not null,
    name            varchar2(100) not null,
    cnic            varchar2(20) not null unique,
    age             number(3) not null check (age between 0 and 120),
    blood_type      varchar2(3) not null check (blood_type in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    weight          number(7,2) check (weight > 0),
    organ_required  varchar2(20) not null check (organ_required in ('Heart','Kidney','Liver','Lung','Pancreas','Intestine','Cornea')),
    registration_date date default sysdate not null,
    status          varchar2(20) default 'Waiting' check (status in ('Waiting','Matched','Transplanted','Deceased','Removed')),
    critical_level  varchar2(10) default 'Medium' check (critical_level in ('Critical','High','Medium','Low')),
    priority_score  number default 50 check (priority_score between 0 and 100),
    medical_history clob,
     contact_id     number not null,
     constraint fk_r_emergency_contact foreign key (contact_id) references emergency_contact(contact_id) on delete cascade,
    constraint fk_recipient_hospital foreign key (hospital_id) references hospital(hospital_id)
);

create index idx_recipient_blood_type on recipient(blood_type);
create index idx_recipient_organ on recipient(organ_required);
create index idx_recipient_status on recipient(status);
create index idx_recipient_critical on recipient(critical_level);
create index idx_recipient_hospital on recipient(hospital_id);

create table potential_match (
    match_id           number generated always as identity primary key,
    organ_id           number not null,
    recipient_id       number not null,
    compatibility_score number(5,2) check (compatibility_score between 0 and 100),
    blood_compatibility char(1) default 'N' check (blood_compatibility in ('Y','N')),
    urgency_score      number check (urgency_score between 0 and 100),
    match_date         date default sysdate not null,
    location_distance  number(10,2),
    estimated_travel_time number,
    status             varchar2(20) default 'Pending' check (status in ('Pending','Accepted','Rejected','Cancelled','Expired')),
    constraint fk_pm_organ foreign key (organ_id) references organ(organ_id) on delete cascade,
    constraint fk_pm_recipient foreign key (recipient_id) references recipient(recipient_id) on delete cascade
);

create index idx_potential_organ on potential_match(organ_id);
create index idx_potential_recipient on potential_match(recipient_id);
create index idx_potential_status on potential_match(status);
create index idx_potential_compatibility on potential_match(compatibility_score);

create table accepted_match (
    accepted_id           number generated always as identity primary key,
    match_id              number unique not null,
    donor_confirmation    char(1) default 'N' check (donor_confirmation in ('Y','N')),
    donor_confirmation_date timestamp,
    admin_approval        char(1) default 'N' check (admin_approval in ('Y','N')),
    match_status          varchar2(20) default 'Pending_Approval' check (match_status in ('Pending_Approval','Approved','Rejected','Completed','Failed')),
    acceptance_date       timestamp default systimestamp not null,
    patient_outcome       clob,
    approved_by           number,
    constraint fk_am_match foreign key (match_id) references potential_match(match_id) on delete cascade,
    constraint fk_am_approved_by foreign key (approved_by) references admin(admin_id)
);

create index idx_accepted_match_status on accepted_match(match_status);
create index idx_accepted_approved_by on accepted_match(approved_by);
create index idx_accepted_match on accepted_match(match_id);

create table hospital_notification (
    notification_id   number generated always as identity primary key,
    accepted_id       number not null,
    hospital_id       number not null,
    notification_date timestamp default systimestamp not null,
    status            varchar2(20) default 'Sent' check (status in ('Sent','Delivered','Acknowledged','Failed')),
    acknowledged_date timestamp,
    constraint fk_hn_accepted foreign key (accepted_id) references accepted_match(accepted_id) on delete cascade,
    constraint fk_hn_hospital foreign key (hospital_id) references hospital(hospital_id) on delete cascade
);

create index idx_notification_hospital on hospital_notification(hospital_id);
create index idx_notification_accepted on hospital_notification(accepted_id);
create index idx_notification_status on hospital_notification(status);


--triggers
create or replace trigger trg_pm_all
before insert or update on potential_match
for each row
declare
    v_donor_age number;
    v_donor_weight number;
    v_donor_bt varchar2(3);
    v_donor_organ varchar2(20);
    v_donor_loc_id number;
    v_donor_area varchar2(100);
    v_donor_district varchar2(100);
    v_donor_city varchar2(100);
    v_donor_province varchar2(100);

    v_recipient_age number;
    v_recipient_weight number;
    v_recipient_bt varchar2(3);
    v_recipient_organ varchar2(20);
    v_recipient_prio number;
    v_recipient_crit varchar2(10);
    v_recip_loc_id number;
    v_recip_area varchar2(100);
    v_recip_district varchar2(100);
    v_recip_city varchar2(100);
    v_recip_province varchar2(100);

 
    v_score number := 0;
    v_weight number;
begin
    
    select d.age, d.weight, d.blood_type, o.organ_type, d.location_id
    into v_donor_age, v_donor_weight, v_donor_bt, v_donor_organ, v_donor_loc_id
    from donor d
    join organ o on d.donor_id = o.donor_id
    where o.organ_id = :new.organ_id;

    select area, district, city, province
    into v_donor_area, v_donor_district, v_donor_city, v_donor_province
    from add_location
    where location_id = v_donor_loc_id;
    
    select age, weight, blood_type, organ_required, priority_score, critical_level, h.location_id
    into v_recipient_age, v_recipient_weight, v_recipient_bt, v_recipient_organ, v_recipient_prio, v_recipient_crit, v_recip_loc_id
    from recipient r
    join hospital h on r.hospital_id = h.hospital_id
    where r.recipient_id = :new.recipient_id;

    select area, district, city, province
    into v_recip_area, v_recip_district, v_recip_city, v_recip_province
    from add_location
    where location_id = v_recip_loc_id;

    if (
        (v_donor_bt = 'O-' ) or
        (v_donor_bt = 'O+' and v_recipient_bt in ('O+','A+','B+','AB+')) or
        (v_donor_bt = 'A-' and v_recipient_bt in ('A-','A+','AB-','AB+')) or
        (v_donor_bt = 'A+' and v_recipient_bt in ('A+','AB+')) or
        (v_donor_bt = 'B-' and v_recipient_bt in ('B-','B+','AB-','AB+')) or
        (v_donor_bt = 'B+' and v_recipient_bt in ('B+','AB+')) or
        (v_donor_bt = 'AB-' and v_recipient_bt in ('AB-','AB+')) or
        (v_donor_bt = 'AB+' and v_recipient_bt = 'AB+')
    ) then
        :new.blood_compatibility := 'Y';
        v_score := v_score + 40;  
    else
        :new.blood_compatibility := 'N';
    end if;
    v_score := v_score + case 
                            when abs(v_donor_age - v_recipient_age) <= 10 then 20
                            when abs(v_donor_age - v_recipient_age) <= 20 then 10
                            else 0 
                          end;
    v_score := v_score + case 
                            when abs(v_donor_weight - v_recipient_weight) <= 10 then 20
                            when abs(v_donor_weight - v_recipient_weight) <= 20 then 10
                            else 0 
                          end;

    if v_donor_organ = v_recipient_organ then
        v_score := v_score + 20;
    end if;

    :new.compatibility_score := least(v_score, 100);

    if v_donor_area = v_recip_area then
        :new.location_distance := 5;
    elsif v_donor_district = v_recip_district then
        :new.location_distance := 15;
    elsif v_donor_city = v_recip_city then
        :new.location_distance := 50;
    elsif v_donor_province = v_recip_province then
        :new.location_distance := 100;
    else
        :new.location_distance := 200;
    end if;

    if :new.location_distance <= 5 then
        :new.estimated_travel_time := round(:new.location_distance / 1.2, 2);
    elsif :new.location_distance <= 15 then
        :new.estimated_travel_time := round(:new.location_distance / 1.5, 2);
    elsif :new.location_distance <= 50 then
        :new.estimated_travel_time := round(:new.location_distance / 40, 2);
    elsif :new.location_distance <= 100 then
        :new.estimated_travel_time := round(:new.location_distance / 60, 2);
    else
        :new.estimated_travel_time := round(:new.location_distance / 80, 2);
    end if;
    v_weight := case v_recipient_crit
                    when 'Critical' then 100
                    when 'High' then 80
                    when 'Medium' then 50
                    when 'Low' then 20
                 end;

    :new.urgency_score := (v_recipient_prio * 0.7) + (v_weight * 0.3);

end;
/


create or replace trigger trg_accepted_match_organ_unavailable
after update of match_status on accepted_match
for each row
begin
    if :new.match_status = 'Approved' and :old.match_status != 'Approved' then
        update organ o
        set o.status = 'Unavailable'
        where o.organ_id = (
            select pm.organ_id 
            from potential_match pm
            where pm.match_id = :new.match_id
        );
    end if;
end;
/

//procedures
create or replace procedure sp_create_matches(p_organ_id number)
as
    v_match_id number;
begin
    for r in (
        select recipient_id
        from recipient
        where organ_required = (
            select organ_type 
            from organ 
            where organ_id = p_organ_id
        )
        and status = 'Waiting'
    )
    loop
        begin
            select match_id into v_match_id
            from potential_match
            where organ_id = p_organ_id
              and recipient_id = r.recipient_id;

        exception
            when no_data_found then
                insert into potential_match (organ_id, recipient_id)
                values (p_organ_id, r.recipient_id)
                returning match_id into v_match_id;
        end;
    end loop;
end;
/

create or replace procedure sp_accept_match(
    p_match_id     in  number,
    p_accepted_id  out number,
    p_message      out varchar2
) as
    v_organ_id     number;
    v_organ_status varchar2(20);
    v_match_status varchar2(20);
begin
    p_accepted_id := null;
    p_message := null;

    begin
        select organ_id, status 
        into v_organ_id, v_match_status
        from potential_match
        where match_id = p_match_id;
    exception
        when no_data_found then
            p_message := 'Match not found';
            return;
    end;

    if v_match_status != 'Pending' then
        p_message := 'Match already processed';
        return;
    end if;
    select status into v_organ_status 
    from organ 
    where organ_id = v_organ_id;

    if v_organ_status != 'Available' then
        p_message := 'Organ is no longer available';
        return;
    end if;
    insert into accepted_match (match_id, donor_confirmation)
    values (p_match_id, 'Y')
    returning accepted_id into p_accepted_id;
    
    update potential_match
       set status = 'Accepted'
     where match_id = p_match_id;

    update organ
       set status = 'Matched'
     where organ_id = v_organ_id;

    update potential_match
       set status = 'Cancelled'
     where organ_id = v_organ_id 
       and match_id != p_match_id 
       and status = 'Pending';

    p_message := 'Match accepted successfully';

exception
    when others then
        raise_application_error(-20003, 'Error accepting match: ' || sqlerrm);
end sp_accept_match;
/

create or replace procedure sp_approve_match(
    p_accepted_id in number,
    p_admin_id    in number,
    p_message     out varchar2
) as
    v_match_id     number;
    v_recipient_id number;
    v_hospital_id  number;
begin
    p_message := null;
    begin
        select pm.match_id, r.recipient_id, r.hospital_id
        into v_match_id, v_recipient_id, v_hospital_id
        from accepted_match am
        join potential_match pm on am.match_id = pm.match_id
        join recipient r on pm.recipient_id = r.recipient_id
        where am.accepted_id = p_accepted_id;
    exception
        when no_data_found then
            p_message := 'Accepted match not found';
            return;
    end;

    update accepted_match
       set admin_approval = 'Y',
           match_status = 'Approved',
           approved_by = p_admin_id
     where accepted_id = p_accepted_id;

    insert into hospital_notification (accepted_id, hospital_id)
    values (p_accepted_id, v_hospital_id);

    update recipient
       set status = 'Matched'
     where recipient_id = v_recipient_id;

    p_message := 'Match approved and hospital notified';

exception
    when others then
        raise_application_error(-20004, 'Error approving match: ' || sqlerrm);
end sp_approve_match;
/

---views
create or replace view vw_active_donors_organs as
select d.donor_id, d.name as donor_name, d.age, d.blood_type, d.status as donor_status,
       o.organ_id, o.organ_type, o.status as organ_status
from donor d
join organ o on d.donor_id = o.donor_id
where d.status = 'Active';

create or replace view vw_waiting_recipients as
select r.recipient_id, r.name as recipient_name, r.age, r.blood_type, r.organ_required,
       r.critical_level, r.priority_score, r.status as recipient_status,
       h.hospital_id, h.name as hospital_name
from recipient r
join hospital h on r.hospital_id = h.hospital_id
where r.status = 'Waiting';

create or replace view vw_potential_matches as
select pm.match_id, pm.organ_id, o.organ_type, pm.recipient_id, r.name as recipient_name,
       pm.compatibility_score, pm.blood_compatibility, pm.urgency_score,
       pm.location_distance, pm.estimated_travel_time, pm.status as match_status
from potential_match pm
join organ o on pm.organ_id = o.organ_id
join recipient r on pm.recipient_id = r.recipient_id;

create or replace view vw_accepted_matches as
select am.accepted_id, am.match_id, am.donor_confirmation, am.admin_approval, am.match_status,
       d.donor_id, d.name as donor_name, o.organ_type,
       r.recipient_id, r.name as recipient_name, r.organ_required as recipient_organ,
       am.acceptance_date, am.approved_by
from accepted_match am
join potential_match pm on am.match_id = pm.match_id
join organ o on pm.organ_id = o.organ_id
join donor d on o.donor_id = d.donor_id
join recipient r on pm.recipient_id = r.recipient_id;

create or replace view vw_hospital_notifications as
select hn.notification_id, hn.accepted_id, hn.hospital_id, h.name as hospital_name,
       hn.notification_date, hn.status as notification_status, hn.acknowledged_date,
       am.match_status as match_status
from hospital_notification hn
join hospital h on hn.hospital_id = h.hospital_id
join accepted_match am on hn.accepted_id = am.accepted_id;

create or replace view vw_donor_potential_summary as
select d.donor_id, d.name as donor_name, o.organ_type, count(pm.match_id) as total_potential_matches,
       sum(case when pm.status = 'Pending' then 1 else 0 end) as pending,
       sum(case when pm.status = 'Accepted' then 1 else 0 end) as accepted,
       sum(case when pm.status = 'Cancelled' then 1 else 0 end) as cancelled
from donor d
join organ o on d.donor_id = o.donor_id
left join potential_match pm on o.organ_id = pm.organ_id
group by d.donor_id, d.name, o.organ_type;

--dummy data and testing
insert into admin(name, email, phone_contact, role, department, address)
values('Usman Ali', 'usman.admin@example.com', '03001110001', 'SuperAdmin', 'Transplant', 'Karachi');
insert into admin(name, email, phone_contact, role, department, address)
values('Hina Ahmed', 'hina.admin@example.com', '03001110002', 'Admin', 'Operations', 'Lahore');
insert into emergency_contact(contact_name, contact_number, relationship)
values('Raza Ali', '03002220001', 'Brother');
insert into emergency_contact(contact_name, contact_number, relationship)
values('Sara Ahmed', '03002220002', 'Sister');
insert into emergency_contact(contact_name, contact_number, relationship)
values('Bilal Khan', '03002220003', 'Father');

insert into add_location(address, area, district, city, province)
values('123 Clifton', 'Clifton', 'Karachi South', 'Karachi', 'Sindh');
insert into add_location(address, area, district, city, province)
values('45 Gulberg', 'Gulberg', 'Lahore Central', 'Lahore', 'Punjab');
insert into add_location(address, area, district, city, province)
values('10 Saddar', 'Saddar', 'Karachi South', 'Karachi', 'Sindh');

insert into donor(name, age, weight, phone_contact, email, blood_type, contact_id, location_id)
values('Ali Raza', 30, 70, '03001230001', 'ali@example.com', 'A+', 1, 1);

insert into donor(name, age, weight, phone_contact, email, blood_type, contact_id, location_id)
values('Sara Khan', 28, 65, '03001230002', 'sara@example.com', 'O+', 2, 2);

insert into donor(name, age, weight, phone_contact, email, blood_type, contact_id, location_id)
values('Ahmed Malik', 40, 80, '03001230003', 'ahmed@example.com', 'B-', 3, 3);

insert into donor(name, age, weight, phone_contact, email, blood_type, contact_id, location_id)
values('marium', 30, 70, '03001230004', 'marium@example.com', 'A+', 1, 1);

insert into organ(donor_id, organ_type, organ_size, organ_condition)
values(1, 'Kidney', 'Medium', 'Healthy');

insert into organ(donor_id, organ_type, organ_size, organ_condition)
values(1, 'Liver', 'Large', 'Good');

insert into organ(donor_id, organ_type, organ_size, organ_condition)
values(2, 'Heart', 'Medium', 'Excellent');

insert into organ(donor_id, organ_type, organ_size, organ_condition)
values(3, 'Kidney', 'Large', 'Good');


insert into hospital(name, license_number, contact_info, email, transplant_facility, location_id)
values('Karachi General', 'HOSP001', '0213000001', 'kgeneral@example.com', 'Y', 1);

insert into hospital(name, license_number, contact_info, email, transplant_facility, location_id)
values('Lahore Medical', 'HOSP002', '0423000002', 'lmed@example.com', 'Y', 2);

insert into hospital_admin(hospital_id, admin_name, contact_no, role)
values(1, 'Dr. Naveed', '03003330001', 'Coordinator');

insert into hospital_admin(hospital_id, admin_name, contact_no, role)
values(2, 'Dr. Sana', '03003330002', 'Coordinator');

insert into recipient(hospital_id, name, cnic, age, blood_type, weight, organ_required, critical_level, priority_score, contact_id)
values(1, 'Imran Ali', '3520212345678', 35, 'A+', 72, 'Kidney', 'High', 80, 1);

insert into recipient(hospital_id, name, cnic, age, blood_type, weight, organ_required, critical_level, priority_score, contact_id)
values(2, 'Ayesha Khan', '3520212345679', 30, 'O+', 65, 'Heart', 'Critical', 90, 2);

insert into recipient(hospital_id, name, cnic, age, blood_type, weight, organ_required, critical_level, priority_score, contact_id)
values(1, 'Bilal Ahmed', '3520212345680', 45, 'B-', 78, 'Kidney', 'Medium', 60, 3);

--potential match manual testing:
insert into potential_match(organ_id, recipient_id)
values(1, 1);

insert into accepted_match(match_id, donor_confirmation)
values(1, 'Y');

insert into organ(donor_id, organ_type, organ_size, organ_condition)
values(4, 'Kidney', 'Large', 'Good');

exec  sp_create_matches(1);
exec  sp_create_matches(4);

select * from potential_match;
select * from accepted_match;
/*
SELECT trigger_name, status 
FROM user_triggers
WHERE trigger_name = 'TRG_GENERATE_POTENTIAL_MATCHES';*/
--DROP TRIGGER trg_generate_potential_matches;


create table webusers (
    user_id number generated always as identity primary key,
    user_name varchar2(100) unique not null,
    email varchar2(200) unique not null,
    password_hash varchar2(400) not null,
    web_role varchar2(30) default 'donor',
    donor_id number,
    created_at timestamp default current_timestamp,
    constraint fk_user_donor foreign key (donor_id)
        references donor(donor_id)
);

commit;

desc donor;

select * from webusers;

select * from users;
select * from donor;
select * from admin;
desc admin;

insert into webusers (
 user_name, email, password_hash, web_role
)
values(
 'admin',
 'admin@example.com',
 '<bcrypt hash>',
 'admin'
);
select * from webusers;
select user_name, email, web_role
from webusers;

delete from webusers;

select * from webusers;

select user_id, user_name, email, web_role
from webusers;

select * from hospital;

desc donor;
select * from organ;
desc organ;

select user_id, user_name, email, password_hash, web_role
from webusers;

select user from dual;

select * from donor;
select * from hospital;
select * from recipient;