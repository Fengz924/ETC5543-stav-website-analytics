# STAV presentation script

13 main slides including the title opening. The supplied PDF splits several slides over two pages. Match slides using both the title and the PDF page reference below. Rounded figures are speaking approximations; exact figures remain on the slides. Planned time is about 10 minutes including the Shiny demonstration.

## Slide 1: Understanding STAV’s contacts and website use

PDF pages: 1. Target: 10 seconds.

Good morning. Today I will present my analysis of STAV’s contact and website data, and the Shiny dashboard I built to explore the findings.

中文提示：开场：先说业务目标，再介绍两个数据源。

## Slide 2: Business questions and data

PDF pages: 2–3. Target: 40 seconds.

This project uses two separate sources. The CRM snapshot contains about six thousand contact records. The website data covers July twenty twenty-five to June twenty twenty-six, with about fifty-six thousand Active Users. The CRM helps us examine contact and membership information. GA4 helps us understand website use. These are different populations, and I did not link individual website users to CRM contacts.

中文提示：说明时间、分析单位和没有进行个人层面关联。

## Slide 3: CRM and website analysis workflow

PDF pages: 4–5. Target: 50 seconds.

I organised the work into two streams. For the CRM, I validated the import, standardised fields and reviewed contact and membership information. For school names, fuzzy matching generated possible matches, which Catie reviewed before they entered the approved mapping. For GA4, I grouped pages into business categories and compared traffic, content use and tracking gaps. The two streams lead to recommendations for STAV.

中文提示：突出 fuzzy matching 是候选生成，人工审核才确认；不要声称具体算法或阈值。

## Slide 4: Fuzzy matching supports school name standardisation

PDF pages: 6. Target: 65 seconds.

The reviewed mapping contains over five hundred school-name variations for two hundred and fifty approved schools. Almost two-thirds of those schools have more than one name. Rather than reading every bar, I will use the example below. Caulfield Grammar School has nine name variations, including the shorter name Caulfield Grammar and a name referring to its Malvern campus. The mapping links these to an approved school while keeping campus information separate. This supports future standardisation. It does not mean that the underlying CRM records have already been merged.

中文提示：强调64%的分母是已审核250所学校；mapping ≠ 已经改好CRM。

## Slide 5: CRM review priorities

PDF pages: 7. Target: 55 seconds.

The CRM checks highlight three review priorities. First, about fourteen hundred records share a name with another record. Most candidates share only a name, so they are not confirmed duplicates. Second, thirty percent of school-plan records have no organisation recorded. Third, about fifty records are marked Active despite an end date before the snapshot. These findings help STAV prioritise checks. They do not prove that a contact is duplicated or a membership is invalid.

中文提示：联系人同名检查与学校fuzzy matching分开；49条不能直接叫过期会员。

## Slide 6: CRM review examples

PDF pages: 8–9. Target: 40 seconds.

These examples show what a review flag means. Two records with the same name and school but different emails could represent one person or two colleagues. A school-plan record with a blank organisation needs its school link confirmed. An Active record with an earlier end date needs checking against renewal and entitlement rules. Each case needs review before changing the CRM.

中文提示：三个例子是报告类别的示意，不是真实联系人明细。重点说下一步怎么核查。

## Slide 7: Website traffic terminology

PDF pages: 10–11. Target: 45 seconds.

Before the traffic results, here are the main terms. Direct means GA4 did not identify another referring source. It can include bookmarks or missing attribution. Organic Search means unpaid search results, such as Google or Bing. Referral means a link from another website. A session is a period of website interaction, so one person can generate several sessions. Engagement rate describes the share of sessions meeting GA4’s engagement criteria. It is not a membership conversion rate.

中文提示：先解释术语再讲图。Direct不只是输入网址；session不是人数；参与率不是转化率。

## Slide 8: Search generates substantial website traffic

PDF pages: 12. Target: 50 seconds.

About half of channel sessions came through Direct, and around forty-four percent came through Organic Search. Together, they contributed roughly ninety-four percent. Referral was much smaller, at around five percent. Search sessions also had a higher engagement rate: about sixty percent, compared with about thirty percent for Direct. The practical message is to protect important search entry pages when changing URLs. Higher engagement alone does not establish greater business value.

