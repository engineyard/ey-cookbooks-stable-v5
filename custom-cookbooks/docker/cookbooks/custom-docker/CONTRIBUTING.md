# Setup

Install Chef-DK from <https://downloads.chef.io/chef-dk>.

## Unit Tests

Through ChefSpec

```
cd cookbooks/docker_custom
rspec spec
```

## Integration tests

Through InSpec

```
cd cookbooks/docker_custom
inspec exec -t ssh://deploy@<instance-ip> -i ~/.ssh/id_rsa \
    -l info --sudo  ./inspec
```
