const {
  classifyCategory,
  determinePriority,
  classifyTask,
  getSuggestedActions,
} = require("../services/classificationService");

describe("Classification Service", () => {
  describe("Category Classification", () => {
    test("should classify scheduling task correctly", () => {
      const category = classifyCategory("Schedule urgent meeting with team");
      expect(category).toBe("scheduling");
    });

    test("should classify finance task correctly", () => {
      const category = classifyCategory("Process invoice payment for vendor");
      expect(category).toBe("finance");
    });

    test("should classify technical task correctly", () => {
      const category = classifyCategory("Fix bug in production server");
      expect(category).toBe("technical");
    });

    test("should classify safety task correctly", () => {
      const category = classifyCategory("Conduct safety inspection on site");
      expect(category).toBe("safety");
    });

    test("should default to general for unrecognized tasks", () => {
      const category = classifyCategory("Random task with no keywords");
      expect(category).toBe("general");
    });

    test("should handle empty text", () => {
      const category = classifyCategory("");
      expect(category).toBe("general");
    });
  });
});

describe("Priority Determination", () => {
  test("should determine high priority correctly", () => {
    const priority = determinePriority("This is urgent and critical");
    expect(priority).toBe("high");
  });

  test("should determine medium priority correctly", () => {
    const priority = determinePriority("Complete this soon this week");
    expect(priority).toBe("medium");
  });

  test("should default to low priority", () => {
    const priority = determinePriority("Regular task without urgency");
    expect(priority).toBe("low");
  });

  test('should detect "today" as high priority', () => {
    const priority = determinePriority("Need this done today");
    expect(priority).toBe("high");
  });

  test('should detect "asap" as high priority', () => {
    const priority = determinePriority("Please complete asap");
    expect(priority).toBe("high");
  });

  test("should handle empty text", () => {
    const priority = determinePriority("");
    expect(priority).toBe("low");
  });
});

describe("Suggested Actions", () => {
  test("should return correct actions for scheduling", () => {
    const actions = getSuggestedActions("scheduling");
    expect(actions).toContain("Block calendar");
    expect(actions).toContain("Send invite");
  });

  test("should return correct actions for finance", () => {
    const actions = getSuggestedActions("finance");
    expect(actions).toContain("Check budget");
    expect(actions).toContain("Get approval");
  });

  test("should return general actions for unknown category", () => {
    const actions = getSuggestedActions("unknown");
    expect(actions).toContain("Review task");
  });

  describe("Full Task Classification", () => {
    test("should classify complete task correctly", () => {
      const result = classifyTask(
        "Schedule urgent meeting today",
        "Need to discuss budget allocation with team"
      );

      expect(result.category).toBe("scheduling");
      expect(result.priority).toBe("high");
      expect(result.suggestedActions).toContain("Block calendar");
      expect(Array.isArray(result.suggestedActions)).toBe(true);
    });

    test("should work with title only", () => {
      const result = classifyTask("Fix critical server bug");

      expect(result.category).toBe("technical");
      expect(result.priority).toBe("high");
      expect(result.suggestedActions).toContain("Diagnose issue");
    });

    test("should handle finance task with medium priority", () => {
      const result = classifyTask("Process invoice payment soon");

      expect(result.category).toBe("finance");
      expect(result.priority).toBe("medium");
    });
  });
});
