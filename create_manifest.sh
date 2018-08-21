#!/bin/bash
# AssetsManagerExのマニフェスト(json)を作成するシェル
#
# usagi:
#   Assetsディレクトリを用意してpngやzipファイルを格納する
#   本シェルはAssetsディレクトと同じ階層に設置し実行(./create_manifest.sh)
#   ※ md5sum が必要なのでインストールしてから実行
#   Macの場合、HomeBrew使えば brew install md5sha1sum でインストールできる
# {
#   "packageUrl" : "https://s3-ap-northeast-1.amazonaws.com/mgnative/container/cdn",
#   "remoteManifestUrl" : "https://s3-ap-northeast-1.amazonaws.com/mgnative/container/main.manifest",
#   "version" : "1.0.0",
#   "engineVersion" : "Cocos2d-x v3.15.1",
#   "assets" : {
#   }
# }

MANIFEST_NAME="main.manifest"
PACKAGE_URL="https://s3-ap-northeast-1.amazonaws.com/mgnative/container/cdn"
REMOTEMANIFEST_URL="https://s3-ap-northeast-1.amazonaws.com/mgnative/container/main.manifest"
VERSION="1.5.0"
ENGINE_VERSION="Cocos2d-x v3.15.1"

function writeHead()
{
  echo '{' > ${MANIFEST_NAME}
  echo '  "packageUrl" : "'"${PACKAGE_URL}"'",' >> ${MANIFEST_NAME}
  echo '  "remoteManifestUrl" : "'"${REMOTEMANIFEST_URL}"'",' >> ${MANIFEST_NAME}
  echo '  "version" : "'"${VERSION}"'",' >>  ${MANIFEST_NAME}
  echo '  "engineVersion" : "'"${ENGINE_VERSION}"'",' >>  ${MANIFEST_NAME}
}

function writeTail()
{
  echo '}' >> ${MANIFEST_NAME}
}

writeHead

echo '  "assets" : {' >> ${MANIFEST_NAME}

FILE_COUNT=`ls ./Assets/ | grep -e ".zip" -e ".png" -e ".jpg" | wc -l | xargs`
echo "FILE_COUNT=${FILE_COUNT}"
LOOP_COUNT=0
for FILE in `find . -type f -mindepth 2 -print | grep -e ".zip" -e ".png" -e ".jpg"`
do
  LOOP_COUNT=$(( LOOP_COUNT + 1 ))
  echo "file count=${LOOP_COUNT}"

  MD5=`md5sum ${FILE} | cut -d ' ' -f 1`
  echo "  ${FILE}"
  echo "md5[ ${MD5} ]"
  FILE_NAME=$(basename ${FILE})
  echo '    "'${FILE_NAME}'": {' >> ${MANIFEST_NAME}
  if [ `echo ${FILE_NAME} | grep '.zip'` ]; then
    echo '      "md5" : "'${MD5}'",' >> ${MANIFEST_NAME}
    echo '      "compressed" : true' >> ${MANIFEST_NAME}
  else
    echo '      "md5" : "'${MD5}'"' >> ${MANIFEST_NAME}
  fi

  if [ $LOOP_COUNT -eq $FILE_COUNT ]; then
    echo '    }' >> ${MANIFEST_NAME}
  else
    echo '    },' >> ${MANIFEST_NAME}
  fi
done
echo '  }' >> ${MANIFEST_NAME}

writeTail

echo "-- create_manifest.sh end --"
