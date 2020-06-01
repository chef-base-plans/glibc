plan_origin = ENV["HAB_ORIGIN"]
plan_name = input("plan_name", value: "glibc")
plan_ident = "#{plan_origin}/#{plan_name}"
length = input("length", value: "54")

hab_pkg_path = command("hab pkg path #{plan_ident}")
describe hab_pkg_path do
  its("exit_status") { should eq 0 }
  its("stdout") { should_not be_empty }
end

glibc_version = command("cut -d/ -f3 #{hab_pkg_path.stdout.strip}/IDENT")
describe glibc_version do
  its("exit_status") { should eq 0 }
  its("stdout") { should_not be_empty }
end

target_file = File.join(hab_pkg_path.stdout.strip, "lib/libc-#{glibc_version.stdout.strip}.so")

get_binutils = command("hab pkg install core/binutils --binlink")
describe get_binutils do
  its("exit_status") { should eq 0 }
end

dl_default_dirname_length_check = command("readelf -s \"#{target_file}\" | grep -E \"_nl_default_dirname\" | awk '{ print $3 }' | tail -n1")
describe dl_default_dirname_length_check do
  its("exit_status") { should eq 0 }
  its("stdout.strip") { should eq length }
end
