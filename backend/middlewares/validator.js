//* VALIDATOR MIDDLEWARE

const Joi = require("joi");

//* <----------- VALIDATION SCHEMAS --------------- >

//* Task Creation Schema
const taskSchema = Joi.object({
  title: Joi.string().required().min(2).max(200).messages({
    "string.empty": "Title is required",
    "string.min": "Title must be at least 3 characters long",
    "string.max": "Title cannot exceed 200 characters",
  }),

  description: Joi.string().allow("", null).max(2000).messages({
    "string.max": "Description cannot exceed 2000 characters",
  }),

  category: Joi.string()
    .valid("scheduling", "finance", "technical", "safety", "general")
    .messages({
      "any.only":
        "Category must be one of: scheduling, finance, technical, safety, general",
    }),

  priority: Joi.string().valid("high", "medium", "low").messages({
    "any.only": "Priority must be one of: high, medium, low",
  }),

  status: Joi.string().valid("pending", "in_progress", "completed").messages({
    "any.only": "Status must be one of: pending, in_progress, completed",
  }),

  assignedTo: Joi.string().allow("", null).max(100),

  dueDate: Joi.date().iso().allow(null).messages({
    "date.format": "Due date must be a valid ISO date string",
  }),

  changedBy: Joi.string().max(100),
});

//* Task Update schema ( All fields are optional )
const taskUpdateSchema = Joi.object({
  title: Joi.string().min(3).max(200).messages({
    "string.min": "Title must be at least 3 characters long",
    "string.max": "Title cannot exceed 200 characters",
  }),

  description: Joi.string().allow("", null).max(2000).messages({
    "string.max": "Description cannot exceed 2000 characters",
  }),

  category: Joi.string()
    .valid("scheduling", "finance", "technical", "safety", "general")
    .messages({
      "any.only":
        "Category must be one of: scheduling, finance, technical, safety, general",
    }),

  priority: Joi.string().valid("high", "medium", "low").messages({
    "any.only": "Priority must be one of: high, medium, low",
  }),

  status: Joi.string().valid("pending", "in_progress", "completed").messages({
    "any.only": "Status must be one of: pending, in_progress, completed",
  }),

  assignedTo: Joi.string().allow("", null).max(100),

  dueDate: Joi.date().iso().allow(null).messages({
    "date.format": "Due date must be a valid ISO date string",
  }),

  changedBy: Joi.string().max(100),
})
  .min(1)
  .messages({
    "object.min": "At least one field must be provided for update",
  });

//* <----------------------- VALIDATION FUNCTIONS ---------------------- >

function validateTask(req, res, next) {
  const { error } = taskSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    const errors = error.details.map((detail) => detail.message);
    return res.status(400).json({
      success: false,
      error: "Validation failed",
      details: errors,
    });
  }

  next();
}

function validateTaskUpdate(req, res, next) {
  const { error } = taskUpdateSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    const errors = error.details.map((detail) => detail.message);
    return res.status(400).json({
      success: false,
      error: "Validation failed",
      details: errors,
    });
  }

  next();
}
function validateUUID(req, res, next) {
  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

  if (!uuidRegex.test(req.params.id)) {
    return res.status(400).json({
      success: false,
      error: "Invalid task ID format",
    });
  }

  next();
}

module.exports = {
  validateTask,
  validateTaskUpdate,
  validateUUID,
};
