# How to use this repository #

This codebase and its cookbooks represent the latest version of Engine Yard's **`stable-v5-3.0`** stack.

Please use this repository:

### 1. To track [Issues](https://github.com/engineyard/ey-cookbooks-stable-v5/issues) with the Engine Yard software stack ###
  * Bug reports and Feature requests encouraged.

### 2. As a reference for what software is setup by default. (and how) ###
  * Hint: It all starts from the `ey-init` cookbook.

### 3. As a reference for implementing custom cookbooks ###
 * [Customizing your environment with Chef](#customize-your-environment-with-custom-chef)
 * Use the [redis](custom-cookbooks/redis) or [hello_world](custom-cookbooks/hello_world) examples for a quick reference.

### 4. As a way to contribute back. ###
 * Bugs fixes, New features, or basic hooks to simplify your own customizations are all welcome.
 * All pull requests should be made against the `next-release` branch.
 * [Contribution Guidelines](#contributing-your-changes-back-to-engine-yard)

### 5. As a place to follow the progress of weekly stack releases ###
 * [Internal Cookbooks Release Process](#engine-yards-release-process)

# Customization is a Major Design Goal of stable-v5 #

Historically, customizations have been the killer feature of Engine Yard Cloud (coupled with unparalleled support), but have also been a bane on progress. As customizations are often dependent on specific stack releases, we are restricted in our ability to keep every customer up-to-date on the latest version.

Thus, as important as your customization is to your application today, so should it be equally important that you maximize it's future chances of compatibility. In some cases this means submitting a contribution back to the mainline repository (this one) to insert a hook or variable for just the thing you need to tweak, and then adjusting your customizations accordingly when your change is accepted and released. If in doubt, just [open a support ticket](https://support.cloud.engineyard.com) and we'll take a look at the custom cookbooks you've concocted.

### If you've used custom chef on Engine Yard before... ###

Throw out your existing understanding of how it works! Previous versions (and the still supported `stable-v4` works this way) ran chef twice. There was a main run (Engine Yard's code) and a custom run (Customer's code). This meant that if a customer wanted to customize something there would always be a brief period of time between the main and custom runs where their change would be un-done until the custom run completed. No More! With `stable-v5` (and going forward) customizations are done as an overlay on the main cookbooks repository.

## Chef configures instances in your environment ##

Engine Yard's Chef stack provides the platform upon which your applications run. Based on the configuration options you choose when creating your environment, Chef will do the work of setting up things like: haproxy, nginx, mysql, and unicorn. We call this setup an "Apply". Whenever you make a configuration change such as adding an SSL certificate, you must "Apply" those changes into reality on your instances. The Chef run may create or modify files and install or upgrade software packages as a result.

The file `/etc/dna.json` is the main input to the Chef run, telling the cookbooks what kind of instance they are running on (such as app or DB), and what other servers and services are connected. This repository, and specifically the `cookbooks` folder comprise the main program passed to `chef-solo`.

## Customize your environment with Custom Chef ##

Each environment managed by Engine Yard supports the ability to upload a folder of custom cookbooks. When you run "Apply", before the chef run begins, the process pulls down both the exact cookbooks version your environment is running (e.g. `stable-v5-3.0.11`), and (if they exist) the latest custom cookbooks for that environment.

See also: example custom cookbooks in [/custom-cookbooks](/custom-cookbooks).

The custom cookbooks folder is extracted on top of the main cookbooks folder. If a file exists in both folders, the custom one will overwrite the main one. This means you could literally replace the entire cookbooks run with your own code, or just customize 1 file.

With the great power to fork this whole repository and change just 1 files, comes the responsibility to scope your changes down to the bare minimum for the benefit of future upgrades.

Additionally, this design allows for 2 major ways of customizing chef without overwriting: hooks and attributes.

### hooks ###

Hooks are empty files such as `cookbooks/ey-custom/recipes/before-main.rb` and `cookbooks/ey-custom/recipes/after-main.rb` which are guaranteed to always be empty files in the main chef repository (or contain only comments). A blank file is a perfectly valid ruby file, thus these files are included via `include_recipe` at appropriate places in the main run. Adding to these files allow you to add cookbooks with recipes to be run directly before or directly after the rest of the main cookbooks.

If you find yourself wanting your custom cookbook to run somewhere specific in the middle of run, you can submit a Pull Request to add the hook you need for inclusion into the next stack release (Submit against the branch `next-release`).

### attributes ###

Much configuration is controlled by attributes files. Most existing attributes files specify defaults of pull attributes out of DNA.  Since chef will pickup any `*.rb` file place within the `attributes` folder of a cookbook, you can easily add (for example) the file `cookbooks/postgresql/attributes/custom.rb` and set the `max_fsm_pages` attribute to something other than the default.

If you find yourself wanting to customize something that isn't controlled by an attribute, but could be, you can submit a Pull Request to add the change you need for inclusion into the next stack release (Submit against the branch `next-release`).

## Contributing your changes back to Engine Yard ##

Please submit all pull requests against the `next-release` branch. We do this because `master` will always reflect the latest production version of stable-v5. If you pull request is merged that means it is currently being tested for inclusion in the next release. If testing passes and a release is cut the PR will be updated with a comment noting in what version it was released. You'll then need to "Upgrade" your environment to use the latest release.

Before submitting a pull request, please rebase it against the next-release branch again by running `git rebase -i origin/next-release`. This way, you get to pull the latest changes and avoid possible merge conflicts, in case a release was made after you started working on your PR.

## Engine Yard's Release Process ##

1. `master` branch should always reflect the latest version of stable-v5 available in production
2. Pull Requests accumulate against the `next-release` branch (and merged as deemed appropriate)
3. Once a week, our QA team will cut a release from the `next-release` branch and run through test plan. During this time now new PRs should be merged unless they are addressing issues found in the QA review.
4. After QA completes, a release will be pushed to production, `next-release` will be merged into `master`, and PRs will again be accepted.
