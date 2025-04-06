import argparse
import multiprocessing
import os
import sys

import yaml

import run_sync


def get_job_names_from_yaml(file_path):
    """Get all job names from GitHub Actions config file"""
    images = []
    with open(file_path, 'r') as file:
        try:
            yaml_content = yaml.safe_load(file)
            # GitHub Actions YAML file structure has a 'jobs' key at its root
            jobs = yaml_content.get('jobs', {})
            for _, v in jobs.items():
                name = v.get('name')
                if name is not None:
                    images.extend(name.split(','))
        except yaml.YAMLError as exc:
            print(f"Error parsing YAML file: {exc}")
    return images


def main():
    img_namespace = os.environ.get('IMG_NAMESPACE', 'library')
    registry_url_src = os.environ.get("REGISTRY_URL", 'docker.io')
    registry_url_dst = os.environ.get("DOCKER_MIRROR_REGISTRY", None)

    parser = argparse.ArgumentParser()
    parser.add_argument('--workflow-file', type=str, default='.github/workflows/build-docker.yml', help='GitHub actions workflow file')
    parser.add_argument('--image-namespace', type=str, default=img_namespace, help='namespace of the image')
    parser.add_argument('--source-registry', type=str, default=registry_url_src, help='REGISTRY_URL')
    parser.add_argument('--target-registry', type=str, default=registry_url_dst, action='extend', nargs='*', help='Target registry URL')
    args = parser.parse_args()

    list_tasks = []
    for image in get_job_names_from_yaml(args.workflow_file):
        img = '/'.join([args.image_namespace, image])
        print("Docker image sync job name found:", img)
        configs = run_sync.generate(
            image=img, tags=None, source_registry=args.source_registry, target_registries=args.target_registry
        )
        for _, c in enumerate(configs):
            list_tasks.append(c)

    with multiprocessing.Pool() as pool:
        res = pool.map_async(run_sync.sync_image, list_tasks)
        ret = sum(res.get())
        return ret


if __name__ == '__main__':
    sys.exit(main())
