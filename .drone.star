def main(ctx):
  return [
    lint(),
    default_tests("1.7", "1.7"),
    default_tests("1.7-prod", "1.7", "Dockerfile.prod"),
    release("1.7", "1.7", custom_tags="latest"),
    release("1.7-prod", "1.7", "Dockerfile.prod", "prod", "latest-prod")
  ]

def lint():
  return {
    "kind": "pipeline",
    "type": "docker",
    "name": "lint",
    "steps": [
      {
        "name": "Lint Dockerfiles",
        "image": "hadolint/hadolint:latest-debian",
        "pull": "if-not-exists",
        "commands": [
          "hadolint --version",
          "hadolint */Dockerfile*"
        ],
        "when": {
          "status": [
            "failure",
            "success"
          ]
        }
      },
      {
        "name": "Lint entrypoint scripts",
        "image": "koalaman/shellcheck-alpine",
        "pull": "if-not-exists",
        "commands": [
          "shellcheck --version",
          "shellcheck entrypoint*.sh"
        ],
        "when": {
          "status": [
            "failure",
            "success"
          ]
        }
      }
    ],
    "trigger": {
      "event": [
        "pull_request",
        "push"
      ],
      "ref": {
        "exclude": [
          "refs/heads/renovate/*"
        ]
      }
    }
  }

def default_tests(name, grav_version, dockerfile="Dockerfile"):
  return {
    "kind": "pipeline",
    "type": "docker",
    "name": "default_tests_%s" % name,
    "steps": [
      {
        "name": "build test",
        "image": "thegeeklab/drone-docker-buildx",
        "pull": "if-not-exists",
        "settings": {
          "dockerfile": "%s/%s" % (grav_version, dockerfile),
          "dry_run": "true",
          "platforms": "linux/amd64,linux/arm64",
          "repo": "mwalbeck/getgrav"
        },
      }
    ],
    "trigger": {
      "event": [
        "pull_request"
      ]
    },
    "depends_on": [
      "lint"
    ]
  }

def release(name, grav_version, dockerfile="Dockerfile", app_env="", custom_tags=""):
  return {
    "kind": "pipeline",
    "type": "docker",
    "name": "release_%s" % name,
    "steps": [
      {
        "name": "determine tags",
        "image": "mwalbeck/determine-docker-tags:latest-distroless",
        "pull": "if-not-exists",
        "environment": {
          "VERSION_TYPE": "docker_env",
          "APP_NAME": "GRAV",
          "DOCKERFILE_PATH": "%s/%s" % (grav_version, dockerfile),
          "APP_ENV": app_env,
          "CUSTOM_TAGS": custom_tags,
          "INCLUDE_MAJOR": "negative"
        },
      },
      {
        "name": "build and publish",
        "image": "thegeeklab/drone-docker-buildx",
        "pull": "if-not-exists",
        "settings": {
          "dockerfile": "%s/%s" % (grav_version, dockerfile),
          "username": {
            "from_secret": "dockerhub_username"
          },
          "password": {
            "from_secret": "dockerhub_password"
          },
          "platforms": "linux/amd64,linux/arm64",
          "repo": "mwalbeck/getgrav"
        },
      },
      {
        "name": "notify",
        "image": "plugins/matrix",
        "pull": "if-not-exists",
        "settings": {
          "homeserver": "https://matrix.mwalbeck.org",
          "roomid": {
            "from_secret": "matrix_roomid"
          },
          "username": {
            "from_secret": "matrix_username"
          },
          "password": {
            "from_secret": "matrix_password"
          }
        },
        "when": {
          "status": [
            "failure",
            "success"
          ]
        }
      }
    ],
    "trigger": {
      "branch": [
        "master"
      ],
      "event": [
        "push"
      ]
    },
    "depends_on": [
      "lint"
    ]
  }
