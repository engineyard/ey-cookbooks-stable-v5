# Redis

This example shows how to include the optional redis cookbooks, and also serves as a basic reference for including other optional cookbooks. Each optional cookbook should be documented in it's respective [README.md](../../cookbooks/redis/README.md). For a full list of supported optional cookbooks see: [MoreCookbooks.md](../../MoreCookbooks.md)

Once included, the redis cookbook will install and configure redis on any utility instance with the exact name "redis". Other optional cookbooks will have different conditions for deciding where to run, see the individual READMEs for details.

Steps to use this example:

1. Setup an environment, create at least 1 utility instance with the name "redis".
2. Run `ey-core recipes upload --environment <nameofenvironment> --path <pathtocookbooksfolder> --apply`
    * The `ey-core` executable can be obtained by installing the [ey-core](https://github.com/engineyard/core-client-rb) gem locally.
3. Connect your app to redis.
    * See the [README](../../cookbooks/redis/README.md) for the redis cookbook for details.

While you could just upload this example's cookbooks folder directly from a clone of this repository, a more common approach would be to add a `cookbooks` directory to your application (And commit it into version control). This way you can keep track of changes you make to cookbooks and manage multiple cookbooks. Since any upload overwrites the previous upload, you'll need to manage merging changes together.

There are only 2 changes that this example actually applies when overlaid on the main recipes.

1. `cookbooks/ey-custom/metadata.rb`
  * This example changes this file to include the line: `depends 'redis'` to this file. This tells chef to load the redis cookbooks, but doesn't tell it when to run. If your environment required multiple optional or custom cookbooks, you would need multiple `depends` lines in this file.
2. `cookbooks/ey-custom/recipes/after-main.rb`
  * This examples changes this file to include the line: `include_recipe "redis"`. This tells Chef to actually run the default recipe and the end of the main run. If you wanted it to run first you could instead use the file `before-main.rb`. And again, if you have multiple cookbooks that need to run here, you would need multiple `include_recipe` calls in your copy of this file.