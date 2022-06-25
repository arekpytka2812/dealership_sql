----------------------------------------
-- Droping sequences, tables, views and triggers --
----------------------------------------

--PURGE RECYCLEBIN;

-- dropping sequnces
DROP SEQUENCE brakes_id_seq;
DROP SEQUENCE engines_id_seq;
DROP SEQUENCE gearboxes_id_seq;
DROP SEQUENCE chassis_id_seq;
DROP SEQUENCE bodies_id_seq;
DROP SEQUENCE tyres_id_seq;
DROP SEQUENCE car_models_id_seq;
DROP SEQUENCE employees_id_seq;
DROP SEQUENCE clients_id_seq;
DROP SEQUENCE address_id_seq;
DROP SEQUENCE orders_id_seq;

-- dropping triggers
DROP TRIGGER Car_models_log_tr;
DROP TRIGGER Employees_log_tr;
DROP TRIGGER Clients_log_tr;
DROP TRIGGER Orders_log_tr;

-- dropping tables
DROP TABLE Brakes CASCADE CONSTRAINTS;
DROP TABLE Engines CASCADE CONSTRAINTS;
DROP TABLE Gearboxes CASCADE CONSTRAINTS;
DROP TABLE Chassis CASCADE CONSTRAINTS;
DROP TABLE Bodies CASCADE CONSTRAINTS;
DROP TABLE Tyres CASCADE CONSTRAINTS;
DROP TABLE Car_models CASCADE CONSTRAINTS;
DROP TABLE Personal_data CASCADE CONSTRAINTS;
DROP TABLE Employees CASCADE CONSTRAINTS;
DROP TABLE Address CASCADE CONSTRAINTS;
DROP TABLE Clients CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;

-- dropping log tables
DROP TABLE Car_models_logs CASCADE CONSTRAINTS;
DROP TABLE Employees_logs CASCADE CONSTRAINTS;
DROP TABLE Clients_logs CASCADE CONSTRAINTS;
DROP TABLE Orders_logs CASCADE CONSTRAINTS;

-- dropping views
DROP VIEW Car_models_view;
DROP VIEW Clients_view;
DROP VIEW Employees_view;
DROP VIEW Orders_view;

-------------------------
-- Creating sequences --
-------------------------

CREATE SEQUENCE brakes_id_seq;
CREATE SEQUENCE engines_id_seq;
CREATE SEQUENCE gearboxes_id_seq;
CREATE SEQUENCE chassis_id_seq;
CREATE SEQUENCE bodies_id_seq;
CREATE SEQUENCE tyres_id_seq;
CREATE SEQUENCE car_models_id_seq;
CREATE SEQUENCE orders_id_seq;
CREATE SEQUENCE employees_id_seq;
CREATE SEQUENCE clients_id_seq;
CREATE SEQUENCE address_id_seq;


------------------------------------
-- Creating tables for car models --
------------------------------------

CREATE TABLE Brakes
(
    brake_id NUMBER(5,0) PRIMARY KEY,
    construction_type VARCHAR2(20) NOT NULL,
    startup_mechanism VARCHAR2(20) NOT NULL,
    efficiency NUMBER(5,0) NOT NULL
);


CREATE TABLE Engines
(
    engine_id NUMBER(5,0) PRIMARY KEY,
    engine_power NUMBER(3,0) NOT NULL,
    predicted_range NUMBER(4,0),
    manufacturer VARCHAR2(45) NOT NULL,
    engine_type VARCHAR2(15) CHECK(engine_type IN('Diesel', 'Elektryczny', 'Benzyna', 'Hybryda')),
    engine_capacity NUMBER(2,1)
);

CREATE TABLE Gearboxes
(
    gearbox_id NUMBER(7,0) PRIMARY KEY,
    gearbox_type VARCHAR2(20) CHECK(gearbox_type IN('Manualna', 'Automatyczna', 'Semiautomatyczna')),
    number_of_gear NUMBER(1,0),
    durability NUMBER(6,0) NOT NULL
);

CREATE TABLE Chassis
(
    chassis_id NUMBER(5,0) PRIMARY KEY,
    drive VARCHAR2(10) CHECK(drive IN ('Przod', 'Tyl', '4x4')), -- rodzaj napedu
    wheel_clearence NUMBER(3,1) NOT NULL -- przeswit auta
);

