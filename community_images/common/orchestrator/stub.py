""" Generates stub """

import logging
import subprocess

from registry_helper import RegistryFactory

class StubGenerator:
    def __init__(self, config_dict, docker_client):
        self.config_dict = config_dict
        self.docker_client = docker_client

    def generate(self):
        repos = self.config_dict.get("repos", [])
        input_registry = self.config_dict.get("input_registry")
        output_registry = self.config_dict.get("output_registry")
        input_registry_url = input_registry.get("registry")
        input_account = input_registry.get("account")

        output_registry_url = output_registry.get("registry")
        output_account = output_registry.get("account")
        input_repo_obj = RegistryFactory.reg_helper_obj(
            self.docker_client, input_registry_url)

        input_repo_obj.auth()

        for repo in repos:
            input_repo = repo.get("input_repo")
            output_repo = repo.get("output_repo")
            input_base_tags = repo.get("input_base_tags", [])

            """
            input_registry:
                registry: docker.io
                account: bitnami
            output_registry:
                registry: docker.io
                account: rapidfort
            repos:
            - input_repo: nats
              input_base_tags:
                - "2.8.4-debian-11-r"
              output_repo: nats
            """

            for tag in input_base_tags:
                latest_tag = input_repo_obj.get_latest_tag(
                    input_account, input_repo, tag)
                logging.info(latest_tag)
                docker_image = self.docker_client.images.pull(
                    repository=f"{input_account}/{input_repo}",
                    tag=latest_tag
                    )
                full_image_tag=f"{input_account}/{input_repo}:{latest_tag}"
                subprocess.run(["rfstub", full_image_tag])
                stub_image_tag=f"{input_account}/{input_repo}:{latest_tag}-rfstub"

                stub_image = self.docker_client.images.get(stub_image_tag)

                output_stub_tag = f"{output_registry_url}/{output_account}/{output_repo}:{latest_tag}-rfstub"
                result = stub_image.tag(output_stub_tag)
                logging.info(f"image tag:[{output_stub_tag}] success=f{result}")
                result = self.docker_client.api.push(
                    f"{output_registry_url}/{output_account}/{output_repo}",
                    f"{latest_tag}-rfstub")
                logging.info(f"docker client push result: {result}")
