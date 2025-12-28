//* < --------- Handles automatic task categorization, priority detection, and action suggestions --- >

//* Keyword mappings for category detection
const CATEGORY_KEYWORDS = {
  scheduling: [
    "meeting",
    "schedule",
    "call",
    "appointment",
    "deadline",
    "calendar",
    "book",
    "reserve",
    "plan",
    "arrange",
    "coordinate",
  ],
  finance: [
    "payment",
    "invoice",
    "bill",
    "budget",
    "cost",
    "expense",
    "purchase",
    "vendor",
    "payroll",
    "reimbursement",
    "quote",
    "price",
  ],
  technical: [
    "bug",
    "fix",
    "error",
    "install",
    "repair",
    "maintain",
    "update",
    "server",
    "system",
    "network",
    "software",
    "hardware",
    "deploy",
    "patch",
    "upgrade",
    "debug",
  ],
  safety: [
    "safety",
    "hazard",
    "inspection",
    "compliance",
    "ppe",
    "incident",
    "risk",
    "accident",
    "injury",
    "emergency",
    "protocol",
    "violation",
    "audit",
  ],
};

//* Priority keywords
const PRIORITY_KEYWORDS = {
  high: [
    "urgent",
    "asap",
    "immediately",
    "today",
    "critical",
    "emergency",
    "now",
    "blocker",
    "high priority",
    "crucial",
  ],
  medium: [
    "soon",
    "this week",
    "important",
    "priority",
    "tomorrow",
    "upcoming",
    "moderate",
  ],
};

//* Suggested actions by category
const SUGGESTED_ACTIONS = {
  scheduling: [
    "Block calendar",
    "Send invite",
    "Prepare agenda",
    "Set reminder",
    "Confirm attendance",
    "Book meeting room",
  ],
  finance: [
    "Check budget",
    "Get approval",
    "Generate invoice",
    "Update records",
    "Verify amount",
    "Process payment",
  ],
  technical: [
    "Diagnose issue",
    "Check resources",
    "Assign technician",
    "Document fix",
    "Test solution",
    "Deploy changes",
  ],
  safety: [
    "Conduct inspection",
    "File report",
    "Notify supervisor",
    "Update checklist",
    "Review procedures",
    "Train staff",
  ],
  general: [
    "Review task",
    "Assign owner",
    "Set deadline",
    "Add details",
    "Track progress",
    "Document outcome",
  ],
};

//* CLassify task category based on content
function classifyCategory(text) {
  if (!text) return "general";

  const lowerText = text.toLowerCase();
  const scores = {};

  //* calculate score for each category ( best score will decide category )
  for (const [category, keywords] of Object.entries(CATEGORY_KEYWORDS)) {
    scores[category] = 0;
    for (const keyword of keywords) {
      if (lowerText.includes(keyword)) {
        scores[category]++;
      }
    }
  }

  //* Find category with highest score
  let maxScore = 0;
  let bestCategory = "general";

  for (const [category, score] of Object.entries(scores)) {
    if (score > maxScore) {
      maxScore = score;
      bestCategory = category;
    }
  }

  return bestCategory;
}

//* Determine task priority based on content
function determinePriority(text) {
  if (!text) return "low";

  const lowerText = text.toLowerCase();

  //* Check high priority first
  for (const keyword of PRIORITY_KEYWORDS.high) {
    if (lowerText.includes(keyword)) {
      return "high";
    }
  }

  //* Then medium
  for (const keyword of PRIORITY_KEYWORDS.medium) {
    if (lowerText.includes(keyword)) {
      return "medium";
    }
  }

  return "low";
}

//* Get suggestions based on memory
function getSuggestedActions(category) {
  return SUGGESTED_ACTIONS[category] || SUGGESTED_ACTIONS.general;
}

//* Main classification function ( combines all above functions )
function classifyTask(title, description = "") {
  const combinedText = `${title} ${description}`;

  const category = classifyCategory(combinedText);
  const priority = determinePriority(combinedText);
  const suggestedActions = getSuggestedActions(category);

  return {
    category,
    priority,
    suggestedActions,
  };
}

module.exports = {
  classifyTask,
  classifyCategory,
  determinePriority,
  getSuggestedActions,
  CATEGORY_KEYWORDS,
  PRIORITY_KEYWORDS,
  SUGGESTED_ACTIONS,
};
