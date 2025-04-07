import argparse
import multiprocessing
import os
import sys
import yaml

from run_sync import generate_tasks_with_auth, generate_tasks_without_auth, sync_image


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
    parser = argparse.ArgumentParser()
    parser.add_argument('--workflow-file', type=str, default='.github/workflows/build-docker.yml', help='GitHub actions workflow file')
    parser.add_argument('--image-namespace', type=str, default=os.environ.get('IMG_NAMESPACE', 'library'), help='namespace of the image')
    parser.add_argument('--source-registry', type=str, default=os.environ.get("REGISTRY_URL", 'docker.io'), help='REGISTRY_URL')
    parser.add_argument('--target-registry', type=str, default=os.environ.get("DOCKER_MIRROR_REGISTRY", '').split(','), action='extend', nargs='*', help='Target registry URL')
    parser.add_argument('--auth-file', type=str, default=os.environ.get("FILE_AUTH", None), help='auth file used for image-sync')
    args = parser.parse_args()

    list_tasks = []
    for image in get_job_names_from_yaml(args.workflow_file):
        img = '/'.join([args.image_namespace, image])
        print("Docker image sync job name found:", img)

        param = dict(
            image=img, tags=None, source_registry=args.source_registry, target_registries=args.target_registry
        )

        if args.auth_file is not None:
            cfg = generate_tasks_without_auth(**param)
            list_tasks.append((cfg, args.auth_file))
        else:
            cfg = generate_tasks_with_auth(**param)
            for _, c in enumerate(cfg):
                list_tasks.append((c, None))

    with multiprocessing.Pool() as pool:
        res = pool.starmap_async(sync_image, list_tasks)
        ret = sum(res.get())
        return ret


if __name__ == '__main__':
    sys.exit(main())
