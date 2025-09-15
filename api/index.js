import express from 'express';
import pkg from 'pg';
import cors from 'cors';

const { Pool } = pkg;

const app = express();
const port = 3000;

const allowedOrigin = [
  "http://localhost:5173",
  "https://app.trackapp.se"  // placeholder för prod
];

app.use(cors({
  origin: (origin, callback) => {
    // Ingen origin = server-till-server eller mobilclient → tillåt
    if (!origin) return callback(null, true);

    // Om origin finns i listan → tillåt
    if (allowedOrigin.includes(origin)) {
      return callback(null, true);
    }

    // Om origin är localhost på fel 517x-port → ge tydligt meddelande
    if (origin.startsWith("http://localhost:517")) {
      return callback(new Error("⚠️ Kör dev på port 5173, inte " + origin));
    }

    // Alla andra → blockeras
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
          o."Id" AS "sändningsnr",
          r."Code" AS "rutt",

          -- Expected Temp som objekt
          json_build_object(
              'min', et."Min"::FLOAT, 
              'max', et."Max"::FLOAT
          ) AS "expectedTemp",

          -- Current Temp & Humidity (senaste mätningen)
          COALESCE(mt."Temp"::FLOAT, 0) AS "currentTemp",
          COALESCE(mt."Humidity"::FLOAT, 0) AS "currentHumidity",

          -- Min/Max Temp & Humidity från alla mätningar
          COALESCE(MIN(mtemp."Temp")::FLOAT, 0) AS "minTempMeasured",
          COALESCE(MAX(mtemp."Temp")::FLOAT, 0) AS "maxTempMeasured",
          COALESCE(MIN(mtemp."Humidity")::FLOAT, 0) AS "minHumidityMeasured",
          COALESCE(MAX(mtemp."Humidity")::FLOAT, 0) AS "maxHumidityMeasured",

          -- Expected Humidity som objekt
          json_build_object(
              'min', em."Min"::FLOAT, 
              'max', em."Max"::FLOAT
          ) AS "expectedHumidity",

          -- Time outside range
          COALESCE(tor."TimeMinutes", 0) AS "timeOutsideRange",

          -- Status som objekt (senaste status eller default "Mottagen")
          json_build_object(
              'text', COALESCE(os."Status", 'Mottagen'),
              'timestamp', COALESCE(os."TimeStamp", CURRENT_TIMESTAMP)
          ) AS "status",

          -- Transport som objekt
          json_build_object(
              'id', t."Id",
              'name', t."Name"
          ) AS "transport",

          -- Sender som objekt
          json_build_object(
              'id', s."Id",
              'name', s."Name",
              'adress1', s."Adress1"
          ) AS "sender"

      FROM "Order" o
      LEFT JOIN "Route" r ON o."RouteId" = r."Id"
      LEFT JOIN "ExpectedTemp" et ON o."ExpectedTempId" = et."Id"
      LEFT JOIN "ExpectedMoist" em ON o."ExpectedMoistId" = em."Id"
      LEFT JOIN "TimeOutsideRange" tor ON o."Id" = tor."OrderId"

      -- Senaste mätningen
      LEFT JOIN (
          SELECT *
          FROM (
              SELECT *,
                    ROW_NUMBER() OVER (PARTITION BY "OrderId" ORDER BY "CurrentTime" DESC) AS rn
              FROM "MeasurementTemp"
          ) sub
          WHERE rn = 1
      ) mt ON o."Id" = mt."OrderId"

      -- Alla mätningar för min/max
      LEFT JOIN "MeasurementTemp" mtemp ON o."Id" = mtemp."OrderId"

      -- Senaste status
      LEFT JOIN (
          SELECT *
          FROM (
              SELECT *,
                    ROW_NUMBER() OVER (PARTITION BY "OrderId" ORDER BY "TimeStamp" DESC) AS rn
              FROM "OrderStatus"
          ) sub
          WHERE rn = 1
      ) os ON o."Id" = os."OrderId"

      -- Transport och Sender
      LEFT JOIN "Transport" t ON o."TransportId" = t."Id"
      LEFT JOIN "Sender" s ON o."SenderId" = s."Id"

      GROUP BY 
          o."Id", r."Code", et."Min", et."Max", em."Min", em."Max",
          mt."Temp", mt."Humidity", tor."TimeMinutes",
          os."Status", os."TimeStamp",
          t."Id", t."Name",
          s."Id", s."Name", s."Adress1"

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
