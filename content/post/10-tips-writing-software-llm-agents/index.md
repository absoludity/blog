---
title: "10 tips for writing software with LLM agents"
date: 2025-09-26T16:18:59+10:00
draft: false
image:
  caption: "A young River Phoenix programs with an agent's help in the 1985 kids sci-fi movie [Explorers](https://www.imdb.com/title/tt0089114/)"
categories: [ "artificial-intelligence", "ai-agents", "programming", "learning" ]
tags: ["article"]
---

I've been working in software development for a whilie now and have consistently chosen to stay in an individual contributer role because, among other reasons, I *love* working and learning together in a team solving problems with code.

So when I say, with complete honesty, that **I have never enjoyed developing software more than the last six months or so while developing together with large language model agents**, it's not because I haven't enjoyed software development in the past. I think it's mostly because having an incredibly fast and knowledgeable coding assistant allows me to **stay in the flow of the actual creative process** (yes, for those unfamiliar with writing software, it can be very creative and fun!) - designing, learning and architecting the solution - rather than constantly deep-diving into the depths of some library or framework to solve some small blocker.

But **the benefit of having an incredibly knowledgable, if some-what over eager, coding assistant comes with a lot of dangers and pitfalls as well**. The same capabilities that make these tools powerful - their speed and broad knowledge - can tempt us to skip the learning process and generate code that we don't fully understand, creating downstream issues for review and maintenance.

In this post, I want to highlight the benefits as well as the strategies to avoid the pitfalls, in a top-10 tips format. Hopefully it's helpful whether you've thirty years experience or three.

<!--more-->

## My LLM agent-based setup

First, it might be handy to outline my own setup for AI agents integrated into my deveolpment environment (to be clear, this is not generating code from a separate ChatGPT or Claude window).

