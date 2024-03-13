import multiprocessing
import os
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
    img_namespace = os.environ.get('IMG_NAMESPACE', 'library')
    registry_url_src = os.environ.get("REGISTRY_URL", 'docker.io')
    registry_url_dst = os.environ.get("DOCKER_MIRROR_REGISTRY", None)

    images = []
    job_names = get_job_names_from_yaml('.github/workflows/build-docker.yml')
    for name in job_names:
        images.extend(name.split(','))

    list_tasks = []
    for image in images:
        img = '/'.join([img_namespace, image])
        print("Docker image sync job name found:", img)
        configs = run_sync.generate(
            image=img, tags=None, source_registry=registry_url_src, target_registries=registry_url_dst
        )
        for _, c in enumerate(configs):
            list_tasks.append(c)

    with multiprocessing.Pool() as pool:
        res = pool.map_async(run_sync.sync_image, list_tasks)
        ret = sum(res.get())
        return ret


if __name__ == '__main__':
    sys.exit(main())
