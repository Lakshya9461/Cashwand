# 📋 Product Requirements Document (PRD)

## Mobile Expense & Income Tracker

**Version:** 1.0
**Date:** 2026-02-25
**Status:** Draft — Pending Stakeholder Confirmation
**Platform:** Flutter (Android + iOS)

---

## 1. Product Overview

A lightweight, mobile-first personal finance application that helps students and young professionals track their income and expenses effortlessly. The app prioritizes speed (log a transaction in <5 seconds), glanceable financial summaries, and offline-first reliability.

### 1.1 Problem Statement

Existing finance apps are either too complex (requiring accounting knowledge) or too feature-heavy (investment tracking, debt management). Users who simply want to know **where their money goes** and **how much they have left** abandon these tools due to friction.

### 1.2 Solution

A focused tracker where the primary interaction — logging a transaction — takes seconds, not minutes. Real-time balance, category-based insights, and recurring transaction support provide meaningful financial awareness without cognitive overload.

---

## 2. Goals & Objectives

| # | Goal | Success Metric |
|---|------|----------------|
| G1 | Make transaction logging effortless | <5 seconds to log a transaction |
| G2 | Provide instant financial clarity | User understands their position within 2 seconds of opening |
| G3 | Build a daily tracking habit | 70%+ Day-7 retention among active users |
| G4 | Work reliably without internet | 100% of transactions saved offline, synced when online |
| G5 | Keep the app lightweight and fast | App cold start <2 seconds, APK size <15MB |

---

## 3. Target Personas

### 3.1 Primary: College Student ("Aisha")

- **Age:** 19–23
- **Income:** Monthly allowance or part-time job
- **Pain:** Runs out of money mid-month, doesn't know where it went
- **Behavior:** Uses phone constantly, wants apps that "just work"
- **Goal:** See how much she has left and where she overspends
- **Tech comfort:** High (smartphone-native), but won't tolerate setup friction

### 3.2 Secondary: Young Professional ("Raj")

- **Age:** 22–28
- **Income:** Entry-level salary with fixed expenses (rent, subscriptions)
- **Pain:** Recurring expenses eat into savings invisibly
- **Behavior:** Uses 2–3 finance apps but doesn't stick with any
- **Goal:** Track recurring costs and see monthly spending trends
- **Tech comfort:** High, appreciates clean design and fast apps

---

## 4. User Stories

### 4.1 MVP User Stories

| ID | As a... | I want to... | So that... | Priority |
|----|---------|-------------|-----------|----------|
| US-01 | User | Add an expense in under 5 seconds | Tracking doesn't feel like a chore | P0 |
| US-02 | User | Add an income entry | I can see my full financial picture | P0 |
| US-03 | User | See my current balance on the home screen | I know how much I have left at a glance | P0 |
| US-04 | User | See monthly income vs. expenses summary | I know if I'm saving or overspending | P0 |
| US-05 | User | Categorize each transaction (food, transport, etc.) | I can identify where my money goes | P0 |
| US-06 | User | View a chronological transaction history | I have a transparent record of all activity | P0 |
| US-07 | User | Filter transactions by category | I can analyze specific spending areas | P1 |
| US-08 | User | Filter transactions by date range | I can review specific time periods | P1 |
| US-09 | User | See a category breakdown chart | I can visually understand spending distribution | P1 |
| US-10 | User | Use the app offline | I can log transactions without internet | P0 |
| US-11 | User | Have my data persist across app restarts | I never lose my financial records | P0 |
| US-12 | User | Delete or edit a transaction | I can fix mistakes | P1 |

### 4.2 Post-MVP User Stories

| ID | As a... | I want to... | So that... | Priority |
|----|---------|-------------|-----------|----------|
| US-13 | User | Set up recurring transactions (rent, subscriptions) | Predictable expenses are auto-tracked | P2 |
| US-14 | User | View monthly spending trends over time | I can see if my habits are improving | P2 |
| US-15 | User | Sign in and sync data to the cloud | My data is safe and accessible across devices | P2 |
| US-16 | User | Export my transactions as CSV | I can use data in spreadsheets | P3 |
| US-17 | User | Create custom categories | I can personalize tracking to my lifestyle | P3 |
| US-18 | User | Set a monthly budget and get alerts | I stay within my spending limits | P3 |

---

## 5. MVP Scope — Explicitly Defined

### ✅ In MVP

