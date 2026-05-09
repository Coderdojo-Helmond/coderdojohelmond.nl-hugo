import os
import re
from datetime import datetime

POSTS_DIR = 'content/edities'
TODAY = datetime.now().date()

def update_posts():
    files = []
    for filename in os.listdir(POSTS_DIR):
        if filename.endswith('.md'):
            match = re.search(r'(\d{2})-(\d{2})-(\d{2})', filename)
            if match:
                file_date = datetime.strptime(match.group(1) + "-" + match.group(2) + "-" + match.group(3), '%y-%m-%d').date()
                files.append({'name': filename, 'date': file_date})

    files.sort(key=lambda x: x['date'])

    next_edition = None
    for f in files:
        if f['date'] > TODAY:
            next_edition = f
            break

    if not next_edition:
        print("No future editions found.")
        return

    file_path = os.path.join(POSTS_DIR, next_edition['name'])
    with open(file_path, 'r') as f:
        content = f.read()

    if 'future: true' in content:
        new_content = content.replace('future: true', 'future: false')
        with open(file_path, 'w') as f:
            f.write(new_content)
        print(f"Updated {next_edition['name']}: set future to false.")
    else:
        print(f"{next_edition['name']} was already set to false.")

if __name__ == "__main__":
    update_posts()
