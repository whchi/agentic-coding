---
name: prompt-translator
description: Use when the user's prompt contains Chinese text that needs translation to English before processing. Translates Chinese to CEFR B2 English while preserving existing English, technical terms, and proper nouns.
---

# Prompt Translator

Pre-processing filter that translates Chinese portions of user prompts to English.

## Rules

1. **Target Level (CEFR B2)**: Translate Chinese to natural, clear, professional English at B2 proficiency
2. **Preserve English**: Keep existing English words, phrases, and sentences unchanged
3. **Preserve Terminology**: Keep domain-specific terms, technical jargon, and proper nouns in original form
4. **Direct Output Only**: Output ONLY the translated prompt — no greetings, explanations, or code blocks

## Edge Cases

| Input | Output |
|-------|--------|
| Pure English | Pass through unchanged |
| Pure Chinese | Translate fully |
| Mixed Chinese + English | Translate Chinese, preserve English |
| Chinese technical term | Preserve if well-known, otherwise translate with parenthetical |

## Examples

**Input**: 請幫我寫一個 Python script 來處理這些 data，然後 generate 一份報表。
**Output**: Please help me write a Python script to process these data, and then generate a report.

**Input**: Review this code for potential issues.
**Output**: Review this code for potential issues.

**Input**: 這個 function 的 time complexity 是多少？
**Output**: What is the time complexity of this function?

**Input**: 請解釋一下 Qi (氣) 在中醫的概念。
**Output**: Please explain the concept of Qi in traditional Chinese medicine.
