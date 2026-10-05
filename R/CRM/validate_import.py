"""Read-only source inspection; strict, fail-closed CRM dialect validation.
Writes only CRM-project derived/validation files. Never logs contact values.
"""
from pathlib import Path
import csv, hashlib, io, json, subprocess, sys
from collections import Counter
ROOT = Path(__file__).resolve().parents[2]
CONTRACT = json.loads((ROOT / "docs/CRM/source_contract.json").read_text())
SOURCE = ROOT / "data/raw/CRM" / CONTRACT["source_filename"]
OUT = ROOT / "data/analysis/CRM/01_preparation"
RESTRICTED = ROOT / "data/clean/CRM/restricted/source_import"

def write_table(path, rows, fields=None):
    rows = list(rows)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields or list(rows[0]))
        w.writeheader(); w.writerows(rows)

def parse_preserving_escapes(text):
    """Strict CSV state machine plus the source's literal backslash-quote rule.
    Backslash escapes never consume literal content. Standard doubled CSV quotes
    become one quote. Any quote-following junk or unquoted quote is fatal.
    Physical newlines within quoted fields are retained, including CRLF.
    """
    rows, spans, row, value = [], [], [], []
    state, i, line, first_line = "start", 0, 1, 1
    escaped, doubled = 0, 0
    while i < len(text):
        c = text[i]
        if state == "start":
            if c == '"': state = "quoted"
            elif c == ',': row.append("")
            elif c == '\n':
                row.append(""); rows.append(row); spans.append((first_line, line))
                row = []; first_line = line + 1
            else: value.append(c); state = "unquoted"
        elif state == "quoted":
            if c == '\\' and i + 1 < len(text) and text[i + 1] == '"':
                # JSON literal: preserve BOTH characters, not a CSV boundary.
                value.extend(['\\', '"']); i += 1; escaped += 1
            elif c == '"':
                if i + 1 < len(text) and text[i + 1] == '"':
                    value.append('"'); i += 1; doubled += 1
                else: state = "closed"
            else: value.append(c)
        elif state in ("closed", "unquoted"):
            if c in ',\n':
                row.append(''.join(value)); value = []; state = "start"
                if c == '\n':
                    rows.append(row); spans.append((first_line, line))
                    row = []; first_line = line + 1
            elif state == "closed":
                raise ValueError(f"Unexpected character after closing quote on physical line {line}")
            elif c == '"':
                raise ValueError(f"Quote inside unquoted field on physical line {line}")
            else: value.append(c)
        if c == '\n': line += 1
        i += 1
    if state == "quoted": raise ValueError("Unterminated quoted field")
    if row or value or state == "closed":
        row.append(''.join(value)); rows.append(row); spans.append((first_line, line))
    return rows, spans, escaped, doubled

def python_escape_semantics(value):
    result, i = [], 0
    while i < len(value):
        if value[i] == '\\' and i + 1 < len(value): i += 1
        result.append(value[i]); i += 1
    return ''.join(result)

R_PROBE = r"""
library(readr)
args <- commandArgs(TRUE)
p <- args[1]
read_one <- function(backslash) suppressWarnings(read_delim(
 p, delim=",", quote="\"", escape_double=TRUE, escape_backslash=backslash,
 col_types=cols(.default=col_character()), na=character(), trim_ws=FALSE,
 name_repair="minimal", show_col_types=FALSE, progress=FALSE, lazy=FALSE,
 num_threads=1))
a <- read_one(FALSE); b <- read_one(TRUE)
cat(jsonlite::toJSON(list(version=as.character(packageVersion("readr")),
 legacy_rows=nrow(a), legacy_fields=ncol(a), legacy_problems=problems(a)[,c("row","col","expected","actual")],
 escaped_problems=nrow(problems(b)), escaped_data=b), dataframe="rows", na="null", auto_unbox=TRUE))
"""
R_COMPARE = r"""
library(readr)
p <- commandArgs(TRUE)[1]
x <- read_delim(p, delim=",", quote="\"", escape_double=TRUE, escape_backslash=FALSE,
 col_types=cols(.default=col_character()), na=character(), trim_ws=FALSE,
 name_repair="minimal", show_col_types=FALSE, progress=FALSE, lazy=FALSE,num_threads=1)
cat(jsonlite::toJSON(list(problems=nrow(problems(x)), data=x),dataframe="rows",na="null",auto_unbox=TRUE))
"""

