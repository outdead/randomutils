# Silly Video Converter
Conv is util for fast changing video format in files.

## Install
### Local
```bash
sudo cp conv.sh /usr/bin/conv
sudo chmod 0644 /usr/bin/conv
sudo chmod +x /usr/bin/conv
```

### Remote
```bash
sudo wget -O /usr/bin/conv https://raw.githubusercontent.com/outdead/randomutils/master/scripts/video/convert/conv.sh
sudo chmod 0644 /usr/bin/conv
sudo chmod +x /usr/bin/conv
```

## Usage
```bash
./convert.sh FILE_NAME FORMAT QUALITY
```

## Example 
```bash
./convert.sh '2021-05-17 01-32-56.mkv' mp4
./convert.sh '2021-05-17 01-32-56.mkv' mp4 5
```
