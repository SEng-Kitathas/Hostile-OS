# D64/FR01 implementation scars — 2026-08-30

Status: PRE-SCIENCE DEVELOPMENT HISTORY

## Duplicate assembly label during smoke compile

Before any FR01 disk image or QEMU science run existed, the initial stage2 draft contained an abandoned stub plus the real `binding_read_handle:` implementation, producing a duplicate-symbol assembler error:

```text
error: symbol 'binding_read_handle' is already defined
```

Disposition:
- no stage2 binary was produced by that failed compile;
- no fixture image was created;
- no QEMU process ran;
- the abandoned stub was removed;
- subsequent assembly, full link, and static/source smoke closure passed.

Science consequence: none. Retained because full project history includes pre-science implementation failures rather than silently erasing them.
