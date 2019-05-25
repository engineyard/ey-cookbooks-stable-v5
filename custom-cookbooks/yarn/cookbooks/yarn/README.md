# Yarn

This cookbook makes it easy to install any version of `yarn` available in a downloadable form in [https://github.com/yarnpkg/yarn/releases/](https://github.com/yarnpkg/yarn/releases/).


## Installation

For simplicity, we recommend that you create the `cookbooks/` directory at the
root of your application. If you prefer to keep the infrastructure code separate
from application code, you can create a new repository.

To use the `yarn` cookbook, you should copy this cookbook
`yarn`. 

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

```
    include_recipe 'yarn'
```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

```
    depends 'yarn'
```

3. Copy `custom-cookbooks/timezone/cookbooks/yarn` to `cookbooks/`

```
    cd ~ # Change this to your preferred directory. Anywhere but inside the application

    git clone https://github.com/engineyard/ey-cookbooks-stable-v5
    cd ey-cookbooks-stable-v5
    cp custom-cookbooks/yarn/cookbooks/yarn /path/to/app/cookbooks/
```

If you do not have `cookbooks/ey-custom` on your app repository, you can copy
`custom-cookbooks/yarn/cookbooks/ey-custom` to `/path/to/app/cookbooks` as well.

## Specifying the Yarn version

The recipe is installing `yarn` version 1.9.4 by default. You may change that by setting the version in `cookbooks/yarn/attributes/default.rb`.

