require("dotenv").config();
const express = require("express");
const cors = require("cors");
const taskRoute = require('./routes/taskRoutes.js');
const { notFoundHandler, errorHandler } = require("./middlewares/errorHandler.js");

const app = express();
const PORT = process.env.PORT || 3000;

//* Middle ware

//* Cors Configuration
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*",
    credentials: true,
  })
);

//* Body parser
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

//* Logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

//* < ------------- ROUTES ---------------------->

//* Health check
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    message: "Server Health is OK",
  });
});

//* root endpoint
app.get("/", (req, res) => {
  res.json({
    message: "Smart Task Manager API",
  });
});

app.use('/api', taskRoute);

//* < ---------------- ERROR HANDLING -------------->

app.use(notFoundHandler);

app.use(errorHandler);

//* < -------------- SERVER ----------------------- >

//* server initialization and shutdown
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

//* handle shutdown

process.on("SIGTERM", () => {
  console.log("SIGTERM signal received: closing HTTP server");
  server.close(() => {
    console.log("HTTP server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  console.log("\nSIGINT signal received: closing HTTP server");
  server.close(() => {
    console.log("HTTP server closed");
    process.exit(0);
  });
});

module.exports = app;
