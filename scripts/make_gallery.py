"""Build documentation contact sheets from actual app screenshots (Pillow)."""
import re
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
PAGES = re.findall(r"^  (\w+)\('([^']+)',", (ROOT / 'lib/core/routes.dart').read_text(), re.M)
OUT = ROOT / 'docs/screenshots'
FONT_PATH = '/System/Library/Fonts/Supplemental/Arial.ttf'
FONT = ImageFont.truetype(FONT_PATH, 13) if Path(FONT_PATH).exists() else ImageFont.load_default()

for theme in ('light', 'dark'):
    sheet = Image.new('RGB', (9 * 138, 5 * 330), '#e8e8e8')
    draw = ImageDraw.Draw(sheet)
    for i, (route, label) in enumerate(PAGES):
        path = OUT / theme / f'{route}.png'
        image = Image.open(path).convert('RGB')
        image.thumbnail((126, 278), Image.Resampling.LANCZOS)
        x, y = (i % 9) * 138 + 6, (i // 9) * 330 + 6
        sheet.paste(image, (x, y))
        draw.text((x, y + 284), f'{i + 1:02} {route[:17]}', fill='black', font=FONT)
    sheet.save(OUT / f'{theme}-overview.jpg', quality=90)

selected = [('light', 'discover', 'Discover'), ('light', 'categoryLive', 'Game categories'),
            ('light', 'watchEmoji', 'Live chat'), ('light', 'channelPast', 'Creator channel'),
            ('light', 'profileSaved', 'Profile'), ('dark', 'discover', 'Dark mode')]
sheet = Image.new('RGB', (3 * 280 + 48, 2 * 626 + 48), '#eeeeee')
draw = ImageDraw.Draw(sheet)
for i, (theme, route, label) in enumerate(selected):
    image = Image.open(OUT / theme / f'{route}.png').convert('RGB')
    image.thumbnail((260, 570), Image.Resampling.LANCZOS)
    x, y = 24 + (i % 3) * 280, 24 + (i // 3) * 626
    draw.text((x, y), label, fill='black', font=FONT)
    sheet.paste(image, (x, y + 28))
sheet.save(OUT / 'main-preview.jpg', quality=92)
print(f'Created galleries for {len(PAGES)} screens in both themes.')
