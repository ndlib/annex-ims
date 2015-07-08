module AnnexFaker
  class Request
    SOURCES = ["aleph", "illiad"]
    REQUEST_TYPES = {
      "aleph" => ["doc_del"],
      "illiad" => ["ill"],
    }
    DELIVERY_TYPES = {
      "aleph" => ["loan"],
      "illiad" => ["loan", "scan"],
    }
    TRANS_PREFIXES = {
      "aleph" => "aleph_",
      "illiad" => "illiad_",
    }

    class << self
      def source
        SOURCES.sample
      end

      def request_type(source)
        REQUEST_TYPES.fetch(source).sample
      end

      def delivery_type(source)
        DELIVERY_TYPES.fetch(source).sample
      end

      def trans(source)
        "#{TRANS_PREFIXES.fetch(source)}#{AnnexFaker::Number.number(9)}"
      end

      def requested
        Date.today - rand(31).days
      end

      def criteria_type
        "barcode"
      end

      def criteria(criteria_type)
        AnnexFaker::Item.barcode
      end

      def attributes(**args)
        args[:source] ||= source
        args[:criteria_type] ||= criteria_type

        {
          requested: requested,
          rapid: false,
        }.merge(attributes_for_source(args.fetch(:source))).
          merge(attributes_for_criteria_type(args.fetch(:criteria_type))).
          merge(args)
      end

      def attributes_for_source(source)
        {
          source: source,
          trans: trans(source),
          req_type: request_type(source),
          del_type: delivery_type(source),
        }
      end

      def attributes_for_criteria_type(type)
        {
          criteria_type: type,
          criteria: criteria(type),
        }.tap do |hash|
          if type == "barcode"
            hash[:barcode] = hash.fetch(:criteria)
          end
        end
      end
    end
  end
end
