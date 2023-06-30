#!/bin/bash
listpath=$(pwd)
VISUrlPath="http://145.192.1.1/DCIM/DCIM/Cache/"
obj="list.json"
#json文件条目格式
VideoTemplate="\t\t\t{\"path\":\"var1\",\"filesize\":\"var2\",\"mtime\":\"var3\",\"duration\":\"var4\"},"
PhotoTemplate="\t\t\t{\"path\":\"var1\",\"filesize\":\"var2\",\"mtime\":\"var3\"},"

#纯文件目录
#./curl ${VISUrlPath} | grep -nr ".MP4" | awk -F ">|<" '{ print $7 }' > VISVideoList
#./curl ${VISUrlPath} | grep -nr ".jpg" | awk -F ">|<" '{ print $7 }' > VISPhotoList
 grep -nr ".MP4" test_web.html | awk -F ">|<" '{ print $7 }' > VISVideoList
 grep -nr ".jpg" test_web.html | awk -F ">|<" '{ print $7 }' > VISPhotoList

#系统第一次运行时，先检查文件目录，并下载新增或没有的文件，再创建list
if [ ! -f ${obj} ]; then
    touch ${obj}
    echo -e "{" > ${obj}

    if [ -s VISVideoList ]; then
    echo -e "\t\"VIS_VIDEO\":\n\t[\n\t]," >> ${obj}
    fi

    if [ -s VISPhotoList ]; then
    echo -e "\t\"VIS_PHOTO\":\n\t[\n\t]," >> ${obj}
    fi

    echo -e "}" >> ${obj}
fi

echo "===================end==================="

if false;then
    while read line
    do
    #	echo $line
    #	echo $line | awk -F/ -v OFS="/" '{$NF=""; _path=sprintf("%s",$0); print _path;}'
        if [ -s $line ]; then
        #文件大小，字节为单位
        #mtime=$($line | sed s/.*//)
        #ffmpeg -i test.mp4  -vcodec copy -acodec copy -f null /dev/null
        #00:00:39.24
        _path=${listpath}/$line
        _filesize=$(wc -c $line | awk '{print $1}')
        _mtime=$(echo $line | cut -d '.' -f 1)
        _duration="30" #$(ffmpeg -i $line 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//)
        tmplist=$(echo $VideoTemplate | sed "s|var1|$_path|g" | sed "s/var2/$_filesize/g" | sed "s/var3/$_mtime/g" | sed "s/var4/$_duration/g")
        lineNum=$(grep -nr ']' ${obj} | awk -F ":" 'END{print $1}')
        echo "$LINENO---$tmplist"
        echo -e "$tmplist"
        echo "$LINENO---$lineNum"
        sed -i "${lineNum} i \\${tmplist}\r" ${obj}
        fi
    done < VISVideoList
fi
  
#更新list文件
#上次文件内容 —— tmpVISVideoList tmpVISPhotoList
#本次读取到的内容 —— VISVideoList VISPhotoList
function createDiffList(){
    local _listFile
    local _listFile
    local tmpList

    test ${1} -eq 0 && test VISVideoList && _listFile=VISVideoList && _Template=${VideoTemplate}
    test ${1} -eq 1 && test VISPhotoList && _listFile=VISPhotoList && _Template=${PhotoTemplate}

    if [ -s tmp${_listFile} ];then
        diff $_listFile tmp$_listFile > diffFile
    fi
    cat diffFile | awk -F+ '{print $2}' >> diff$_listFile
}

#用于生成list.json文件
#${1}==0 VIS--Video
#${1}==1 VIS--Photo
#${1}==2 IR--Video
#${1}==3 IR--Photo
function createList(){
    local _path
    local _filesize
    local _mtime
    local _duration
    local tmplist
    local _Template
    local _listFile
    local lineNum

    if [ ${1} -eq 0 ];then
        if [ -s diffVISVideoList ]; then
            _listFile=diffVISVideoList
        else 
            _listFile=VISVideoList
        fi
        _Template=${VideoTemplate}
    elif [ ${1} -eq 1 ]; then
        if [ -s diffVISPhotoList ]; then
            _listFile=diffVISPhotoList
        else 
            _listFile=VISPhotoList
        fi
        _Template=${PhotoTemplate}
    elif [ ${1} -eq 2 ]; then
        echo "2"
    elif [ ${1} -eq 3 ]; then
        echo "3"
    fi
#    test ${1} -eq 0 && test VISVideoList && _listFile=VISVideoList && _Template=${VideoTemplate}
#    test ${1} -eq 1 && test VISPhotoList && _listFile=VISPhotoList && _Template=${PhotoTemplate}
    lineNum=$((${1}+1))
    echo "$LINENO---$lineNum $_listFile $_Template"
#    _listFile="${1}${2}List"
    echo "$LINENO---$_listFile"
    if [ -s $_listFile ];then
        while read line
        do
            if [ -s $line ]; then
            #文件大小，字节为单位
            #mtime=$($line | sed s/.*//)
            #ffmpeg -i test.mp4  -vcodec copy -acodec copy -f null /dev/null
            #00:00:39.24
            _path=${listpath}/$line
            _filesize=$(wc -c $line | awk '{print $1}')
            if [ ${1} -eq 0 || ${1} -eq 2];then
                _mtime=$(echo $line | cut -d '.' -f 1)
                _duration="30" #$(ffmpeg -i $line 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//)
                tmplist=$(echo ${_Template} | sed "s|var1|$_path|g" | sed "s/var2/$_filesize/g" | sed "s/var3/$_mtime/g" | sed "s/var4/$_duration/g")
            else
                _mtime=$(echo $line | cut -d '_' -f 1,2)
                tmplist=$(echo ${_Template} | sed "s|var1|$_path|g" | sed "s/var2/$_filesize/g" | sed "s/var3/$_mtime/g")
            fi
            #lineNum=$(grep -nr ']' ${obj} | awk -F ":" 'END{print $1}')
            lineNum=$(grep -nr ']' ${obj} | sed -n "${lineNum}p" | awk -F ":" '{print $1}')
            echo "$LINENO---$tmplist"
            echo -e "$tmplist"
            echo "$LINENO---$lineNum"
            sed -i "${lineNum} i \\${tmplist}\r" ${obj}
            fi
        done < ${_listFile}
    fi

    #备份文件，用于与下一次获取的list比较，更新json文件
    case $1 in
    0)
        cp VISVideoList tmpVISVideoList
    ;;
    0)
        cp VISPhotoList tmpVISPhotoList
    ;;
    0)
        cp IRVideoList tmpIRVideoList
    ;;
    0)
        cp IRPhotoList tmpIRPhotoList
    ;;
    *)

    esac
    return 0
}

createList 0
createList 1

echo "$LINENO===================end==================="