def main():
    raw = SOURCE.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    if digest != CONTRACT["sha256"]: raise ValueError("Source SHA-256 differs from approved source contract")
    text = raw.decode("utf-8-sig")
    parsed, spans, escaped, doubled = parse_preserving_escapes(text)
    header, rows = parsed[0], parsed[1:]
    if len(header) != CONTRACT["expected_fields"] or len(set(header)) != len(header):
        raise ValueError("Header field count or uniqueness failed")
    if len(rows) != CONTRACT["expected_records"] or any(len(row) != len(header) for row in rows):
        raise ValueError("Record count or source-field alignment failed")
    # Independent Python delimiter decisions; exact per-cell comparison AFTER
    # explicit normalisation to its documented backslash-consuming semantics.
    independent = list(csv.reader(io.StringIO(text, newline=""),escapechar="\\",doublequote=True,strict=True))
    boundary_diffs = sum(python_escape_semantics(v) != independent[i][j]
                         for i,row in enumerate(parsed) for j,v in enumerate(row))
    if len(independent)!=len(parsed) or any(len(r)!=len(header) for r in independent) or boundary_diffs:
        raise ValueError("Independent Python dialect agreement failed")
    default = list(csv.reader(io.StringIO(text, newline="")))
    default_bad = [i for i,r in enumerate(default[1:],1) if len(r)!=len(header)]
    strict_default_error = ""
    try: list(csv.reader(io.StringIO(text,newline=""),strict=True))
    except csv.Error as exc: strict_default_error = str(exc)
    notes_index = header.index("notes")
    # JSON is nested source content, not a business classification.
    notes_count = 0
    for row in rows:
        if row[notes_index].strip():
            if not isinstance(json.loads(row[notes_index]),list):
                raise ValueError("Notes JSON is not a list")
            notes_count += 1
    probe = json.loads(subprocess.check_output(["Rscript","-e",R_PROBE,str(SOURCE)],text=True))
    r_escaped = probe.pop("escaped_data")
    r_boundary_diffs = sum(python_escape_semantics(v)!=r_escaped[i][header[j]]
                           for i,row in enumerate(rows) for j,v in enumerate(row))
    if len(r_escaped)!=len(rows) or probe["escaped_problems"] or r_boundary_diffs:
        raise ValueError("Independent R delimiter agreement failed")
    canonical = RESTRICTED / "crm_source_import_internal.csv"
    with canonical.open("w",encoding="utf-8",newline="") as f:
        writer=csv.writer(f,lineterminator="\n",quoting=csv.QUOTE_ALL)
        writer.writerows(parsed)
    canonical.chmod(0o600)
    # Exact round trip, with no backslash consumption, in Python AND R.
    with canonical.open(encoding="utf-8",newline="") as f: roundtrip=list(csv.reader(f,strict=True))
    if roundtrip != parsed: raise ValueError("Python canonical round trip failed")
    r_roundtrip=json.loads(subprocess.check_output(["Rscript","-e",R_COMPARE,str(canonical)],text=True))
    exact_r_diffs=sum(v!=r_roundtrip["data"][i][header[j]]
                      for i,row in enumerate(rows) for j,v in enumerate(row))
    if r_roundtrip["problems"] or exact_r_diffs: raise ValueError("R canonical exact round trip failed")
    changed_by_escape=sum(v!=python_escape_semantics(v) for row in rows for v in row)
    multiline=sum(end>start for start,end in spans[1:])
    metrics=[
      ("Declared source fields",len(header)),("Logical source records",len(rows)),
      ("Physical source lines",text.count("\n")),("Multiline logical records",multiline),
      ("Default Python over-width records",len(default_bad)),
      ("Legacy R parser problem entries",len(probe["legacy_problems"])),
      ("Literal backslash-quote sequences handled",escaped),("Doubled CSV quotes decoded",doubled),
      ("Source notes JSON lists validated",notes_count),
      ("Cells altered by consuming-backslash parser",changed_by_escape),
      ("Independent Python boundary comparison unequal cells",boundary_diffs),
      ("Independent R boundary comparison unequal cells",r_boundary_diffs),
      ("Canonical R exact comparison unequal cells",exact_r_diffs),
      ("Canonical R parser problems",r_roundtrip["problems"]),
      ("Final unresolved structural issues",0)]
    write_table(OUT/"crm_import_validation.csv",[{"check":k,"result":v} for k,v in metrics])
    write_table(OUT/"crm_parser_comparison.csv",[
      {"method":"Python default permissive","records":len(default)-1,"fields":71,"width_or_parser_issues":len(default_bad),"literal_escapes_preserved":"Unreliable quoting","accepted":False},
      {"method":"Legacy R readr","records":probe["legacy_rows"],"fields":probe["legacy_fields"],"width_or_parser_issues":len(probe["legacy_problems"]),"literal_escapes_preserved":"Unreliable quoting","accepted":False},
      {"method":"Python explicit backslash dialect","records":len(independent)-1,"fields":71,"width_or_parser_issues":0,"literal_escapes_preserved":"No","accepted":False},
      {"method":"R explicit backslash dialect","records":len(r_escaped),"fields":71,"width_or_parser_issues":probe["escaped_problems"],"literal_escapes_preserved":"No","accepted":False},
      {"method":"Strict literal-preserving dialect + canonical R round trip","records":len(rows),"fields":71,"width_or_parser_issues":0,"literal_escapes_preserved":"Yes","accepted":True}])
    write_table(RESTRICTED/"crm_source_record_map_internal.csv",[
      {"source_record_number":i,"physical_line_start":start,"physical_line_end":end,
       "source_multiline_record":end>start,"source_quote_dialect_exception":i in set(default_bad)}
      for i,(start,end) in enumerate(spans[1:],1)])
    affected=set(default_bad)
    for problem in probe["legacy_problems"]: affected.add(problem["row"]-1)
    write_table(ROOT/"data/analysis/CRM/01_preparation/restricted/crm_import_dialect_review_internal.csv",[
      {"source_record_number":i,"physical_line_start":spans[i][0],"physical_line_end":spans[i][1],
       "default_python_fields":len(default[i]),"legacy_R_problem":i in {p["row"]-1 for p in probe["legacy_problems"]},
       "validated_fields":len(rows[i-1]),"notes_json_valid":True} for i in sorted(affected)])
    manifest={"source_filename":SOURCE.name,"source_sha256":digest,"source_bytes":len(raw),
      "extract_date":CONTRACT["extract_date"],"canonical_sha256":hashlib.sha256(canonical.read_bytes()).hexdigest(),
      "records":len(rows),"source_fields":len(header),"import_passed":True,
      "readr_version":probe["version"],"python_version":sys.version.split()[0],
      "strict_default_python_error":strict_default_error,"legacy_R_problems":probe["legacy_problems"],
      "dialect_rule":"Inside quoted fields, preserve literal backslash + quote; decode doubled CSV quotes; reject malformed boundaries.",
      "all_notes_json_valid":True,"python_canonical_exact_roundtrip":True,"R_canonical_exact_roundtrip":True}
    (ROOT/"data/analysis/CRM/01_preparation/validation/source_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
    write_table(ROOT/"data/analysis/CRM/01_preparation/validation/source_field_inventory.csv",[{"position":i,"source_field":v} for i,v in enumerate(header,1)])
    print(f"Import PASS: {len(rows)} records x {len(header)} source fields; exact Python/R round trips; no unresolved structural issues.")

if __name__ == "__main__":
    marker=ROOT/"data/analysis/CRM/01_preparation/validation/source_manifest.json"
    # Invalidate a previous success before each attempt. Downstream R is gated.
    if marker.exists(): marker.unlink()
    try: main()
    except Exception as exc:
        (ROOT/"data/analysis/CRM/01_preparation/validation/import_failure.txt").write_text(type(exc).__name__+": "+str(exc)+"\n")
        raise SystemExit("Import FAILED; no validated analysis dataset may be used. See data/analysis/CRM/01_preparation/validation/import_failure.txt.")
    else:
        failure=ROOT/"data/analysis/CRM/01_preparation/validation/import_failure.txt"
        if failure.exists(): failure.unlink()
