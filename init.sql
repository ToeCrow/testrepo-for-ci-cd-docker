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

-- ORDERSEQUENCES
CREATE TABLE "OrderSequence" (
  "Id" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) UNIQUE NOT NULL,
  "sequence" INT NOT NULL
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
  "OrdersequenceId" INT REFERENCES "OrderSequence"("Id"),
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

-- ROUTES
INSERT INTO "Route" ("Name", "Code") VALUES
('Stockholm', 'STO'),('Göteborg', 'GOT'),('Malmö', 'MMA'),('Värnamo', 'VMO'),
('Borlänge', 'BLE'),('Linköping', 'LKG'),('Luleå', 'LLA'),('Skellefteå', 'SFT'),
('Umeå', 'UME'),('Halmstad', 'HSD'),('Karlstad', 'KSD'),('Växjö', 'VXO'),
('Jönköping', 'JKG'),('Helsingborg', 'HBG'),('Kristianstad', 'KID'),('Borås', 'BSZ'),
('Örnsköldsvik', 'OSK'),('Sundsvall', 'SDL'),('Västerås', 'VST'),('Nybro', 'NYB'),
('Skara', 'SKA'),('Vänersborg', 'VAN'),('Visby', 'VBY'),('Örebro', 'ORB'),('Gävle', 'GVX');

-- EXPECTED TEMP
INSERT INTO "ExpectedTemp" ("Name", "Min", "Max") VALUES
('Kylkedja temp', 2.0, 8.0),
('Rumstemp', 5.0, 25.0);

-- EXPECTED HUMIDITY
INSERT INTO "ExpectedMoist" ("Name", "Min", "Max") VALUES
('Standard humidity', 30.0, 70.0);

-- TRANSPORT
INSERT INTO "Transport" ("Name") VALUES ('Schenker'), ('DHL'), ('UPS');

-- POSTADRESS
INSERT INTO "Postadress" ("Postnummer", "Postadress") VALUES
(16970, 'Solna'),(11226, 'Stockholm'),(17173, 'Solna'),
(11830, 'Stockholm'),(11120, 'Stockholm'),(12630, 'Hägersten');

-- SENDER
INSERT INTO "Sender" ("PostadressId", "Name", "Adress1") VALUES
(1, 'ICA AB', 'Kolonnvägen 20'),
(2, 'Hjärtat AB', 'Fleminggatan 18'),
(3, 'Coop AB', 'Terminalvägen 21');

-- RECIPIENT
INSERT INTO "Recipient" ("PostadressId", "Name", "Adress1") VALUES
(4, 'Restaurang Pelikan', 'Blekingegatan 40'),
(5, 'Stockholms Universitet', 'Universitetsvägen 10'),
(6, 'Ericsson AB', 'Telefonvägen 30'),
(5, 'Karolinska Sjukhuset', 'Solnavägen 1'),
(4, 'Södersjukhuset', 'Sjukhusbacken 10'),
(6, 'Stockholmsmässan', 'Mässvägen 1');

-- SENSOR
INSERT INTO "Sensor" ("Id", "Name") VALUES
('sensor-001', 'Temp/Humidity Sensor 1');

-- ORDERSEQUENCE
INSERT INTO "OrderSequence" ("Name", "sequence") VALUES
('Skapad', 1),('Lastad', 2),('Levererad', 3),('Åter', 4);

-- =========================
-- ORDERS, STATUS, MEASUREMENTS
-- =========================