CREATE TABLE Bodies
(
    body_id NUMBER(5,0) PRIMARY KEY,
    body_type VARCHAR2(12) CHECK(body_type iN ('Hatchback', 'Sedan', 'Kombi', 'Van')),
    color VARCHAR2(12) NOT NULL,
    number_of_doors NUMBER(1,0) NOT NULL,
    amount_of_passengers NUMBER(1,0) NOT NULL
);

CREATE TABLE Tyres
(
    tyres_id NUMBER(5,0) PRIMARY KEY,
    manufacturer VARCHAR2(20) NOT NULL,
    durability NUMBER(5,0) NOT NULL,
    tyres_size NUMBER(2,0) NOT NULL
);

CREATE TABLE Car_models
(
    car_model_id NUMBER(3,0) PRIMARY KEY,
    brake_id NUMBER(5,0) REFERENCES Brakes(brake_id) ON DELETE SET NULL,
    engine_id NUMBER(5,0) REFERENCES Engines(engine_id) ON DELETE SET NULL,
    gearbox_id NUMBER(7,0) REFERENCES Gearboxes(gearbox_id) ON DELETE SET NULL,
    chassis_id NUMBER(5,0) REFERENCES Chassis(chassis_id) ON DELETE SET NULL,
    body_id NUMBER(5,0) REFERENCES Bodies(body_id) ON DELETE SET NULL,
    tyres_id NUMBER(5,0) REFERENCES Tyres(tyres_id) ON DELETE SET NULL,
    car_model VARCHAR2(20) NOT NULL,
    status VARCHAR2(15) CHECK(status IN('TO BUY', 'RESERVED', 'SOLD')),
    price NUMBER(6,0) NOT NULL
);
   
------------------------------------------- 
-- Creating tables for people and orders --
-------------------------------------------

CREATE TABLE Personal_data
(
    pesel NUMBER(11,0) PRIMARY KEY,
    first_name VARCHAR2(15) NOT NULL,
    last_name VARCHAR2(15) NOT NULL,
    phone_number NUMBER(9,0) NOT NULL,
    email VARCHAR2(50) CHECK(email LIKE '%@%.com') NOT NULL
);

CREATE TABLE Address
(
    address_id NUMBER(5,0) PRIMARY KEY,
    city VARCHAR2(40) NOT NULL,
    street VARCHAR2(40),
    postal_code VARCHAR2(6) NOT NULL,
    house_number NUMBER(3,0) NOT NULL,
    home_number NUMBER(3,0)
);

CREATE TABLE Employees
(
    employee_id NUMBER(7,0) PRIMARY KEY,
    pesel NUMBER(11,0) REFERENCES Personal_data(pesel) ON DELETE SET NULL,
    salary NUMBER(5,0) NOT NULL,
    working_position VARCHAR2(10) CHECK(working_position IN('DEALER', 'ADMIN'))
);
    
CREATE TABLE Clients
(
    client_id NUMBER(7,0) PRIMARY KEY,
    pesel NUMBER(11,0) REFERENCES Personal_data(pesel) ON DELETE SET NULL,
    address_id NUMBER(5,0) REFERENCES Address(address_id) ON DELETE SET NULL
);
    
CREATE TABLE Orders
(
    order_id NUMBER(4,0) PRIMARY KEY,
    order_date DATE NOT NULL,
    status VARCHAR2(20) DEFAULT 'ACCEPTED TO PROCESS' CHECK(status IN('ACCEPTED TO PROCESS', 'PROCESSING', 'FINISHED')),
    employee_id NUMBER(7,0) REFERENCES Employees(employee_id) ON DELETE SET NULL,
    client_id NUMBER(7,0) REFERENCES Clients(client_id) ON DELETE SET NULL,
    car_model_id NUMBER(3,0) REFERENCES Car_models(car_model_id) ON DELETE SET NULL
);

--------------------------
-- Creating logs tables --
--------------------------

-- When admin makes changes to car models table
-- its saved into Car_models_logs

CREATE TABLE Car_models_logs
(
    log_id NUMBER(4,0) PRIMARY KEY,
    timestamp_ TIMESTAMP,
    change_type VARCHAR2(20) CHECK(change_type IN('SYSTEM', 'INSERT', 'UPDATE')),
    car_model_id NUMBER(3,0) REFERENCES Car_models(car_model_id) ON DELETE SET NULL,
    log_descryption VARCHAR2(200)
);

-- When order is completed
-- then it's carried to logs table
    
