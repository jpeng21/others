#! /bin/bash

path=$(pwd)

grep -nr ".MP4" | awk -F ">|<" '{ print $7 }'

./curl http://145.192.1.1/DCIM/DCIM/Cache/ | grep -nr ".MP4" | awk -F ">|<" '{ print $7 }' >> list
./curl http://145.192.1.1/DCIM/DCIM/Cache/ | grep -nr ".jpg" | awk -F ">|<" '{ print $7 }' >> list

./curl http://145.192.1.1/DCIM/DCIM/Cache/ | grep -nrE ".MP4|.jpg" | awk -F ">|<" '{ print $7 }' > list

./curl http://145.192.1.1/DCIM/DCIM/Cache/ | grep -nrE ".MP4|.jpg" | awk -F ">" '{ print $6 }' > list


echo ""

#json文件
{
    "VIS_VIDEO":
    [
        { "path": ".pm4", "filesize": 1049, "mtime": 19087677, "duration": 10}，
    ]
    "VIS_PHOTO":
    [
        {}，
        {}，
    ]
    "IR_VIDEO":
    [
        {}，
        {}，
    ]
    "IR_PHOTO":
    [
        {}，
        {}，
    ]
}