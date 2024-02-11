import argparse
import json
import os
import subprocess
import sys
import tempfile


def generate(image: str, target_registries: list = None, tags: list = None, target_image: str = None):
    """Generate a config item which will be used by `image-syncer`."""
    uname = os.environ.get('DOCKER_MIRROR_REGISTRY_USERNAME', None)
    passwd = os.environ.get('DOCKER_MIRROR_REGISTRY_PASSWORD', None)

    if uname is None or passwd is None:
        print('ENV variable required: DOCKER_MIRROR_REGISTRY_USERNAME and DOCKER_MIRROR_REGISTRY_PASSWORD !')
        sys.exit(-2)

    if target_registries is None:
        # , 'cn-shanghai', 'cn-shenzhen', 'cn-chengdu', 'cn-hongkong', 'us-west-1', eu-central-1
        destinations = ['cn-beijing', 'cn-hangzhou']
        target_registries = ['registry.%s.aliyuncs.com' % i for i in destinations]

    for dest in target_registries:
        src = "%s:%s" % (image, tags) if tags is not None else image
        yield {
            'auth': {
                dest: {"username": uname, "password": passwd}
            },
            'images': {
                src: "%s/%s" % (dest, target_image or image)
            }
        }


def sync_image(cfg: dict):
    """Run the sync task using `image-syncer` with given config item."""
    with tempfile.NamedTemporaryFile(mode='wt', encoding='UTF-8', suffix='.json') as fp:
        json.dump(cfg, fp, ensure_ascii=False, indent=2, sort_keys=True)
        fp.flush()
        ret = 0
        try:
            subprocess.run(['image-syncer', '--proc=16', '--retries=2', '--config=' + fp.name], check=True)
        except subprocess.CalledProcessError as e:
            ret = e.returncode
            print(e)
    return ret


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('img', type=str, help='Source image, with or without tag')
    parser.add_argument('--tags', type=str, action='extend', nargs='*', help='Tags to sync, optional.')
    parser.add_argument('--dest-image', type=str, help='Target image name, with our without tag')
    parser.add_argument('--dest-registry', type=str, action='extend', nargs='*', help='tTarget registry URL')
    args = parser.parse_args()

    configs = generate(image=args.img, tags=args.tags, target_registries=args.dest_registry, target_image=args.dest_image)
    for _, c in enumerate(configs):
        ret = sync_image(cfg=c)
    return ret


if __name__ == '__main__':
    sys.exit(main())
