# Install Node
node.default['nodejs']['install_method'] = 'binary'
node.default['nodejs']['version'] = '6.11.2'
node.default['nodejs']['binary']['checksum'] = '1ca74833ff79e6a3a713a88bba8e7f5f5cda5d4008a6ffeb2293a1bf98f83e04'
# node.default['nodejs']['version'] = '6.11.0'
# node.default['nodejs']['binary']['checksum'] = '2b0e1b06bf8658ce02c16239eb6a74b55ad92d4fb7888608af1d52b383642c3c'
# node.default['nodejs']['version'] = '0.12.15'
# node.default['nodejs']['binary']['checksum'] = 'ab2dc52174552e3959f15a438918b32b59e49409e5640f2acb1a3b9c85cf2a95'
include_recipe 'nodejs'
include_recipe 'nodejs::npm'
