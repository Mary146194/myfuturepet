# My Future Pet public landing and staff entry

## Approved direction — 2026-10-20
Full public landing page for shelter staff and administrators; licensed rescue-themed photography; orange-and-white branding; restrained interactions; separate sign-in view. Impeccable composition/accessibility guidance and Taste existing-project workflow applied. The previous login-first and split-panel landing directions are replaced.

## Visual system
White dominates, with orange #ba4b26 actions and emphasis, ink #302b26, warm neutral secondary text and lightly tinted support surfaces. Self-hosted Manrope variable font with system fallback and font-display swap. Bounded layout up to 1280px, generous section spacing, asymmetrical hero, one photo per photographic section. Photography is illustrative and credited; never evidence of actual Jagna shelter activity. See src/assets/landing/SOURCES.md and the bundled font license.

## Public page hierarchy
Header with logo, Workspace/Partner shelter/Support anchors and staff entry. Hero with operational message, dog portrait and sign-in/explore actions. Workspace selector for rescue records, adoption reviews and visits. Partner-shelter narrative with animal-care image. Closing staff invitation, account-access disclosures and restrained footer with photography credits. No fictional activity, testimonials, statistics, dashboard simulation or public private-data fetches.

## Responsive interaction
Desktop tabs use linked panels, selected state, roving focus and Left/Right/Home/End keys. Below 768px, use stacked native disclosure panels. Mobile menu closes on Escape, returns focus to its trigger and closes on navigation or resizing to desktop. Hero content precedes photography on phones. Reduced-motion CSS removes transitions and the hero-image entrance. All anchors have real targets, with focusable section targets and a skip link. Failed photos retain a readable fallback.

## Staff entry and route contract
Signed-out / shows the landing. /sign-in shows the existing validated form and Back to website. Unknown paths redirect to /. Authorized sessions use the existing dashboard at / and redirect away from /sign-in. Supabase session/profile role checks, password visibility, Caps Lock notice, field validation, help, pending guard and error/loading behavior remain. No database or permission changes. Existing Vercel SPA rewrite retained.

## Verification
22 tests across 5 suites pass. Production build and git diff --check pass; Impeccable detector returned []. Browser reviewed desktop/mobile navigation, feature controls, support disclosures, direct sign-in reload, back-to-website and unknown-route redirect. Widths 320/390/667 landscape/768/1024/1440 checked without horizontal overflow. Sampled small-text/action contrast ratios 4.55–5.32:1; font and local images load. Real physical devices and live credential submission were not tested. No production deployment.

## Authenticated dashboard — 2026-10-20
The overview prioritizes operational work: actionable totals, application inbox, upcoming Philippine-time visits, recent pet roster and application breakdown. No sample records are used by the production component; screenshots use separate automated-test fixtures. Technical health claims were removed because they were not measured. Existing reports and management destinations remain accessible. Shared shell: white navigation, restrained orange active state, warm neutral canvas, bordered working panels, native section selector, accessible account menu, collapsible desktop rail and off-canvas phone navigation. Smaller screens stack work panels and keep status labels visible; tables scroll within their panel.
