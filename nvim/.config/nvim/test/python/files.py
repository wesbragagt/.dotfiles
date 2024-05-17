# create a program that lists files in the current directory logging them to stdout

import os

def list_files():
    for file in os.listdir():
        print(file)