CREATE TABLE Orders_logs
(
    log_id NUMBER(4,0) PRIMARY KEY,
    timestamp_ TIMESTAMP,
    order_id NUMBER(4,0) REFERENCES Orders(order_id) ON DELETE SET NULL,
    log_descryption VARCHAR2(200)
);
    
-- When admin makes changes to employees table
-- its saved into Employees_logs table

CREATE TABLE Employees_logs
(
    log_id NUMBER(4,0) PRIMARY KEY,
    timestamp_ TIMESTAMP,
    employee_id NUMBER(7,0) REFERENCES Employees(employee_id) ON DELETE SET NULL,
    salary_old NUMBER(5,0),
    salary_new NUMBER(5,0),
    log_descryption VARCHAR2(200)
);

-- When admin or dealer makes changes to clients table
-- its saved into Clients_logs table
    
CREATE TABLE Clients_logs
(
    log_id NUMBER(4,0) PRIMARY KEY,
    timestamp_ TIMESTAMP,
    client_id NUMBER(7,0) REFERENCES Clients(client_id) ON DELETE SET NULL,
    log_descryption VARCHAR2(200)
);
     
--------------------
-- Creating views --
--------------------

CREATE VIEW Car_models_view AS
SELECT m.car_model_id "ID modelu", m.car_model "Nazwa modelu", b.body_type "Rodzaj"
FROM Car_models m, Bodies b
WHERE status = 'TO BUY' AND m.body_id = b.body_id;

CREATE VIEW Orders_view AS
SELECT order_id "ID zamowienia", order_date "Data zlozenia", status "Status", employee_id "ID pracownika", client_id "ID klienta"
FROM Orders;

CREATE VIEW Clients_view AS
SELECT c.client_id "ID klienta", pd.first_name "Imie", pd.last_name "Nazwisko", a.address_id "ID adresu"
FROM Clients c, Personal_data pd, Address a
WHERE c.pesel = pd.pesel;

CREATE VIEW Employees_view AS
SELECT e.employee_id "ID pracownika", pd.first_name "Imie", pd.last_name "Nazwisko", e.working_position "Stanowisko"
FROM Employees e, Personal_data pd
WHERE e.pesel = pd.pesel;

-------------------------------------------
-- Creating startup data into log tables --
-------------------------------------------

INSERT INTO Car_models_logs(log_id, timestamp_, change_type, log_descryption) VALUES(1, sysdate + 1, 'SYSTEM', 'System startup');
INSERT INTO Orders_logs(log_id, timestamp_, log_descryption) VALUES(1, sysdate + 1, 'System startup');
INSERT INTO Employees_logs(log_id, timestamp_, log_descryption) VALUES(1, sysdate + 1, 'System startup');
INSERT INTO Clients_logs(log_id, timestamp_, log_descryption) VALUES(1, sysdate + 1, 'System startup');

-----------------------
-- Creating triggers --
-----------------------

-- Car models log table trigger

CREATE OR REPLACE TRIGGER Car_models_log_tr
    AFTER INSERT OR DELETE OR UPDATE OF status
    ON Car_models
    FOR EACH ROW
DECLARE 
    last_log_id NUMBER(4,0);
BEGIN
    SELECT MAX(log_id) INTO last_log_id FROM Car_models_logs;
    
    IF(INSERTING())
        THEN
            -- if car has been added
            INSERT INTO Car_models_logs VALUES(last_log_id + 1, sysdate + 1, 
                'INSERT', :NEW.car_model_id, 'Car added');
    END IF;
    
    IF(:NEW.status = 'RESERVED')
        THEN
            -- if car has been ordered
            INSERT INTO Car_models_logs VALUES(last_log_id + 1, sysdate + 1, 
                'UPDATE', :NEW.car_model_id, 'status: TO BUY -> RESERVED');
    END IF;
    
    IF(:NEW.status = 'SOLD')
        THEN
            -- if car has been sold
            INSERT INTO Car_models_logs VALUES(last_log_id + 1, sysdate + 1, 
                'UPDATE', :NEW.car_model_id, 'status: RESERVED -> SOLD');
    END IF;
END;
/

-- Orders log table trigger

CREATE OR REPLACE TRIGGER Orders_log_tr
    AFTER INSERT OR UPDATE OF status
    ON Orders
    FOR EACH ROW
DECLARE 
    last_order_log_id NUMBER(4, 0);
