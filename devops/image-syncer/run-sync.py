import os
import sys
import json
import tempfile
import subprocess


def generate(image, tag=None):
    # , 'cn-shanghai', 'cn-shenzhen', 'cn-chengdu', 'cn-hongkong', 'us-west-1', eu-central-1
    destinations = ['cn-beijing', 'cn-hangzhou']
    destinations = ['registry.%s.aliyuncs.com' % i for i in destinations]

    crend_uname = os.environ.get('DOCKER_MIRROR_REGISTRY_USERNAME', None)
    crend_paswd = os.environ.get('DOCKER_MIRROR_REGISTRY_PASSWORD', None)

    if crend_uname is None or crend_paswd is None:
        print('ENV variable requried: DOCKER_MIRROR_REGISTRY_USERNAME and DOCKER_MIRROR_REGISTRY_PASSWORD !')
        sys.exit(-2)

    for dest in destinations:
        src = image
        if tag is not None:
            src = "%s:%s" % (image, tag)

        yield {
            'auth': {
                dest: {"username": crend_uname, "password": crend_paswd}
            },
            'images':{
                src : "%s/%s" % (dest, image)
            }
        }

if __name__ == '__main__':
    args = sys.argv[1:]
    segs = args[1:]

    if len(args) < 1 or len(segs) > 2:
        print('Usage:')
        print('\tDOCKER_MIRROR_REGISTRY_USERNAME="*" DOCKER_MIRROR_REGISTRY_PASSWORD="*" python run-sync.py repo/image:tag')
        sys.exit(-1)

    img = args[0]
    tag = None if len(segs) == 0 else ','.join(segs[1:])

    configs = generate(image=img, tag=tag)
    for i, c in enumerate(configs):
        with tempfile.NamedTemporaryFile(mode='wt', encoding='UTF-8', suffix='.json') as fp:
            json.dump(c, fp, ensure_ascii=False, indent=2, sort_keys=True)
            fp.flush()
            ret = subprocess.run(['image-syncer', '--proc=6', '--retries=2', '--config=' + fp.name])
    sys.exit(ret)
