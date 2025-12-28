const prisma = require("./prisma");

process.on("beforeExit", async () => {
  await prisma.$disconnect();
});

module.exports = prisma;
