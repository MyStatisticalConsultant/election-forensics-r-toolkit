# Election Forensics R Toolkit v1.7.9 — clean consolidated publication

[Srpski (latinica)](RELEASE_NOTES_SER_v1.7.9.md)

**Klimek module:** v0.1.4. **Descriptive Statistics:** v0.3.1. **RZS Data Preparation:** existing version unchanged.

This clean GitHub snapshot replaces the earlier root-level patch-by-patch instructions and superseded development release notes. It includes one current release-note pair, the current documentation, the full three-module source tree, tests, examples, licences, reference files and refreshed SHA-256 manifests. The original historical commits and the module changelogs preserve development history.

**Klimek changes consolidated from v0.1.3.4-dev:** multilingual graph titles, full group subtitles, A/B visual formatting, standard/JHK separation, 10-point percentage ticks, RZS special district labels, 0/1/multiple-station plotting and complete zero-station territorial rows. **No analytical R source code or numerical formulas were changed for this clean publication.** The two other modules' R sources are unchanged from the previous consolidated snapshot.

**Validation confirmed by the researcher:** All Klimek tests and end-to-end checks passed for presidential 2017, presidential 2022 and parliamentary 2022. The detailed console log supplied for parliamentary 2022 records 7,787 Main stations, 480 QC-accepted stations below 100, 436 figures and a passing export check. For the two presidential elections the author confirmed PASS without supplying equivalent console transcripts. See the [validation record](modules/klimek/VALIDATION_RECORD_2026-10-23.md). Tests were not independently rerun by the release packager.

**Public repository scope:** Maintainer-only instructions for uploading, replacing repository contents and release checklists are kept privately, outside this distribution. Public README, workflow, module registry, release notes, validation evidence, methods and contributing documents remain in the repository.

These are descriptive cumulative curves; neither their shapes nor these software tests prove electoral misconduct or constitute the complete JHK inferential test.
