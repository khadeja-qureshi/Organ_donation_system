BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HOSPITAL_NOTIFICATION CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ACCEPTED_MATCH CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE POTENTIAL_MATCH CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE EMERGENCY_CONTACT CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ADD_LOCATION CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HOSPITAL_ADMIN CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE RECIPIENT CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ORGAN CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DONOR CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HOSPITAL CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ADMIN CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE ADMIN (
    Admin_Id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name          VARCHAR2(100) NOT NULL,
    Email         VARCHAR2(100) UNIQUE NOT NULL,
    Phone_Contact VARCHAR2(20),
    Role          Varchar(50),
    Department    VARCHAR2(50),
    Address       VARCHAR2(200)
);


CREATE TABLE EMERGENCY_CONTACT (
    Contact_Id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Contact_Name    VARCHAR2(100) NOT NULL,
    Contact_Number  VARCHAR2(20) NOT NULL,
    Relationship    VARCHAR2(50)
);

CREATE TABLE Add_Location (
    Location_Id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Address    VARCHAR2(200) NOT NULL,
    Area       VARCHAR2(100) NOT NULL,
    District    VARCHAR2(100) NOT NULL,
    City         VARCHAR2(100) NOT NULL,
    Province    VARCHAR2(100) NOT NULL
);




CREATE TABLE DONOR (
    Donor_Id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name           VARCHAR2(100) NOT NULL,
    Age            NUMBER(3) NOT NULL CHECK (Age BETWEEN 18 AND 75),
    Weight         NUMBER(7,2) CHECK (Weight > 0),
    Phone_Contact  VARCHAR2(20),
    Email          VARCHAR2(100) UNIQUE,
    Registration_Date DATE DEFAULT SYSDATE NOT NULL,
    Blood_Type     VARCHAR2(3) NOT NULL CHECK (Blood_Type IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    Last_Checkup   DATE,
    Medical_Condition  clob,
    Status         VARCHAR2(20) DEFAULT 'Active' CHECK (Status IN ('Active','Inactive','Deceased','Suspended')),
    Is_Verified    CHAR(1) DEFAULT 'N' CHECK (Is_Verified IN ('Y','N')),
    Verified_By    number,
    Contact_Id     number not null,
    Location_Id     number not null,
    CONSTRAINT fk_emergency_contact FOREIGN KEY (Contact_Id) REFERENCES EMERGENCY_CONTACT(Contact_Id) ON DELETE CASCADE,
    CONSTRAINT fk_location FOREIGN KEY (Location_Id) REFERENCES Add_Location(Location_Id) ON DELETE CASCADE,
    CONSTRAINT fk_d_verfied_by FOREIGN KEY (Verified_By) REFERENCES ADMIN(Admin_Id)
);

CREATE INDEX idx_donor_blood_type ON DONOR(Blood_Type);
CREATE INDEX idx_donor_status ON DONOR(Status);

CREATE TABLE ORGAN (
    Organ_Id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Donor_Id     NUMBER NOT NULL,
    Organ_Type   VARCHAR2(20) NOT NULL CHECK (Organ_Type IN ('Heart','Kidney','Liver','Lung','Pancreas','Intestine','Cornea')),
    Status       VARCHAR2(20) DEFAULT 'Available' CHECK (Status IN ('Available','Unavailable','Matched','Transplanted','Expired')),
    Registration_Date DATE DEFAULT SYSDATE NOT NULL,
    Organ_Size         VARCHAR2(20),
    Organ_Condition    varchar2(500),
    CONSTRAINT fk_organ_donor FOREIGN KEY (Donor_Id) REFERENCES DONOR(Donor_Id) ON DELETE CASCADE
);

CREATE INDEX idx_organ_status ON ORGAN(Status);
CREATE INDEX idx_organ_type ON ORGAN(Organ_Type);
CREATE INDEX idx_organ_donor ON ORGAN(Donor_Id);

CREATE TABLE HOSPITAL (
    Hospital_Id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name              VARCHAR2(150) NOT NULL,
    License_Number    VARCHAR2(50) UNIQUE NOT NULL,
    Contact_Info      VARCHAR2(20),
    Email             VARCHAR2(100) UNIQUE,
    Transplant_Facility CHAR(1) DEFAULT 'N' CHECK (Transplant_Facility IN ('Y','N')),
    Status            VARCHAR2(20) DEFAULT 'Active' CHECK (Status IN ('Active','Inactive','Suspended')),
    Is_Verified       CHAR(1) DEFAULT 'N' CHECK (Is_Verified IN ('Y','N')),
    Verified_By    number,
    Registration_Date DATE DEFAULT SYSDATE NOT NULL,
    location_id number not null,
    CONSTRAINT fk_h_location FOREIGN KEY (Location_Id) REFERENCES Add_Location(Location_Id) ON DELETE CASCADE,
    CONSTRAINT fk_h_verfied_by FOREIGN KEY (Verified_By) REFERENCES ADMIN(Admin_Id)
);

CREATE INDEX idx_hospital_status ON HOSPITAL(Status);
CREATE INDEX idx_hospital_transplant ON HOSPITAL(Transplant_Facility);

CREATE TABLE HOSPITAL_ADMIN (
    Hospital_Admin_Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Hospital_Id       NUMBER NOT NULL,
    Admin_Name        Varchar2(200),
    Contact_No        VARCHAR2(20),
    Role              varchar2(50),
    CONSTRAINT fk_ha_hospital FOREIGN KEY (Hospital_Id) REFERENCES HOSPITAL(Hospital_Id) ON DELETE CASCADE
);

CREATE INDEX idx_hospital_admin_hospital ON HOSPITAL_ADMIN(Hospital_Id);
CREATE INDEX idx_hospital_admin_admin ON HOSPITAL_ADMIN(Admin_Name);

CREATE TABLE RECIPIENT (
    Recipient_Id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Hospital_Id     NUMBER NOT NULL,
    Name            VARCHAR2(100) NOT NULL,
    CNIC            VARCHAR2(20) NOT NULL UNIQUE,
    Age             NUMBER(3) NOT NULL CHECK (Age BETWEEN 0 AND 120),
    Blood_Type      VARCHAR2(3) NOT NULL CHECK (Blood_Type IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    Weight          NUMBER(7,2) CHECK (Weight > 0),
    Organ_Required  VARCHAR2(20) NOT NULL CHECK (Organ_Required IN ('Heart','Kidney','Liver','Lung','Pancreas','Intestine','Cornea')),
    Registration_Date DATE DEFAULT SYSDATE NOT NULL,
    Status          VARCHAR2(20) DEFAULT 'Waiting' CHECK (Status IN ('Waiting','Matched','Transplanted','Deceased','Removed')),
    Critical_Level  VARCHAR2(10) DEFAULT 'Medium' CHECK (Critical_Level IN ('Critical','High','Medium','Low')),
    Priority_Score  NUMBER DEFAULT 50 CHECK (Priority_Score BETWEEN 0 AND 100),
    Medical_History CLOB,
     Contact_Id     number not null,
     CONSTRAINT fk_r_emergency_contact FOREIGN KEY (Contact_Id) REFERENCES EMERGENCY_CONTACT(Contact_Id) ON DELETE CASCADE,
    CONSTRAINT fk_recipient_hospital FOREIGN KEY (Hospital_Id) REFERENCES HOSPITAL(Hospital_Id)
);

CREATE INDEX idx_recipient_blood_type ON RECIPIENT(Blood_Type);
CREATE INDEX idx_recipient_organ ON RECIPIENT(Organ_Required);
CREATE INDEX idx_recipient_status ON RECIPIENT(Status);
CREATE INDEX idx_recipient_critical ON RECIPIENT(Critical_Level);
CREATE INDEX idx_recipient_hospital ON RECIPIENT(Hospital_Id);

CREATE TABLE POTENTIAL_MATCH (
    Match_Id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Organ_Id           NUMBER NOT NULL,
    Recipient_Id       NUMBER NOT NULL,
    Compatibility_Score NUMBER(5,2) CHECK (Compatibility_Score BETWEEN 0 AND 100),
    Blood_Compatibility CHAR(1) DEFAULT 'N' CHECK (Blood_Compatibility IN ('Y','N')),
    Urgency_Score      NUMBER CHECK (Urgency_Score BETWEEN 0 AND 100),
    Match_Date         DATE DEFAULT SYSDATE NOT NULL,
    Location_Distance  NUMBER(10,2),
    Estimated_Travel_Time NUMBER,
    Status             VARCHAR2(20) DEFAULT 'Pending' CHECK (Status IN ('Pending','Accepted','Rejected','Cancelled','Expired')),
    CONSTRAINT fk_pm_organ FOREIGN KEY (Organ_Id) REFERENCES ORGAN(Organ_Id) ON DELETE CASCADE,
    CONSTRAINT fk_pm_recipient FOREIGN KEY (Recipient_Id) REFERENCES RECIPIENT(Recipient_Id) ON DELETE CASCADE
);

CREATE INDEX idx_potential_organ ON POTENTIAL_MATCH(Organ_Id);
CREATE INDEX idx_potential_recipient ON POTENTIAL_MATCH(Recipient_Id);
CREATE INDEX idx_potential_status ON POTENTIAL_MATCH(Status);
CREATE INDEX idx_potential_compatibility ON POTENTIAL_MATCH(Compatibility_Score);

CREATE TABLE ACCEPTED_MATCH (
    Accepted_Id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Match_Id              NUMBER UNIQUE NOT NULL,
    Donor_Confirmation    CHAR(1) DEFAULT 'N' CHECK (Donor_Confirmation IN ('Y','N')),
    Donor_Confirmation_Date TIMESTAMP,
    Admin_Approval        CHAR(1) DEFAULT 'N' CHECK (Admin_Approval IN ('Y','N')),
    Match_Status          VARCHAR2(20) DEFAULT 'Pending_Approval' CHECK (Match_Status IN ('Pending_Approval','Approved','Rejected','Completed','Failed')),
    Acceptance_Date       TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    Patient_Outcome       CLOB,
    Approved_By           NUMBER,
    CONSTRAINT fk_am_match FOREIGN KEY (Match_Id) REFERENCES POTENTIAL_MATCH(Match_Id) ON DELETE CASCADE,
    CONSTRAINT fk_am_approved_by FOREIGN KEY (Approved_By) REFERENCES ADMIN(Admin_Id)
);

CREATE INDEX idx_accepted_match_status ON ACCEPTED_MATCH(Match_Status);
CREATE INDEX idx_accepted_approved_by ON ACCEPTED_MATCH(Approved_By);
CREATE INDEX idx_accepted_match ON ACCEPTED_MATCH(Match_Id);

CREATE TABLE HOSPITAL_NOTIFICATION (
    Notification_Id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Accepted_Id       NUMBER NOT NULL,
    Hospital_Id       NUMBER NOT NULL,
    Notification_Date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    Status            VARCHAR2(20) DEFAULT 'Sent' CHECK (Status IN ('Sent','Delivered','Acknowledged','Failed')),
    Acknowledged_Date TIMESTAMP,
    CONSTRAINT fk_hn_accepted FOREIGN KEY (Accepted_Id) REFERENCES ACCEPTED_MATCH(Accepted_Id) ON DELETE CASCADE,
    CONSTRAINT fk_hn_hospital FOREIGN KEY (Hospital_Id) REFERENCES HOSPITAL(Hospital_Id) ON DELETE CASCADE
);

CREATE INDEX idx_notification_hospital ON HOSPITAL_NOTIFICATION(Hospital_Id);
CREATE INDEX idx_notification_accepted ON HOSPITAL_NOTIFICATION(Accepted_Id);
CREATE INDEX idx_notification_status ON HOSPITAL_NOTIFICATION(Status);


--triggers
CREATE OR REPLACE TRIGGER trg_pm_all
BEFORE INSERT OR UPDATE ON POTENTIAL_MATCH
FOR EACH ROW
DECLARE
    -- Donor info
    v_donor_age NUMBER;
    v_donor_weight NUMBER;
    v_donor_bt VARCHAR2(3);
    v_donor_organ VARCHAR2(20);
    v_donor_loc_id NUMBER;
    v_donor_area VARCHAR2(100);
    v_donor_district VARCHAR2(100);
    v_donor_city VARCHAR2(100);
    v_donor_province VARCHAR2(100);

    -- Recipient info
    v_recipient_age NUMBER;
    v_recipient_weight NUMBER;
    v_recipient_bt VARCHAR2(3);
    v_recipient_organ VARCHAR2(20);
    v_recipient_prio NUMBER;
    v_recipient_crit VARCHAR2(10);
    v_recip_loc_id NUMBER;
    v_recip_area VARCHAR2(100);
    v_recip_district VARCHAR2(100);
    v_recip_city VARCHAR2(100);
    v_recip_province VARCHAR2(100);

    -- Scores
    v_score NUMBER := 0;
    v_weight NUMBER;
BEGIN
    
    -- Fetch donor info
    SELECT D.Age, D.Weight, D.Blood_Type, O.Organ_Type, D.Location_Id
    INTO v_donor_age, v_donor_weight, v_donor_bt, v_donor_organ, v_donor_loc_id
    FROM DONOR D
    JOIN ORGAN O ON D.Donor_Id = O.Donor_Id
    WHERE O.Organ_Id = :NEW.Organ_Id;

    SELECT Area, District, City, Province
    INTO v_donor_area, v_donor_district, v_donor_city, v_donor_province
    FROM Add_Location
    WHERE Location_Id = v_donor_loc_id;

    -- Fetch recipient info
    SELECT Age, Weight, Blood_Type, Organ_Required, Priority_Score, Critical_Level, H.Location_Id
    INTO v_recipient_age, v_recipient_weight, v_recipient_bt, v_recipient_organ, v_recipient_prio, v_recipient_crit, v_recip_loc_id
    FROM RECIPIENT R
    JOIN HOSPITAL H ON R.Hospital_Id = H.Hospital_Id
    WHERE R.Recipient_Id = :NEW.Recipient_Id;

    SELECT Area, District, City, Province
    INTO v_recip_area, v_recip_district, v_recip_city, v_recip_province
    FROM Add_Location
    WHERE Location_Id = v_recip_loc_id;

-- Blood Compatibility
    IF (
        (v_donor_bt = 'O-' ) OR
        (v_donor_bt = 'O+' AND v_recipient_bt IN ('O+','A+','B+','AB+')) OR
        (v_donor_bt = 'A-' AND v_recipient_bt IN ('A-','A+','AB-','AB+')) OR
        (v_donor_bt = 'A+' AND v_recipient_bt IN ('A+','AB+')) OR
        (v_donor_bt = 'B-' AND v_recipient_bt IN ('B-','B+','AB-','AB+')) OR
        (v_donor_bt = 'B+' AND v_recipient_bt IN ('B+','AB+')) OR
        (v_donor_bt = 'AB-' AND v_recipient_bt IN ('AB-','AB+')) OR
        (v_donor_bt = 'AB+' AND v_recipient_bt = 'AB+')
    ) THEN
        :NEW.Blood_Compatibility := 'Y';
        v_score := v_score + 40;  -- Blood match points
    ELSE
        :NEW.Blood_Compatibility := 'N';
    END IF;

-- Compatibility Score
    -- Age difference
    v_score := v_score + CASE 
                            WHEN ABS(v_donor_age - v_recipient_age) <= 10 THEN 20
                            WHEN ABS(v_donor_age - v_recipient_age) <= 20 THEN 10
                            ELSE 0 
                          END;

    -- Weight difference
    v_score := v_score + CASE 
                            WHEN ABS(v_donor_weight - v_recipient_weight) <= 10 THEN 20
                            WHEN ABS(v_donor_weight - v_recipient_weight) <= 20 THEN 10
                            ELSE 0 
                          END;

    -- Organ type match
    IF v_donor_organ = v_recipient_organ THEN
        v_score := v_score + 20;
    END IF;

    :NEW.Compatibility_Score := LEAST(v_score, 100);

    
    -- Location Distance
    IF v_donor_area = v_recip_area THEN
        :NEW.Location_Distance := 5;
    ELSIF v_donor_district = v_recip_district THEN
        :NEW.Location_Distance := 15;
    ELSIF v_donor_city = v_recip_city THEN
        :NEW.Location_Distance := 50;
    ELSIF v_donor_province = v_recip_province THEN
        :NEW.Location_Distance := 100;
    ELSE
        :NEW.Location_Distance := 200;
    END IF;

    -- Estimated Travel Time
    IF :NEW.Location_Distance <= 5 THEN
        :NEW.Estimated_Travel_Time := ROUND(:NEW.Location_Distance / 1.2, 2);
    ELSIF :NEW.Location_Distance <= 15 THEN
        :NEW.Estimated_Travel_Time := ROUND(:NEW.Location_Distance / 1.5, 2);
    ELSIF :NEW.Location_Distance <= 50 THEN
        :NEW.Estimated_Travel_Time := ROUND(:NEW.Location_Distance / 40, 2);
    ELSIF :NEW.Location_Distance <= 100 THEN
        :NEW.Estimated_Travel_Time := ROUND(:NEW.Location_Distance / 60, 2);
    ELSE
        :NEW.Estimated_Travel_Time := ROUND(:NEW.Location_Distance / 80, 2);
    END IF;
--Urgency Score
    v_weight := CASE v_recipient_crit
                    WHEN 'Critical' THEN 100
                    WHEN 'High' THEN 80
                    WHEN 'Medium' THEN 50
                    WHEN 'Low' THEN 20
                 END;

    :NEW.Urgency_Score := (v_recipient_prio * 0.7) + (v_weight * 0.3);

END;
/


CREATE OR REPLACE TRIGGER trg_accepted_match_organ_unavailable
AFTER UPDATE OF Match_Status ON ACCEPTED_MATCH
FOR EACH ROW
BEGIN
    IF :NEW.Match_Status = 'Approved' AND :OLD.Match_Status != 'Approved' THEN
        -- Set corresponding organ status to Unavailable
        UPDATE ORGAN o
        SET o.Status = 'Unavailable'
        WHERE o.Organ_Id = (
            SELECT pm.Organ_Id 
            FROM POTENTIAL_MATCH pm
            WHERE pm.Match_Id = :NEW.Match_Id
        );
    END IF;
END;
/

//procedures
CREATE OR REPLACE PROCEDURE sp_create_matches(p_organ_id NUMBER)
AS
    v_match_id NUMBER;
BEGIN
    -- Loop through all eligible recipients
    FOR r IN (
        SELECT Recipient_Id
        FROM RECIPIENT
        WHERE Organ_Required = (
            SELECT Organ_Type 
            FROM ORGAN 
            WHERE Organ_Id = p_organ_id
        )
        AND Status = 'Waiting'
    )
    LOOP
        -- Try to find existing match
        BEGIN
            SELECT Match_Id INTO v_match_id
            FROM POTENTIAL_MATCH
            WHERE Organ_Id = p_organ_id
              AND Recipient_Id = r.Recipient_Id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- If not found → insert new match
                INSERT INTO POTENTIAL_MATCH (Organ_Id, Recipient_Id)
                VALUES (p_organ_id, r.Recipient_Id)
                RETURNING Match_Id INTO v_match_id;
        END;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE sp_accept_match(
    p_match_id     IN  NUMBER,
    p_accepted_id  OUT NUMBER,
    p_message      OUT VARCHAR2
) AS
    v_organ_id     NUMBER;
    v_organ_status VARCHAR2(20);
    v_match_status VARCHAR2(20);
BEGIN
    p_accepted_id := NULL;
    p_message := NULL;

    -- Fetch organ and potential match status
    BEGIN
        SELECT Organ_Id, Status 
        INTO v_organ_id, v_match_status
        FROM POTENTIAL_MATCH
        WHERE Match_Id = p_match_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_message := 'Match not found';
            RETURN;
    END;

    IF v_match_status != 'Pending' THEN
        p_message := 'Match already processed';
        RETURN;
    END IF;

    -- Check organ availability
    SELECT Status INTO v_organ_status 
    FROM ORGAN 
    WHERE Organ_Id = v_organ_id;

    IF v_organ_status != 'Available' THEN
        p_message := 'Organ is no longer available';
        RETURN;
    END IF;

    -- Accept match
    INSERT INTO ACCEPTED_MATCH (Match_Id, Donor_Confirmation)
    VALUES (p_match_id, 'Y')
    RETURNING Accepted_Id INTO p_accepted_id;

    -- Update potential match status
    UPDATE POTENTIAL_MATCH
       SET Status = 'Accepted'
     WHERE Match_Id = p_match_id;

    -- Update organ status
    UPDATE ORGAN
       SET Status = 'Matched'
     WHERE Organ_Id = v_organ_id;

    -- Cancel other pending matches for this organ
    UPDATE POTENTIAL_MATCH
       SET Status = 'Cancelled'
     WHERE Organ_Id = v_organ_id 
       AND Match_Id != p_match_id 
       AND Status = 'Pending';

    p_message := 'Match accepted successfully';

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error accepting match: ' || SQLERRM);
END sp_accept_match;
/

CREATE OR REPLACE PROCEDURE sp_approve_match(
    p_accepted_id IN NUMBER,
    p_admin_id    IN NUMBER,
    p_message     OUT VARCHAR2
) AS
    v_match_id     NUMBER;
    v_recipient_id NUMBER;
    v_hospital_id  NUMBER;
BEGIN
    p_message := NULL;

    -- Fetch match, recipient, and hospital
    BEGIN
        SELECT pm.Match_Id, r.Recipient_Id, r.Hospital_Id
        INTO v_match_id, v_recipient_id, v_hospital_id
        FROM ACCEPTED_MATCH am
        JOIN POTENTIAL_MATCH pm ON am.Match_Id = pm.Match_Id
        JOIN RECIPIENT r ON pm.Recipient_Id = r.Recipient_Id
        WHERE am.Accepted_Id = p_accepted_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_message := 'Accepted match not found';
            RETURN;
    END;

    -- Approve match by admin
    UPDATE ACCEPTED_MATCH
       SET Admin_Approval = 'Y',
           Match_Status = 'Approved',
           Approved_By = p_admin_id
     WHERE Accepted_Id = p_accepted_id;

    -- Create hospital notification
    INSERT INTO HOSPITAL_NOTIFICATION (Accepted_Id, Hospital_Id)
    VALUES (p_accepted_id, v_hospital_id);

    -- Update recipient status
    UPDATE RECIPIENT
       SET Status = 'Matched'
     WHERE Recipient_Id = v_recipient_id;

    p_message := 'Match approved and hospital notified';

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error approving match: ' || SQLERRM);
END sp_approve_match;
/

---views
-- Active Donors with Organs
CREATE OR REPLACE VIEW vw_active_donors_organs AS
SELECT d.Donor_Id, d.Name AS Donor_Name, d.Age, d.Blood_Type, d.Status AS Donor_Status,
       o.Organ_Id, o.Organ_Type, o.Status AS Organ_Status
FROM DONOR d
JOIN ORGAN o ON d.Donor_Id = o.Donor_Id
WHERE d.Status = 'Active';

-- Recipients Waiting for Transplant
CREATE OR REPLACE VIEW vw_waiting_recipients AS
SELECT r.Recipient_Id, r.Name AS Recipient_Name, r.Age, r.Blood_Type, r.Organ_Required,
       r.Critical_Level, r.Priority_Score, r.Status AS Recipient_Status,
       h.Hospital_Id, h.Name AS Hospital_Name
FROM RECIPIENT r
JOIN HOSPITAL h ON r.Hospital_Id = h.Hospital_Id
WHERE r.Status = 'Waiting';

-- Potential Matches with Scores
CREATE OR REPLACE VIEW vw_potential_matches AS
SELECT pm.Match_Id, pm.Organ_Id, o.Organ_Type, pm.Recipient_Id, r.Name AS Recipient_Name,
       pm.Compatibility_Score, pm.Blood_Compatibility, pm.Urgency_Score,
       pm.Location_Distance, pm.Estimated_Travel_Time, pm.Status AS Match_Status
FROM POTENTIAL_MATCH pm
JOIN ORGAN o ON pm.Organ_Id = o.Organ_Id
JOIN RECIPIENT r ON pm.Recipient_Id = r.Recipient_Id;

-- Accepted Matches with Donor and Recipient Info
CREATE OR REPLACE VIEW vw_accepted_matches AS
SELECT am.Accepted_Id, am.Match_Id, am.Donor_Confirmation, am.Admin_Approval, am.Match_Status,
       d.Donor_Id, d.Name AS Donor_Name, o.Organ_Type,
       r.Recipient_Id, r.Name AS Recipient_Name, r.Organ_Required AS Recipient_Organ,
       am.Acceptance_Date, am.Approved_By
FROM ACCEPTED_MATCH am
JOIN POTENTIAL_MATCH pm ON am.Match_Id = pm.Match_Id
JOIN ORGAN o ON pm.Organ_Id = o.Organ_Id
JOIN DONOR d ON o.Donor_Id = d.Donor_Id
JOIN RECIPIENT r ON pm.Recipient_Id = r.Recipient_Id;

-- Hospital Notifications
CREATE OR REPLACE VIEW vw_hospital_notifications AS
SELECT hn.Notification_Id, hn.Accepted_Id, hn.Hospital_Id, h.Name AS Hospital_Name,
       hn.Notification_Date, hn.Status AS Notification_Status, hn.Acknowledged_Date,
       am.Match_Status AS Match_Status
FROM HOSPITAL_NOTIFICATION hn
JOIN HOSPITAL h ON hn.Hospital_Id = h.Hospital_Id
JOIN ACCEPTED_MATCH am ON hn.Accepted_Id = am.Accepted_Id;

-- Donor Potential Matches Summary
CREATE OR REPLACE VIEW vw_donor_potential_summary AS
SELECT d.Donor_Id, d.Name AS Donor_Name, o.Organ_Type, COUNT(pm.Match_Id) AS Total_Potential_Matches,
       SUM(CASE WHEN pm.Status = 'Pending' THEN 1 ELSE 0 END) AS Pending,
       SUM(CASE WHEN pm.Status = 'Accepted' THEN 1 ELSE 0 END) AS Accepted,
       SUM(CASE WHEN pm.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled
FROM DONOR d
JOIN ORGAN o ON d.Donor_Id = o.Donor_Id
LEFT JOIN POTENTIAL_MATCH pm ON o.Organ_Id = pm.Organ_Id
GROUP BY d.Donor_Id, d.Name, o.Organ_Type;

--dummy data and testing
INSERT INTO ADMIN(Name, Email, Phone_Contact, Role, Department, Address)
VALUES('Usman Ali', 'usman.admin@example.com', '03001110001', 'SuperAdmin', 'Transplant', 'Karachi');

INSERT INTO ADMIN(Name, Email, Phone_Contact, Role, Department, Address)
VALUES('Hina Ahmed', 'hina.admin@example.com', '03001110002', 'Admin', 'Operations', 'Lahore');

--emergency contact
INSERT INTO EMERGENCY_CONTACT(Contact_Name, Contact_Number, Relationship)
VALUES('Raza Ali', '03002220001', 'Brother');

INSERT INTO EMERGENCY_CONTACT(Contact_Name, Contact_Number, Relationship)
VALUES('Sara Ahmed', '03002220002', 'Sister');

INSERT INTO EMERGENCY_CONTACT(Contact_Name, Contact_Number, Relationship)
VALUES('Bilal Khan', '03002220003', 'Father');

--Add_Location
INSERT INTO Add_Location(Address, Area, District, City, Province)
VALUES('123 Clifton', 'Clifton', 'Karachi South', 'Karachi', 'Sindh');

INSERT INTO Add_Location(Address, Area, District, City, Province)
VALUES('45 Gulberg', 'Gulberg', 'Lahore Central', 'Lahore', 'Punjab');

INSERT INTO Add_Location(Address, Area, District, City, Province)
VALUES('10 Saddar', 'Saddar', 'Karachi South', 'Karachi', 'Sindh');

--DONOR
INSERT INTO DONOR(Name, Age, Weight, Phone_Contact, Email, Blood_Type, Contact_Id, Location_Id)
VALUES('Ali Raza', 30, 70, '03001230001', 'ali@example.com', 'A+', 1, 1);

INSERT INTO DONOR(Name, Age, Weight, Phone_Contact, Email, Blood_Type, Contact_Id, Location_Id)
VALUES('Sara Khan', 28, 65, '03001230002', 'sara@example.com', 'O+', 2, 2);

INSERT INTO DONOR(Name, Age, Weight, Phone_Contact, Email, Blood_Type, Contact_Id, Location_Id)
VALUES('Ahmed Malik', 40, 80, '03001230003', 'ahmed@example.com', 'B-', 3, 3);

INSERT INTO DONOR(Name, Age, Weight, Phone_Contact, Email, Blood_Type, Contact_Id, Location_Id)
VALUES('marium', 30, 70, '03001230004', 'marium@example.com', 'A+', 1, 1);
--ORGAN
INSERT INTO ORGAN(Donor_Id, Organ_Type, Organ_Size, Organ_Condition)
VALUES(1, 'Kidney', 'Medium', 'Healthy');

INSERT INTO ORGAN(Donor_Id, Organ_Type, Organ_Size, Organ_Condition)
VALUES(1, 'Liver', 'Large', 'Good');

INSERT INTO ORGAN(Donor_Id, Organ_Type, Organ_Size, Organ_Condition)
VALUES(2, 'Heart', 'Medium', 'Excellent');

INSERT INTO ORGAN(Donor_Id, Organ_Type, Organ_Size, Organ_Condition)
VALUES(3, 'Kidney', 'Large', 'Good');


--HOSPITAL
INSERT INTO HOSPITAL(Name, License_Number, Contact_Info, Email, Transplant_Facility, Location_Id)
VALUES('Karachi General', 'HOSP001', '0213000001', 'kgeneral@example.com', 'Y', 1);

INSERT INTO HOSPITAL(Name, License_Number, Contact_Info, Email, Transplant_Facility, Location_Id)
VALUES('Lahore Medical', 'HOSP002', '0423000002', 'lmed@example.com', 'Y', 2);

--HOSPITAL_ADMIN
INSERT INTO HOSPITAL_ADMIN(Hospital_Id, Admin_Name, Contact_No, Role)
VALUES(1, 'Dr. Naveed', '03003330001', 'Coordinator');

INSERT INTO HOSPITAL_ADMIN(Hospital_Id, Admin_Name, Contact_No, Role)
VALUES(2, 'Dr. Sana', '03003330002', 'Coordinator');

--RECIPIENT
INSERT INTO RECIPIENT(Hospital_Id, Name, CNIC, Age, Blood_Type, Weight, Organ_Required, Critical_Level, Priority_Score, contact_id)
VALUES(1, 'Imran Ali', '3520212345678', 35, 'A+', 72, 'Kidney', 'High', 80, 1);

INSERT INTO RECIPIENT(Hospital_Id, Name, CNIC, Age, Blood_Type, Weight, Organ_Required, Critical_Level, Priority_Score, contact_id)
VALUES(2, 'Ayesha Khan', '3520212345679', 30, 'O+', 65, 'Heart', 'Critical', 90, 2);

INSERT INTO RECIPIENT(Hospital_Id, Name, CNIC, Age, Blood_Type, Weight, Organ_Required, Critical_Level, Priority_Score, contact_id)
VALUES(1, 'Bilal Ahmed', '3520212345680', 45, 'B-', 78, 'Kidney', 'Medium', 60, 3);


--potential match manual testing:
INSERT INTO POTENTIAL_MATCH(Organ_Id, Recipient_Id)
VALUES(1, 1);

INSERT INTO ACCEPTED_MATCH(Match_Id, Donor_Confirmation)
VALUES(1, 'Y');

INSERT INTO ORGAN(Donor_Id, Organ_Type, Organ_Size, Organ_Condition)
VALUES(4, 'Kidney', 'Large', 'Good');

exec  sp_create_matches(1);
exec  sp_create_matches(4);

select * from potential_match;
select * from accepted_match;
/*
SELECT trigger_name, status 
FROM user_triggers
WHERE trigger_name = 'TRG_GENERATE_POTENTIAL_MATCHES';*/
--DROP TRIGGER trg_generate_potential_matches;


CREATE TABLE WEBUSERS (
    User_Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    User_name VARCHAR2(100) UNIQUE NOT NULL,
    Email VARCHAR2(200) UNIQUE NOT NULL,
    Password_Hash VARCHAR2(400) NOT NULL,
    Web_Role VARCHAR2(30) DEFAULT 'donor',
    Donor_Id NUMBER,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_donor FOREIGN KEY (Donor_Id)
        REFERENCES DONOR(Donor_Id)
);

commit;

desc donor;

select * from webusers;

SELECT * FROM USERS;
select * from donor;
select * from admin;
desc admin;

INSERT INTO WEBUSERS (
 User_name, Email, Password_Hash, Web_Role
)
VALUES(
 'admin',
 'admin@example.com',
 '<bcrypt hash>',
 'admin'
);
select * from webusers;
SELECT USER_NAME, EMAIL, WEB_ROLE
FROM WEBUSERS;

DELETE FROM WEBUSERS;

SELECT * FROM WEBUSERS;

SELECT USER_ID, USER_NAME, EMAIL, WEB_ROLE
FROM WEBUSERS;

select * from hospital;

desc donor;
select * from organ;
desc organ;

SELECT USER_ID, USER_NAME, EMAIL, PASSWORD_HASH, WEB_ROLE
FROM WEBUSERS;

SELECT USER FROM dual;

select * from donor;
select * from hospital;
select * from recipient;