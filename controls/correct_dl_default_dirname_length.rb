title 'Tests to confirm the dl_default_dirname_length is set correctly'

plan_origin = ENV["HAB_ORIGIN"]
plan_name = input("plan_name", value: "glibc")
plan_ident = "#{plan_origin}/#{plan_name}"
length = input("length", value: 50)

control 'core-plans-dl-default-dirname-length' do
  impact 1.0
  title 'Ensure dl default dirname length is correct'
  desc '
  To test that the dl default dirname length is correct we must first find the libc-VERSION.so file.
  This default dirname length depends on the length of the origin name used to build it. The way to calculate this is 50 + length of origin. So for core, it is 50 + 4 = 54. So we also calculate this from the plan_origin environment variable. 
  After that we install binutils so that we can run readelf on the file so that we can check the _nl_default_dirname length.
    $ readelf -s "TARGET_FILE" | grep -E "_nl_default_dirname" | awk "{ print $3 }" | tail -n1
      54
  '

  hab_pkg_path = command("hab pkg path #{plan_ident}")
  describe hab_pkg_path do
    its("stdout") { should_not be_empty }
    #its("stderr") { should be_empty}
    its("exit_status") { should eq 0 }  
  end

  glibc_version = command("cut -d/ -f3 #{hab_pkg_path.stdout.strip}/IDENT")
  describe glibc_version do
    its("stdout") { should match /[0-9]+.[0-9]+/ }
    #its("stderr") { should be_empty }
    its("exit_status") { should eq 0 }
  end

  target_file = File.join(hab_pkg_path.stdout.strip, "lib/libc-#{glibc_version.stdout.strip}.so")

  get_binutils = command("hab pkg install core/binutils --binlink --force")
  #describe get_binutils do
  #  its("stdout") { should match /Installing core\/binutils/ }
  #  its("stdout") { should match /Binlinked readelf/ }
  #  #its("stderr") { should be_empty}
  #  its("exit_status") { should eq 0 }
  #end

  # dl_default_dirname_length is 50 plus the origin name
  length = length + plan_origin.length

  dl_default_dirname_length_check = command("readelf -s \"#{target_file}\" | grep -E \"_nl_default_dirname\" | awk '{ print $3 }' | tail -n1")
  describe dl_default_dirname_length_check do
    its("stdout.strip.to_i") { should eq length }
    #its("stderr") { should be_empty }
    its("exit_status") { should eq 0 }
  end

end
