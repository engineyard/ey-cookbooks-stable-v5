ey-custom
=========

This library is used to enable customizations to the Chef cookbooks provided
by Engine Yard.  The process is as follows:

1. Identify where you want to inject your customizations.

  Many recipes need to be run before one thing, or after another.  This is
  facilitated by the main cookbooks providing customization hooks in the form
  of blank recipes that can be overridden with your custom recipe.  These
  hooks can be found under the ey-custom/recipes/\*

2. Provide a file to over-write the blank hook file.

  If for example, you want your recipes to run at the end of the main run, you
  provide the file cookbooks/ey-custom/recipes/after-main.rb.  While, you can
  just add the resources in that file, it is recommended that you simply write
  an include_recipe command to the actual recipes you want to add.

3. Specify your dependencies in the cookbook/ey-custom/metadata.rb file

  If you include other recipes, you need to add these recipes to the
  metadata.rb file using `depends` command so they get added correctly. 

4. Overwrite your recipe attributes

  If you are using a pre-made optional recipe, you may need also over-write
  the attributes file to customize it for your needs.

5. Provide your custom recipe

  If you need to provide a whole recipe yourself, you'll need to create it
  under cookbooks/ directory and name it something appropriate.  We recommend
  prefixing it with your organization's name, as we ourselves have prefixed
  many of our recipes with ey-
