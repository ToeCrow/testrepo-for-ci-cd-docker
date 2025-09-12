-- ---------------------------
-- TABELLER
-- ---------------------------

-- ROUTE
CREATE TABLE "Route" (
  "Id" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50),
  "Code" VARCHAR(10)
);

-- EXPECTED TEMPERATURE
CREATE TABLE "ExpectedTemp" (
  "Id" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50),
  "Min" DECIMAL(3,1),
  "Max" DECIMAL(3,1)
);

-- EXPECTED HUMIDITY
CREATE TABLE "ExpectedMoist" (
  "Id" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50),
  "Min" DECIMAL(3,1),
  "Max" DECIMAL(3,1)
);

-- TRANSPORT / VEHICLE
CREATE TABLE "Transport" (
  "Id" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50)
);

-- POSTADRESS
CREATE TABLE "Postadress" (
  "Id" SERIAL PRIMARY KEY,
  "Postnummer" INT,
  "Postadress" VARCHAR(35)
);

-- SENDER
CREATE TABLE "Sender" (
  "Id" SERIAL PRIMARY KEY,
  "PostadressId" INT REFERENCES "Postadress"("Id"),
  "Name" VARCHAR(50),
  "Adress1" VARCHAR(35)
);

-- RECIPIENT
CREATE TABLE "Recipient" (
  "Id" SERIAL PRIMARY KEY,
  "PostadressId" INT REFERENCES "Postadress"("Id"),
  "Name" VARCHAR(50),
  "Adress1" VARCHAR(35)
);

-- ORDERS
CREATE TABLE "Order" (
  "Id" SERIAL PRIMARY KEY,
  "RouteId" INT REFERENCES "Route"("Id"),
  "ExpectedTempId" INT REFERENCES "ExpectedTemp"("Id"),
  "ExpectedMoistId" INT REFERENCES "ExpectedMoist"("Id"),
  "TransportId" INT REFERENCES "Transport"("Id"),
  "SenderId" INT REFERENCES "Sender"("Id"),
  "RecipientId" INT REFERENCES "Recipient"("Id")
);