中文提示：Direct不只是手动输入网址；参与率不等于商业价值。

## Slide 9: Science Talent Search leads content use

PDF pages: 13. Target: 50 seconds.

Science Talent Search, or STS, was the leading content category. It accounted for about one-third of entry sessions and just over one-third of page views. That is roughly sixty-eight thousand views across the year. Entry sessions describe where visits begin, while page views include repeated viewing throughout a visit. STS viewing also varied substantially: around ten thousand views in the peak month, compared with just over one thousand in the quietest month. This supports prioritising STS content maintenance. The data alone does not explain the cause of the monthly changes.

中文提示：解释入口与浏览量不同；不要把浏览量解读为完成任务。

## Slide 10: Tracking gaps limit outcome measurement

PDF pages: 14–15. Target: 65 seconds.

GA4 recorded around twenty-one thousand form starts, twelve thousand form submissions and ten thousand downloads. But those totals do not tell us which forms or resources generated the activity. We also cannot divide starts and submissions to calculate a completion rate, because the records do not establish the same form journey. At the reported inspection, recent interaction events were not marked as Key Events. Missing events, missing detail and Key Event settings are different issues. STAV needs to audit important actions before measuring outcomes reliably.

中文提示：关键页：没记录、缺参数、没设Key Event是三个问题；具体完全缺失的行为需要现场验证。

## Slide 11: Shiny app: what I built

PDF pages: 16–17. Target: 60 seconds.

I built the Shiny app to make the prepared findings easier to explore. I added input checks for required fields, export dates and duplicate monthly rows. I also implemented filters that update the charts and summaries. Here, I can select a channel and compare it with the previous calendar month. Missing data stays unavailable rather than becoming zero. For engagement, changes use percentage points. Users can also explore content categories and download filtered results. Separate configuration and fictional demo data make the app easier to maintain and demonstrate. It remains a local prototype using prepared data.

中文提示：按“我实现了什么→为什么这样设计”来讲，不要只读页面功能。约60秒内，演示Traffic筛选和月度对比，再切Content说明导出；输入验证和配置用一句话带过。图中公式是实现逻辑示例，不是新的分析结果。

## Slide 12: Recommendations for STAV

PDF pages: 18–19. Target: 45 seconds.

The recommendations follow the evidence. For CRM, standardise reviewed school names and check priority records using agreed membership rules. For the website, prioritise STS maintenance and protect important search entry points. For measurement, audit tags, add useful event details and define meaningful Key Events. Dated CRM interactions would also support future engagement reporting. The dashboard supports exploration, while these data improvements remain future work.

中文提示：讲建议如何对应证据，别声称已经实施或带来改善。

## Slide 13: Conclusions

PDF pages: 20. Target: 25 seconds.

To conclude, the project provides a reviewed school mapping, targeted CRM checks and evidence for website priorities. The Shiny app makes those findings easier to explore. Better tracking and interaction history would support stronger outcome measurement. Thank you. I welcome your questions.

中文提示：总结贡献与实际价值，停下来进入问答。

## Number pronunciation guide

Use these rounded phrases in speech. Keep exact figures on the slides.

- 6,051 CRM records: “about six thousand contact records”.
- 55,599 Active Users: “about fifty-six thousand Active Users”.
- 544 school-name variations: “over five hundred school-name variations”.
- 160/250 or 64%: “almost two-thirds of the reviewed schools”.
- 1,379 same-name candidates: “about fourteen hundred candidate records”.
- 189/630 or 30%: “thirty percent of school-plan records”.
- 49 Active records: “about fifty records”.
- Direct 50.6%, Organic Search 43.5%, together about 94%: “about half”, “around forty-four percent”, “roughly ninety-four percent”.
- Engagement 59.3% versus 29.2%: “about sixty percent compared with about thirty percent”.
- STS entry share 31.7% and view share 35.3%: “about one-third of entry sessions and just over one-third of page views”.
- 68,467 STS views: “roughly sixty-eight thousand views”.
- Peak 10,082 and low 1,114 STS views: “around ten thousand” and “just over one thousand”.
- 20,562 form starts; 11,890 submissions; 9,756 downloads: “around twenty-one thousand”, “twelve thousand”, “ten thousand”.