BEGIN 
    -- getting last logs ID to increment with next insertions
    SELECT MAX(log_id) INTO last_order_log_id FROM Orders_logs;

    IF(:NEW.status = 'ACCEPTED TO PROCESS') 
        THEN 
            -- inserting new record to orders log table
            INSERT INTO Orders_logs VALUES (last_order_log_id + 1, sysdate + 1, 
                :NEW.order_id, 'Order accepted to process.');
            
            -- updating car status to RESERVED having made the order
            UPDATE Car_models
            SET status = 'RESERVED'
            WHERE car_model_id = :NEW.car_model_id;
            
    END IF;
    
    IF(:NEW.status = 'PROCESSING')
        THEN
            -- inserting new record to log table
            INSERT INTO Orders_logs VALUES (last_order_log_id + 1, sysdate + 1, :NEW.order_id, 'Order processing.');
    END IF;

    IF(:NEW.status = 'FINISHED')
        THEN
            -- inserting new record to log table
            INSERT INTO Orders_logs VALUES (last_order_log_id + 1, sysdate + 1, :NEW.order_id, 'Order finished.');
            
            -- updating car status to SOLD having finished the order
            UPDATE Car_models
            SET status = 'SOLD'
            WHERE car_model_id = :NEW.car_model_id;  
                                                        
    END IF;
END;
/

-- Employees log table trigger

CREATE OR REPLACE TRIGGER Employees_log_tr
    AFTER INSERT OR DELETE OR UPDATE OF salary
    ON Employees
    FOR EACH ROW
DECLARE
    last_log_id NUMBER(4);
BEGIN
    -- getting last log ID to increment with next insertion
    SELECT MAX(log_id) INTO last_log_id FROM Employees_logs;
    
    -- if salary has changed
    iF(:NEW.salary != :OLD.salary)
        THEN
            -- inserting new record to loga table with old and new salary
            INSERT INTO Employees_logs VALUES(last_log_id + 1, sysdate + 1, :NEW.employee_id, :OLD.salary, :NEW.salary, 'Salary changed.');
    END IF;
    
    -- if employee acount has been created
    IF(INSERTING())
        THEN
            INSERT INTO Employees_logs VALUES(last_log_id + 1, sysdate + 1, :NEW.employee_id, NULL, NULL, 'Added employee.');
    END IF;  
    
    IF(DELETING())
        THEN
            INSERT INTO Employees_logs VALUES(last_log_id + 1, sysdate + 1, :NEW.employee_id, NULL, NULL, 'Deleted employee.');
    END IF;
END;
/

-- Clients log table trigger

CREATE OR REPLACE TRIGGER Clients_log_tr
    AFTER INSERT OR DELETE
    ON Clients
    FOR EACH ROW
DECLARE
    last_log_id NUMBER(4,0);
BEGIN

    -- getting last log ID to increment with next insertion
    SELECT MAX(log_id) INTO last_log_id FROM Clients_logs;

    IF(INSERTING())
        THEN 
            --if client has been created
            INSERT INTO Clients_logs VALUES(last_log_id + 1, sysdate, :NEW.client_id, 'Client created.');
    END IF;
    
    IF(DELETING())
        THEN 
            --if client has been created
            INSERT INTO Clients_logs VALUES(last_log_id + 1, sysdate, :NEW.client_id, 'Client deleted.');
    END IF;
END;
/

--------------------
-- Inserting Data --
--------------------

-- inserting brakes data
INSERT INTO Brakes VALUES(brakes_id_seq.NEXTVAL, 'Tarczowe', 'Mechaniczne', 25000);
INSERT INTO Brakes VALUES(brakes_id_seq.NEXTVAL, 'Tasmowe', 'Hydrauliczne', 30000);
INSERT INTO Brakes VALUES(brakes_id_seq.NEXTVAL, 'Szczekowo - bebnowe', 'Pneumatyczne', 35000);
INSERT INTO Brakes VALUES(brakes_id_seq.NEXTVAL, 'Tarczowe', 'Elektropneumatyczne', 20000);
INSERT INTO Brakes VALUES(brakes_id_seq.NEXTVAL, 'Tasmowe', 'Hydrauliczne', 40000);
INSERT INTO Brakes VALUES(brakes_id_seq.NEXTVAL, 'Szczekowo - bebnowe', 'Mechaniczne', 27500);
INSERT INTO Brakes VALUES(brakes_id_seq.NEXTVAL, 'Tarczowe', 'Pneumatyczne', 33000);

