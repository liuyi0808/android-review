# Intellectual Property Policy

## Table of Contents
- [IP.1 Core Prohibition](#ip1-core-prohibition)
- [IP.2 Trademark Infringement](#ip2-trademark-infringement)
- [IP.3 Copyright Infringement](#ip3-copyright-infringement)
- [IP.4 Encouraging Infringement](#ip4-encouraging-infringement)
- [IP.5 Counterfeit Goods](#ip5-counterfeit-goods)
- [IP.6 Financial App IP Risk Areas](#ip6-financial-app-ip-risk-areas)
- [IP.7 IP Compliance Checklist](#ip7-ip-compliance-checklist)

---

Google Play's Intellectual Property policy applies to **all apps**. Finance and loan apps are a high-risk category because unauthorized use of bank names, logos, or government/regulator marks is a recurring rejection cause.

**Policy reference**: [Intellectual Property](https://support.google.com/googleplay/android-developer/answer/9888072)

## IP.1 Core Prohibition

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9888072)):

> "We don't allow apps or developer accounts that infringe on the intellectual property rights of others (including trademark, copyright, patent, trade secret, and other proprietary rights)."

## IP.2 Trademark Infringement

**Policy definition** ([source](https://support.google.com/googleplay/android-developer/answer/9888072)):

> "Trademark infringement is improper or unauthorized use of an identical or similar trademark in a way that is likely to cause confusion as to the source of that product."

**Complaint channel**: Trademark owners can submit complaints via the [trademark complaint form](https://support.google.com/googleplay/android-developer/contact/ip_trademark).

## IP.3 Copyright Infringement

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9888072)): Apps that infringe copyright are prohibited. Examples cited by the policy include cover art, movie marketing materials, sports logos, and celebrity photos. Modifications to copyrighted content do not make the use permissible.

**Complaint channel**: [DMCA procedure](https://support.google.com/legal/answer/1120734).

## IP.4 Encouraging Infringement

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9888072)):

> "Apps that induce or encourage copyright infringement."

The policy specifically cites streaming apps that facilitate unauthorized downloads.

## IP.5 Counterfeit Goods

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/9888072)):

> "We don't allow apps that sell or promote for sale counterfeit goods."

Counterfeit goods are defined as those using "identical or substantially indistinguishable" trademarks to impersonate genuine products.

**Complaint channel**: [Counterfeit notice form](https://support.google.com/googleplay/android-developer/contact/counterfeit).

## IP.6 Financial App IP Risk Areas

The following are common IP violation patterns for financial and loan apps (audit guidance — derived from the general IP policy, not individually named in policy text):

| Risk Area | Example | Severity |
|-----------|---------|----------|
| Bank name / logo usage | App icon or branding uses "ICICI", "Bank of America", "HDFC" logo without authorization | BLOCKER |
| Regulator mark usage | App displays RBI, OJK, SEC, CBK, BoT logos without authorization | BLOCKER |
| Competitor app name | App title or description references competitor loan apps by name | BLOCKER |
| Store listing imagery | Screenshots or feature graphics use logos/images owned by banks or payment providers without license | BLOCKER |
| Partner misrepresentation | App claims partnership with a lender, NBFC, or bank that is not verifiable | BLOCKER |

**Relation to Deceptive Behavior**: IP violations involving bank or regulator brand misuse also commonly trigger the [Deceptive Behavior policy](https://support.google.com/googleplay/android-developer/answer/16680223) — the same asset may be rejected under both policies.

## IP.7 IP Compliance Checklist

**Code and asset audit**:

```bash
# Check strings.xml for bank / brand / regulator mentions:
grep -rn "Bank\|Banco\|RBI\|OJK\|SEC\|CBK\|BoT\|FCCPC\|SECP" --include="*.xml" app/src/main/res/values/

# Check app icon and graphic assets — manual review required for:
# - app/src/main/res/mipmap-*/ic_launcher*.png (app icon)
# - play-store-listing/icon.png, feature-graphic.png, screenshots/
# - Any drawable that resembles a bank/regulator logo
ls -la app/src/main/res/mipmap-*/ 2>/dev/null
ls -la app/src/main/res/drawable*/ 2>/dev/null

# Check manifest for label and app name references:
grep -n "android:label\|android:name" AndroidManifest.xml
```

- [ ] App name, icon, and branding do not copy or closely imitate any bank, lender, or regulator
- [ ] No unauthorized use of bank, NBFC, or regulator logos in assets, screenshots, or feature graphic
- [ ] Screenshots show only assets the developer owns or has licensed
- [ ] No claims of partnership with a lender, bank, or regulator that cannot be documented
- [ ] Store listing title does not reference competitor app names or trademarks
- [ ] All third-party fonts, icons, images have documented licenses
- [ ] Developer account name does not impersonate an established entity (e.g. "ICICI Loans Official" without rights)
- [ ] No copyrighted music, video, or text shipped with the app without a license
