//* mock prisma
jest.mock("../config/prisma", () => ({
  task: {
    create: jest.fn(),
    findMany: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    aggregate: jest.fn(),
  },
  $disconnect: jest.fn(),
}));

const taskService = require("../services/taskService");

describe("Task Service Structure", () => {
  test("should have createTask method", () => {
    expect(typeof taskService.createTask).toBe("function");
  });

  test("should have getTasks method", () => {
    expect(typeof taskService.getTasks).toBe("function");
  });

  test("should have getTaskById method", () => {
    expect(typeof taskService.getTaskById).toBe("function");
  });

  test("should have updateTask method", () => {
    expect(typeof taskService.updateTask).toBe("function");
  });

  test("should have deleteTask method", () => {
    expect(typeof taskService.deleteTask).toBe("function");
  });

  test("should have getTaskStats method", () => {
    expect(typeof taskService.getTaskStats).toBe("function");
  });
});
