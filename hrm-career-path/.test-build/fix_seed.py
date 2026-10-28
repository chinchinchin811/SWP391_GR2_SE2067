from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
path = root / 'database/seed_data/seed_data_sqlserver.sql'
text = path.read_text(encoding='utf-8')
keys = {
    'Roles':['role_name'], 'Job_Levels':['level_name'], 'Departments':['department_name'],
    'Positions':['position_name','department_id'], 'Users':['username'],
    'Employee_History':['user_id','change_type','change_date'], 'FlashcardDecks':['title'],
    'Flashcards':['deck_id','question'], 'Learning_Materials':['title','scope_type','department_id'],
    'Video_Checkpoints':['material_id','stop_time_seconds'], 'Training_Classes':['class_code'],
    'Class_Materials':['class_id','material_id'], 'Class_Enrollments':['class_id','user_id'],
    'Learning_Progress':['user_id','material_id','class_id'],
}
departments = ['Phòng Kỹ Thuật (IT)','Phòng Nhân Sự (HR)','Phòng Kinh Doanh (Sales)',
               'Phòng Marketing & Truyền Thông','Phòng Kế Toán - Tài Chính']
maps = {
    'department':('Departments','department_id','department_name',departments),
    'position':('Positions','position_id','position_name',['Java Developer','Frontend Developer','QA / Software Tester','HR Officer','Sales Executive']),
    'level':('Job_Levels','level_id','level_name',['Intern','Fresher','Junior','Middle','Senior','Lead']),
    'role':('Roles','role_id','role_name',['ADMIN','HR','MANAGER','EMPLOYEE','MENTOR']),
    'user':('Users','user_id','username',['admin','hr_manager','manager_it','dev_fresher','dev_tester','mentor_java','locked_user']),
    'deck':('FlashcardDecks','deck_id','title',['Văn hóa công ty','Chuyên môn Java Backend']),
}
def lookup(col):
    kind = ('user' if col in ('user_id','created_by','enrolled_by','mentor_id') else
            'department' if col.endswith('department_id') else
            'position' if col.endswith('position_id') else
            'level' if col.endswith('level_id') else
            'role' if col=='role_id' else 'deck' if col=='deck_id' else None)
    if kind is None: return 's.'+col
    table, idcol, namecol, names = maps[kind]
    cases = ' '.join(f"WHEN {i} THEN N'{name.replace(chr(39), chr(39)*2)}'" for i,name in enumerate(names,1))
    return f'(SELECT TOP (1) {idcol} FROM dbo.{table} WHERE {namecol}=CASE s.{col} {cases} END ORDER BY {idcol})'

# Match only the sample INSERT ... VALUES statements, preserving quoted text/semicolons.
pattern = re.compile(r"INSERT INTO dbo\.(\w+)\s*\(([^)]+)\)\s*VALUES\s*((?:N?'(?:''|[^'])*'|[^;'])*);", re.DOTALL)
changed=[]
def replace(m):
    table=m[1]
    if table not in keys: return m[0]
    cols=[c.strip() for c in m[2].split(',')]
    projected=',\n        '.join(lookup(c)+' AS '+c for c in cols)
    predicate=' AND '.join(f'(existing.{c}=src.{c} OR (existing.{c} IS NULL AND src.{c} IS NULL))' for c in keys[table])
    if table=='Users':
        predicate='(existing.username=src.username OR existing.email=src.email)'
    changed.append(table)
    return (f"INSERT INTO dbo.{table} ({', '.join(cols)})\nSELECT {', '.join('src.'+c for c in cols)}\n"
            f"FROM (\n    SELECT {projected}\n    FROM (VALUES\n{m[3]}\n    ) AS s ({', '.join(cols)})\n) AS src\n"
            f"WHERE NOT EXISTS (SELECT 1 FROM dbo.{table} existing WITH (UPDLOCK,HOLDLOCK) WHERE {predicate});")
text=pattern.sub(replace,text)
assert len(changed)==18, changed
text=text.replace('UPDATE dbo.Departments SET manager_id = 3 WHERE department_id = 1;',
    "UPDATE dbo.Departments SET manager_id = (SELECT user_id FROM dbo.Users WHERE username='manager_it')\nWHERE department_name=N'Phòng Kỹ Thuật (IT)' AND manager_id IS NULL;")
text=text.replace('UPDATE dbo.Departments SET manager_id = 2 WHERE department_id = 2;',
    "UPDATE dbo.Departments SET manager_id = (SELECT user_id FROM dbo.Users WHERE username='hr_manager')\nWHERE department_name=N'Phòng Nhân Sự (HR)' AND manager_id IS NULL;")
# Resolve the earliest existing material consistently if an earlier seed run made duplicates.
text=re.sub(r'SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = (N\x27(?:\x27\x27|[^\x27])*\x27)',
            r'SELECT TOP 1 material_id FROM dbo.Learning_Materials WHERE title = \1 ORDER BY material_id',text)
text=text.replace('USE HRM_Project_DB;\nGO', 'USE HRM_Project_DB;\nGO\n\n-- Có thể chạy lại: chỉ thêm dữ liệu mẫu còn thiếu, không ghi đè dữ liệu đang có.\nSET NOCOUNT ON;\nSET XACT_ABORT ON;\nSET QUOTED_IDENTIFIER ON;\nSET ANSI_NULLS ON;\nSET ANSI_PADDING ON;\nSET ANSI_WARNINGS ON;\nSET ARITHABORT ON;\nSET CONCAT_NULL_YIELDS_NULL ON;\nSET NUMERIC_ROUNDABORT OFF;\nGO')
path.write_text(text,encoding='utf-8')
print('Updated sample inserts:', ', '.join(changed))