中文提示：数字前保留 about、around、roughly，明确是近似值。不要逐个朗读每条柱状图或所有分母。年份读 twenty twenty-five / twenty twenty-six。技术问答需要精确数字时，再看幻灯片上的值。

## Shiny demo run sheet (60 seconds, speak while operating)

Before presenting, run from the project root in RStudio:

```r
source('apps/stav-dashboard/check_data.R')
shiny::runApp('apps/stav-dashboard', launch.browser = TRUE)
```

- 0–15 seconds: Briefly point to input validation on the slide, then switch to the running app. Explain that prepared CRM summaries and monthly GA4 exports feed the dashboard.
- 15–40 seconds: GA4 Traffic. Select Organic Search. Show that the chart and summary respond. Point to the previous calendar month comparison. Explain that missing months are unavailable and engagement changes use percentage points.
- 40–55 seconds: GA4 Content. Select Science Talent Search and point out the filtered table and download control. Mention that configuration is separate and a fictional demo mode is available.
- 55–60 seconds: Return to the recommendations slide.

Keep the full script as rehearsal material, not a second narration before the demo. If you run out of time, show one filter and the comparison only. If the app cannot open, explain the implementation table and continue. Label fictional demo data explicitly. The app uses prepared snapshots, not automatic CRM updates or website-to-membership conversion linkage.

## Lecturer’s Q&A tips and useful phrases

These tips come from the lecturer’s message supplied by the presenter.

1. **Understand the question.** Ask for clarification before answering if needed: “Do you mean the fuzzy matching method, or the manual review of the mapping?” / “Are you asking about recorded membership status or engagement?”
2. **Take your time.** Pause, then respond: “Let me think about that for a moment.” Give the main answer first and support it with evidence.
3. **Turn uncertainty into discussion.** State the boundary honestly, then invite guidance: “We did not address that in this analysis. One possible next step would be to validate it against an authoritative source. Do you have suggestions for how we could approach that?” Avoid inventing an algorithm, result or causal explanation.
4. **Treat questions as feedback.** Listen and note useful ideas: “That is a useful suggestion. It could help us improve the next stage of the analysis.”

**Example for a difficult matching question:** “The mapping uses manually reviewed candidates. I have not reported a validated precision estimate, so I cannot claim a particular accuracy. Would a labelled validation sample be an appropriate way to evaluate it?”

**Example for a tagging question:** “The annual exports show some recorded events but limited business context. I would start by testing important actions and checking their parameters. Are there particular STAV outcomes you would prioritise?”

**Example for conversion:** “We did not link individual website users to CRM contacts in this analysis. What evidence would you recommend collecting to evaluate the website’s contribution to membership outcomes?”

## Q&A preparation

**Why use fuzzy matching?** Exact matching misses spelling and naming variations. Fuzzy matching proposes candidates for human review. Similarity alone does not confirm school identity.

**Which algorithm and threshold did you use?** Confirm this from the original candidate-generation code before presenting an exact metric or threshold. The mapping builder reads the reviewed candidate file and does not establish the original matching algorithm.

**Are the 1,379 records duplicates?** They share normalised names. Additional organisation and phone evidence helps review, but identity needs confirmation.

**Did you clean the live CRM?** The reviewed mapping provides a basis for standardisation. The analysis does not establish that live records were merged or changed.

**Does GA4 track nothing?** GA4 records some events. The available data lacks sufficient detail for some business questions, and important actions need a tracking audit. A Key Event setting is distinct from whether an event fires.

**What should STAV tag?** First choose important business actions, then test the existing implementation. Add missing events or parameters such as form_name, file_name and resource_type where needed. Confirm events fire correctly before selecting Key Events.

**Did you measure conversion or dormant contacts?** No. The available aggregate events cannot establish a linked form completion rate, and the CRM lacks adequate dated interaction history for a reliable dormancy classification.
