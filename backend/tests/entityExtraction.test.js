const {
  extractEntities,
  extractDueDate,
} = require("../utils/entityExtractor.js");

describe("Entity Extraction", () => {
  describe("Date Extraction", () => {
    test('should extract "today" and "tomorrow"', () => {
      const entities = extractEntities(
        "Meeting scheduled for today and tomorrow"
      );
      expect(entities.dates).toContain("today");
      expect(entities.dates).toContain("tomorrow");
    });

    test("should extract day of week", () => {
      const entities = extractEntities("Schedule for Monday and Friday");
      expect(entities.dates).toContain("monday");
      expect(entities.dates).toContain("friday");
    });

    test('should extract "this week"', () => {
      const entities = extractEntities("Complete this week");
      expect(entities.dates).toContain("this week");
    });

    test('should extract "next week"', () => {
      const entities = extractEntities("Meeting next week");
      expect(entities.dates).toContain("next week");
    });
  });

  describe("People Extraction", () => {
    test('should extract person name after "with"', () => {
      const entities = extractEntities("Schedule meeting with John Smith");
      expect(entities.people).toContain("John Smith");
    });

    test('should extract person name after "assign to"', () => {
      const entities = extractEntities("Assign to Alice Johnson");
      expect(entities.people).toContain("Alice Johnson");
    });

    test("should extract person name with @ symbol", () => {
      const entities = extractEntities("Contact @Bob Williams for details");
      expect(entities.people).toContain("Bob Williams");
    });
  });

  describe("Action Extraction", () => {
    test("should extract action verbs", () => {
      const entities = extractEntities(
        "Please review and approve the document"
      );
      expect(entities.actions).toContain("review");
      expect(entities.actions).toContain("approve");
    });

    test("should extract multiple actions", () => {
      const entities = extractEntities(
        "Schedule, prepare, and send the report"
      );
      expect(entities.actions).toContain("schedule");
      expect(entities.actions).toContain("prepare");
      expect(entities.actions).toContain("send");
    });
  });

  describe("Empty Text Handling", () => {
    test("should handle empty text gracefully", () => {
      const entities = extractEntities("");
      expect(entities).toEqual({
        dates: [],
        people: [],
        locations: [],
        actions: [],
      });
    });

    test("should handle null text", () => {
      const entities = extractEntities(null);
      expect(entities).toEqual({
        dates: [],
        people: [],
        locations: [],
        actions: [],
      });
    });
  });

  describe("Due Date Extraction", () => {
    test('should extract "today" as due date', () => {
      const date = extractDueDate("Complete today");
      expect(date).toBeInstanceOf(Date);
      expect(date.toDateString()).toBe(new Date().toDateString());
    });

    test("should return null for unrecognized dates", () => {
      const date = extractDueDate("Some random text");
      expect(date).toBeNull();
    });
  });
});
