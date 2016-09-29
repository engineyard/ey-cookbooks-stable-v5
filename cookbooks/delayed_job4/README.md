# Delayed Job

This cookbook can serve as a good starting point for setting up Delayed Job support in your application. In this recipe your Delayed Job workers will be set up to run under monit. The number of workers will vary based on the size of the instance running Delayed Job.

** Please Note ** This recipe will setup delayed_job on a single instance environment or on a Utility instance in a cluster environment. If you need delayed_job to run on app instances (if you are not using a Utility instance), you will need to modify custom-delayed_job4 not this recipe.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

You should not add this recipe (delayed_job4) to your repository. You should add custom-delayed_job4 as mentioned below.

1. Edit cookbooks/ey-custom/recipes/after-main.rb and add

      ```
      include_recipe 'custom-delayed_job4'
      ```

2. Edit cookbooks/ey-custom/metadata.rb and add

      ```
      depends 'custom-delayed_job4'
      ```

3. Copy examples/delayed_job4/cookbooks/custom-delayed_job4 to cookbooks/

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp examples/delayed_job4/cookbooks/custom-delayed_job4 /path/to/app/cookbooks/
      ```

## Customizations

Customizations are done on cookbooks/custom-delayed_job4/attributes/default.rb. Check the file for examples.

## Restarting your workers

This recipe does NOT restart your workers. The reason for this is that shipping your application and
rebuilding your instances (i.e. running chef) are not always done at the same time. It is best to
restart your Delayed Job workers when you ship (deploy) your application code.

If you're running Delayed Job on a solo instance or on your app master, add a deploy hook similar to:

```
on_app_master do
  sudo "monit -g dj_#{config.app} restart all"
end
```

On the other hand, if you'r running Delayed Job on a dedicated utility instance, the deploy hook should be like:

```
on_utilities :delayed_job do
  sudo "monit -g dj_#{config.app} restart all"
end
```

where delayed_job is the name of the utility instance.

You likely want to use the after_restart hook for this. Put the code above in deploy/after_restart.rb.

See our [Deploy Hook](https://engineyard.zendesk.com/entries/21016568-use-deploy-hooks) documentation for more information on using deploy hooks.
