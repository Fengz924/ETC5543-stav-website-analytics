"""Synthetic parser regression checks; no real CRM contact values."""
import csv, importlib.util, io, json
from pathlib import Path
spec=importlib.util.spec_from_file_location("validator",Path(__file__).resolve().parent/"validate_import.py")
v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)

def check(text,expected):
    actual,_,_,_=v.parse_preserving_escapes(text)
    assert actual==expected

check('a,b\n1,2\n',[['a','b'],['1','2']])
check('a,b\n1,2',[['a','b'],['1','2']])
check('a,b,c\n1,,\n',[['a','b','c'],['1','','']])
check('a,b\n"one,two","three"\n',[['a','b'],['one,two','three']])
check('a,b\n"one\r\ntwo",three\n',[['a','b'],['one\r\ntwo','three']])
check('a,b\n"one""two",three\n',[['a','b'],['one"two','three']])
notes=json.dumps([{'body':'quoted "word", newline\n slash /; unicode \u2603'}])
stream=io.StringIO(newline='');csv.writer(stream,lineterminator='\n',quoting=csv.QUOTE_ALL).writerow(['1',notes,''])
# The source's mixed dialect leaves JSON's backslash-quotes undoubled.
fixture=stream.getvalue().replace('\\""','\\"')
check(fixture,[['1',notes,'']])
assert json.loads(v.parse_preserving_escapes(fixture)[0][0][1])==json.loads(notes)
for malformed in ['a,"unterminated','a,"closed"junk\n','a,unquoted"quote\n']:
    try:v.parse_preserving_escapes(malformed)
    except ValueError:pass
    else:raise AssertionError('Malformed quoting was accepted')
print('PASS: 10 synthetic parsing cases; nested JSON content preserved; malformed quoting rejected.')