-- inserting engines data
INSERT INTO Engines VALUES(engines_id_seq.NEXTVAL, 90, 700, 'Honda', 'Diesel', 1.0);
INSERT INTO Engines VALUES(engines_id_seq.NEXTVAL, 140, NULL, 'Honda', 'Benzyna', 1.8);
INSERT INTO Engines VALUES(engines_id_seq.NEXTVAL, 200, 550, 'Mercedes', 'Hybryda', 2.0);
INSERT INTO Engines VALUES(engines_id_seq.NEXTVAL, 110, 630, 'Peugeot', 'Elektryczny', NULL);
INSERT INTO Engines VALUES(engines_id_seq.NEXTVAL, 250, NULL, 'Honda', 'Benzyna', 2.0);
INSERT INTO Engines VALUES(engines_id_seq.NEXTVAL, 100, 400, 'Honda', 'Elektryczny', NULL);
INSERT INTO Engines VALUES(engines_id_seq.NEXTVAL, 120, 600, 'Peugeot', 'Diesel', 1.6);

-- inserting gearboxes data
INSERT INTO Gearboxes VALUES(gearboxes_id_seq.NEXTVAL, 'Manualna', 5, 90000);
INSERT INTO Gearboxes VALUES(gearboxes_id_seq.NEXTVAL, 'Automatyczna', 6, 120000);
INSERT INTO Gearboxes VALUES(gearboxes_id_seq.NEXTVAL, 'Manualna', 7, 150000);
INSERT INTO Gearboxes VALUES(gearboxes_id_seq.NEXTVAL, 'Semiautomatyczna', 5, 80000);
INSERT INTO Gearboxes VALUES(gearboxes_id_seq.NEXTVAL, 'Manualna', 5, 100000);
INSERT INTO Gearboxes VALUES(gearboxes_id_seq.NEXTVAL, 'Automatyczna', 5, 95000);

-- inserting chassis data
INSERT INTO Chassis VALUES(chassis_id_seq.NEXTVAL, 'Przod', 15.5);
INSERT INTO Chassis VALUES(chassis_id_seq.NEXTVAL, 'Tyl', 20.0);
INSERT INTO Chassis VALUES(chassis_id_seq.NEXTVAL, '4x4', 27.5);
INSERT INTO Chassis VALUES(chassis_id_seq.NEXTVAL, 'Tyl', 17.0);
INSERT INTO Chassis VALUES(chassis_id_seq.NEXTVAL, 'Przod', 23.0);
INSERT INTO Chassis VALUES(chassis_id_seq.NEXTVAL, '4x4', 30.5);
INSERT INTO Chassis VALUES(chassis_id_seq.NEXTVAL, 'Tyl', 22.5);

-- inserting bodies data
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Hatchback', 'Bialy', 3, 5);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Sedan', 'Czerwony', 5, 5);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Van', 'Zielony', 5, 7);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Kombi', 'Bialy', 5, 5);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Hatchback', 'Czarny', 5, 5);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Kombi', 'Brazowy', 5, 5);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Van', 'Niebieski', 5, 5);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Sedan', 'Zielony', 5, 5);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Hatchback', 'Bialy', 3, 2);
INSERT INTO Bodies VALUES(bodies_id_seq.NEXTVAL, 'Sedan', 'Czarny', 5, 5);

-- inserting tyres data
INSERT INTO Tyres VALUES(tyres_id_seq.NEXTVAL, 'Bridgestone', 50000,  20);
INSERT INTO Tyres VALUES(tyres_id_seq.NEXTVAL, 'Dunlop', 70000,  15);
INSERT INTO Tyres VALUES(tyres_id_seq.NEXTVAL, 'Debica', 95000,  16);
INSERT INTO Tyres VALUES(tyres_id_seq.NEXTVAL, 'Michelin', 84000,  14);
INSERT INTO Tyres VALUES(tyres_id_seq.NEXTVAL, 'Dunlop', 75000,  18);

