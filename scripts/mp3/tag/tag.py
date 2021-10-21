#!/usr/bin/python3

import os
from mutagen.easyid3 import EasyID3

for subdir, dirs, files in os.walk(os.getcwd()):
    print(os.path.basename(subdir))

    dirs.sort()
    files.sort()

    for file in files:
        filename, ext = os.path.splitext(file)

        if ext == '.mp3':
            audio = EasyID3(os.path.join(subdir, file))
            number = audio['tracknumber'][0]

            if len(number) == 1:
                audio['tracknumber'] = '0' + number
                audio.save()
                print("\033[32m{}\033[0m{}" .format('[ done ] ', file))
            else:
                print('[ skip ]', file)
                # print("\033[33m{}\033[0m{}" .format('[ skip ] ', file))
