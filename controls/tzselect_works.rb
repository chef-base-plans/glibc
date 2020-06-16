tzselect = input("tzselect", value: "/bin/tzselect")

describe bash("echo '2\n49\n22\n1' >> tz-test.txt") do
  its('stdout') { should be_empty }
  its('stderr') { should be_empty }
  its('exit_status') { should eq 0}
end

describe bash("#{tzselect} < tz-test.txt 2>&1 | tail -n1 ") do
  its('stdout.strip') { should eq "#? America/Anchorage" }
  its('stderr') { should be_empty}
  its('exit_status') { should eq 0 }
end
