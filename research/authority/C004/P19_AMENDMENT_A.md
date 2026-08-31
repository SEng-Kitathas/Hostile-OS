# C004/P19 Amendment A — caller-provenance stack offset repair

Status: PRE-CLOSURE HARNESS/IMPLEMENTATION AMENDMENT AFTER UNKNOWN RUN

The first controlling attempt timed out after10s and is classified `UNKNOWN`, not mechanism FAIL. Partial trace showed incorrect caller classification (`A_READ=U`) and incomplete progression.

Cause: `mediated_handler` used `call derive_caller`. The call instruction pushes a return address, so inside `derive_caller` the CPU-saved user CS is at `[esp+8]`, not `[esp+4]`. The implementation incorrectly read `[esp+4]`, which is the mediator's own return address.

Correction: change only the caller-provenance read from `4(%esp)` to `8(%esp)` inside `derive_caller`.

The preregistered question, two caller code selectors, authority state, sequence, expected trace, switch-frame logic, evaluator, and authority ceiling are unchanged.
