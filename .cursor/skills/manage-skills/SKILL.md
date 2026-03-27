---
description: Manage rules & skills in NVIM/CodeCompanion
alwaysApply: false
---

Discover available skills and update my code companion configuration with rule_groups that can take advantage of them.

# Discover Skills

Search for new skills in
  - ~/projects/ai_prompts
  - ~/projects/skills

Check if these repositories have updates and ask the user if they want to pull the latest.

Skills are usually named `SKILL.md` and are grouped by directory.

The common case is that a single skill be added as a rule group in codecompanion.lua.

If supporting files exist, include them too.

Choose a name for the skill
  - if a single word or phrase is descriptive, use it
  - summarize the description of the skill into a single word of very short phrase (1-3 words)


# Prompt the user about available skills

Show the user a table of the available skills. Include the following data:
  - skill name
  - location
  - short description (summarize the Description in 5-10 words
  - green check if this skill is already included in a rule group in codecompanion.lua
  - name of the existing rule group if already included in codecompanion.lus

Ask the user whether they would like to add any new skills to their configuration.

## Add new skills
The user may ask you to add one or more new skills.

### Adding multiple skills into dedicated rule groups
Unless otherwise instructed, assume a dedicated rule group per skill.

Example user input
```
Add skills:
- skill 1
- skill 2
```

Example rule group:
```
      manage_rule_groups = {
        description = "Manage my rule groups with discovery of new skills",
        files = { ".cursor/skills/manage-skills/*" },
      },

```


## Adding multiple skills into a single rule group

Example user input
```
Add these skills to a group named "my awesome group"
- skill 1
- skill 2
```

