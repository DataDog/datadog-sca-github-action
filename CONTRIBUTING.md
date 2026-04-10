# Contribute

## How to release?

For the full release process (including validation steps), refer to the internal Confluence page: [Release process — datadog-sca-github-action](https://datadoghq.atlassian.net/wiki/spaces/Vulnerabil/pages/6528631938).

Summary:

1. Open a PR against `main` and validate your branch before merging.
2. After merging, create a new GitHub Release from the UI: create a new `vX.Y.Z` tag and mark it as `Latest release`.
3. (Optional) Move the major version tag to the same commit. This is only needed if users pin to `@vX` instead of `@vX.Y.Z`:
```
git tag --delete vX
git push --delete origin vX
git tag vX
git push --tags
```
