plan_origin = ENV["HAB_ORIGIN"]
plan_name = input("plan_name", value: "glibc")
plan_ident = "#{plan_origin}/#{plan_name}"
ldconfig_path = input("ldconfig_path", value: "/bin/ldconfig")

hab_pkg_path = command("hab pkg path #{plan_ident}")
describe hab_pkg_path do
  its("exit_status") { should eq 0 }
  its("stdout") { should_not be_empty }
end

target_file = File.join(hab_pkg_path.stdout.strip, ldconfig_path)

ldd_search_path_check = command("#{target_file} --print-cache | tail -n +1 | awk '{print $8}'")
describe ldd_search_path_check do
  its("exit_status") { should eq 0 }
  its("stdout") { should_not be_empty }
  for line in ldd_search_path_check.stdout.split()
    describe command("echo #{line} | cut -d/ -f1-7") do
      its("exit_status") { should eq 0 }
      its("stdout.strip") { should eq "#{hab_pkg_path.stdout.strip}" }
    end
  end
end
