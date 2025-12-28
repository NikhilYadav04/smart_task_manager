//* <----- BUSINESS LOGIC FOR TASK MANAGEMENT OPERATIONS -------- >

const prisma = require("../config/database.js");
const { extractEntities } = require("../utils/entityExtractor.js");
const { classifyTask } = require("./classificationService.js");

class TaskService {
  //* create a new task with auto-classification
  async createTask(data) {
    //* Auto classify the task
    const classification = classifyTask(data.title, data.description);
    const entities = extractEntities(`${data.title} ${data.description || ""}`);

    const taskData = {
      title: data.title,
      description: data.description || null,
      category: data.category || classification.category,
      priority: data.priority || classification.priority,
      status: data.status || "pending",
      assignedTo: data.assignedTo || null,
      dueDate: data.dueDate ? new Date(data.dueDate) : null,
      extractedEntities: entities,
      suggestedActions: classification.suggestedActions,
    };

    //* create task and history entry( txn )
    const result = await prisma.$transaction(async (tx) => {
      const task = await tx.task.create({
        data: taskData,
      });

      await tx.taskHistory.create({
        data: {
          taskId: task.id,
          action: "created",
          newValue: taskData,
          changedBy: data.changedBy || "system",
        },
      });

      return task;
    });

    return result;
  }

  //* Get all tasks with filters and pagination
  async getTasks(filters = {}, pagination = {}) {
    const { status, category, priority, search } = filters;
    const {
      limit = 20,
      offset = 0,
      sortBy = "createdAt",
      sortOrder = "desc",
    } = pagination;

    const where = {};

    if (status) where.status = status;
    if (category) where.category = category;
    if (priority) where.priority = priority;

    const [tasks, total] = await Promise.all([
      prisma.task.findMany({
        where,
        skip: parseInt(offset),
        take: parseInt(limit),
        orderBy: { [sortBy]: sortOrder },
      }),
      prisma.task.count({ where }),
    ]);

    return {
      tasks,
      pagination: {
        total,
        limit: parseInt(limit),
        offset: parseInt(offset),
        hasMore: parseInt(offset) + parseInt(limit) < total,
      },
    };
  }

  //* Get tasks by id
  async getTaskById(id) {
    const task = await prisma.task.findUnique({
      where: { id },
      include: {
        history: {
          orderBy: { changedAt: "desc" },
          take: 20,
        },
      },
    });

    return task;
  }

  //* update a task
  async updateTask(id, data, changedBy = "system") {
    const existingTask = await prisma.task.findUnique({ where: { id } });

    if (!existingTask) {
      throw new Error("Task not found");
    }

    //* update due date if provided
    const updateData = { ...data };
    if (updateData.dueDate) {
      updateData.dueDate = new Date(updateData.dueDate);
    }

    //* Remove undefined values ( clearing )
    Object.keys(updateData).forEach((key) => {
      if (updateData[key] === undefined) {
        delete updateData[key];
      }
    });

    const result = await prisma.$transaction(async (tx) => {
      delete updateData.changedBy;
      delete updateData.changed_by;

      const updatedTask = await tx.task.update({
        where: { id },
        data: updateData,
      });

      let action = "updated";
      if (data.status && data.status !== existingTask.status) {
        action = "status_changed";
        if (data.status === "completed") {
          action = "completed";
        }
      }

      await tx.taskHistory.create({
        data: {
          taskId: id,
          action,
          oldValue: existingTask,
          newValue: updateData,
          changedBy: changedBy,
        },
      });

      return updatedTask;
    });

    return result;
  }

  //* Delete a task
  async deleteTask(id) {
    const existingTask = await prisma.task.findUnique({ where: { id } });

    if (!existingTask) {
      throw new Error("Task not found");
    }
    await prisma.task.delete({
      where: { id },
    });

    return { success: true, message: "Task deleted successfully" };
  }

  //* Get task stats
  async getTaskStats() {
    const [
      totalTasks,
      pendingTasks,
      inProgressTasks,
      completedTasks,
      highPriorityTasks,
      tasksByCategory,
    ] = await Promise.all([
      prisma.task.count(),
      prisma.task.count({ where: { status: "pending" } }),
      prisma.task.count({ where: { status: "in_progress" } }),
      prisma.task.count({ where: { status: "completed" } }),
      prisma.task.count({ where: { priority: "high" } }),
      prisma.task.groupBy({
        by: ["category"],
        _count: true,
      }),
    ]);

    return {
      total: totalTasks,
      byStatus: {
        pending: pendingTasks,
        in_progress: inProgressTasks,
        completed: completedTasks,
      },
      highPriority: highPriorityTasks,
      byCategory: tasksByCategory.reduce((acc, item) => {
        acc[item.category] = item._count;
        return acc;
      }, {}),
    };
  }
}

module.exports = new TaskService();
