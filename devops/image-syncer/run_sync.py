import os
import sys
import json
import tempfile
import subprocess
import argparse
import logging


def generate(image: str, target_registries: list = None, tags: list=None, target_image:str = None):
    """Generate a config item which will be used by `image-syncer`."""
    crend_uname = os.environ.get('DOCKER_MIRROR_REGISTRY_USERNAME', None)
    crend_paswd = os.environ.get('DOCKER_MIRROR_REGISTRY_PASSWORD', None)

    if crend_uname is None or crend_paswd is None:
        print('ENV variable requried: DOCKER_MIRROR_REGISTRY_USERNAME and DOCKER_MIRROR_REGISTRY_PASSWORD !')
        sys.exit(-2)

    if target_registries is None:
        # , 'cn-shanghai', 'cn-shenzhen', 'cn-chengdu', 'cn-hongkong', 'us-west-1', eu-central-1
        destinations = ['cn-beijing', 'cn-hangzhou']
        target_registries = ['registry.%s.aliyuncs.com' % i for i in destinations]

    for dest in target_registries:
        src = "%s:%s" % (image, tags) if tags is not None else image
        yield {
            'auth': {
                dest: {"username": crend_uname, "password": crend_paswd}
            },
            'images':{
                src : "%s/%s" % (dest, target_image or image)
            }
        }


def sync_image(cfg: dict):
    """Run the sync task using `image-syncer` with given config item."""
    with tempfile.NamedTemporaryFile(mode='wt', encoding='UTF-8', suffix='.json') as fp:
        json.dump(cfg, fp, ensure_ascii=False, indent=2, sort_keys=True)
        fp.flush()
        ret = 0
        try:
            subprocess.run(['image-syncer', '--proc=8', '--retries=2', '--config=' + fp.name], check=True)
        except subprocess.CalledProcessError as e:
            ret = e.returncode
            print(e)
    return ret


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('img', type=str, help='Source image, with or without tag')
    parser.add_argument('--tags', type=list, default=None, help='Tags to sync, optional.')
    parser.add_argument('--dest-image', type=str, help='Target image name, with our without tag')
    parser.add_argument('--dest-registry', type=list, default=None, help='tTarget registry URL')
    args = parser.parse_args()

    dest_registries = args.dest_registry

    configs = generate(image=args.img, tags=args.tags, target_registries=dest_registries, target_image=args.dest_image)
    for i, c in enumerate(configs):
        ret = sync_image(cfg=c)

    sys.exit(ret)

if __name__ == '__main__':
    main()