Initially I was using the git/CLI-based [Aider](https://aider.chat/) - "Pair programming in your terminal" - simply because it was the best open source solution that a friend had mentioned at the time. You bring your own LLM or API key (I'm using anthropic currently) and allow the agent to propose changes across your codebase in response to your conversation. I did enjoy Aider but found myself struggling with the commit-based workflow that it uses (I take pride in my commits).

Since then I've switched to [Zed](https://zed.dev) - an editor written from scratch in Rust (think: fast) by the team that built Atom/Electron years ago (think: experience in dev UX). The beautiful thing about Zed is that it's built for "[agentic engineering](https://zed.dev/agentic-engineering)" - "Combining human craftsmanship with AI tools to build better software". In fact, the intro of that Zed blog post is worth quoting in the context of this post:

  > Software development is changing and we find ourselves at a convergence. Between the extremes of technological zealotry ("all code will be AI-generated") and dismissive skepticism ("AI-generated code is garbage") lies a more practical and nuanced approach—one that is ours to discover together.

It's this focus on tuning the development experience combining human craftsmanship with AI tools that keeps me using Zed right now. There's plenty of other options out there too - people using non-OSS tools such as Cursor (based on VS Code) and others, so take your pick.

Now for what it's worth, my personal tips:

## 1: **OWN** the code change

The Zed folk say this well in their [Core principles of agentic engineering](https://zed.dev/agentic-engineering#core-principles):

> As engineers, we are solely responsible for the quality of what we build. It's up to us to develop judgment about when AI improves our outcomes and when it doesn't. There's no prescribed formula (yet); we have to build our own understanding of how AI best fits into our craft.

My summary of this sentiment is: **own the code that you commit**. Hopefully it goes without saying never to commit any code that you don't understand - that's a missed learning opportunity - but also don't commit any code which you've not personally reviewed, evaluated, possibly improved and integrated because **you are convinced that it improves the state of the code-base** towards the end goal. Review, iterate and learn with the AI agent to craft the code into a state that *you* are proud of. We have to own - and be ready to defend - our code, otherwise we risk frustrating our team-mates as well as our future selves, so don't just generate and push.

It's worth expanding on this a little, I think:

**Read and understand every line.** Just because the agent wrote it doesn't mean you can skip the review. I often find myself interrupting the agent with "Wait, why are you doing X?" or replying after reviewing with "This works, but X and Y could be DRYed up." The agent is our pair programming partner, not your replacement (well, not yet) - you are responsible for the code change.

**Iterate not just for your reviewer but also for your future self.** Not specific to AI-generated code, but don't settle for "it works." Prompt for better variable names, clearer logic flow, better error handling or, more commonly, less extensive and more focused unit tests. You will need to work with and maintain this code into the future so own it and ensure the code clearly expresses its intent and purpose. Avoid frustrating your reviewer or even your future self who might lose valuable time trying to understand it 6 months from now.

The bottom line is: if you're not comfortable putting your name on the code and defending each decision it encodes, then don't commit it. The agent is a powerful collaborator, but you remain the author of the commits going into your codebase, so own it.


## 2: Make the most of the opportunity to **learn efficiently** while coding.

This might be the biggest missed opportunity of LLM agents - they're incredible learning partners *if* you take the time to learn. When the agent suggests a pattern you don't recognize, ask "Why did you choose this approach?" When it uses a library method you haven't seen, ask for an explanation and alternatives.

I find myself enjoying learning more now while writing code simply because of the lack of friction to learn more about the very specific thing I'm struggling with whenever the opportunity arises. The agent can instantly explain design patterns, show idiomatic ways to use a language feature, or walk through various trade-offs between different approaches. **It won't always be right, but it is always, in my opinion, helpful for learning** if you are ready to evaluate and think things through yourself. I find myself describing LLM agents to people as incredibly knowledgable but not so experienced junior developers, whom I can learn so much from while still needing to provide significant direction and guidance within a project.

Don't lose sight of this development opportunity. If you are in a decent team, I'm pretty sure **your team will much prefer you produce less code while consistently developing your software engineering skills**, than outputing lots of code that you may not necessarily understand as it grows in complexity.

## 3: **Remain in the flow** working towards the higher-level goal

LLM agents allow you to continue thinking and working towards goals *without* having to continuously dive down and spend significant time in the depths of framework-x or library-y to debug why something doesn't work. Yes, you still hit those issues, but **use the LLM agent to get a summary of the problem together with a summary of possible solutions** which you can evaluate, decide on a way forward quickly and efficiently and minimise the time you're out of your normal goal-oriented flow. **The cognitive load stays on the interesting problems** - the system design, the trade-offs, the user experience - rather than syntax and boilerplate.


## 4: Take the opportunity to **refactor and improve code** with a much lower cost

Similarly, LLM agents help **remove the friction that often prevents good architectural decisions** that require tedious time and effort. Previously, I'd see an opportunity to improve the design but hesitate because of the time cost - refactoring interfaces, updating all the implementations, fixing tests, updating example scripts and related documentation. The tedious work required and time pulled away from the flow towards the goal (tip 3) would outweigh the architectural benefit. Now you can simply **document the refactor's reason and approach and use the LLM agent work on it** while you do something else. Later read through and possibly iterate on the result, evaluating if it worked the way you expected, and push the PR up for review and discussion. There's much less room for commitment bias - the tendency to stick with suboptimal decisions simply because we've already invested effort in them. When change is cheaper, you're freer to pursue better designs without the psychological weight of sunk costs.

## 5: Start every session with full context (and avoid sycophantic tendencies)

The lack of context when starting a new thread due to token exhaustion (a limitation of current LLM agents) can be an advantage, as it forces you to **document your LLM Agent preferences in your repository**. After typing "Please avoid sycophantic commentary like 'You're absolutely correct!' or 'Brilliant idea!'" for the hundredth time, you'll want to save these preferences somewhere and just point the agent at them when you start. (I only really learned what "sycophantic" meant after dealing with this during the first few months - I guess we humans are happier to pay for services that tell us we have "brilliant idea!"'s and are "absolutely right" all the time, which is kind of scary long-term).

One option is a simple file like `.ai-instructions` in your project root with coding preferences, style guidelines, and common patterns, but it typically becomes large and hard to manage as you realise it's not just preferences, but current tasks, technology and design pattern decisions, and a whole bunch of context that is useful to document. I like the memory-bank pattern which I *think* began in the Cline community (Cline is a lesser known LLM agent) with the [Cline memory-bank pattern](https://docs.cline.bot/prompting/cline-memory-bank). The **memory-bank is basically a *directory* containing multiplpe markdown files with the context of the project**, chosen technologies, current progress, tasks, together with instructions for the agent to keep this context up to date.

## 6: Start each task with a **pre-implementation discussion**

Another great learning opportunity: LLM agents can help you **think through problems before diving into code**. Instead of jumping straight to implementation, start a pre-implpementation discussion, with something like: "Don't make any changes yet. I'm thinking about options for X, my current idea is Y, but that may not be the best option. Looking at files ... , what different approaches you can see? Give me a summary with the pros and cons of each." I've been suprised quite a few times and been saved from a less-optimal path.

This isn't just about getting better solutions - it's an opportunity to learn about patterns, libraries, and architectural approaches you might not encounter or otherwise consider. The key is **maintaining your role as the decision maker**. The agent provides options and analysis; you choose the path forward based on your understanding of the codebase, team preferences, and project constraints. Though be careful - the sycophantic tendencies which seem to be baked in to most LLMs (are we humans really that much more happy when treated that way) might betray you and yoru "Brilliant idea!" may not be so brilliant.

## 7: Use the agent to help you **plan for small, focused changes**

Remember, at the end of the day, it is humans who will be reviewing and maintaining the code. When working on a change, **part of your job is to make it easy for a reviewer to understand your change**. Smaller diffs in the context of a larger change only come about by planning a change in small discrete, contained steps. And smaller, focused diffs are *much* easier to review than a single huge diff of many changes across different contexts.

The speed of LLM agents can be a double-edged sword. Without guidance they will generate sweeping changes across multiple files, but this usually creates large, harder-to-review changes.

**Planning larger code changes into sets of smaller, contained commits which are easy to review and pass CI is a higher-level skill that, in my opinion, takes years to hone**. So if it's not something you're used to doing, use the agent's planning abilities to break work into small, logical steps and **start learning this skill now**. Just ask: "How should we approach this feature in small, reviewable chunks?" It won't be perfect, but the agent can help you identify natural breakpoints through a larger code change and help you hone your skill to identify reviewable chunks of work.

This discipline benefits everyone: your reviewers get focused, understandable diffs and your future self gets code that is easier to understand and maintain with a cleaner git history. For what it's worth, I still often miss things I could have separated out from a larger change and end up stashing my current work, going back and branching from main, doing a quick "prequal" branch to my current work, getting that reviewed and landed and rebasing - just so my current work can stay focused on the actual change.

## 8: Do **watch and interrupt** the agent

Usually, for most non-trivial changes, I watch the agent work in real-time and will interrupt with "No, wait - why are you doing X" when I see it heading down a path I didn't expect - sometimes we'll continue once I understand, othertimes we'll change course.

But when the request is clear and I have guard-rails in place (tests and linters), I'll start the agent on a task and switch to something else - maybe reviewing another PR or grabbing a glass of water. When I switch back, I can read the summary of what was done and **review every change** made.

You'll learn when to watch versus when to switch tasks. Generally there's always something to learn while watching, so start by generally staying engaged. But **always review** - you are responsible for the code you're committing and need to understand and own it.

## 9: Give the agent automated tools to work with

Most agent-based (yes, I'm avoiding "agentic") tooling gives agents access to the same information which the IDE presents to humans - syntax issues, type checking - but you can also give the agent explicit instructions for running tests or linters. Adding relevant instructions for the agents workflow into your memory bank can automate this for each thread, saving you time in your own workflow.

## 10: Don't let speed become technical debt

This is more of a summary than a tenth tip, but the incredible speed of LLM agents can feel like a superpower while being a trap. The ease of generating code can help us move fast while accumulating technical debt, building a maintenance nightmare and potentially limiting our own learning and development.

So **maintain the same standards you'd have without the agent**. Own every line of code, take time to make each interaction with the agent a learning opportunity, and use that speed advantage to help you **design and build better software faster** while also **consistently building your own knowledge and skills** faster than you could otherwise.

When you get this balance right, LLM agents can become the best coding and learning partner you've ever had. When you get it wrong, they can become an expensive way to create maintenance nightmares and possibly limit your career.
