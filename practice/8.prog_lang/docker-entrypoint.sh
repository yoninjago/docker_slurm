#!/bin/sh

python setup.py && flask run --host=0.0.0.0 --port 8000
