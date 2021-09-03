# 这个脚本放到下载后的DSYM文件夹的根目录下，直接运行
# 生成的解析日志名为  原crash log.crash

echo '==========start=========='
pathName=$1
fileName=$(basename ${pathName} .crash)
newPathName=$fileName'log.crash'
echo $newPathName
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
~/symbolicatecrash $pathName ./dSYMs/IphoneCom.app.dSYM > $newPathName
echo '=======end======'