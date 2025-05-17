Rust Darwin Builder Action
========================

![GitHub](https://img.shields.io/github/license/aig787/rust-darwin-cross-builder)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/aig787/rust-darwin-cross-builder)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/aig787/rust-darwin-cross-builder/CI)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/aig787/rust-darwin-cross-builder)

GitHub action for building Darwin targeted rust binaries (x86_64-apple-darwin). 

```yaml
- uses: aig787/rust-darwin-cross-action@1.87.0
  with:
    args: build --release --all-features
    git_credentials: ${{ secrets.GIT_CREDENTIALS }}
```

### Inputs
| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| args     | Arguments passed to cargo | true | `build --release` | 
| git_credentials | If provided git will be configured to use these credentials and https | false | |
| directory | Relative path under $GITHUB_WORKSPACE where Cargo project is located | false | |

### Credits:
* [osxcross](https://github.com/tpoechtrager/osxcross)
* [osxcross-extras](https://github.com/liushuyu/osxcross-extras)
