import argparse
import json
import os
import subprocess
import sys
import tempfile


def generate_tasks_without_auth(image: str, source_registry: str = None, target_registries: list = None, tags: list = None):
    """Generate a config item which will be used by `image-syncer`."""
    if target_registries is None or len(target_registries) == 0:
        destinations = 'cn-beijing,cn-hangzhou'.split(',')  # ,cn-shanghai,cn-shenzhen,cn-chengdu,cn-hongkong,us-west-1,eu-central-1
        target_registries = ['registry.%s.aliyuncs.com' % i for i in destinations]

    img_src_tag = '%s:%s' % (image, tags) if tags is not None else image
    img_src: str = "%s/%s" % (source_registry, img_src_tag)
    img_dst = ["%s/%s" % (target_registry, image) for target_registry in target_registries]
    images = {img_src: img_dst}
    return images


def generate_tasks_with_auth(image: str, source_registry: str = None, target_registries: list = None, tags: list = None):
    """Generate a config item which will be used by `image-syncer`."""
    uname_mirror = os.environ.get('DOCKER_MIRROR_REGISTRY_USERNAME', None)
    passwd_mirror = os.environ.get('DOCKER_MIRROR_REGISTRY_PASSWORD', None)

    if uname_mirror is None or passwd_mirror is None:
        raise ValueError('ENV variable required: DOCKER_MIRROR_REGISTRY_USERNAME and DOCKER_MIRROR_REGISTRY_PASSWORD!')
    
    auth = {"username": uname_mirror, "password": passwd_mirror}

    if target_registries is None or len(target_registries) == 0:
        destinations = 'cn-beijing,cn-hangzhou'.split(',')  # ,cn-shanghai,cn-shenzhen,cn-chengdu,cn-hongkong,us-west-1,eu-central-1
        target_registries = ['registry.%s.aliyuncs.com' % i for i in destinations]

    for target_registry in target_registries:
        img_src_tag = '%s:%s' % (image, tags) if tags is not None else image
        img_src: str = "%s/%s" % (source_registry, img_src_tag)
        img_dst: str = "%s/%s" % (target_registry, image)
        images = {img_src: img_dst}

        c = { 'images': images, 'auth': { target_registry: auth } }
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


def sync_image(cfg: dict = None, file_path_auth: str = None):
    """Run the sync task using `image-syncer` with given config item."""
    fp = tempfile.NamedTemporaryFile(mode='wt', encoding='UTF-8', suffix='.json', delete_on_close=True)
    json.dump(cfg, fp, ensure_ascii=False, indent=2, sort_keys=True)
    fp.flush()

    if 'auth' in cfg:
        opts = ['--config=' + fp.name]
    else:
        if file_path_auth is None:
            raise ValueError('file_path_auth required if auth not provided directly!')
        opts = ['--auth=' + file_path_auth, '--images=' + fp.name]

    cmd = ['image-syncer', '--proc=16', '--retries=2', ] + opts
    # print('Running cmd:', ' '.join(cmd))
    # print('Job payload:', json.dumps(cfg, ensure_ascii=False, indent=None))
    ret = 0
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        ret = e.returncode
        print(e)
    fp.close()
    return ret


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('img', type=str, help='Source image, with or without tag')
    parser.add_argument('--tags', type=str, action='extend', nargs='*', help='Tags to sync, optional.')
    parser.add_argument('--source-registry', type=str, default='docker.io', help='Target image name, with our without tag')
    parser.add_argument('--target-registry', type=str, action='extend', nargs='*', help='Target registry URL')
    args = parser.parse_args()

    configs = generate_tasks_with_auth(image=args.img, tags=args.tags, source_registry=args.source_registry, target_registries=args.target_registry)
    ret = 0
    for _, c in enumerate(configs):
        ret += sync_image(cfg=c)
    return ret


if __name__ == '__main__':
    sys.exit(main())
