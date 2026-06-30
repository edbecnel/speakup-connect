## Economical AI Codebase Exploration Strategies (Codex 5.3 Token Saving)

### Strategy 1: Finding an Unknown Bug or Conceptual Issue

Use this template in **Plan Mode** when you have a conceptual, exploratory question or bug across your codebase, but do not know which files are responsible.

### The Prompt Template

text

    I am facing a conceptual issue/feature request: 
    [INSERT YOUR BUG OR FEATURE DESCRIPTION HERE]
    
    Before you analyze any code, you must adhere to these strict budget constraints:
    1. Do NOT read, open, or ingest my codebase files yet.
    2. Use terminal tools (like `grep`, `find`, `rg`, or directory listings) to search for relevant files and locate where this logic lives.
    3. Present a list/checklist of the candidate filenames to me first for my approval.
    4. Wait for my explicit confirmation before reading the contents of any specific file.
    

Use code with caution.

* * *

### Strategy 2: Mapping a New Full-Stack Feature (Database, App, Web App)

Use this template in **Plan Mode** when a new feature requires changes across multiple structural layers, and you do not know which files are involved.

### The Prompt Template

text

    I need to implement a full-stack feature: 
    [INSERT FULL-STACK FEATURE DESCRIPTION HERE]
    
    To protect my budget, do NOT read any code files yet. Instead, use terminal commands to scan our directory structures and trace filenames across our layers. Run the following steps:
    
    1. DATABASE: Search for schemas, models, or migration folders/files to find where our relevant data entities are mapped.
    2. APP (BACKEND): Scan for API routes, controllers, or service directories that will handle the backend logic for this feature.
    3. WEB APP (FRONTEND): Locate the UI components, pages, or state management files that will display or interact with this feature.
    
    Output an organized checklist of the candidate file paths you find across these three layers. Wait for my review and explicit approval before opening any of them.
    

Use code with caution.

* * *

### Moving From Analysis to Implementation

### 1\. Handling Indexing Prompts

*   **Note:** Because your workspace index is turned off to save tokens, Cursor may show a message like *"Results will get much better when Cursor understands your codebase. Start indexing"*.
*   **Action:** Ignore this message completely. Do **NOT** click "Start indexing". The AI will still read files perfectly fine using terminal commands or manual instructions.

### 2\. Giving Execution Permission

Once you review the AI's filename checklist and confirm the files look correct, give the green light by using this prompt format:

text

    The candidate files are correct. You now have permission to read [insert the specific approved filenames here] and implement the code changes. Run any necessary build or test terminal commands to verify it works.
    

Use code with caution.

### 3\. Interacting with the Plan Mode Checklist (To-dos)

When you give permission to implement, Plan Mode will generate an interactive list of **To-dos** (bullet points with circles) before modifying files.

*   **The "Build" Step:** Click the **"Build"** or **"Apply"** button with your mouse at the bottom of the chat pane to start execution.
*   **Granular Tracking:** The AI will automatically check off these circles one by one as it completes the code updates.
*   **Safety Lock:** If the AI writes incorrect code on Step 1, it will halt. This prevents it from propagating errors into the remaining steps, saving you from expensive multi-file troubleshooting loops.

* * *

### Handling a Broken Fix (Preventing Agent Spend Spirals)

If the AI applies a fix but it fails on runtime verification, **do not let the agent blindly rewrite code**. Doing so triggers an expensive multi-file guessing loop that drains credits.

Halt the execution immediately by responding with this precise prompt format:

text

    Do NOT rewrite or apply any code changes yet. 
    
    Instead, print the current values of `window.location.search`, `sessionStorage.getItem('rv_editor_return_to')`, and the console logs when clicking Save/Cancel. Let me see the diagnosis first.
    

Use code with caution.

* * *

### Advanced Troubleshooting: The SPA State Tracking Trap

When routing fixes fail even after a hard refresh, the culprit is often a **Single-Page Application (SPA) state gap** that the AI's standard static analysis cannot see. If toggling view states (like entering a "Browse" view) only hides/shows HTML components without modifying the browser's URL, the navigation context is fundamentally missing.

### 1\. Diagnostic Step: Check for Parameter Mismatches & Stale Links

Before letting the AI write any tracking logic, manually inspect the runtime values via the browser console:

*   **Check the key names:** Verify if the HTML `href` attribute parameter name (e.g., `from=`) actually matches what the AI is fetching via javascript (e.g., `params.get('returnTo')`).
*   **Check the link rendering lifecycle:** Inspect the link elements. If state updates are made *after* the initial page render, the HTML link tags might contain a stale version of the URL missing critical route parameters or hash strings (`#browse`).

### 2\. The Resolution Blueprint

Force the AI to move from static, pre-generated links to **live event capturing** during runtime. Instruct it with this prompt template:

text

    The root cause of the navigation failure is an interactive SPA state disconnect. The link parameters are containing stale base-path URLs because they are generated before active layout changes occur.
    
    To protect the budget and avoid trial-and-error loops, please refactor the launch sequence using live tracking:
    1. In the navigation file, append unique state identifiers (like hashes or parameters, e.g., `window.location.hash = 'browse'`) directly to the browser window when active views change.
    2. In the click event listener file, update the Edit element handlers to dynamically capture the live `window.location.href` at the exact millisecond of the user's click, injecting that fresh state string into the navigation query payload.
    

Use code with caution.

* * *

### Universal Rules for Both Strategies

### 1\. Why This Saves Money

*   **The Expensive Way:** Codex 5.3 pulls dozens of full source code files into its 400k context window to read them. You pay for massive input tokens on every single chat turn.
*   **The Economical Way:** Codex 5.3 runs a local terminal tool. The output returned to the AI is just a few short lines of filenames. Your token input cost drops by up to 95%. Even when it finally reads the specific files to execute the code, it is only opening the exact files targeted rather than your entire project repository.

### 2\. Dealing with Uncertainty

If the AI presents a file path and you are unsure if it is relevant, do not let it open the file. Reply with:

text

    Do not read the full file for [filepath]. Instead, use a terminal command to show me the first 25 lines (using `head`) or grep the main exports/functions so we can verify its purpose cheaply.
    

Use code with caution.

### 3\. Cleaning Up

Once the analysis is complete and you know what to do, immediately hit the **New Chat** button to clear the short-term token memory before you actually start writing or fixing the code.