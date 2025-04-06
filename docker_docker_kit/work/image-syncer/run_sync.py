import argparse
import json
import os
import subprocess
import sys
import tempfile


def generate(image: str, source_registry: str = None, target_registries: list = None, tags: list = None):
    """Generate a config item which will be used by `image-syncer`."""
    uname_mirror = os.environ.get('DOCKER_MIRROR_REGISTRY_USERNAME', None)
    passwd_mirror = os.environ.get('DOCKER_MIRROR_REGISTRY_PASSWORD', None)

    if uname_mirror is None or passwd_mirror is None:
        print('ENV variable required: DOCKER_MIRROR_REGISTRY_USERNAME and DOCKER_MIRROR_REGISTRY_PASSWORD!')
        sys.exit(-2)

    if target_registries is None:
        # , 'cn-shanghai', 'cn-shenzhen', 'cn-chengdu', 'cn-hongkong', 'us-west-1', eu-central-1
        destinations = ['cn-beijing', 'cn-hangzhou']
        target_registries = ['registry.%s.aliyuncs.com' % i for i in destinations]

    for target_registry in target_registries:
        img_src_tag = '%s:%s' % (image, tags) if tags is not None else image
        img_src: str = "%s/%s" % (source_registry, img_src_tag)
        img_dst: str = "%s/%s" % (target_registry, image)

        c = {
            'auth': {
                target_registry: {"username": uname_mirror, "password": passwd_mirror}
            },
            'images': {img_src: img_dst}
        }
        if source_registry is not None:
            uname_source = os.environ.get('DOCKER_REGISTRY_USERNAME', None)
            passwd_source = os.environ.get('DOCKER_REGISTRY_PASSWORD', None)
            if uname_source is None or passwd_source is None:
                print('ENV variable required: DOCKER_REGISTRY_USERNAME and DOCKER_REGISTRY_PASSWORD!')
                sys.exit(-2)
            c['auth'].update({source_registry: {
                "username": uname_source, "password": passwd_source}
            })
        yield c


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
    parser.add_argument('--source-registry', type=str, default='docker.io', help='Target image name, with our without tag')
    parser.add_argument('--target-registry', type=str, action='extend', nargs='*', help='Target registry URL')
    args = parser.parse_args()

    configs = generate(image=args.img, tags=args.tags, source_registry=args.source_registry, target_registries=args.target_registry)
    ret = 0
    for _, c in enumerate(configs):
        ret += sync_image(cfg=c)
    return ret


if __name__ == '__main__':
    sys.exit(main())
