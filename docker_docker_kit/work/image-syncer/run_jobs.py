import os
import json
import sys
import yaml

import run_sync


def get_job_names_from_yaml(file_path):
    """Get all job names from GitHub Actions config file"""
    with open(file_path, 'r') as file:
        try:
            yaml_content = yaml.safe_load(file)
            # GitHub Actions YAML file structure has a 'jobs' key at its root
            jobs = yaml_content.get('jobs', {})
            for _, v in jobs.items():
                name = v.get('name')
                if name is not None:
                    yield name
        except yaml.YAMLError as exc:
            print(f"Error parsing YAML file: {exc}")
            return []


def main():
    namespace = os.environ.get('IMG_NAMESPACE')
    if namespace is None:
        print('Using default IMG_NAMESPACE=library !')
        namespace = 'library'

    images = []
    job_names = get_job_names_from_yaml('.github/workflows/build-docker.yml')
    for name in job_names:
        images.extend(name.split(','))

    for image in images:
        img = '/'.join([namespace, image])
        print("Docker image sync job name found:", img)
        configs = run_sync.generate(image=img, tags=None)
        for _, c in enumerate(configs):
            s_config = json.dumps(c, ensure_ascii=False, sort_keys=True)
            print('Config item:', json.dumps(c, ensure_ascii=False, sort_keys=True))
            ret = run_sync.sync_image(cfg=c)
            if ret != 0:
                return ret
    return ret


if __name__ == '__main__':
    sys.exit(main())
