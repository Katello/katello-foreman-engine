module KatelloForemanEngine

  module Actions

    class OrgCreate < Eventum::Action

      def subscribe
        Events::OrgCreate
      end

      output_format do
        param :uuid, String
      end

      def handle
        Rails.logger.info("So you really want to create org #{input['label'} - #{input['name']} ?")
        output['uuid'] = '1234-5678-0000-0000'
      end
    end
  end
end
