#!/usr/bin/python3
import os


print(os.environ["BATCH"])

if not os.path.exists('/opt/test'):
    os.mknod('/opt/test')