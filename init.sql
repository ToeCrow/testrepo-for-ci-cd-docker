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
('Rumstemp', 15.0, 25.0);

-- EXPECTED HUMIDITY
INSERT INTO "ExpectedMoist" ("Name", "Min", "Max") VALUES
('Standard humidity', 30.0, 70.0),
('Torr', 0.0, 30.0);

-- TRANSPORT
INSERT INTO "Transport" ("Name") VALUES ('Schenker'), ('DHL'), ('UPS');

-- POSTADRESS
INSERT INTO "Postadress" ("Id","Postnummer", "Postadress") VALUES
(1,16970, 'Solna'),(2,11226, 'Stockholm'),(3,17173, 'Solna'),
(4,11830, 'Stockholm'),(5,11120, 'Stockholm'),(6,12630, 'Hägersten');

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
('Skapad', 1),
('Lastad', 2),
('Omlastad', 3),
('Levererad', 4);

-- =========================
-- ORDERS, STATUS, MEASUREMENTS
-- =========================

-- Order 1
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (1,1,1,1,1,1);

-- Status
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(1,1,'2025-09-10 08:30'),
(1,2,'2025-09-10 09:00'),
(1,3,'2025-09-10 09:30'),
(1,4,'2025-09-10 11:00');

-- Temperature & Humidity
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(1, 'sensor-001', 5.0, 55, '2025-09-10 08:30'),
(1, 'sensor-001', 5.1, 56, '2025-09-10 08:31'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 08:32'),
(1, 'sensor-001', 5.2, 57, '2025-09-10 08:33'),
(1, 'sensor-001', 5.3, 56, '2025-09-10 08:34'),
(1, 'sensor-001', 5.5, 58, '2025-09-10 08:35'),
(1, 'sensor-001', 5.4, 57, '2025-09-10 08:36'),
(1, 'sensor-001', 5.3, 56, '2025-09-10 08:37'),
(1, 'sensor-001', 5.2, 55, '2025-09-10 08:38'),
(1, 'sensor-001', 5.0, 54, '2025-09-10 08:39'),
-- 10-minuters större ändring
(1, 'sensor-001', 6.0, 60, '2025-09-10 08:40'),
(1, 'sensor-001', 6.1, 61, '2025-09-10 08:41'),
(1, 'sensor-001', 6.0, 60, '2025-09-10 08:42'),
(1, 'sensor-001', 6.2, 62, '2025-09-10 08:43'),
(1, 'sensor-001', 6.1, 61, '2025-09-10 08:44'),
(1, 'sensor-001', 6.3, 63, '2025-09-10 08:45'),
(1, 'sensor-001', 6.2, 62, '2025-09-10 08:46'),
(1, 'sensor-001', 6.1, 61, '2025-09-10 08:47'),
(1, 'sensor-001', 6.0, 60, '2025-09-10 08:48'),
(1, 'sensor-001', 5.9, 59, '2025-09-10 08:49'),
-- Nästa 10 min
(1, 'sensor-001', 5.5, 57, '2025-09-10 08:50'),
(1, 'sensor-001', 5.6, 58, '2025-09-10 08:51'),
(1, 'sensor-001', 5.5, 57, '2025-09-10 08:52'),
(1, 'sensor-001', 5.4, 56, '2025-09-10 08:53'),
(1, 'sensor-001', 5.3, 55, '2025-09-10 08:54'),
(1, 'sensor-001', 5.4, 56, '2025-09-10 08:55'),
(1, 'sensor-001', 5.3, 55, '2025-09-10 08:56'),
(1, 'sensor-001', 5.2, 54, '2025-09-10 08:57'),
(1, 'sensor-001', 5.1, 53, '2025-09-10 08:58'),
(1, 'sensor-001', 5.0, 52, '2025-09-10 08:59'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:00'),
(1, 'sensor-001', 5.1, 56, '2025-09-10 09:01'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:02'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 09:03'),
(1, 'sensor-001', 5.2, 56, '2025-09-10 09:04'),
(1, 'sensor-001', 5.2, 56, '2025-09-10 09:05'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 09:06'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:07'),
(1, 'sensor-001', 5.1, 56, '2025-09-10 09:08'),
(1, 'sensor-001', 5.2, 56, '2025-09-10 09:09'),
(1, 'sensor-001', 5.1, 56, '2025-09-10 09:10'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:11'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 09:12'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:13'),
(1, 'sensor-001', 5.2, 56, '2025-09-10 09:14'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 09:15'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:16'),
(1, 'sensor-001', 5.2, 56, '2025-09-10 09:17'),
(1, 'sensor-001', 5.1, 56, '2025-09-10 09:18'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:19'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 09:20'),
(1, 'sensor-001', 5.2, 56, '2025-09-10 09:21'),
(1, 'sensor-001', 5.1, 56, '2025-09-10 09:22'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:23'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 09:24'),
(1, 'sensor-001', 5.2, 56, '2025-09-10 09:25'),
(1, 'sensor-001', 5.1, 55, '2025-09-10 09:26'),
(1, 'sensor-001', 5.0, 55, '2025-09-10 09:27'),
(1, 'sensor-001', 5.1, 56, '2025-09-10 09:28'),
(1, 'sensor-001', 6.0, 58, '2025-09-10 09:29'),

-- 09:30 (omlastning, snabb uppgång)
(1, 'sensor-001', 6.0, 58, '2025-09-10 09:30'),
(1, 'sensor-001', 6.8, 60, '2025-09-10 09:31'),
(1, 'sensor-001', 7.5, 61, '2025-09-10 09:32'),
(1, 'sensor-001', 7.9, 62, '2025-09-10 09:33'),
(1, 'sensor-001', 7.7, 61, '2025-09-10 09:34'),
(1, 'sensor-001', 7.5, 60, '2025-09-10 09:35'),
(1, 'sensor-001', 7.2, 59, '2025-09-10 09:36'),
(1, 'sensor-001', 7.0, 58, '2025-09-10 09:37'),
(1, 'sensor-001', 6.8, 57, '2025-09-10 09:38'),
(1, 'sensor-001', 6.5, 56, '2025-09-10 09:39'),
-- 09:40–10:59 (långsam nedgång mot 5–6°C)
(1, 'sensor-001', 6.3, 56, '2025-09-10 09:40'),
(1, 'sensor-001', 6.2, 55, '2025-09-10 09:41'),
(1, 'sensor-001', 6.1, 55, '2025-09-10 09:42'),
(1, 'sensor-001', 6.0, 55, '2025-09-10 09:43'),
(1, 'sensor-001', 5.9, 54, '2025-09-10 09:44'),
(1, 'sensor-001', 5.8, 54, '2025-09-10 09:45'),
(1, 'sensor-001', 5.7, 54, '2025-09-10 09:46'),
(1, 'sensor-001', 5.6, 53, '2025-09-10 09:47'),
(1, 'sensor-001', 5.6, 53, '2025-09-10 09:48'),
(1, 'sensor-001', 5.5, 53, '2025-09-10 09:49'),
(1, 'sensor-001', 5.4, 52, '2025-09-10 09:50'),
(1, 'sensor-001', 5.3, 52, '2025-09-10 09:51'),
(1, 'sensor-001', 5.2, 52, '2025-09-10 09:52'),
(1, 'sensor-001', 5.1, 52, '2025-09-10 09:53'),
(1, 'sensor-001', 5.0, 52, '2025-09-10 09:54'),
(1, 'sensor-001', 5.0, 52, '2025-09-10 09:55'),
(1, 'sensor-001', 5.0, 52, '2025-09-10 09:56'),
(1, 'sensor-001', 5.0, 52, '2025-09-10 09:57'),
(1, 'sensor-001', 5.0, 52, '2025-09-10 09:58'),
(1, 'sensor-001', 5.0, 52, '2025-09-10 09:59'),
(1, 'sensor-001', 5.2, 52, '2025-09-10 10:00'),
(1, 'sensor-001', 5.2, 52, '2025-09-10 10:01'),
(1, 'sensor-001', 5.2, 52, '2025-09-10 10:02'),
(1, 'sensor-001', 5.3, 52, '2025-09-10 10:03'),
(1, 'sensor-001', 5.3, 52, '2025-09-10 10:04'),
(1, 'sensor-001', 5.4, 52, '2025-09-10 10:05'),
(1, 'sensor-001', 5.4, 52, '2025-09-10 10:06'),
(1, 'sensor-001', 5.5, 52, '2025-09-10 10:07'),
(1, 'sensor-001', 5.5, 52, '2025-09-10 10:08'),
(1, 'sensor-001', 5.6, 52, '2025-09-10 10:09'),
(1, 'sensor-001', 5.6, 52, '2025-09-10 10:10'),
(1, 'sensor-001', 5.7, 52, '2025-09-10 10:11'),
(1, 'sensor-001', 5.7, 52, '2025-09-10 10:12'),
(1, 'sensor-001', 5.8, 52, '2025-09-10 10:13'),
(1, 'sensor-001', 5.8, 52, '2025-09-10 10:14'),
(1, 'sensor-001', 5.9, 52, '2025-09-10 10:15'),
(1, 'sensor-001', 5.9, 52, '2025-09-10 10:16'),
(1, 'sensor-001', 6.0, 52, '2025-09-10 10:17'),
(1, 'sensor-001', 6.0, 52, '2025-09-10 10:18'),
(1, 'sensor-001', 6.1, 52, '2025-09-10 10:19'),
(1, 'sensor-001', 6.1, 52, '2025-09-10 10:20'),
(1, 'sensor-001', 6.2, 52, '2025-09-10 10:21'),
(1, 'sensor-001', 6.2, 52, '2025-09-10 10:22'),
(1, 'sensor-001', 6.3, 52, '2025-09-10 10:23'),
(1, 'sensor-001', 6.3, 52, '2025-09-10 10:24'),
(1, 'sensor-001', 6.4, 52, '2025-09-10 10:25'),
(1, 'sensor-001', 6.4, 52, '2025-09-10 10:26'),
(1, 'sensor-001', 6.5, 52, '2025-09-10 10:27'),
(1, 'sensor-001', 6.5, 52, '2025-09-10 10:28'),
(1, 'sensor-001', 6.6, 52, '2025-09-10 10:29'),
(1, 'sensor-001', 6.6, 52, '2025-09-10 10:30'),
(1, 'sensor-001', 6.7, 52, '2025-09-10 10:31'),
(1, 'sensor-001', 6.7, 52, '2025-09-10 10:32'),
(1, 'sensor-001', 6.8, 52, '2025-09-10 10:33'),
(1, 'sensor-001', 6.8, 52, '2025-09-10 10:34'),
(1, 'sensor-001', 6.9, 52, '2025-09-10 10:35'),
(1, 'sensor-001', 6.9, 52, '2025-09-10 10:36'),
(1, 'sensor-001', 7.0, 52, '2025-09-10 10:37'),
-- gå ner mot 5.0 igen
(1, 'sensor-001', 7.0, 52, '2025-09-10 10:38'),
(1, 'sensor-001', 6.8, 52, '2025-09-10 10:39'),
(1, 'sensor-001', 6.8, 52, '2025-09-10 10:40'),
(1, 'sensor-001', 6.7, 52, '2025-09-10 10:41'),
(1, 'sensor-001', 6.7, 52, '2025-09-10 10:42'),
(1, 'sensor-001', 6.6, 52, '2025-09-10 10:43'),
(1, 'sensor-001', 6.6, 52, '2025-09-10 10:44'),
(1, 'sensor-001', 6.5, 52, '2025-09-10 10:45'),
(1, 'sensor-001', 6.5, 52, '2025-09-10 10:46'),
(1, 'sensor-001', 6.4, 52, '2025-09-10 10:47'),
(1, 'sensor-001', 6.4, 52, '2025-09-10 10:48'),
(1, 'sensor-001', 6.3, 52, '2025-09-10 10:49'),
(1, 'sensor-001', 6.3, 52, '2025-09-10 10:50'),
(1, 'sensor-001', 6.2, 52, '2025-09-10 10:51'),
(1, 'sensor-001', 6.2, 52, '2025-09-10 10:52'),
(1, 'sensor-001', 6.1, 52, '2025-09-10 10:53'),
(1, 'sensor-001', 6.1, 52, '2025-09-10 10:54'),
(1, 'sensor-001', 6.0, 52, '2025-09-10 10:55'),
(1, 'sensor-001', 6.0, 52, '2025-09-10 10:56'), 
(1, 'sensor-001', 5.9, 52, '2025-09-10 10:57'),
(1, 'sensor-001', 5.9, 52, '2025-09-10 10:58'),
(1, 'sensor-001', 5.8, 52, '2025-09-10 10:59'),
(1, 'sensor-001', 5.8, 52, '2025-09-10 11:00');

-- Order 2
INSERT INTO "Order" ("RouteId","ExpectedTempId","ExpectedMoistId","TransportId","SenderId","RecipientId")
VALUES (2,2,2,1,1,1);

-- Status
INSERT INTO "OrderStatus" ("OrderId","OrdersequenceId","TimeStamp") VALUES
(2,1,'2025-09-10 08:45'),
(2,2,'2025-09-10 09:15'),
(2,3,'2025-09-10 09:45'),
(2,4,'2025-09-10 11:00');

-- Temperature & Humidity (Rumstemp/Torr)
INSERT INTO "MeasurementTemp" ("OrderId","SensorId","Temp","Humidity","CurrentTime") VALUES
(2,'sensor-001',15.0,10,'2025-09-10 08:45'),
(2,'sensor-001',17.0,15,'2025-09-10 09:15'),
(2,'sensor-001',20.0,20,'2025-09-10 09:45'),
(2,'sensor-001',22.0,25,'2025-09-10 10:15'),
(2,'sensor-001',24.0,28,'2025-09-10 11:00');

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
