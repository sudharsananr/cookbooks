path_to_motd = value_for_platform(
    'ubuntu' => { 'default' => '/etc/update-motd.d/rsmotd' },
    'default' => '/etc/motd'
)

perm_motd = value_for_platform(
    'ubuntu' => { 'default' => 0755 },
    'default' => 0444
)

prefix = "  "
width = 78
realwidth = width - prefix.length

if node['motd_description']
    description = node['motd_description'].gsub(/(.{1,#{realwidth}})(?: +|$)\n?|(.{#{realwidth}})/, "#{prefix}\\1\\2\n").chomp
else
    description = nil
end

rolelist = node['roles'].join(', ').gsub(/(.{1,#{realwidth}})(?: +|$)\n?|(.{#{realwidth}})/, "#{prefix}\\1\\2\n").lstrip.chomp

template path_to_motd do
    source 'motd.erb'
    owner 'root'
    group 'root'
    mode perm_motd
    action :create
    variables({
        'description' => description,
       'rolelist' => rolelist
    })
    notifies :run, 'execute[update motd]', :immediately
    not_if { node['custom_motd'] }
end

execute 'update motd' do
    command 'run-parts --lsbsysinit /etc/update-motd.d > /var/run/motd'
    action :nothing
    only_if { platform?('ubuntu') }
end
