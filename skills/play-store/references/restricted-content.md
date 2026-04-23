# Restricted Content Policy

## Table of Contents
- [RC.1 Scope](#rc1-scope)
- [RC.2 Child Endangerment](#rc2-child-endangerment)
- [RC.3 Sexual Content and Profanity](#rc3-sexual-content-and-profanity)
- [RC.4 Hate Speech](#rc4-hate-speech)
- [RC.5 Violence](#rc5-violence)
- [RC.6 Violent Extremism](#rc6-violent-extremism)
- [RC.7 Sensitive Events](#rc7-sensitive-events)
- [RC.8 Bullying and Harassment](#rc8-bullying-and-harassment)
- [RC.9 Dangerous Products](#rc9-dangerous-products)
- [RC.10 Marijuana](#rc10-marijuana)
- [RC.11 Tobacco and Alcohol](#rc11-tobacco-and-alcohol)
- [RC.12 Financial App Relevance](#rc12-financial-app-relevance)
- [RC.13 Restricted Content Checklist](#rc13-restricted-content-checklist)

---

## RC.1 Scope

Restricted Content policies apply to **all apps on Google Play**, regardless of category. For loan and financial apps, the main exposure surface is user-visible text: in-app copy, notifications, customer-support messages, marketing banners, and any assets shipped inside the APK.

**Policy reference**: [Developer Program Policy](https://support.google.com/googleplay/android-developer/answer/16810878)

## RC.2 Child Endangerment

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "Apps that do not prohibit users from creating, uploading, or distributing content that facilitates the exploitation or abuse of children will be subject to immediate removal from Google Play."

## RC.3 Sexual Content and Profanity

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that contain or promote sexual content or profanity, including pornography, or any content or services intended to be sexually gratifying."

## RC.4 Hate Speech

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that promote violence, or incite hatred against individuals or groups based on race or ethnic origin, religion, disability, age, nationality, veteran status, sexual orientation, gender, gender identity, caste, immigration status, or any other characteristic that is associated with systemic discrimination or marginalization."

## RC.5 Violence

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that depict or facilitate gratuitous violence or other dangerous activities."

## RC.6 Violent Extremism

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We do not permit terrorist organizations, or other dangerous organizations or movements that have engaged in, prepared for, or claimed responsibility for acts of violence against civilians to publish apps on Google Play for any purpose, including recruitment."

## RC.7 Sensitive Events

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that capitalize on or are insensitive toward a sensitive event with significant social, cultural, or political impact, such as civil emergencies, natural disasters, public health emergencies, conflicts, deaths, or other tragic events."

## RC.8 Bullying and Harassment

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that contain or facilitate threats, harassment, or bullying."

**Loan app note**: The Personal Loans policy and the Spyware policy separately prohibit harassment patterns used in debt collection (automated messages to contacts, threatening or shaming language). See `loan-harassment.md`. A violation in a loan app may be flagged under both Bullying and Harassment and the Personal Loans policy.

## RC.9 Dangerous Products

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that facilitate the sale of explosives, firearms, ammunition, or certain firearms accessories."

## RC.10 Marijuana

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that facilitate the sale of marijuana or marijuana products, regardless of legality."

## RC.11 Tobacco and Alcohol

**Policy** ([source](https://support.google.com/googleplay/android-developer/answer/16810878)):

> "We don't allow apps that facilitate the sale of tobacco or products containing nicotine (such as e-cigarettes, vape pens and nicotine pouches) or encourage the illegal or inappropriate use of alcohol, tobacco, or nicotine."

## RC.12 Financial App Relevance

Compliant loan apps do not sell or promote any of the products above. The most common ways restricted-content issues appear in a loan app are:

| Surface | Risk | Example |
|---------|------|---------|
| In-app strings | Harassment / threatening language in overdue notifications | "We will expose you" / insulting debtor language |
| Customer support chat | Agents or chatbot using abusive or discriminatory language | Scripts or AI responses not moderated |
| Marketing banners | Insensitive imagery during a sensitive event | Ads referencing an active civil emergency |
| Store listing copy | Discriminatory targeting language | "Only for [group]" phrasing |
| Bundled assets | Copyrighted music/video that also includes restricted content | Promo video with violence |

**Code audit**:

```bash
# Scan string resources for threatening / harassing language:
grep -rn --include="*.xml" -iE "(expose|shame|humiliate|threaten|warn your contacts|amenaza|amenazar|vergüenza)" app/src/main/res/values*/

# Scan notifications / messages for harassment patterns:
grep -rn --include="*.kt" --include="*.java" -iE "(expose|shame|threaten|public)" | grep -iE "(notif|message|sms|push)"

# Scan for discriminatory targeting in copy:
grep -rn --include="*.xml" -iE "(only for|solo para|excluded|not eligible).*(race|religion|gender|caste|nationality|age)" app/src/main/res/values*/
```

## RC.13 Restricted Content Checklist

- [ ] No sexual content, profanity, or gratuitous violence in any in-app text, image, audio, or video
- [ ] No hate speech or content inciting hatred against protected groups in app copy, notifications, or support messages
- [ ] No threatening, shaming, or harassing language in overdue / collection notifications (see also `loan-harassment.md`)
- [ ] Customer-support scripts and AI chatbot responses reviewed for harassment and discrimination
- [ ] No promotion or facilitation of sales of firearms, explosives, marijuana, tobacco, nicotine, or alcohol
- [ ] Marketing and promotional material does not reference active sensitive events (natural disasters, conflicts, public health emergencies) in a way that capitalizes on them
- [ ] Store listing assets (screenshots, feature graphic, description) contain none of the restricted content categories above
- [ ] Bundled media assets (videos, music, sounds) reviewed for restricted content
