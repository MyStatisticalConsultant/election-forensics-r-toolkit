# Changelog — voter_rigging

## 0.1.1

- Clarified the A (`B/E`) versus B (`C/E`) turnout definitions in Figure 4A subtitles.
- Added a dashed 50% reference line to every Figure 4B panel.
- Replaced underscores in public-facing election legend labels; added Serbian-Latin election names.
- Configured multirow legends with up to three entries per row.
- Changed Figure 4A's vertical axis to **Effect size, D(p)** / **Veličina efekta, D(p)** (italic p); `δ(p)` remains intentionally unavailable without a verified international reference set.
- Clarified that Figure 4B is identical under A and B, and preserved existing output filenames and CSV schemas.
- No changes to data preparation, reference standardization, ellipse trimming, `D(p)` calculation, or cumulative-share calculations.

## 0.1.0

- Initial descriptive `D(p)` and cumulative-vote-share module with bilingual Figure 4-style graphics, reproducible CSV diagnostics and supplementary exploratory checks.
