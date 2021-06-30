# Contributing Guidelines

## Issues / PR / Ideas

You can create issues to share ideas or report a problem.  
Feel free also to submit pull requests.


## Commit Signing

All the commits need to be signed with a PGP key.  
Your commit command should look like...

```bash
# "S" is upper-case
commit -S -m "your commit message"
```

... unless you enabled the setting to automatically sign your commits.

```bash
# Verify signing is enabled by default
git config commit.gpgsign
```

The following links will help you to configure your client:

* [Signing commits](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits)
* [Generating a new GPG key](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/generating-a-new-gpg-key)
* [Telling Git about your key](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/telling-git-about-your-signing-key)
