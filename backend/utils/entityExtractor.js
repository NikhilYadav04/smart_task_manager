//* <--------------- EXTRACTS EXTRACTION UTILITY --------------- >
//*< ----- Extracts structured information from unstructured task text ---- >

function extractEntities(text) {
  if (!text) {
    return {
      dates: [],
      people: [],
      locations: [],
      actions: [],
    };
  }

  const entities = {
    dates: [],
    people: [],
    locations: [],
    actions: [],
  };

  //* Extract dates ( using patterns )
  const datePatterns = [
    /\b(today|tomorrow|yesterday)\b/gi,
    /\b\d{1,2}\/\d{1,2}\/\d{2,4}\b/g,
    /\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{1,2}(st|nd|rd|th)?\b/gi,
    /\b(january|february|march|april|may|june|july|august|september|october|november|december) \d{1,2}(st|nd|rd|th)?\b/gi,
    /\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b/gi,
    /\bthis (week|month|year|quarter)\b/gi,
    /\bnext (week|month|year|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b/gi,
  ];

  datePatterns.forEach((pattern) => {
    const matches = text.match(pattern);
    if (matches) {
      matches.forEach((match) => {
        if (!entities.dates.includes(match.toLowerCase())) {
          entities.dates.push(match.toLowerCase());
        }
      });
    }
  });

  //* Extract peopler ( after keywords like "with" "by" "assigned_to" "assign to" "call")
  const peoplePatterns = [
    /(?:with|by|assign to|contact|meet|call)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)+)/gi,
    /@([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)/g,
  ];

  peoplePatterns.forEach((pattern) => {
    let match;
    while ((match = pattern.exec(text)) !== null) {
      const person = match[1].trim();
      if (!entities.people.includes(person)) {
        entities.people.push(person);
      }
    }
  });

  //* Extract locations (after "at", "in", "to")
  const locationPattern =
    /(?:at|in|to)\s+(?:the\s+)?([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*(?:\s+(?:Office|Building|Room|Hall|Center|Site|Location))?)/g;
  let match;
  while ((match = locationPattern.exec(text)) !== null) {
    const location = match[1].trim();
    if (!entities.locations.includes(location)) {
      entities.locations.push(location);
    }
  }

  // Extract action verbs
  const actionVerbs = [
    "schedule",
    "call",
    "email",
    "send",
    "review",
    "complete",
    "fix",
    "update",
    "check",
    "prepare",
    "submit",
    "approve",
    "contact",
    "coordinate",
    "arrange",
    "book",
    "reserve",
    "install",
    "repair",
    "maintain",
    "inspect",
    "verify",
    "process",
    "generate",
    "create",
    "delete",
    "modify",
  ];

  const words = text
    .toLowerCase()
    .replace(/[^\w\s]/g, "")
    .split(/\s+/);

  actionVerbs.forEach((verb) => {
    if (words.includes(verb) && !entities.actions.includes(verb)) {
      entities.actions.push(verb);
    }
  });

  return entities;
}

//* Extract due dates from text
function extractDueDate(text) {
  if (!text) return null;

  const lowerText = text.toLowerCase();
  const now = new Date();

  //* Today
  if (lowerText.includes("today")) {
    return now;
  }

  //* Tomorrow
  if (lowerText.includes("tomorrow")) {
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);
    return tomorrow;
  }

  //* This week (default to Friday)
  if (lowerText.includes("this week")) {
    const friday = new Date(now);
    friday.setDate(friday.getDate() + (5 - friday.getDay()));
    return friday;
  }

  //* Next week (default to next Friday)
  if (lowerText.includes("next week")) {
    const nextFriday = new Date(now);
    nextFriday.setDate(nextFriday.getDate() + (12 - nextFriday.getDay()));
    return nextFriday;
  }

  return null;
}

module.exports = {
  extractEntities,
  extractDueDate,
};
