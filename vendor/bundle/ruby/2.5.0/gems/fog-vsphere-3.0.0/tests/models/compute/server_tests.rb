Shindo.tests('Fog::Compute[:vsphere] | server model', ['vsphere']) do
  servers = Fog::Compute[:vsphere].servers
  server = servers.last

  tests('The server model should') do
    tests('have the action') do
      test('reload') { server.respond_to? 'reload' }
      %w[stop suspend destroy reboot].each do |action|
        test(action) { server.respond_to? action }
        test("#{action} returns successfully") { server.send(action.to_sym) ? true : false }
      end
      test('start') { server.respond_to?('start') }
      test('start returns false, because it is already poweredOn') { server.start ? true : false }
      test('guest_processes') { server.respond_to? 'guest_processes' }
      test('take_snapshot') do
        test('responds') { server.respond_to? 'take_snapshot' }
        test('returns successfully') { server.take_snapshot('name' => 'foobar').is_a? Hash }
      end
      test('snapshots') do
        test('responds') { server.respond_to? 'snapshots' }
        test('returns successfully') { server.snapshots.is_a? Fog::Vsphere::Compute::Snapshots }
      end
      test('find_snapshot') do
        test('responds') { server.respond_to? 'find_snapshot' }
        test('returns successfully') do
          server.find_snapshot('snapshot-0101').is_a? Fog::Vsphere::Compute::Snapshot
        end
        test('returns correct snapshot') do
          server.find_snapshot('snapshot-0101').ref == 'snapshot-0101'
        end
      end
      tests('revert_snapshot') do
        test('responds') { server.respond_to? 'revert_snapshot' }
        tests('returns correctly') do
          test('when correct input given') { server.revert_snapshot('snapshot-0101').is_a? Hash }
          test('when incorrect input given') do
            raises(ArgumentError) { server.revert_snapshot(1) }
          end
        end
      end
      test('tickets') do
        test('acquire ticket successfully') { server.acquire_ticket.is_a? Fog::Vsphere::Compute::Ticket }
      end
    end
    tests('have attributes') do
      model_attribute_hash = server.attributes
      attributes = %i[id
                      instance_uuid
                      uuid
                      power_state
                      tools_state
                      mo_ref
                      tools_version
                      hostname
                      mac_addresses
                      operatingsystem
                      connection_state
                      hypervisor
                      name
                      public_ip_address]
      tests('The server model should respond to') do
        attributes.each do |attribute|
          test(attribute.to_s) { server.respond_to? attribute }
        end
      end
      tests('The attributes hash should have key') do
        attributes.each do |attribute|
          test(attribute.to_s) { model_attribute_hash.key? attribute }
        end
      end
    end
    test('be a kind of Fog::Vsphere::Compute::Server') { server.is_a? Fog::Vsphere::Compute::Server }
  end
end
