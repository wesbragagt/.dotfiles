#!/bin/bash
# Fuzzy search through a list of git tags, edit the environments/production/version.yaml and commit changes

# comes in the format of "sha refs/tags/version"
selection=$(git show-ref --tags -d | fzf)

if [[ -z "$selection" ]]; then
  echo "nothing selected"
  exit 0;
fi

get_current_branch(){
  git branch --show-current
}

grab_tag(){
  # since we have to extract the tag version "sha refs/tags/version"
  echo -n $@ | awk -F' ' '{print $2}' | awk -F'/' '{print $3}'
}

create_release_version_commit(){
  echo "version: '$1'" > "environments/production/version.yaml" && git add . && git commit -m "chore: release version $1"
}

create_release_version_commit $(grab_tag $selection)