-- ORDERSTATUS
CREATE TABLE "OrderStatus" (
  "Id" SERIAL PRIMARY KEY,
  "OrderId" INT REFERENCES "Order"("Id"),
  "Status" VARCHAR(20),
  "TimeStamp" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SENSOR
CREATE TABLE "Sensor" (
  "Id" VARCHAR(50) PRIMARY KEY,
  "Name" VARCHAR(50)
);

-- MEASUREMENT TEMP
CREATE TABLE "MeasurementTemp" (
  "Id" SERIAL PRIMARY KEY,
  "OrderId" INT REFERENCES "Order"("Id"),
  "SensorId" VARCHAR(35) REFERENCES "Sensor"("Id"),
  "Temp" DECIMAL(3,1),
  "Humidity" INT,
  "CurrentTime" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TIME OUTSIDE RANGE
CREATE TABLE "TimeOutsideRange" (
  "Id" SERIAL PRIMARY KEY,
  "OrderId" INT REFERENCES "Order"("Id"),
  "TimeMinutes" INT
);

-- ---------------------------
-- INSERT MOCKDATA
-- ---------------------------

INSERT INTO "Route" ("Name", "Code") VALUES
('Stockholm', 'STO'),
('Göteborg', 'GOT'),
('Malmö', 'MMA'),
('Värnamo', 'VMO'),
('Borlänge', 'BLE'),
('Linköping', 'LKG'),
('Luleå', 'LLA'),
('Skellefteå', 'SFT'),
('Umeå', 'UME'),
('Halmstad', 'HSD'),
('Karlstad', 'KSD'),
('Växjö', 'VXO'),
('Jönköping', 'JKG'),
('Helsingborg', 'HBG'),
('Kristianstad', 'KID'),
('Borås', 'BSZ'),
('Örnsköldsvik', 'OSK'),
('Sundsvall', 'SDL'),
('Västerås', 'VST'),
('Nybro', 'NYB'),
('Skara', 'SKA'),
('Vänersborg', 'VAN'),
('Visby', 'VBY'),
('Örebro', 'ORB'),
('Gävle', 'GVX');

-- EXPECTED TEMP
INSERT INTO "ExpectedTemp" ("Name", "Min", "Max") VALUES
('Kylkedja temp', 2.0, 8.0);

-- EXPECTED HUMIDITY
INSERT INTO "ExpectedMoist" ("Name", "Min", "Max") VALUES
('Standard humidity', 30.0, 70.0);

-- TRANSPORT
INSERT INTO "Transport" ("Name") VALUES ('Bil 1');

-- POSTADRESS
INSERT INTO "Postadress" ("Postnummer", "Postadress") VALUES
(11122, 'Sändarvägen 1'),
(33344, 'Mottagarvägen 5');

-- SENDER
INSERT INTO "Sender" ("PostadressId", "Name", "Adress1") VALUES
(1, 'Sändare AB', 'Sändarvägen 1');

-- RECIPIENT
INSERT INTO "Recipient" ("PostadressId", "Name", "Adress1") VALUES
(2, 'Mottagare AB', 'Mottagarvägen 5');

-- SENSOR
INSERT INTO "Sensor" ("Id", "Name") VALUES
('sensor-001', 'Temp/Humidity Sensor 1');

-- =========================
-- Orders with measurements
-- =========================

-- Order 1
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (1,'Skapad','2025-09-10 08:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(1,'sensor-001',5.0,55,'2025-09-10 08:30'),
(1,'sensor-001',6.3,57,'2025-09-10 09:00'),
(1,'sensor-001',4.8,53,'2025-09-10 09:30');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (1,0);

-- Order 2
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (2,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (2,'Lastad','2025-09-10 09:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(2,'sensor-001',7.1,75,'2025-09-10 09:15'),
(2,'sensor-001',8.0,78,'2025-09-10 09:45'),
(2,'sensor-001',6.9,74,'2025-09-10 10:15');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (2,12);

-- Order 3
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (3,'Levererad','2025-09-10 11:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(3,'sensor-001',5.0,60,'2025-09-10 10:00'),
(3,'sensor-001',5.5,61,'2025-09-10 10:30'),
(3,'sensor-001',4.9,59,'2025-09-10 11:00');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (3,0);

-- Order 4
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (3,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (4,'Skapad','2025-09-10 08:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(4,'sensor-001',4.0,45,'2025-09-10 08:00'),
(4,'sensor-001',4.5,47,'2025-09-10 08:30'),
(4,'sensor-001',3.8,44,'2025-09-10 09:00');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (4,0);

-- Order 5
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (4,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (5,'Lastad','2025-09-10 08:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(5,'sensor-001',6.4,62,'2025-09-10 08:30'),
(5,'sensor-001',6.8,63,'2025-09-10 09:00'),
(5,'sensor-001',6.0,61,'2025-09-10 09:30');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (5,0);

-- Order 6
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (5,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (6,'Skapad','2025-09-10 09:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(6,'sensor-001',3.2,38,'2025-09-10 09:00'),
(6,'sensor-001',3.6,40,'2025-09-10 09:30'),
(6,'sensor-001',2.9,37,'2025-09-10 10:00');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (6,0);

-- Order 7
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (2,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (7,'Levererad','2025-09-10 12:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(7,'sensor-001',6.8,59,'2025-09-10 10:30'),
(7,'sensor-001',7.2,60,'2025-09-10 11:00'),
(7,'sensor-001',6.5,58,'2025-09-10 11:30');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (7,0);

-- Order 8
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (6,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (8,'Lastad','2025-09-10 09:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(8,'sensor-001',7.3,70,'2025-09-10 09:15'),
(8,'sensor-001',7.6,72,'2025-09-10 09:45'),
(8,'sensor-001',7.1,69,'2025-09-10 10:15');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (8,0);

-- Order 9
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (7,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (9,'Skapad','2025-09-10 09:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(9,'sensor-001',5.0,48,'2025-09-10 09:30'),
(9,'sensor-001',5.4,50,'2025-09-10 10:00'),
(9,'sensor-001',4.7,47,'2025-09-10 10:30');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (9,0);

-- Order 10
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (8,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (10,'Lastad','2025-09-10 10:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(10,'sensor-001',2.0,33,'2025-09-10 10:00'),
(10,'sensor-001',2.5,35,'2025-09-10 10:30'),
(10,'sensor-001',2.2,32,'2025-09-10 11:00');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (10,0);

-- Order 11
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (9,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (11,'Skapad','2025-09-10 10:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(11,'sensor-001',8.0,69,'2025-09-10 10:15'),
(11,'sensor-001',8.4,70,'2025-09-10 10:45'),
(11,'sensor-001',7.8,68,'2025-09-10 11:15');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (11,0);

-- Order 12
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (2,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (12,'Åter','2025-09-10 12:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(12,'sensor-001',3.2,69,'2025-09-10 10:30'),
(12,'sensor-001',3.5,70,'2025-09-10 11:00'),
(12,'sensor-001',2.9,68,'2025-09-10 11:30');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (12,12);

-- Order 13
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (10,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (13,'Lastad','2025-09-10 10:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(13,'sensor-001',6.0,61,'2025-09-10 10:30'),
(13,'sensor-001',6.3,62,'2025-09-10 11:00'),
(13,'sensor-001',5.8,60,'2025-09-10 11:30');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (13,0);

-- Order 14
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (11,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (14,'Skapad','2025-09-10 10:45');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(14,'sensor-001',9.0,80,'2025-09-10 10:45'),
(14,'sensor-001',9.5,82,'2025-09-10 11:15'),
(14,'sensor-001',8.8,79,'2025-09-10 11:45');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (14,25);

-- Order 15
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (12,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","Status","TimeStamp")
VALUES (15,'Lastad','2025-09-10 11:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(15,'sensor-001',5.5,50,'2025-09-10 11:00'),
(15,'sensor-001',5.9,51,'2025-09-10 11:30'),
(15,'sensor-001',5.2,49,'2025-09-10 12:00');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (15,0);
