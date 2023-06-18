# Editing mp3 tags
ID3 tag writer.  

- Adds a prefix "0" to the track number if it is less than 10.
- Sets total tracks number (add -t flag).
- Copies ID3v2 to ID3v1 (add -c flag).

## Requirements
https://mutagen.readthedocs.io/en/latest/user/id3.html#easy-id3  

    python3 -m pip install mutagen

## Install
```bash
sudo cp tag.py /usr/bin/tag && sudo chmod 0644 /usr/bin/tag && sudo chmod +x /usr/bin/tag
```

## Usage
```bash
tag
```
