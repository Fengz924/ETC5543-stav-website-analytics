# STAV Shiny dashboard

## 日常启动

在 RStudio 打开仓库的 `.Rproj`，在 Console 运行：

```r
source('apps/stav-dashboard/check_data.R')
shiny::runApp('apps/stav-dashboard', launch.browser = TRUE)
```

点击 Stop 停止；修改配置或数据后需要重新启动。

## 更新数据：先修改 config.R

`apps/stav-dashboard/config.R` 是唯一的路径和日期配置入口：

- `title`：App 标题。
- `crm$summary_dir`：已生成的 CRM 汇总 CSV 文件夹。
- `crm$snapshot_date`：该批汇总对应的原始导出日期（YYYY-MM-DD）。
- `ga4$start_date`、`end_date`：GA4 导出期间，必须覆盖完整月份。
- `ga4$traffic_file`、`pages_file`：月度渠道、月度页面导出文件路径。
- `ga4$header_lines`：CSV 列名前的说明行数，目前为 9。

所有数据路径相对于仓库根目录。配置不包含密码。

### 更新 GA4

1. 从 GA4 导出相同维度和指标的两份月度 CSV，放入本地数据目录。
2. 在配置中修改两个文件路径及报告起止日期。
3. 运行 `check_data.R`，通过后重启 App。

年份由配置期间自动映射，无需修改绘图代码。导出说明中的起止日期必须匹配配置。由于目前导出只有月份数字，报告期间不能包含两个同名月份（例如两年的 January）；超过 12 个月需改用含年月维度的导出。各表中不存在的行不会被自动解释为零，检查也不能证明导出没有被截断。

### 更新 CRM：当前仍需先生成汇总

App 读取已有分析汇总，不直接读取原始联系人数据。只换原始 CRM 文件不会更新页面。

现有 `R/CRM/prepare_crm.R` 使用 `docs/CRM/source_contract.json` 验证特定导出；`reports/CRM/02_crm_analysis_report.qmd` 还包含旧快照的人数断言和叙述。因此新导出需要先适配来源契约、清洗和分析，复核学校映射，重新生成汇总，再修改 App 配置。不要为了让新数据通过而直接删除检查。

本次整理没有改动这些现有报告，也没有把它们包装为新数据的一键刷新流程。检查入口只验证 App 输入，不执行清洗或重跑报告。CRM 复核指标文本中的日期必须与配置一致，但这无法独立证明所有汇总来自同一批数据；更新时必须把整批汇总一起生成和替换。

## 文件职责

- `config.R`：路径、标题、报告期间。
- `R/data.R`：数据读取、格式检查、月份映射、流量汇总。
- `check_data.R`：独立运行输入检查，不写入或替换数据。
- `app.R`：页面和交互。

## 筛选及指标

GA4 Traffic 页的月份和渠道筛选只影响该页结果。GA4 Content 页独立提供月份和内容类别筛选，影响页面图、表及下载；内容分类沿用 GA4 报告的 URL 规则。CRM 默认展示所有已记录的会员状态。表格搜索不影响 CSV 下载。下载月份显示 YYYY-MM。

参与率 = 筛选后的 engaged sessions 总和 / sessions 总和。Active users 不跨页或月份求和。CRM 记录不是已验证的独立人数，复核指标可重叠，Active 状态不证明当前权益或互动。

## 环境与共享

需要的 R 包：

```r
install.packages(c('shiny', 'bslib', 'ggplot2', 'dplyr', 'readr', 'janitor', 'DT', 'scales', 'stringr'))
```

目前未生成 `renv.lock`，所以这是输入与配置整理，并非完整的环境版本锁定。换电脑时仍需安装 R 和依赖包。后续锁定环境前应确认需要包含哪些项目依赖。

数据仍被 Git 忽略，仓库本身不包含完整运行数据。App 使用 CRM 汇总，无联系人明细，但汇总仍可能含学校名称或小样本。当前是无认证的本地版本，外部分享前需要审查数据和访问方式。

## 使用完全虚构的数据运行演示

从仓库根目录运行（先停止正在运行的 App）：

```r
source('apps/stav-dashboard/demo/generate_data.R')
Sys.setenv(STAV_DASHBOARD_MODE = 'demo')
source('apps/stav-dashboard/check_data.R')
shiny::runApp('apps/stav-dashboard', launch.browser = TRUE)
```

返回真实数据模式：先停止 App，再运行：

```r
Sys.unsetenv('STAV_DASHBOARD_MODE')
source('apps/stav-dashboard/check_data.R')
shiny::runApp('apps/stav-dashboard', launch.browser = TRUE)
```

生成脚本完全不读取真实数据，每次得到相同的 120 条虚构联系人和 12 个月 GA4 月度表。数据写入 `data/example/dashboard/`，不替换真实数据。这一目录仅包含完全虚构的数据，可随代码分享；生成器也可重新生成相同内容。

虚构数据包含空字段、同名联系人、会员字段不一致等情况，便于练习筛选与复核。邮箱使用 `.invalid`，学校和姓名均为虚构；电话号码为明确的演示文本。

此生成器的简单清理（去前后空格、状态统一大小写、日期转换）和汇总仅用于演示 App 接口，并不等同于生产 CRM 的完整解析和业务分类。它没有运行 `01_crm_data_preparation.qmd` 的 71 字段、嵌套 JSON、特殊引号和来源契约验证，也未测试学校名称映射。演示通过不代表真实 CRM 清理流程通过。

原有 `data/example/CRM/crm_contacts_synthetic.csv` 是一个字段较少的旧示例，仍保留；此次演示使用独立生成器，不会将旧示例传入要求完整字段的真实清理流程。

## 月度对比和重置

Traffic 与 Content 各有独立的 Month to compare，默认选择最新数据月。对比的是上一日历月，不是上一个有记录的月份。对比沿用该页渠道/内容类别，但独立于图表月份范围，卡片标题明确显示两个年月。

Sessions 和 Views 用百分比变化；Engagement rate 用百分点变化。上一月计数为零时百分比变化不可计算，缺少任一月导出记录时显示无法比较，不补零。重置按钮恢复该页全部月份、All 和最新对比月，不改变另一页筛选。对比仅适用于现有导出的覆盖范围，无法证明导出是否完整；没有行也不能推断业务没有活动。
