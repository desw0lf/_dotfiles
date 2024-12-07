// add browser window settings
const fs = require("fs").promises;
const readline = require("readline");
const path = require("path");

const BROWSER_WINDOW_SETTINGS = {
  titleBarStyle: "hiddenInset",
  trafficLightPosition: { x: 8, y: 8 }
};

const POTENTIAL_MAIN_PATHS = [
  '/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/code/electron-main/main.js',
  '/Applications/Visual Studio Code.app/Contents/Resources/app/out/main.js'
]

const settings = {
  filePath: POTENTIAL_MAIN_PATHS[1],
  searchString: '"HighlightAPI",sandbox:!0},experimentalDarkMode:!0',
  makeBackup: true
}

const textToAppend = "," + stringify(BROWSER_WINDOW_SETTINGS);
const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

function stringify(obj) {
  return Object.entries(obj).map(([key, value]) => {
    if (typeof value === "object") {
      return `${key}:{${stringify(value)}}`;
    }
    if (typeof value === "string") {
      return `${key}:"${value}"`;
    }
    return `${key}:${value}`;
  }).join(",");
}

function log(val, colour = "reset") {
  const c = { red: "\x1b[31m", green: "\x1b[32m", blue: "\x1b[34m", cyan: "\x1b[36m", bgRed: "\x1b[41m", reset: "\x1b[0m" };
  if (typeof val === "string") {
    console.log(c[colour] + "%s" + c.reset, val);
    return;
  }
  console.log(val);
}

function separator(type = "hr") {
  switch(type) {
    case "br": {
      console.log("\n");
      break;
    };
    case "hr": {
      console.log("----------------------------------------");
      break;
    };
    default: {
      console.log(type);
    }
  }
}


async function backupFile(filePath, fileContent) {
  const backupFileName = `${path.basename(filePath, ".js")}.backup-${Date.now()}.js`;
  console.log(process.cwd());
  const backupPath = path.join(process.cwd() + "/backups", backupFileName);
  const dirExists = await fs.access(path.dirname(backupPath)).then(() => true, () => false);
  if (!dirExists) {
    await fs.mkdir(path.dirname(backupPath));
  }
  await fs.writeFile(backupPath, fileContent);
  log(`Backup created at: ${backupPath}`, "cyan");
}

const MAX_CONTEXT = 1000; // Maximum characters to search for context boundaries
const SEARCH_BACK_UNTIL_STR = "={";
const SEARCH_FORWARD_UNTIL_STR = "};";

async function findContextBoundaries(content, stringIndex) {
    // Search backwards for '={'
    let startContext = stringIndex;
    let searchBackward = content.substring(Math.max(0, stringIndex - MAX_CONTEXT), stringIndex);
    const lastEquals = searchBackward.lastIndexOf(SEARCH_BACK_UNTIL_STR);
    if (lastEquals !== -1) {
        startContext = Math.max(0, stringIndex - (searchBackward.length - lastEquals));
    }

    // Search forward for '};'
    let endContext = stringIndex;
    let searchForward = content.substring(stringIndex, Math.min(content.length, stringIndex + MAX_CONTEXT));
    const firstSemicolon = searchForward.indexOf(SEARCH_FORWARD_UNTIL_STR);
    if (firstSemicolon !== -1) {
        endContext = stringIndex + firstSemicolon + SEARCH_FORWARD_UNTIL_STR.length; // +2 to include '};'
    }

    return { startContext, endContext };
}

const askQuestion = (query, type = "boolean") => {
  return new Promise((resolve) => {
    rl.question(query, (answer) => {
      if (type === "boolean") {
        resolve(["1", "y", "yes", "true"].includes(answer.toLowerCase()));
      } else {
        resolve(answer);
      }
    });
  })
}

async function modifyFile(filePath, searchString, textToAppend) {
  try {
    const fileContent = await fs.readFile(filePath, 'utf8');
    // Find the search string
    const stringIndex = fileContent.indexOf(searchString);
    if (stringIndex === -1) {
        throw new Error('Search string not found in file');
    }

    // Get context based on ={ and }; boundaries
    const { startContext, endContext } = await findContextBoundaries(fileContent, stringIndex);
    const contextString = fileContent.substring(startContext, endContext);

    // Show context and ask for confirmation
    separator("br");
    log("Found string with context:", "blue");
    separator();
    log(contextString);
    separator();

    const confirm = await askQuestion("Is this the correct location to modify? (y/n): ");
    if (confirm) {
      if (settings.makeBackup) {
        await backupFile(filePath, fileContent);
      }
      let newContent = fileContent.slice(0, stringIndex + searchString.length) + textToAppend + fileContent.slice(stringIndex + searchString.length);

      const previouslyAppendedText = fileContent.substring(stringIndex, endContext).substring(searchString.length).slice(0, -SEARCH_FORWARD_UNTIL_STR.length).trim();

      if (previouslyAppendedText.length > 0) {
        separator("br");
        separator();
        log("It seems the patch has already been applied previously:", "blue");
        log("Replace");
        log(previouslyAppendedText, "red");
        log("with");
        log(textToAppend, "green");
        separator();
        const replace = await askQuestion("Replace? (y/n): ");
        if (replace) {
          newContent = fileContent.slice(0, stringIndex + searchString.length) +  textToAppend +  fileContent.slice(endContext - SEARCH_FORWARD_UNTIL_STR.length);
        } else {
          const append = await askQuestion("Still append? (y/n): ");
          if (!append) {
            return false;
          }
          log("I hope you know what you are doing...", "bgRed");
        }
      }

      rl.close();

      try {
        await fs.writeFile(filePath, newContent);
        log("File successfully modified!", "green");
        return true;
      } catch (err) {
        log("Error writing to file:" + err, "red");
      }
    }

    return false;
  } catch (error) {
    console.error("Error:", error.message);
    rl.close();
    return false;
  }
}

modifyFile(settings.filePath, settings.searchString, textToAppend)
  .then(() => process.exit())
  .catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });