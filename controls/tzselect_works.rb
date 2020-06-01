tzselect = attribute("tzselect", default: "/bin/tzselect")

describe bash("/bin/tzselect << EOF \n2\n49\n22\n1\nEOF\n") do
  its('stdout') { should eq "America/Anchorage"}
  its('stderr') { should eq "" }
  its('exit_status') { should eq 0 }
end
