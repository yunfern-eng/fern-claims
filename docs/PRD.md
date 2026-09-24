## Problem

Each month, Director PAs / admins must gather invoices from multiple email accounts and platforms, sort them by company, match them against the credit-card statement, and produce an executive summary of expenditure. This is slow, error-prone, and manual.

## Target User

Director PA (primary), Director (review), Accountant (final check).

## Core Objects

- **Company** — entity claims are filed for (e.g. subsidiary or brand).
- **Invoice** — a downloaded or uploaded invoice PDF with vendor, amount, date, category.
- **CCStatement** — monthly credit-card statement upload; contains CCStatementLine items.
- **Claim** — a grouped set of invoices for one company in one period.
- **ExpenditureSummary** — auto-generated executive summary per claim.

## MVP (v1) — checklist

- [ ] Upload / import invoices (file upload + manual entry).
- [ ] Upload CC statement; parse into line items.
- [ ] Match invoices to CC statement lines.
- [ ] Group invoices into a claim by company + period.
- [ ] Auto-generate executive expenditure summary (totals by category, vendor, company).
- [ ] Export claim summary (PDF/CSV).

## Non-goals (v1)

- No mobile app.
- No email auto-ingest (manual upload only in v1).
- No multi-tenant SaaS — internal tool for one team.
- No payments / reimbursements.

## Success Criteria

A PA uploads 10 invoices + a CC statement, matches them to statement lines, groups into a claim for one company, and exports an executive summary showing total spend broken down by category and vendor — end to end in one session.