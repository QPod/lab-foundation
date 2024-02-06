import os
import sys
import json
import tempfile
import subprocess


def generate(image, tags=None):
    if tags is None:
        tags = ['latest']

    tags = ','.join(tags)

    # , 'cn-shanghai', 'cn-shenzhen', 'cn-chengdu', 'cn-hongkong', 'us-west-1', eu-central-1
    destinations = ['cn-beijing', 'cn-hangzhou']
    destinations = ['registry.%s.aliyuncs.com' % i for i in destinations]

    crend_uname = os.environ.get('DOCKER_MIRROR_REGISTRY_USERNAME', None)
    crend_paswd = os.environ.get('DOCKER_MIRROR_REGISTRY_PASSWORD', None)

    if crend_uname is None or crend_paswd is None:
        print('ENV variable requried: DOCKER_MIRROR_REGISTRY_USERNAME and DOCKER_MIRROR_REGISTRY_PASSWORD !')
        sys.exit(-2)

    for dest in destinations:
        yield {
            'auth': {
                dest: {"username": crend_uname, "password": crend_paswd}
            },
            'images':{
                "%s:%s" % (image, tags) : "%s/%s" % (dest, image)
            }
        }

if __name__ == '__main__':
    args = sys.argv[1:]

    if len(args) < 1:
        print('Usage:')
        print('\tDOCKER_MIRROR_REGISTRY_USERNAME="*" DOCKER_MIRROR_REGISTRY_PASSWORD="*" python run-sync.py repo/image')
        sys.exit(-1)

    img = args[0]
    tags = args[1:] or None

    configs = generate(image=img, tags=tags)
    for i, c in enumerate(configs):
        with tempfile.NamedTemporaryFile(mode='wt', encoding='UTF-8', suffix='.json') as fp:
            json.dump(c, fp, ensure_ascii=False, indent=2, sort_keys=True)
            fp.flush()
            subprocess.run(['image-syncer', '--proc=6', '--retries=2', '--config=' + fp.name])
    sys.exit(0)
