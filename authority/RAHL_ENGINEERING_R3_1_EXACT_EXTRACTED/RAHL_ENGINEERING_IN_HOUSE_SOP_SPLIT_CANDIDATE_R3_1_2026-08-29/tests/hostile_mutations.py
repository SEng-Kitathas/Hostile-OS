from pathlib import Path
import json, tempfile, shutil, subprocess, sys, hashlib, os
SRC=Path(__file__).resolve().parents[1]
ENV=os.environ.copy(); ENV['PYTHONDONTWRITEBYTECODE']='1'
CASES=[]

def reseal(root):
    files=[p for p in root.rglob('*') if p.is_file() and p.name!='MANIFEST_SHA256.json']
    m={str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)}
    (root/'MANIFEST_SHA256.json').write_text(json.dumps(m,indent=2,sort_keys=True)+'\n',encoding='utf-8')

def run_case(name, mutate):
    with tempfile.TemporaryDirectory() as td:
        root=Path(td)/SRC.name; shutil.copytree(SRC,root,ignore=shutil.ignore_patterns('__pycache__','*.pyc','*.pyo'))
        mutate(root); reseal(root)
        cp=subprocess.run([sys.executable,'VERIFY_CANDIDATE.py'],cwd=root,env=ENV,text=True,capture_output=True)
        if cp.returncode==0: raise AssertionError(name+' survived')
        msg=(cp.stdout+cp.stderr).strip().splitlines()[0] if (cp.stdout+cp.stderr).strip() else ''
        CASES.append({'case':name,'result':'REJECTED_AS_EXPECTED','message':msg})

def jmut(rel, fn):
    def m(root):
        p=root/rel; d=json.loads(p.read_text(encoding='utf-8')); fn(d); p.write_text(json.dumps(d,indent=2,sort_keys=True)+'\n',encoding='utf-8')
    return m

def textmut(rel, old, new):
    def m(root):
        p=root/rel; s=p.read_text(encoding='utf-8'); assert old in s; p.write_text(s.replace(old,new,1),encoding='utf-8')
    return m

run_case('promote_C09_class', jmut('machine/ENGINEERING_AUTHORITY_BINDINGS.json', lambda d: d[8].__setitem__('inherited_classes',['ADMISSIBILITY_CONSTRAINT'])))
run_case('invert_C16_human_body', textmut('01_ENGINEERING_AUTHORITY_SURFACE.md','Exact inheritance requires logical sufficiency; bounded probabilistic claims may rely on calibrated evidence with an explicit error model.','Any convenient proxy proves exact inheritance and no error model is needed.'))
def relocate_c16_expected_text(root):
    p=root/'01_ENGINEERING_AUTHORITY_SURFACE.md'
    good='Exact inheritance requires logical sufficiency; bounded probabilistic claims may rely on calibrated evidence with an explicit error model.'
    bad='Any convenient proxy proves exact inheritance and no error model is needed.'
    s=p.read_text(encoding='utf-8')
    assert good in s
    s=s.replace(good,bad,1)
    s += '\n\n## Quoted counterexample text\n\n' + good + '\n'
    p.write_text(s,encoding='utf-8')
run_case('relocate_expected_C16_text_outside_live_section', relocate_c16_expected_text)
run_case('mutate_C16_registry_body', jmut('machine/ENGINEERING_AUTHORITY_BINDINGS.json', lambda d: d[15].__setitem__('statement','Any convenient proxy proves exact inheritance.')))
run_case('move_G10_into_engineering', jmut('machine/INTERNAL_GOVERNANCE_REGISTRY.json', lambda d: d[9].__setitem__('surface','CLASSIFIED_ENGINEERING_AUTHORITY')))
run_case('grant_G10_product_authority', jmut('machine/INTERNAL_GOVERNANCE_REGISTRY.json', lambda d: d[9].__setitem__('product_authority',True)))
run_case('activate_project_by_default', jmut('machine/PROJECT_OBLIGATION_SCHEMA.json', lambda d: d.__setitem__('active_by_default',True)))
run_case('instantiate_unearned_substrate_profile', jmut('machine/SUBSTRATE_PROFILE.json', lambda d: (d.__setitem__('profile_instance',{'entries':[]}),d.__setitem__('status','ACTIVE'))))
run_case('drop_legacy_topic', jmut('machine/COLD_START_COVERAGE.json', lambda d: d.pop()))
run_case('fake_replacement_ready', jmut('machine/AUTHORITY_CONTRACT.json', lambda d: d.__setitem__('replacement_ready',True)))
run_case('drop_active_scar', jmut('machine/ACTIVE_SCARS.json', lambda d: (d['scars'].pop(),d.__setitem__('count',d['count']-1))))
run_case('drop_execution_obligation', jmut('machine/EXECUTION_RELEASE_OBLIGATIONS.json', lambda d: d.pop()))
run_case('change_pinned_parent_source', textmut('ancestry/V5/27_DOCTRINE_AUTHORITY_CLASSES_AND_CONFLICT_RESOLUTION.md','A default is expected to have lawful exceptions.','A default is mandatory and has no exceptions.'))
def extra(root): (root/'UNDECLARED_AUTHORITY.md').write_text('# surprise\n',encoding='utf-8')
run_case('add_unmanifested_authority_file',extra)
run_case('remove_human_C01_class', textmut('01_ENGINEERING_AUTHORITY_SURFACE.md','Inherited classes: `ADMISSIBILITY_CONSTRAINT, QUALIFICATION_RULE`','Inherited classes: `FOUNDATION_PROMOTED`'))
run_case('change_authority_effect', jmut('machine/ENGINEERING_AUTHORITY_BINDINGS.json', lambda d: d[0].__setitem__('authority_effect','FOUNDATION_PROMOTION')))
run_case('resume_method_stack_automatically', jmut('machine/MACHINERY_AND_MODES.json', lambda d: d.__setitem__('automatic_resume',True)))
run_case('grant_role_authority', jmut('machine/MACHINERY_AND_MODES.json', lambda d: d['roles'][0].__setitem__('authority','CANONICAL_INTEGRATION_AUTHORITY')))
run_case('drop_named_machinery_status', jmut('machine/MACHINERY_AND_MODES.json', lambda d: d['machinery'].pop()))

print(json.dumps({'total':len(CASES),'rejected':len(CASES),'cases':CASES},indent=2,sort_keys=True))