-- inserting car models data
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 3, 1, 5, 7, 10, 2, 'Gamma', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 4, 3, 1, 1, 9, 1, 'Delta', 'TO BUY', 50000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 1, 5, 4, 3, 4, 4, 'Alfa', 'TO BUY', 120000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 2, 3, 2, 2, 1, 3, 'Duster', 'TO BUY', 65000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 3, 2, 1, 5, 8, 5, 'Air', 'TO BUY', 150000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 5, 4, 3, 6, 9, 5, 'Panda', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 7, 6, 6, 1, 7, 1, 'Oracle', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 6, 7, 2, 2, 3, 2, 'Kotlin', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 2, 1, 5, 4, 5, 4, 'Monster', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 1, 2, 1, 7, 6, 2, 'Samsung', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 3, 5, 6, 1, 7, 1, 'Roller', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 5, 3, 3, 3, 2, 5, 'Cactus', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 5, 4, 2, 2, 8, 3, 'Lion', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 7, 7, 4, 5, 1, 3, 'Idea', 'TO BUY', 70000);
INSERT INTO Car_models VALUES(car_models_id_seq.NEXTVAL, 2, 1, 1, 6, 4, 2, 'Logic', 'TO BUY', 70000);

-- inserting personal data data
INSERT INTO Personal_data VALUES(37122785595, 'Julianna', 'Sosnowska',498287948 , 'julia.sosnowska@gmail.com');
INSERT INTO Personal_data VALUES(40053127336, 'Leonarda', 'Piasecka', 485198537, 'leonarda.piasecka@gmail.com');
INSERT INTO Personal_data VALUES(54071903418, 'Laura', 'Leszczynska', 485739465, 'laura.lesczynska@gmail.com');
INSERT INTO Personal_data VALUES(69063032711, 'Adolf', 'Bak', 468519785, 'adolf.bak@gmail.com');
INSERT INTO Personal_data VALUES(35070935853, 'Paula', 'Walczak', 498723168, 'paula.walczak@gmail.com');
INSERT INTO Personal_data VALUES(35111455935, 'Oliver', 'Bednarczyk', 498482649, 'oliver.bednarczyk@gmail.com');
INSERT INTO Personal_data VALUES(46061046872, 'Iwona', 'Grzelak', 471374487, 'iwona.grzelak@gmail.com');
INSERT INTO Personal_data VALUES(45062232444, 'Sonia', 'Wojciechowska', 316497852, 'sonia.wojciechowska@gmail.com');
INSERT INTO Personal_data VALUES(93111235164, 'Wilhelm', 'Andrzejewski', 548457913, 'wilhelm.aandrzejewski@gmail.com');
INSERT INTO Personal_data VALUES(23103153226, 'Edyta', 'Zalewska', 487942824, 'edyta.zalewska@gmail.com');
INSERT INTO Personal_data VALUES(66052809516, 'Angelika', 'Jastrzebska', 444968468, 'angelika.jastrzebska@gmail.com');
INSERT INTO Personal_data VALUES(71111890266, 'Violetta', 'Piatek', 468468132, 'violetta.piatek@gmail.com');
INSERT INTO Personal_data VALUES(18270285605, 'Maksymilian', 'Kolodziej', 498558487, 'maksymilian.kolodziej@gmail.com');
INSERT INTO Personal_data VALUES(13262533526, 'Damian', 'Przybylski', 465598822, 'damian.przybylski@gmail.com');
INSERT INTO Personal_data VALUES(41052168474, 'Pelagia', 'Szulc', 464841323, 'pelagia.szulc@gmail.com');
INSERT INTO Personal_data VALUES(00271237989, 'Hildegarda', 'Lis', 987874813, 'hildegarda.lis@gmail.com');
INSERT INTO Personal_data VALUES(74091840564, 'Justyna', 'Malinowska', 468585132, 'justyna.malinowska@gmail.com');
INSERT INTO Personal_data VALUES(10281746764, 'Maksym', 'Kowal', 465648135, 'maksym.kowal@gmail.com');
INSERT INTO Personal_data VALUES(23021278379, 'Kornelia', 'Wolska', 798584846, 'kornelia.wolska@gmail.com');
INSERT INTO Personal_data VALUES(26072775680, 'Rafal', 'Bielecki', 989897462, 'rafal.bielecki@gmail.com');

-- inserting employees
INSERT INTO Employees VALUES(employees_id_seq.NEXTVAL, 37122785595, 5000, 'DEALER');
INSERT INTO Employees VALUES(employees_id_seq.NEXTVAL, 40053127336, 3000, 'DEALER');
INSERT INTO Employees VALUES(employees_id_seq.NEXTVAL, 54071903418, 4500, 'DEALER');
INSERT INTO Employees VALUES(employees_id_seq.NEXTVAL, 69063032711, 7000, 'DEALER');
INSERT INTO Employees VALUES(employees_id_seq.NEXTVAL, 35070935853, 12000, 'ADMIN');

