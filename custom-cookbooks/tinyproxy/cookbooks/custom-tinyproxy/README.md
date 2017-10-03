## Tinyproxy

This is a wrapper cookbook for Tinyproxy. This is designed to help you customize how Tinyproxy is setup on your environment without having to modify the Tinyproxy recipe. If you find you're unable to modify the way Tinyproxy runs just by modifying this recipe, please open a Github issue.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the tinyproxy recipe but it is not included by default. To use the tinyproxy recipe, you should copy this recipe, `custom-tinyproxy`. You should not copy the actual tinyproxy recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

  ```
  include_recipe 'custom-tinyproxy'
  ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

  ```
  depends 'custom-tinyproxy'
  ```

3. Copy `custom-cookbooks/tinyproxy/cookbooks/custom-tinyproxy ` to `cookbooks/`

  ```
  cd ~ # Change this to your preferred directory. Anywhere but inside the application

  git clone https://github.com/engineyard/ey-cookbooks-stable-v5
  cd ey-cookbooks-stable-v5
  cp custom-cookbooks/tinyproxy/cookbooks/custom-tinyproxy /path/to/app/cookbooks/
  ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

## Customizations

All customizations go to `cookbooks/custom-tinyproxy/attributes/default.rb`.


### Specify where Tinyproxy runs

The recipe supports running Tinyproxy in app_master, or in a dedicated utility instance.

#### A. Run Tinyproxy in a named utility instance

Uncomment these lines if you want to run Tinyproxy in a utility instance.

```
  #tinyproxy['is_tinyproxy_instance'] = (
  #  node['dna']['instance_role'] == 'util' &&
  #  node['dna']['name'] == tinyproxy['utility_name']
  #)
```

Comment out this line:

```
  tinyproxy['is_tinyproxy_instance'] = (node['dna']['instance_role'] == 'app_master')
```

Change this if you're using a different name for the Tinyproxy instance.

```
    tinyproxy['utility_name'] = 'tinyproxy'
```

#### B. Run Tinyproxy in app_master

Uncomment this line:

```
  #tinyproxy['is_tinyproxy_instance'] = (node['dna']['instance_role'] == 'app_master')
```

And comment out these lines, if not yet commented out:

```
  tinyproxy['is_tinyproxy_instance'] = (
    node['dna']['instance_role'] == 'util' &&
    node['dna']['name'] == tinyproxy['utility_name']
  )
```

When an automated takeover happens, the recipe will install Tinyproxy in the new app_master.

Please ensure that _all_ the app slave instances do not have an attached EIP. Please refer to this [KB article](https://support.cloud.engineyard.com/hc/en-us/articles/205407858-Application-Master-Takeover#eipaddressing) for more information.

### Specify the Tinyproxy port

Change this if you want to have TinyProxy listen on a different port. The default port is 8888.

```
  tinyproxy['port'] = '8888'
```

### Specify the Tinyproxy version

You can specify the Tinyproxy version to use by changing this line:

```
  tinyproxy['version'] = '1.8.3-r4'
```

Currently only version 1.8.3-r4 is supported by this recipe. If you need a newer version, please open a Support ticket.

## Usage

This custom chef recipe creates `/data/app_name/shared/config/tinyproxy.yml`, which is automatically linked to `/data/app_name/current/config/tinyproxy.yml`.

### Rails Usage

You can parse the tinyproxy.yml file to determine the hostname and port used by tinyproxy like this:

```
yaml_file = File.join(Rails.root || current_path, 'config', 'tinyproxy.yml')
tinyproxy_config = YAML::load(ERB.new(IO.read(yaml_file)).result)
tinyproxy_host = tinyproxy_config[:hostname] || 'localhost'
tinyproxy_port = tinyproxy_config[:port] || '8888'
```

Once that is done, you can call Net::HTTP like this:

```
Net::HTTP.new(target_url, nil, tinyproxy_host, tinyproxy_port).start { |http|
  http.get(target_url, '')
}
```

## Test Cases

This custom chef recipe has been verified using these test cases:

```
A. Install tinyproxy on app_master
  A1. tinyproxy should be running on app_master
  A2. tinyproxy should not be running on any other instance
  A3. /data/app_name/shared/config/tinyproxy.yml should have the correct host and port settings
  A4. Initiate a takeover. tinyproxy should be running on the new app_master

B. Install tinyproxy on util instance named tinyproxy
  B1. tinyproxy should be running on tinyproxy
  B2. tinyproxy should not be running on any other instance
  B3. /data/app_name/shared/config/tinyproxy.yml should have the correct host and port settings
```

If you encounter a problem, please open a Github issue and metion which of these cases failed.
