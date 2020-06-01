plan_origin = ENV["HAB_ORIGIN"]
plan_name = input("plan_name", value: "glibc")
plan_ident = "#{plan_origin}/#{plan_name}"
ldd_search_path = input("ldd_search_path", value: "/bin/ldd")
rtldlist = input("rtldlist", value: "/lib/ld-linux.so.2")

hab_pkg_path = command("hab pkg path #{plan_ident}")
describe hab_pkg_path do
  its("exit_status") { should eq 0 }
  its("stdout") { should_not be_empty }
end

target_file = File.join(hab_pkg_path.stdout.strip, ldd_search_path)
expected_file = File.join(hab_pkg_path.stdout.strip, rtldlist)

ldd_search_path_check = command("grep \"^RTLDLIST=\" #{target_file} |cut -d'\"' -f2 |cut -d' ' -f1")
describe ldd_search_path_check do
  its("exit_status") { should eq 0 }
  its("stdout.strip") { should eq "#{expected_file}" }
end
