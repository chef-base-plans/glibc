plan_origin = ENV["HAB_ORIGIN"]
plan_name = input("plan_name", value: "glibc")
plan_ident = "#{plan_origin}/#{plan_name}"
abi_version = input("abi_version", value: "3.2.0")

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

abi_check = command("readelf -n \"#{target_file}\" | grep \"OS: Linux, ABI:\" | awk '{ print $4 }'")
describe abi_check do
  its("exit_status") { should eq 0 }
  its("stdout.strip") { should eq abi_version }
end
