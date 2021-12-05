#!/usr/bin/python3

import os
import sys
import re
from mutagen.easyid3 import EasyID3

version = "0.2.4"


def get_number_from_file_name(filename):
    first = re.search('^(([0-9])([0-9]+)?)[ ._-]', filename)
    if first:
        number = int(first.groups()[0])
        return f'{number:02d}' if number != 0 else ''
    return ''


def count_mp3_files(files):
    files_count = 0
    for file in files:
        if os.path.splitext(file)[-1] == '.mp3':
            files_count += 1
    return str(files_count)


def walker():
    # TODO: Add any args reader
    set_totaltracks = True if len(sys.argv) > 1 and sys.argv[1] == '-t' else False
    remove_trash = True if len(sys.argv) > 1 and sys.argv[1] == '-r' else False
    copy_v2_to_v1 = True if len(sys.argv) > 1 and sys.argv[1] == '-c' else False
    print_version = True if len(sys.argv) > 1 and sys.argv[1] == '-v' else False

    if print_version:
        print("tag version v%s" % version)
        return

    for subdir, dirs, files in os.walk(os.getcwd()):
        if subdir.find('_skipme') != -1:
            continue

        print(os.path.basename(subdir))
        dirs.sort()
        files.sort()

        files_count = count_mp3_files(files)

        for file in files:
            if os.path.splitext(file)[-1] != '.mp3':
                continue

            number_from_filename = get_number_from_file_name(file)
            audio = EasyID3(os.path.join(subdir, file))

            if remove_trash:
                if "album" not in audio:
                    print("\033[31m{}\033[0m{}" .format('[ warn ] ', file))
                else:
                    album = audio['album'][0]
                    album = album\
                        .replace('(EP)', '').replace('[EP]', '')\
                        .replace('(CDS)', '').replace('[CDS]', '')\
                        .replace('(Single)', '').replace('[Single]', '')\
                        .replace('(Demo)', '').replace('[Demo]', '')\
                        .replace('(Promo)', '').replace('[Promo]', '')\
                        .replace('(Split)', '').replace('[Split]', '')\
                        .replace('(Compilation)', '').replace('[Compilation]', '')\
                        .replace('(Limited Edition)', '').replace('[Limited Edition]', '')\
                        .replace('(CD1)', '').replace('[CD1]', '')\
                        .replace('(CD2)', '').replace('[CD2]', '')\
                        .replace('(CD 1)', '').replace('[CD 1]', '')\
                        .replace('(CD 2)', '').replace('[CD 2]', '')\
                        .split(" [", 1)[0].strip()

                    audio['album'] = album
                    audio.save()
                    print("\033[32m{}\033[0m{}" .format('[ done ] ', file))
            elif copy_v2_to_v1:
                audio.save()
                print("\033[32m{}\033[0m{}" .format('[ done ] ', file))
            else:
                if "tracknumber" not in audio:
                    if number_from_filename == '':
                        print("\033[31m{}\033[0m{}" .format('[ warn ] ', file))
                    else:
                        if set_totaltracks:
                            number_from_filename += '/' + files_count

                        audio['tracknumber'] = number_from_filename
                        audio.save()
                        print("\033[32m{}\033[0m{}" .format('[ done ] ', file))
                    continue

                tracknumber = audio['tracknumber'][0]
                number = tracknumber.split('/')[0]

                if len(number) == 0:
                    if number_from_filename == '':
                        print("\033[31m{}\033[0m{}" .format('[ warn ] ', file))
                        continue
                    else:
                        number = number_from_filename
                elif len(number) == 1:
                    number = '0' + number
                elif not set_totaltracks:
                    print('[ skip ]', file)
                    continue

                if set_totaltracks:
                    number += '/' + files_count

                if tracknumber == number:
                    print('[ skip ]', file)
                    continue

                audio['tracknumber'] = number
                audio.save()
                print("\033[32m{}\033[0m{}" .format('[ done ] ', file))


walker()
