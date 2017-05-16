# env_vars

This recipe is used to upload a /data/app_name/shared/config/env.custom file on the stable-v5 stack. This file is used to load environment variables for the web application; the v5 scripts for Passenger and Unicorn were written to source this file on startup.

The env_vars recipe is managed by Engine Yard. You should not copy this recipe to your repository but instead copy custom-env_vars. Please check the [custom-env_vars readme](../../custom-cookbooks/env_vars/cookbooks/custom-env_vars) for the complete instructions.

We accept contributions for changes that can be used by all customers.
