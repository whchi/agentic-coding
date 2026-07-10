---
name: super-search-research
description: Use when the user asks to search, find, verify, research, collect sources, find reports, find tutorials, find tools, find software alternatives, find assets, or improve search queries. Trigger on phrases like "搜一下", "幫我找資料", "查證", "找源頭", "找報告", "找 PDF", "找教程", "找素材", "找工具", "有沒有替代軟體", "怎麼搜", "research this", "find sources", "verify this claim". Do NOT use for summarizing a provided document, answering purely from a local codebase, private doxxing/background investigation, bypassing paywalls, or finding copyrighted material for unauthorized use.
---

# Super Search Research

## Purpose

Turn a vague search need into a source-first research workflow. Choose where to search, how to query, how to verify, and what result to deliver.

## Inputs

- User's goal or question
- Desired output type: answer, source list, tutorial, report, asset, tool, software, dataset, or verification
- Freshness requirement, if any
- Region, language, platform, budget, licensing, or format constraints
- Known source, product, claim, name, URL, DOI, file type, or domain, if provided

## Procedure

1. Classify the search intent.

   Use these categories:

   - Information: news, facts, statistics, current events, product parameters
   - Knowledge: concepts, tutorials, courses, papers, industry reports
   - Materials: images, video, audio, icons, templates, datasets, files
   - Tools: online utilities, software, plugins, extensions, alternatives

   Also classify the purpose:

   - Know something
   - Learn something
   - Create something
   - Do something

   If the request spans categories, split it into sub-searches.

2. Prefer source-first search.

   Before searching broad web results, identify the likely original or authoritative source:

   - Laws, policy, registration, standards: official regulator or government database
   - Product specs: official product page, manual, marketplace listing, or manufacturer documentation
   - Company or project news: official blog, release notes, social account, GitHub, or documentation
   - Academic claims: paper title, DOI, Google Scholar, publisher page, or preprint server
   - Industry data: original report publisher, consulting firm, exchange, regulator, or dataset owner
   - Software behavior: official docs, changelog, issue tracker, source repository
   - Asset licensing: original asset platform and license page

   If the source is not obvious, generate candidate source types before querying.

3. Build search queries deliberately.

   Start broad enough to identify source vocabulary, then narrow.

   Use advanced operators when they fit:

   - Exact phrase: `"term"` when wording must match exactly
   - Title constraint: `intitle:term` or `allintitle:term1 term2` when pages should be specifically about the topic
   - Body constraint: `intext:term` when a term must appear in page content
   - Domain constraint: `site:domain.com` when the source is known
   - URL constraint: `inurl:term` when reports, docs, or categories are reflected in URLs
   - File format: `filetype:pdf`, `filetype:ppt`, `filetype:xlsx` when the desired artifact is a document or dataset
   - Image size: `imagesize:widthxheight` when exact image dimensions matter

   Combine operators sparingly. If results are too sparse, remove the most restrictive operator first.

4. Choose the search surface by task.

   For information verification:

   - Search official sources first.
   - Cross-check with reputable secondary sources.
   - Prefer dated pages when freshness matters.
   - Report uncertainty when official data is absent or stale.

   For learning a subject:

   - Look for structured tutorials, books, courses, papers, and reports.
   - Prefer materials with clear authorship, depth, examples, and maintenance.
   - For industry onboarding, search for reports using query patterns like:
     - `<industry> report filetype:pdf`
     - `<topic> white paper filetype:pdf`
     - `<topic> site:<trusted-domain>`

   For academic papers:

   - Search by exact title, DOI, author, or key phrase.
   - Prefer Google Scholar, publisher pages, institutional repositories, preprints, and official PDFs.
   - Do not recommend illegal access paths.

   For materials and creative assets:

   - Determine required media type, resolution, license, style, and commercial-use needs.
   - Prefer reputable asset libraries with explicit licenses.
   - For icons, search by object + icon + desired format.
   - For templates, prefer editable sources over screenshots or flattened files.
   - Always surface licensing constraints.

   For tools and software:

   - Prefer online tools for one-off tasks.
   - Prefer installed software when repeated work, privacy, batch processing, or advanced control matters.
   - Prefer plugins/extensions only when the user already uses the host app or browser.
   - For alternatives, search with patterns like:
     - `alternative to <software>`
     - `best <task> online tool`
     - `best <software> plugin`
     - `best chrome extensions <workflow>`

5. Use AI as a research accelerator, not the only source.

   Use AI to:

   - Generate query variants
   - Compare options
   - Explain concepts
   - Create a research plan
   - Extract decision criteria
   - Combine multiple sub-questions

   Verify factual, current, legal, medical, financial, or high-stakes claims against primary or reputable sources.

6. Evaluate results.

   Check:

   - Is this the original source or a repost?
   - Is it current enough?
   - Does it show author, publisher, date, method, data source, or license?
   - Does the page answer the user's actual intent?
   - Are there conflicting sources?
   - Is the result usable in the user's region, language, budget, or toolchain?

   If results conflict, rank sources by authority and recency, then explain the conflict briefly.

7. Deliver the result in the user's needed form.

   Provide one or more of:

   - Best answer with source links
   - Search strategy and exact queries to run
   - Source map: where to look and why
   - Shortlist of tools/resources with tradeoffs
   - Verification checklist
   - Next-step research plan

## Output Contract

Return:

1. Search intent classification
2. Best source strategy
3. Recommended queries or search operators
4. Findings or recommended resources
5. Verification notes, including uncertainty and licensing/legal constraints when relevant
6. Next step only when useful

Keep the answer practical. Do not explain every search operator unless the user asked to learn search technique.

## Guardrails

- Do not produce a generic summary when the user needs a search plan, verified answer, source list, or resource shortlist.
- Do not treat reposts, marketing pages, or social commentary as primary sources when an official source exists.
- Do not use advanced operators as decoration; each operator must narrow the search for a reason.
- Do not recommend doxxing, private personal background investigation, credential scraping, piracy, or unauthorized copyrighted downloads.
- Do not overfit to one platform. Choose the source based on the task, region, language, and artifact type.
- Do not state single-source claims as certain when the evidence is weak, stale, or unverifiable.
- Do not ignore licensing for images, video, audio, icons, templates, or datasets.

## Definition of Done

The skill is complete when:

- The user's search need is classified
- The likely source of truth is identified
- Search surfaces and operators fit the task
- Results are evaluated for authority, freshness, usability, and constraints
- The output gives usable queries, sources, findings, or next actions
- Uncertainty, conflicts, and legal/licensing limits are visible
