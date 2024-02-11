import os
import yaml
import run_sync


def get_job_names_from_yaml(file_path):
    with open(file_path, 'r') as file:
        try:
            yaml_content = yaml.safe_load(file)
            # GitHub Actions YAML file structure has a 'jobs' key at its root
            jobs = yaml_content.get('jobs', {})
            for k, v in jobs.items():
                name = v.get('name')
                if name is not None:
                    yield name
        except yaml.YAMLError as exc:
            print(f"Error parsing YAML file: {exc}")
            return []


def main():
    namespace = os.environ.get('NAMESPACE', 'library')

    images = []
    job_names = get_job_names_from_yaml('.github/workflows/build-docker.yml')
    for name in job_names:
        images.extend(name.split(','))

    for image in images:
        print("Job names found:", image)
        configs = run_sync.generate(image='/'.join([namespace, image]), tags=None)
        for i, c in enumerate(configs):
            ret = run_sync.sync_image(cfg=c)
    return ret

if __name__ == '__main__':
    main()
