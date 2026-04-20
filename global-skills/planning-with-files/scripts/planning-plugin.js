/**
 * planning-with-files plugin
 *
 * Replicates Claude Code hook behavior using OpenCode plugin events:
 * - tool.execute.before → injects plan context before tool execution
 * - tool.execute.after  → reminds to update progress after writes
 * - session.idle        → runs completion check when session ends
 */

const PLANNING_FILES = ['task_plan.md', 'progress.md', 'findings.md'];

export const PlanningWithFilesPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    /**
     * Replaces PreToolUse hook: inject plan context before tool execution
     */
    'tool.execute.before': async (input, output) => {
      const { tool } = input;
      const readTools = ['read', 'glob', 'grep', 'bash'];

      if (readTools.includes(tool)) {
        const fs = await import('fs');
        const path = await import('path');
        const planPath = path.join(project, 'task_plan.md');

        if (fs.existsSync(planPath)) {
          const planContent = fs.readFileSync(planPath, 'utf-8').split('\n').slice(0, 30).join('\n');
          output.args._planningContext = `[planning-with-files] ACTIVE PLAN — current state:\n${planContent}`;
        }
      }
    },

    /**
     * Replaces PostToolUse hook: remind to update progress after writes
     */
    'tool.execute.after': async (input, output) => {
      const { tool } = input;
      const writeTools = ['write', 'edit'];

      if (writeTools.includes(tool)) {
        const fs = await import('fs');
        const path = await import('path');
        const planPath = path.join(project, 'task_plan.md');

        if (fs.existsSync(planPath)) {
          output.result += '\n\n[planning-with-files] Reminder: Update progress.md with what you just did. If a phase is now complete, update task_plan.md status.';
        }
      }
    },

    /**
     * Replaces Stop hook: check completion when session ends
     */
    'session.idle': async ({ event }) => {
      const fs = await import('fs');
      const path = await import('path');
      const planPath = path.join(project, 'task_plan.md');

      if (!fs.existsSync(planPath)) {
        return;
      }

      const planContent = fs.readFileSync(planPath, 'utf-8');
      const phaseMatches = planContent.match(/### Phase/g);
      const totalPhases = phaseMatches ? phaseMatches.length : 0;
      const completePhases = (planContent.match(/\*\*Status:\*\* complete/g) || []).length;

      if (totalPhases > 0 && completePhases === totalPhases) {
        console.log(`[planning-with-files] ALL PHASES COMPLETE (${completePhases}/${totalPhases})`);
      } else if (totalPhases > 0) {
        const inProgress = (planContent.match(/\*\*Status:\*\* in_progress/g) || []).length;
        const pending = (planContent.match(/\*\*Status:\*\* pending/g) || []).length;
        console.log(`[planning-with-files] Task in progress (${completePhases}/${totalPhases} phases complete)`);
        if (inProgress > 0) console.log(`[planning-with-files] ${inProgress} phase(s) still in progress.`);
        if (pending > 0) console.log(`[planning-with-files] ${pending} phase(s) pending.`);
      }
    },
  };
};
