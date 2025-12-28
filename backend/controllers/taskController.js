const { classifyTask } = require("../services/classificationService.js");
const taskService = require("../services/taskService.js");
const { extractEntities } = require("../utils/entityExtractor.js");

class TaskController {
  //* Create a task
  async createTask(req, res, next) {
    try {
      const task = await taskService.createTask(req.body);

      res.status(201).json({
        success: true,
        message: "Task created successfully",
        data: task,
      });
    } catch (error) {
      next(error);
    }
  }

  //* Get tasks with filters
  async getTasks(req, res, next) {
    try {
      const filters = {
        status: req.query.status,
        category: req.query.category,
        priority: req.query.priority,
        search: req.query.search,
      };

      const pagination = {
        limit: req.query.limit || 20,
        offset: req.query.offset || 0,
        sortBy: req.query.sortBy || "createdAt",
        sortOrder: req.query.sortOrder || "desc",
      };

      const result = await taskService.getTasks(filters, pagination);

      res.json({
        success: true,
        data: result.tasks,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  }

  //* get tasks by id
  async getTaskById(req, res, next) {
    try {
      const task = await taskService.getTaskById(req.params.id);

      if (!task) {
        return res.status(404).json({
          success: false,
          error: "Task not found",
        });
      }

      res.json({
        success: true,
        data: task,
      });
    } catch (error) {
      next(error);
    }
  }

  //* update task
  async updateTask(req, res, next) {
    try {
      const task = await taskService.updateTask(
        req.params.id,
        req.body,
        req.body.changedBy || "system"
      );

      res.json({
        success: true,
        message: "Task updated successfully",
        data: task,
      });
    } catch (error) {
      if (error.message === "Task not found") {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  //* delete task
  async deleteTask(req, res, next) {
    try {
      const result = await taskService.deleteTask(req.params.id);

      res.json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      if (error.message === "Task not found") {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  //* get task stats
  async getStats(req, res, next) {
    try {
      const stats = await taskService.getTaskStats();

      res.json({
        success: true,
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }

  //* preview auto-generated classification, categories before saving
  async previewClassification(req, res, next) {
    try {
      const { title, description } = req.body;

      if (!title) {
        return res.status(400).json({
          success: false,
          error: "Title is required",
        });
      }

      const classification = classifyTask(title, description);
      const entities = extractEntities(`${title} ${description || ""}`);

      res.json({
        success: true,
        data: {
          ...classification,
          extractedEntities: entities,
        },
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new TaskController();
