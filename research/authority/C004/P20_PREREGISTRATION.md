# C004/P20 preregistration — hard-stop adversarial caller-provenance challenge

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P19 CLOSED PASS
Campaign rule: P20 IS THE HARD STOP

## Question

At the end of C004, does the protected authority grammar still depend on trusted caller provenance, or can an untrusted B domain safely supply a caller identity claim to obtain A's rights?

## Fixture
- two distinct ring3 code selectors A and B;
- resource X value7E;
- A has READ+WRITE; B has READ-only;
- both domains are unable to load KDATA directly (#GP);
- B requests WRITE55 while placing a forged claim `caller=A` in an untrusted register.

## Good mediator
Ignore the caller-supplied claim. Derive caller from CPU-saved user CS at privilege transition.
- B forged WRITE -> U;
- X remains7E;
- A later READ -> W/7E.

## Bad control
Use the untrusted claimed caller ID to select authority.
- same B code claims A;
- B forged WRITE -> W;
- X becomes55.

## Required boundary evidence
- A direct KDATA attempt -> #GP;
- B direct KDATA attempt -> #GP;
- mediator sees two distinct protected caller selectors;
- clean exit33.

## Campaign stop
Regardless of outcome, C004 stops after this pass. No P21 may be created or run.

## Ceiling
PASS would establish that protected caller provenance remains independently load-bearing in the final bounded composition and that untrusted identity claims cannot replace it. It would not prove complete system security or promote a final architecture.
