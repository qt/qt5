#!/usr/local/bin/python3
# -*- coding: UTF-8 -*-
import os
import sys
from os import listdir

success = 0
failed = 0
skipped = 0

def check_arch(file_name, arch):
#    print("lipo " + file_name + " -verify_arch " + arch)
    return os.system("lipo " + file_name + " -verify_arch " + arch)


def lipo(universal_path, arm64_path, x86_64_path):
#    print("lipo -create -output " + universal_path + " " + arm64_path + " " + x86_64_path)
    return os.system("lipo -create -output " + universal_path + " " + arm64_path + " " + x86_64_path)


def merge_binary(universal_path, arm64_path, x86_64_path):
    global failed
    global success
    global skipped
    if check_arch(universal_path, "arm64") != 0:
        if check_arch(arm64_path, "arm64") == 0:
            if lipo(universal_path, arm64_path, x86_64_path) == 0:
#                print("success adding arm64 arch to binary")
                success += 1
            else:
                print("failed adding arm64 arch to binary")
                failed += 1
        else:
#            print(arm64_path)
            print("failed doesn't has arm64 arch in binary")
            failed += 1
    else:
        skipped += 1


def traverse_path(universal_path, arm64_path, x86_64_path):
    for filename in os.listdir(x86_64_path):
        x86_64_full_path = x86_64_path + '/' + filename
        arm64_full_path = arm64_path + '/' + filename
        universal_full_path = universal_path + '/' + filename
        if os.path.isdir(x86_64_full_path) is True and os.path.islink(x86_64_full_path) is False:
            traverse_path(universal_full_path, arm64_full_path, x86_64_full_path)
        elif os.path.isfile(x86_64_full_path) and (os.access(x86_64_full_path, os.X_OK) or x86_64_full_path.endswith(".a")) and check_arch(x86_64_full_path, "x86_64") == 0:
            merge_binary(universal_full_path, arm64_full_path, x86_64_full_path)


def copy_x86_to_universal(x86_64_path, universal_path):
    os.system("rsync -av --progress -l -r " + x86_64_path + "/ " + universal_path)


def main(universal_path, x86_64_path, arm64_path):
    copy_x86_to_universal(x86_64_path, universal_path)
    traverse_path(universal_path, arm64_path, x86_64_path)
    print("success file", success, "failed", + failed, "skipped", skipped)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("usage: python3 make_universal.py universal_path x86_64_path arm64_path")
    main(sys.argv[1], sys.argv[2], sys.argv[3])
