//* ERROR HANDLING MIDDLEWARE

function errorHandler(err, req, res, next) {
  console.error("Error occurred:", {
    message: err.message,
    path: req.path,
    method: req.method,
  });

  //* Prisma-specific errors
  if (err.code) {
    return handlePrismaError(err, res);
  }

  //* Validation errors
  if (err.name === "ValidationError") {
    return res.status(400).json({
      success: false,
      error: "Validation failed",
      details: err.message,
    });
  }

  const statusCode = err.statusCode || err.status || 500;
  const message = err.message || "Internal server error";

  res.status(statusCode).json({
    success: false,
    error: message,
  });
}

//* HANDLE PRISMA ERRORS

function handlePrismaError(err, res) {
  switch (err.code) {
    case "P2002":
      //* Unique constraint violation
      return res.status(409).json({
        success: false,
        error: "A record with this unique field already exists",
        field: err.meta?.target,
      });

    case "P2025":
      //* Record not found
      return res.status(404).json({
        success: false,
        error: "Record not found",
      });

    case "P2003":
      //* Foreign key constraint violation
      return res.status(400).json({
        success: false,
        error: "Related record not found",
        field: err.meta?.field_name,
      });

    case "P2014":
      //* Invalid ID
      return res.status(400).json({
        success: false,
        error: "Invalid ID provided",
      });

    default:
      //* Generic Prisma error
      return res.status(500).json({
        success: false,
        error: "Database error occurred",
        ...(process.env.NODE_ENV === "development" && { details: err.message }),
      });
  }
}

//* NOT FOUND ( 404 ) HANDLER
function notFoundHandler(req, res) {
  res.status(404).json({
    success: false,
    error: "Route not found",
    path: req.path,
  });
}

module.exports = {
  errorHandler,
  notFoundHandler,
};
