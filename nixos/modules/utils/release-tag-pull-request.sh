#!/bin/bash
# Fuzzy search through a list of git tags, edit the environments/production/version.yaml and commit changes

# comes in the format of "sha refs/tags/version"
selection=$(git show-ref --tags -d | fzf)

if [[ -z "$selection" ]]; then
  echo "nothing selected"
  exit 0;
fi

production_environment_version="environments/production/version.yaml"

get_current_branch(){
  git branch --show-current
}

grab_tag(){
  # since we have to extract the tag version "sha refs/tags/version"
  echo -n $@ | awk -F' ' '{print $2}' | awk -F'/' '{print $3}'
}

create_release_version_commit(){
  git checkout -b "deploy/$1" && echo "version: '$1'" > $production_environment_version && git add environments/production/version.yaml && git commit -m "chore: deploy version $1"
}

create_release_version_commit $(grab_tag $selection)
