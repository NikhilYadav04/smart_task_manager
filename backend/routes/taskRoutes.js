const express = require("express");
const taskController = require("../controllers/taskController.js");
const { validateUUID, validateTask, validateTaskUpdate } = require("../middlewares/validator.js");
const router = express.Router();

//* Get Task Stats
router.get("/tasks/stats", taskController.getStats);

//* Create a new task with auto-classification
router.post("/tasks", validateTask, taskController.createTask);

//* Get all tasks with filters and pagination
router.get("/tasks", taskController.getTasks);

//* Get single task by ID with history
router.get("/tasks/:id", validateUUID, taskController.getTaskById);

//* Update task
router.patch(
  "/tasks/:id",
  validateUUID,
  validateTaskUpdate,
  taskController.updateTask
);

//* Delete task
router.delete("/tasks/:id", validateUUID, taskController.deleteTask);

//* Classification preview before saving
router.post("/tasks/classify", taskController.previewClassification);

module.exports = router;
