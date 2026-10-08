---
name: benchmark-checklist
description: Use when you report, compare, or act on a number that you measured, such as a speedup, a regression, a throughput, a latency, a benchmark result, or an eval result. Do NOT use to measure Core Web Vitals or to audit page load (`web-perf`); use this skill to vet the numbers that `web-perf` or any other tool produces.
origin: backnotprop/pstack@3a60467 (MIT)
---

# Benchmark Checklist

Use this skill before you trust, report, or act on a measured number. Examples are a before-and-after comparison, a regression claim, a harness for a metric, and a choice between libraries or configurations. Answer each question with evidence from a run. Do not answer from a guess about the code.

## Why

A measured number is a claim about a system. A run that failed can still print a plausible number. Failed requests, a cache that skipped the work, code that did not run, an untuned side, and run-to-run noise all produce numbers that look correct. If you cannot say why the number is not two times better, you do not know what you measured.

## Terms

- **Run:** one execution of the measurement.
- **Side:** one option in a comparison, such as the baseline or the change.
- **Limiter:** the resource or code path that bounds the result, such as a core, a lock, the disk, the network, or the load generator.

## Quick estimate

The user can ask for a quick estimate. Then one run is sufficient. Still answer questions 4 and 7, and say that the result comes from one run. Do the other questions only if that run looks incorrect. A choice between options is never a quick estimate.

## Before you run the measurement

1. Write the claim that you expect to make, in the words that you will report. Example: "Export is 30% faster at p50 on the 60k-row dataset." The questions test that sentence.
2. Read the measurement script.
3. Write what the script times, what it counts, and what it ignores.
4. Check the load average with `uptime` and the core count with `nproc` (or `sysctl -n hw.ncpu` on macOS).
5. If the machine is busy, find the processes that cause the load.
6. If you cannot stop those processes, alternate the sides so that both sides get the same noise. Say this in the report.

## The seven questions

1. **Why not double?** Name the limiter.
   - Profile in a separate run that you do not report, because profilers make the work slower.
   - Use CPU per process (`top`, `pidstat`), a runtime profiler (`node --cpu-prof`, `py-spy`, `perf`), I/O wait, and syscall counts (`strace -c` on Linux).
   - Map the hot spot to the source code.
   - Monitor the load generator. If it saturates first, you measured the load generator.
   - If a change did not change the number, the limiter tells you why. Find the limiter before you call the change useless.
2. **Was it tuned?** Run each side the same way that production runs it.
   - Use release builds, production flags and environment, batch and transaction settings, connection pools, and production cache state.
   - Use the same versions and the same data on all sides.
   - If one side runs on defaults, you compared configurations, not implementations.
   - A limiter that is a setting makes that side untuned. Examples are a commit per row, a debug build, and a missing index.
   - Tune that side and measure again before you select a winner. If you cannot tune it, do not select a winner from that run.
   - A narrower claim about "the code as it ships today" does not solve this problem when the user selects an option to adopt.
3. **Did it break limits?** Do the arithmetic.
   - Compare bytes per second with the disk and network bandwidth.
   - Compare operations per second, multiplied by the cost per operation, with the available cores.
   - Compare the time saved with the time that the changed part used. If you remove a part that uses 10% of the run, the run is at most about 11% faster.
   - A result past a limit means that the run measured something other than the work. Examples are a cache, a no-op, and a bug.
4. **Did it error?** Count failures and non-success responses.
   - Check that the outputs are correct, not only present.
   - Errors have different timing from successes. Rejections are often fast. Timeouts and retries are slow.
   - If the script does not count errors, add the count.
5. **Does it reproduce?** Run each side at least 5 times.
   - Alternate the sides (A, B, A, B) so that warmup, lazy initialization, caches, and drift do not help one side.
   - Report the median and the range.
   - A gap that is smaller than the run-to-run variation is no measurable difference.
   - When the result is close, use a rank-sum test or the statistics of the harness.
6. **Does it matter?** Measure the end-to-end path that a user waits on, next to each micro result.
   - Use realistic data sizes and concurrency.
   - Report the micro result as a percentage of the end-to-end time.
   - A helper that uses 1% of a request can make the request at most 1% faster.
7. **Did it even happen?** Confirm that the work ran inside the timed region.
   - Confirm that the request arrived at the server and the rows were written.
   - Confirm that the bytes were read and the code used the result.
   - Lazy code and timeouts produce numbers for work that did not occur. Examples are generators that nothing iterates, promises that nothing awaits, and results that the JIT can discard.

## Eval results

Apply the same method to an eval result. Confirm that each trial did the task. Confirm that the gap holds across trials and models. Confirm that the scenario is relevant to real use.

## Report

- Start with the verdict: faster, slower, no measurable difference, or inconclusive.
- Give the number with its unit, the run count, the range, and the limiter. Example: "p50 41 ms → 33 ms, median of 7 runs per side, range 32 to 35 ms after, bound by JSON parsing on one core."
- Give the verdict "inconclusive" when you claim a difference but cannot name the limiter.
- Give the verdict "inconclusive" when a side ran untuned.
- Give the verdict "inconclusive" when you could not answer questions 4 and 7. Name the gap.
- In a short summary, such as a PR body, give one primary number. Put the runs, the range, and the limiter evidence in a linked artifact or a notes file.

## Signs that you did not use this skill

- The evidence for a number has no run count, no range, or no named limiter.
- The time saved is larger than the time that the changed part used.

## Boundary with `web-perf`

The `web-perf` skill measures Core Web Vitals and page-load behavior. This skill does not measure page load. This skill vets any measured number, including the results that `web-perf` produces.
