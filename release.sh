#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

usage() {
    echo "usage: ./release.sh <major|minor|patch|v<semantic-version>>" >&2
}

if (( $# != 1 )); then
    usage
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "working tree must be clean before releasing" >&2
    exit 1
fi

requested="$1"
semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?(\+[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?$'
stable_semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

case "$requested" in
    major | minor | patch)
        remote_tags="$(git ls-remote --tags --refs origin 'refs/tags/v*')"
        latest_major=0
        latest_minor=0
        latest_patch=0

        while read -r _ ref; do
            [[ -n "$ref" ]] || continue
            candidate="${ref#refs/tags/v}"
            [[ "$candidate" =~ $stable_semver ]] || continue
            IFS=. read -r candidate_major candidate_minor candidate_patch <<< "$candidate"

            if (( 10#$candidate_major > 10#$latest_major ||
                  (10#$candidate_major == 10#$latest_major && 10#$candidate_minor > 10#$latest_minor) ||
                  (10#$candidate_major == 10#$latest_major && 10#$candidate_minor == 10#$latest_minor && 10#$candidate_patch > 10#$latest_patch) )); then
                latest_major="$candidate_major"
                latest_minor="$candidate_minor"
                latest_patch="$candidate_patch"
            fi
        done <<< "$remote_tags"

        case "$requested" in
            major) version="$((10#$latest_major + 1)).0.0" ;;
            minor) version="$latest_major.$((10#$latest_minor + 1)).0" ;;
            patch) version="$latest_major.$latest_minor.$((10#$latest_patch + 1))" ;;
        esac
        ;;
    v*)
        version="${requested#v}"
        if [[ ! "$version" =~ $semver ]]; then
            echo "explicit version must have the form v<semantic-version>" >&2
            exit 1
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

source_tag="source-$version"
version_tag="v$version"

echo "Resolved version: $version"

if git ls-remote --exit-code --tags origin "refs/tags/$version_tag" >/dev/null 2>&1; then
    echo "tag $version_tag already exists on origin" >&2
    exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/$source_tag" >/dev/null 2>&1; then
    echo "tag $source_tag already exists on origin; rerun its existing workflow instead" >&2
    exit 1
fi

head_commit="$(git rev-parse HEAD)"
if git show-ref --verify --quiet "refs/tags/$source_tag"; then
    tagged_commit="$(git rev-parse "$source_tag^{commit}")"
    if [[ "$tagged_commit" != "$head_commit" ]]; then
        echo "local tag $source_tag points to $tagged_commit, not HEAD ($head_commit)" >&2
        exit 1
    fi
else
    git tag "$source_tag" "$head_commit"
fi

git push origin "refs/tags/$source_tag"
echo "Pushed $source_tag; the release workflow will publish $version_tag"
