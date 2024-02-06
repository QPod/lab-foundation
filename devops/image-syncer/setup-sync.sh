VER_IMAGE_SYNCER="1.5.4"
URL_IMAGE_SYNCER="https://github.com/AliyunContainerService/image-syncer/releases/download/v${VER_IMAGE_SYNCER}/image-syncer-v${VER_IMAGE_SYNCER}-linux-amd64.tar.gz"

echo "Downloading executable from: ${URL_IMAGE_SYNCER}"

curl -o /tmp/image_syncer.tgz -sL ${URL_IMAGE_SYNCER}

mkdir -pv /tmp/image_syncer &&  tar -zxvf /tmp/image_syncer.tgz -C /tmp/image_syncer
sudo chmod +x /tmp/image_syncer/image-syncer 
sudo mv /tmp/image_syncer/image-syncer /usr/bin/
rm -rf /tmp/image_syncer*
