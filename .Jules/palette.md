## 2024-05-23 - Micro-interactions matter

**Learning:** Users (even simulated ones!) appreciate knowing what a button does before they click it, especially for "destructive" or "state-changing" actions like advancing time.
**Action:** Always add `Tooltip`s to primary action buttons that perform significant state changes.

## 2024-05-23 - Visual context needs semantic translation

**Learning:** Visual indicators like a circular progress bar with a number inside are intuitive for sighted users but ambiguous for screen readers ("55" vs "55 out of 100").
**Action:** When overlaying text on a progress indicator, use `ExcludeSemantics` on the indicator and add a descriptive `semanticsLabel` to the text to provide context (e.g., "X out of Y").
