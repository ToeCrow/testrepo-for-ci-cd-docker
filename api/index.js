import express from "express";
import pkg from "pg";
import cors from "cors";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "superhemligt";

const { Pool } = pkg;
const app = express();
app.use(express.json());

const port = process.env.PORT || 8080;

app.use(cors({
  origin: "http://trackapp-frontend.s3-website.eu-north-1.amazonaws.com",
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));



function authenticateToken(req, res, next) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

function authorizeRole(role) {
  return (req, res, next) => {
    if (req.user.role !== role) return res.sendStatus(403);
    next();
  };
}

// ---- Databasanslutning ----
const pool = new Pool({
  user: process.env.POSTGRES_USER || "postgres",
  host: process.env.POSTGRES_HOST || "trackapp-db.cfmqcwquqry6.eu-north-1.rds.amazonaws.com",
  database: process.env.POSTGRES_DB || "trackapp",
  password: process.env.POSTGRES_PASSWORD || "postgres",
  port: Number(process.env.POSTGRES_PORT) || 5432,
  ssl:
    process.env.NODE_ENV === "production"
      ? { rejectUnauthorized: false } // krävs för RDS
      : false, // ingen SSL lokalt
});

// LOGIN route
app.post("/login", async (req, res) => {
  const { username, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM "User" WHERE "Username" = $1', [username]);
    const user = result.rows[0];

    if (!user) return res.status(401).json({ message: "User not found" });

    const isMatch = await bcrypt.compare(password, user.PasswordHash);
    if (!isMatch) return res.status(401).json({ message: "Invalid password" });

    const token = jwt.sign(
      {
        sub: user.Id,
        username: user.Username,
        role: user.Role,
      },
      JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get("/admin/data", authenticateToken, authorizeRole("Admin"), (req, res) => {
  res.json({ secret: "Detta är hemligt admininnehåll!" });
});


// ---- Testroute ----
app.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json({ status: "ok", db_time: result.rows[0].now });
  } catch (err) {
    console.error("DB connection failed:", err);
    res.status(500).json({ error: "DB connection failed" });
  }
});

// ---- /orders ----
app.get("/orders", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        o."Id" AS "id",
        o."Id" AS "sändningsnr",
        r."Code" AS "rutt",
        json_build_object('name', et."Name", 'min', et."Min"::FLOAT, 'max', et."Max"::FLOAT) AS "expectedTemp",
        COALESCE(mt."Temp"::FLOAT, 0) AS "currentTemp",
        COALESCE(mt."Humidity"::FLOAT, 0) AS "currentHumidity",
        COALESCE(MIN(mtemp."Temp")::FLOAT, 0) AS "minTempMeasured",
        COALESCE(MAX(mtemp."Temp")::FLOAT, 0) AS "maxTempMeasured",
        COALESCE(MIN(mtemp."Humidity")::FLOAT, 0) AS "minHumidityMeasured",
        COALESCE(MAX(mtemp."Humidity")::FLOAT, 0) AS "maxHumidityMeasured",
        json_build_object('name', em."Name", 'min', em."Min"::FLOAT, 'max', em."Max"::FLOAT) AS "expectedHumidity",
        COALESCE(tor."TimeMinutes", 0) AS "timeOutsideRange",
        json_build_object('text', os."StatusName", 'timestamp', os."TimeStamp") AS "status",
        json_build_object('id', t."Id", 'name', t."Name") AS "transport",
        json_build_object('id', s."Id", 'name', s."Name") AS "sender"
      FROM "Order" o
      LEFT JOIN "Route" r ON o."RouteId" = r."Id"
      LEFT JOIN "ExpectedTemp" et ON o."ExpectedTempId" = et."Id"
      LEFT JOIN "ExpectedMoist" em ON o."ExpectedMoistId" = em."Id"
      LEFT JOIN "TimeOutsideRange" tor ON o."Id" = tor."OrderId"
      LEFT JOIN (
        SELECT os1."OrderId", os1."TimeStamp", seq."Name" AS "StatusName"
        FROM "OrderStatus" os1
        JOIN "OrderSequence" seq ON os1."OrdersequenceId" = seq."Id"
        WHERE os1."Id" IN (
          SELECT MAX("Id") FROM "OrderStatus" GROUP BY "OrderId"
        )
      ) os ON o."Id" = os."OrderId"
      LEFT JOIN (
        SELECT mt1."OrderId", mt1."Temp", mt1."Humidity"
        FROM "MeasurementTemp" mt1
        WHERE mt1."Id" IN (
          SELECT MAX("Id") FROM "MeasurementTemp" GROUP BY "OrderId"
        )
      ) mt ON o."Id" = mt."OrderId"
      LEFT JOIN "MeasurementTemp" mtemp ON o."Id" = mtemp."OrderId"
      LEFT JOIN "Transport" t ON o."TransportId" = t."Id"
      LEFT JOIN "Sender" s ON o."SenderId" = s."Id"
      GROUP BY
        o."Id", r."Code",
        et."Name", et."Min", et."Max",
        em."Name", em."Min", em."Max",
        mt."Temp", mt."Humidity",
        tor."TimeMinutes",
        os."StatusName", os."TimeStamp",
        t."Id", t."Name",
        s."Id", s."Name"
      ORDER BY o."Id";
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching orders:", err);
    res.status(500).json({ error: "Serverfel vid hämtning av ordrar" });
  }
});

