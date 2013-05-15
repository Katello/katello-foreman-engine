require 'test_helper'

module KatelloForemanEngine
  module Actions
    class OrgCreateTest < ActiveSupport::TestCase

      test 'calls bindings to create organization' do
        Bindings.expects(:organization_create). with('KT-[ACME]')
        OrgCreate.new('label' => 'ACME').run
      end

    end
  end
end
