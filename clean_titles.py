import re

file_path = r'c:\Users\vivek\Gita-Life\lib\data\bulk_audio_data.dart'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern to find '"title": "... "'
    def clean_title(match):
        title = match.group(1)
        # Strip common prefixes
        prefixes = [
            'LNS Bhajans - ',
            'LNS - ',
            'Lecture - ',
            'Radhe Radhe - ',
            'HH Lokanath Swami - ',
            '16 Hours Kirtan-',
            'Hare Krishna Kirtan-'
        ]
        for p in prefixes:
            # Use re.escape to handle special characters and re.IGNORECASE
            title = re.sub('^' + re.escape(p), '', title, flags=re.IGNORECASE)
        
        # Also clean up redundant numbering or file extensions in title if any
        # title = title.replace('.mp3', '') # Scraper usually removes this but just in case
        
        # Clean up leading/trailing dashes, spaces, and dots
        title = title.strip(' -.')
        return f'"title": "{title}"'

    new_content = re.sub(r'"title": "(.*?)"', clean_title, content)

    with open(file_path, 'w', encoding='utf-8', newline='') as f:
        f.write(new_content)
    print("Successfully cleaned titles.")
except Exception as e:
    print(f"Error: {e}")
