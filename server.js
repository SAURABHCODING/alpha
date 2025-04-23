const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const { exec } = require("child_process");
const fs = require("fs");
const path = require("path");
const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(bodyParser.json());

const LANGUAGES = {
  python: {
    extension: ".py",
    command: (filename) => `python3 ${filename}`,
  },
  cpp: {
    extension: ".cpp",
    command: (filename) => `g++ ${filename} -o ${filename}.out && ${filename}.out`,
  },
  javascript: {
    extension: ".js",
    command: (filename) => `node ${filename}`,
  },
  java: {
    extension: ".java",
    command: (filename) => {
      const baseName = path.basename(filename, ".java");
      return `javac ${filename} && java ${baseName}`;
    },
  },
};

app.post("/run", async (req, res) => {
  const { language, code, testcases = [] } = req.body;

  if (!LANGUAGES[language]) {
    return res.status(400).json({ error: "Unsupported language" });
  }

  const { extension, command } = LANGUAGES[language];
  const filename = `Code${Date.now()}${extension}`;
  const filepath = path.join(__dirname, filename);

  fs.writeFileSync(filepath, code);

  const results = [];

  for (const { input = "", expected = "" } of testcases.length ? testcases : [{ input: "", expected: "" }]) {
    const result = await new Promise((resolve) => {
      const execCommand = command(filepath);
      const child = exec(execCommand, { timeout: 5000 }, (error, stdout, stderr) => {
        const output = (stdout || stderr || error?.message || "No output").trim();
        const status = output === expected ? "passed" : "failed";
        resolve({ output, expected, status });
      });

      if (input) {
        child.stdin.write(input);
        child.stdin.end();
      }
    });

    results.push(result);
  }

  // Clean up
  try {
    fs.unlinkSync(filepath);
    if (language === "cpp") fs.unlinkSync(`${filepath}.out`);
    if (language === "java") {
      const baseName = path.basename(filepath, ".java");
      fs.unlinkSync(path.join(__dirname, `${baseName}.class`));
    }
  } catch {}

  const passedCount = results.filter((r) => r.status === "passed").length;
  const total = results.length;
  const score = total > 0 ? `${Math.round((passedCount / total) * 100)}%` : "0%";

  res.json({ results, score });
});

app.listen(PORT, () => {
  console.log(`Code Runner API listening on port ${PORT}`);
});