-- Example: Order 1
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(1,1,'2025-09-10 08:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(1,'sensor-001',5.1,59,'2025-09-10 08:30'),
(1,'sensor-001',5.2,60,'2025-09-10 08:45');

-- Order 2
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (2,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(2,1,'2025-09-10 08:45'),
(2,2,'2025-09-10 09:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(2,'sensor-001',5.0,58,'2025-09-10 08:45'),
(2,'sensor-001',5.3,60,'2025-09-10 09:10'),
(2,'sensor-001',5.5,61,'2025-09-10 09:15');

-- Order 3
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(3,1,'2025-09-10 09:00'),
(3,2,'2025-09-10 10:15'),
(3,3,'2025-09-10 11:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(3,'sensor-001',5.0,57,'2025-09-10 09:00'),
(3,'sensor-001',5.4,59,'2025-09-10 10:00'),
(3,'sensor-001',5.6,61,'2025-09-10 11:30');

-- Order 4 (Skapad)
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (3,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(4,1,'2025-09-10 08:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(4,'sensor-001',5.2,59,'2025-09-10 08:00');

-- Order 5 (Lastad)
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (4,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(5,1,'2025-09-10 08:15'),
(5,2,'2025-09-10 08:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(5,'sensor-001',5.1,58,'2025-09-10 08:15'),
(5,'sensor-001',5.3,60,'2025-09-10 08:30');

-- Order 6 (Skapad)
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (5,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(6,1,'2025-09-10 09:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(6,'sensor-001',5.5,61,'2025-09-10 09:00'),
(6,'sensor-001',5.7,62,'2025-09-10 09:15'),
(6,'sensor-001',8.2,63,'2025-09-10 09:30');
-- Tid utanför range för Order 6
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (6,15);

-- Order 7 (Levererad)
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (2,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(7,1,'2025-09-10 10:30'),
(7,2,'2025-09-10 11:00'),
(7,3,'2025-09-10 12:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(7,'sensor-001',4.8,62,'2025-09-10 10:30'),
(7,'sensor-001',5.0,60,'2025-09-10 11:00'),
(7,'sensor-001',5.2,61,'2025-09-10 12:00');
-- Tid utanför range för Order 7
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (7,15);

-- Order 8 (Lastad)
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (6,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(8,1,'2025-09-10 09:00'),
(8,2,'2025-09-10 09:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(8,'sensor-001',5.0,59,'2025-09-10 09:00'),
(8,'sensor-001',5.1,60,'2025-09-10 09:15');

-- Order 9 (Skapad)
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (7,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(9,1,'2025-09-10 09:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(9,'sensor-001',5.2,58,'2025-09-10 09:30');

-- Order 10
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (8,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(10,1,'2025-09-10 09:45'),
(10,2,'2025-09-10 10:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(10,'sensor-001',5.0,60,'2025-09-10 09:45'),
(10,'sensor-001',5.2,61,'2025-09-10 10:00');

-- Order 11
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (9,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(11,1,'2025-09-10 10:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(11,'sensor-001',5.1,59,'2025-09-10 10:15');

-- Order 12
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (2,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(12,1,'2025-09-10 10:30'),
(12,2,'2025-09-10 11:00'),
(12,3,'2025-09-10 11:30'),
(12,4,'2025-09-10 12:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(12,'sensor-001',5.0,58,'2025-09-10 10:30'),
(12,'sensor-001',5.5,62,'2025-09-10 11:00'),
(12,'sensor-001',6.0,65,'2025-09-10 11:30'),
(12,'sensor-001',5.8,63,'2025-09-10 12:15');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (12,20);

-- Order 13
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (10,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(13,1,'2025-09-10 10:15'),
(13,2,'2025-09-10 10:30');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(13,'sensor-001',5.2,60,'2025-09-10 10:15'),
(13,'sensor-001',5.4,62,'2025-09-10 10:30');

-- Order 14
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (11,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(14,1,'2025-09-10 10:45');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(14,'sensor-001',5.1,59,'2025-09-10 10:45');

-- Order 15
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (12,1,1,1,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(15,1,'2025-09-10 10:45'),
(15,2,'2025-09-10 11:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(15,'sensor-001',5.0,58,'2025-09-10 10:45'),
(15,'sensor-001',5.3,60,'2025-09-10 11:00');

-- Order 16
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,3,1,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(16,1,'2025-09-11 08:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(16,'sensor-001',5.1,59,'2025-09-11 08:00');

-- Order 17
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,2,2,2);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(17,1,'2025-09-11 08:30'),
(17,2,'2025-09-11 08:45');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(17,'sensor-001',5.0,60,'2025-09-11 08:30'),
(17,'sensor-001',5.2,61,'2025-09-11 08:45');

-- Order 18
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,1,3,3);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(18,1,'2025-09-11 09:00'),
(18,2,'2025-09-11 09:30'),
(18,3,'2025-09-11 10:15');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(18,'sensor-001',4.9,63,'2025-09-11 09:00'),
(18,'sensor-001',5.2,60,'2025-09-11 09:30'),
(18,'sensor-001',5.5,61,'2025-09-11 10:15');
INSERT INTO "TimeOutsideRange" ("OrderId","TimeMinutes") VALUES (18,10);

-- Order 19
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,3,2,1);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(19,1,'2025-09-11 07:45');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(19,'sensor-001',5.1,59,'2025-09-11 07:45');

-- Order 20
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,2,1,2);
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(20,1,'2025-09-11 09:30'),
(20,2,'2025-09-11 10:00'),
(20,3,'2025-09-11 10:30'),
(20,4,'2025-09-11 11:00');
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(20,'sensor-001',5.0,58,'2025-09-11 09:30'),
(20,'sensor-001',5.3,60,'2025-09-11 10:00'),
(20,'sensor-001',5.5,61,'2025-09-11 10:30'),
(20,'sensor-001',5.2,59,'2025-09-11 11:00');