-- inserting  various ad
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Bytom', 'Grunwaldzka', '11-874', 50, 25);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Sopot', 'Ogrodowa', '44-676', 36, 2);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Nowy Sacz', 'Cwiklinskiej', '44-354', 23, 2);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Zielona Góra', 'Skromna', '49-004', 70, NULL);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Tarnobrzeg', 'Stachury', '76-081', 69, 2);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Plock', 'S³owackiego', '24-601', 1, 1);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Jelenia Gora', 'Klasztorna', '35-522', 6, 4);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Jastrzêbie-Zdroj', 'Obwodowa', '63-667', 25, 7);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Lublin', 'Szkolna', '11-266', 15, NULL);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Kielce', 'Piesza', '14-198', 1, NULL);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Tarnobrzeg', 'Lakowa', '78-658', 22, NULL);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Gorzow Wielkopolski', '£¹kowa', '38-974', 85, 1);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Grudziadz', 'Sandaczowa', '53-194', 6, 9);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Piekary Sl¹skie', 'Sosnowa', '86-794', 1, 12);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Bydgoszcz', 'Bydgoszcz', '30-300', 55, 1);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Suwalki', 'Ogrodowa', '30-973', 2, 4);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Bytom', 'Kujawska', '61-437', 1, 5);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Suwalki', 'Modra', '08-275', 33, 9);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Poznan', 'Kujawska', '83-356', 19, 33);
INSERT INTO Address VALUES(address_id_seq.NEXTVAL, 'Poznan', 'Kosiby', '94-481', 37, 2);

-- inserting clients data
INSERT INTO Clients VALUES(clients_id_seq.NEXTVAL, 26072775680, 1);
INSERT INTO Clients VALUES(clients_id_seq.NEXTVAL, 23021278379, 2);
INSERT INTO Clients VALUES(clients_id_seq.NEXTVAL, 10281746764, 3);
INSERT INTO Clients VALUES(clients_id_seq.NEXTVAL, 74091840564, 4);
INSERT INTO Clients VALUES(clients_id_seq.NEXTVAL, 00271237989, 5);

-- inserting orders
INSERT INTO Orders(order_id, order_date, employee_id, client_id, car_model_id) 
    VALUES(orders_id_seq.NEXTVAL, TO_DATE('17/12/2015', 'DD/MM/YYYY'), 1, 1, 3);
INSERT INTO Orders(order_id, order_date, employee_id, client_id, car_model_id) 
    VALUES(orders_id_seq.NEXTVAL, TO_DATE('29/05/2022', 'DD/MM/YYYY'), 1, 1, 1);
INSERT INTO Orders(order_id, order_date, employee_id, client_id, car_model_id) 
    VALUES(orders_id_seq.NEXTVAL, TO_DATE('17/03/2022', 'DD/MM/YYYY'), 1, 2, 2);
INSERT INTO Orders(order_id, order_date, employee_id, client_id, car_model_id) 
    VALUES(orders_id_seq.NEXTVAL, TO_DATE('03/03/2022', 'DD/MM/YYYY'), 1, 2, 8);
INSERT INTO Orders(order_id, order_date, employee_id, client_id, car_model_id) 
    VALUES(orders_id_seq.NEXTVAL, TO_DATE('23/04/2022', 'DD/MM/YYYY'), 2, 3, 4);
INSERT INTO Orders(order_id, order_date, employee_id, client_id, car_model_id) 
    VALUES(orders_id_seq.NEXTVAL, TO_DATE('05/05/2022', 'DD/MM/YYYY'), 3, 4, 5);
    
-- various updates to fill logs tables
UPDATE Orders 
SET status = 'PROCESSING' 
WHERE order_id = 1;

UPDATE Orders 
SET status = 'PROCESSING' 
WHERE order_id = 2;

UPDATE Orders 
SET status = 'PROCESSING' 
WHERE order_id = 3;

UPDATE Orders 
SET status = 'PROCESSING' 
WHERE order_id = 4;

UPDATE Orders 
SET status = 'FINISHED' 
WHERE order_id = 5;

UPDATE Employees
SET salary = 7000
WHERE employee_id = 1;
