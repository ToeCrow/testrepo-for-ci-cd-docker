import express from 'express';
import pkg from 'pg';
import cors from 'cors';

const { Pool } = pkg;

const app = express();
const port = 3000;

app.use(cors());

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
          et."Min" AS "ExpectedTempMin",
          et."Max" AS "ExpectedTempMax",
          em."Min" AS "ExpectedHumidityMin",
          em."Max" AS "ExpectedHumidityMax",
          t."Name" AS "Transport",
          s."Name" AS "SenderName",
          rec."Name" AS "RecipientName",
          os."Status",
          os."TimeStamp" AS "StatusTime",
          mt."Temp" AS "CurrentTemp",
          mt."Humidity" AS "CurrentHumidity",
          tor."TimeMinutes" AS "TimeOutsideRange"
      FROM "Order" o
      LEFT JOIN "Route" r ON o."RouteId" = r."Id"
      LEFT JOIN "expectedTemp" et ON o."ExpectedTempId" = et."Id"
      LEFT JOIN "expectedMoist" em ON o."ExpectedMoistId" = em."Id"
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