// ---- /order/:sändningsnr ----
app.get("/order/:sändningsnr", async (req, res) => {
  const { sändningsnr } = req.params;

  try {
    const client = await pool.connect();

    const orderQuery = `
      SELECT
        o."Id",
        o."Id" AS "sändningsnr",
        r."Name" AS "rutt",
        et."Name" AS "expectedTempName",
        et."Min" AS "expectedTempMin",
        et."Max" AS "expectedTempMax",
        em."Name" AS "expectedHumidityName",
        em."Min" AS "expectedHumidityMin",
        em."Max" AS "expectedHumidityMax",
        t."Name" AS "transportName",
        s."Name" AS "senderName",
        s."Adress1" AS "senderAddress",
        sp."Postnummer" AS "senderPostcode",
        sp."Postadress" AS "senderCity",
        rcp."Name" AS "recipientName",
        rcp."Adress1" AS "recipientAddress",
        rp."Postnummer" AS "recipientPostcode",
        rp."Postadress" AS "recipientCity"
      FROM "Order" o
      LEFT JOIN "Route" r ON o."RouteId" = r."Id"
      LEFT JOIN "ExpectedTemp" et ON o."ExpectedTempId" = et."Id"
      LEFT JOIN "ExpectedMoist" em ON o."ExpectedMoistId" = em."Id"
      LEFT JOIN "Transport" t ON o."TransportId" = t."Id"
      LEFT JOIN "Sender" s ON o."SenderId" = s."Id"
      LEFT JOIN "Postadress" sp ON s."PostadressId" = sp."Id"
      LEFT JOIN "Recipient" rcp ON o."RecipientId" = rcp."Id"
      LEFT JOIN "Postadress" rp ON rcp."PostadressId" = rp."Id"
      WHERE o."Id" = $1
    `;
    const orderResult = await client.query(orderQuery, [sändningsnr]);

    if (orderResult.rowCount === 0) {
      client.release();
      return res.status(404).json({ message: "Order not found" });
    }

    const order = orderResult.rows[0];

    const statusResult = await client.query(
      `
      SELECT os."TimeStamp", osq."Name" AS "statusText"
      FROM "OrderStatus" os
      JOIN "OrderSequence" osq ON os."OrdersequenceId" = osq."Id"
      WHERE os."OrderId" = $1
      ORDER BY os."TimeStamp" ASC
    `,
      [sändningsnr]
    );

    const measurementsResult = await client.query(
      `
      SELECT "Temp", "Humidity", "CurrentTime"
      FROM "MeasurementTemp"
      WHERE "OrderId" = $1
      ORDER BY "CurrentTime" ASC
    `,
      [sändningsnr]
    );

    const timeOutsideResult = await client.query(
      `
      SELECT "TimeMinutes"
      FROM "TimeOutsideRange"
      WHERE "OrderId" = $1
    `,
      [sändningsnr]
    );

    client.release();

    const response = {
      id: order.Id,
      sändningsnr: order.sändningsnr,
      rutt: order.rutt,
      expectedTemp: {
        name: order.expectedTempName,
        min: order.expectedTempMin,
        max: order.expectedTempMax,
      },
      expectedHumidity: {
        name: order.expectedHumidityName,
        min: order.expectedHumidityMin,
        max: order.expectedHumidityMax,
      },
      transport: { name: order.transportName },
      sender: {
        name: order.senderName,
        address: order.senderAddress,
        postcode: order.senderPostcode,
        city: order.senderCity,
      },
      recipient: {
        name: order.recipientName,
        address: order.recipientAddress,
        postcode: order.recipientPostcode,
        city: order.recipientCity,
      },
      status: statusResult.rows.map((s) => ({
        text: s.statusText,
        timestamp: s.TimeStamp,
      })),
      measurements: measurementsResult.rows.map((m) => ({
        temp: m.Temp,
        humidity: m.Humidity,
        timestamp: m.CurrentTime,
      })),
      timeOutsideRange: timeOutsideResult.rows[0]?.TimeMinutes || 0,
    };

    return res.json(response);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: "Internal server error" });
  }
});

// ---- POST /orders/:orderId/next-status ----
app.post("/orders/:orderId/next-status", async (req, res) => {
  const { orderId } = req.params;

  try {
    const orderCheck = await pool.query(
      `SELECT 1 FROM "Order" WHERE "Id" = $1`,
      [orderId]
    );

    if (orderCheck.rowCount === 0) {
      return res.status(404).json({ message: "Order not found" });
    }

    const currentStatusResult = await pool.query(
      `SELECT MAX(os."OrdersequenceId") AS current_sequence
       FROM "OrderStatus" os
       WHERE os."OrderId" = $1`,
      [orderId]
    );

    const currentSequence = currentStatusResult.rows[0].current_sequence || 0;

    const nextStatusResult = await pool.query(
      `SELECT "Id", "Name"
       FROM "OrderSequence"
       WHERE "sequence" > $1
       ORDER BY "sequence" ASC
       LIMIT 1`,
      [currentSequence]
    );

    if (nextStatusResult.rowCount === 0) {
      return res
        .status(400)
        .json({ message: "Order is already at the final status" });
    }

    const nextStatus = nextStatusResult.rows[0];

    const insertResult = await pool.query(
      `INSERT INTO "OrderStatus" ("OrderId", "OrdersequenceId", "TimeStamp")
       VALUES ($1, $2, CURRENT_TIMESTAMP)
       RETURNING *`,
      [orderId, nextStatus.Id]
    );

    res.json({ message: "Next status added", status: insertResult.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// ---- Starta servern ----
app.listen(port, "0.0.0.0", () => {
  console.log(`✅ Server running on port ${port}`);
});
