
# TrackApp Mock API

Detta repo innehåller ett mock-API med PostgreSQL som backend för TrackApp.  
Frontend-utvecklare kan använda detta för att hämta mockdata via [http://localhost:3000/orders](http://localhost:3000/orders).

---

## Förutsättningar

- [Docker](https://www.docker.com/get-started) installerat
- [Docker Compose](https://docs.docker.com/compose/install/) installerat

---

## Projektstruktur

```

.
├── api
│   ├── Dockerfile
│   ├── index.js
│   ├── package.json
│   └── package-lock.json
├── docker-compose.yml
├── init.sql
└── .gitignore

````

- **api/** – Node.js/Express API  
- **init.sql** – Initiering av databasen med tabeller och mockdata  
- **docker-compose.yml** – Konfiguration av databasen och API  
- **.gitignore** – ignorerar `node_modules` och andra filer

---

## Starta mock-API

1. **Stoppa alla tidigare containrar och rensa databasen**:

```bash
docker-compose down -v
````

2. **Bygg om API och DB utan cache**:

```bash
docker-compose build --no-cache
```

3. **Starta containrar i bakgrunden**:

```bash
docker-compose up -d
```

4. **Kontrollera att API\:t körs**:

```bash
docker-compose logs -f api
```

Du ska se:

```
API listening on port 3000
```

5. **Testa API i webbläsare eller Postman**:

Öppna: [http://localhost:3000/orders](http://localhost:3000/orders)

Exempel på JSON-respons:

```json
[
  {
    "OrderId": 1,
    "RouteName": "Stockholm",
    "RouteCode": "STO",
    "Sändningsnr": 123456,
    "ExpectedTempMin": 2,
    "ExpectedTempMax": 8,
    "ExpectedHumidityMin": 30,
    "ExpectedHumidityMax": 70,
    "Transport": "Transport Name",
    "SenderName": "Sender Name",
    "RecipientName": "Recipient Name",
    "Status": "Skapad",
    "StatusTime": "2025-09-10T08:30:00.000Z",
    "CurrentTemp": 5.0,
    "CurrentHumidity": 55,
    "TimeOutsideRange": 0
  }
]
```

---

## Stoppa allt

När du är klar:

```bash
docker-compose down
```

---

## Tips

* Om du vill ändra mockdata, redigera `init.sql` och kör om steg 1–3.
* Allt körs lokalt i Docker-containrar – ingen extern server behövs.
* API och databas körs i separata containrar.

```

## Snabbguide: Starta API och databas

Följ dessa kommandon i terminalen (från projektets root):

```bash
# 1. Stoppa alla tidigare containrar och rensa volymer (tömmer databasen)
docker-compose down -v

# 2. Bygg om API och databas utan cache
docker-compose build --no-cache

# 3. Starta containrar i bakgrunden
docker-compose up -d

# 4. Kontrollera att API:t körs
docker-compose logs -f api

# 5. Testa API i webbläsare eller Postman
# Öppna: http://localhost:3000/orders

# 6. Stoppa allt när du är klar
docker-compose down

