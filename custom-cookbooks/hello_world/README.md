# Hello World

This example demonstrates the minimum effort required to add a NEW custom cookbook. The `hello_wold` cookbook does nothing other than output "Hello World" to the chef log. It can also be used to validate that custom cookbooks are working properly.

Steps to use this example:

1. Setup an environment
2. Run `ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply --verbose`
    * The `ey-core` executable can be obtained by installing the [ey-core](https://github.com/engineyard/core-client-rb) gem locally.

This example consists of 2 cookbooks:

1. The `ey_custom` cookbook. This cookbook is already included with the main chef run, but does nothing by default. It exists for the purpose of being overriden by customers for custom chef. In this example we override `cookbooks/ey-custom/metadata.rb` and `cookbooks/ey-custom/recipes/before-main.rb` to invoke the `hello_world` cookbook
3. The `hello_word` cookbook. This cookbook includes the bare minimum: a `metadata.rb` file and a `default.rb` recipe. (the log output line is in the default recipe).