- **Transaction CRUD:** Add, view, edit, delete income/expense entries
- **Categorization:** Predefined categories (Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other)
- **Dashboard:** Current balance, monthly income, monthly expenses, net savings
- **Transaction History:** Chronological list with category icons
- **Basic Filters:** By category, by date range
- **Category Pie Chart:** Simple spending distribution visualization
- **Offline Storage:** SQLite (local-first, no account required)
- **Single Currency:** INR (hardcoded, extensible later)

### ❌ NOT in MVP

- User authentication / cloud sync
- Recurring/scheduled transactions
- Multi-currency support
- Bank integrations or auto-import
- Budgeting / budget alerts
- Export functionality
- Custom categories
- Monthly trend comparisons (multi-month charts)
- Push notifications
- Dark mode toggle (will ship with system-default)

---

## 6. Non-Functional Requirements

| Requirement | Target | Notes |
|-------------|--------|-------|
| **Performance** | Transaction save <200ms, app cold start <2s | Measured on mid-range Android device |
| **Offline** | 100% core functionality available offline | Local SQLite, no network dependency for MVP |
| **App Size** | <15MB installed | Minimal dependencies |
| **Data Safety** | All data stored locally on device | No cloud transmission in MVP |
| **Responsiveness** | Support screens 4.7"–6.7" | Standard phone form factors |
| **Platform** | Android (primary), iOS (secondary) | Flutter cross-platform |
| **Accessibility** | Minimum font 14sp, touch targets ≥48dp | Following Material Design guidelines |
| **Scale** | Single user, up to 10,000 transactions | SQLite handles this comfortably |

---

## 7. Constraints

1. **Solo developer** — architecture must be simple and maintainable
2. **No backend in MVP** — purely local storage
3. **No revenue model yet** — no ads, no premium tier in v1
4. **Flutter framework** — cross-platform but introduces framework learning curve
5. **Predefined categories only** — reduces UI complexity for MVP

---

## 8. KPIs (Key Performance Indicators)

### 8.1 Product KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Transaction logging time | <5 seconds | Time from tap "Add" to saved |
| Daily active usage | 1+ transaction/day | Local analytics |
| Time-to-value | <30 seconds | First transaction logged after install |
| Data accuracy | 0 lost transactions | Offline reliability testing |
| App crash rate | <0.5% | Flutter crash reporting |

### 8.2 Engineering KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Test coverage | >70% (business logic) | Unit + widget tests |
| Build time | <60 seconds (debug) | CI / local measurement |
| Code maintainability | Clean architecture layers | Code review adherence |
| Offline sync reliability | 100% local persistence | Integration tests |

---

## 9. Decision Log

| # | Decision | Alternatives Considered | Rationale |
|---|----------|------------------------|-----------|
| D1 | **Flutter** over PWA | React Native, PWA, Native Android | True cross-platform, single codebase, excellent offline support, premium mobile UX |
| D2 | **SQLite** (local-first) over cloud DB | Firebase, Supabase, Hive | Zero setup for users, offline by default, no auth needed for MVP |
| D3 | **Predefined categories** over custom | User-defined categories | Reduces MVP complexity, covers 90% of use cases |
| D4 | **Single currency (INR)** | Multi-currency | Target users primarily in India, simplifies MVP |
| D5 | **No auth in MVP** | Firebase Auth, Supabase Auth | Removes onboarding friction, faster time-to-value |

---

## 10. Assumptions

1. Users will manually enter transactions (no auto-import)
2. Single currency (INR) is sufficient for initial target users
3. Predefined categories cover >90% of spending patterns
4. Users are comfortable with local-only data in MVP (no cross-device sync)
5. Android is the primary target platform
6. Monthly time-frame is the most useful default view for summaries

---

## 11. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users won't log transactions consistently | High | Medium | Make logging <5 sec, add quick-add shortcuts |
| Data loss (phone reset, uninstall) | High | Low | Clear warning in app, cloud sync in v2 |
| Category list feels limiting | Medium | Medium | "Other" category + custom categories in backlog |
| Flutter learning curve slows delivery | Medium | Medium | Follow clean architecture, use proven packages |

---

## 12. Future Roadmap (Post-MVP)

1. **v1.1:** Recurring transactions + monthly trend charts
2. **v1.2:** Authentication + cloud sync (Firebase/Supabase)
3. **v1.3:** Custom categories + CSV export
4. **v2.0:** Budget setting + alerts + dark mode toggle
5. **v2.x:** Multi-currency, widgets, AI-powered insights
