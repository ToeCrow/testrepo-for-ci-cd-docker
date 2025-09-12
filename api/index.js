import express from 'express';
import pkg from 'pg';
import cors from 'cors';

const { Pool } = pkg;

const app = express();
const port = 3000;

const allowedOrigin = [
  "http://localhost:5173",
  "https://app.trackapp.se"  //placeholder for actual domain
];

app.use(cors({
  origin: (origin, callback) => {
    // Tillåt mobilklienter & server-to-server (ingen origin header)
    if (!origin) return callback(null, true);

    if (origin === allowedOrigin) {
      // Helt okej
      return callback(null, true);
    }

    // Om det är en annan 517x-port → ge ett specifikt meddelande
    if (origin.startsWith("http://localhost:517")) {
      return callback(new Error("⚠️ Kör dev på port 5173, inte " + origin));
    }

    // Allt annat → blockeras
    return callback(new Error("❌ Origin not allowed: " + origin));
  }
}));


const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});


// GET /orders
app.get('/orders', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
    o."Id" AS "OrderId",
    r."Name" AS "RouteName",
    r."Code" AS "RouteCode",
    o."Id" AS "Sändningsnr",

    -- Expected Temp som objekt
    json_build_object(
        'min', et."Min",
        'max', et."Max"
    ) AS "expectedTemp",

    -- Current Temp (senaste mätningen)
    mt."Temp" AS "currentTemp",

    -- Min/Max Temp från alla mätningar
    MIN(mt."Temp") OVER (PARTITION BY o."Id") AS "minTempMeasured",
    MAX(mt."Temp") OVER (PARTITION BY o."Id") AS "maxTempMeasured",

    -- Expected Humidity som objekt
    json_build_object(
        'min', em."Min",
        'max', em."Max"
    ) AS "expectedHumidity",

    -- Current Humidity (senaste mätningen)
    mt."Humidity" AS "currentHumidity",

    -- Min/Max Humidity från alla mätningar
    MIN(mt."Humidity") OVER (PARTITION BY o."Id") AS "minHumidityMeasured",
    MAX(mt."Humidity") OVER (PARTITION BY o."Id") AS "maxHumidityMeasured",

    -- Time outside range
    tor."TimeMinutes" AS "timeOutsideRange",

    -- Status som objekt
    json_build_object(
        'text', os."Status",
        'timestamp', os."TimeStamp"
    ) AS "status"

FROM "Order" o
LEFT JOIN "Route" r ON o."RouteId" = r."Id"
LEFT JOIN "ExpectedTemp" et ON o."ExpectedTempId" = et."Id"
LEFT JOIN "ExpectedMoist" em ON o."ExpectedMoistId" = em."Id"
LEFT JOIN "Transport" t ON o."TransportId" = t."Id"
LEFT JOIN "Sender" s ON o."SenderId" = s."Id"
LEFT JOIN "Recipient" rec ON o."RecipientId" = rec."Id"
LEFT JOIN "OrderStatus" os ON o."Id" = os."OrderId"
LEFT JOIN "MeasurementTemp" mt ON o."Id" = mt."OrderId"
LEFT JOIN "TimeOutsideRange" tor ON o."Id" = tor."OrderId"
ORDER BY o."Id";


    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
