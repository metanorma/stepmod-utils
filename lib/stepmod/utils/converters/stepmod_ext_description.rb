module Stepmod
  module Utils
    module Converters
      class StepmodExtDescription < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          state = state.merge(schema_name: node["linkend"])
          linkend = node["linkend"].split(".")

          # We only want ENTITY entries, not their attributes
          # https://github.com/metanorma/iso-10303-2/issues/36#issuecomment-841300092
          return nil if linkend.length != 2

          child_text = treat_children(node, state).strip
          return nil if child_text.empty?

          # Unless the first paragraph ends with "between" and is followed by a
          # list, don't split
          first_child = child_text.split("\n").first

          unless (
            first_child =~ /between:?\s*\Z/ ||
            first_child =~ /include:?\s*\Z/ ||
            first_child =~ /of:?\s*\Z/ ||
            first_child =~ /[:;]\s*\Z/
            ) &&
            child_text =~ /\n\n\*/

            # Only taking the first paragraph of the definition
            child_text = first_child
          end

          # TEMP: Remove any whitespace (" ", not newlines) after an immediate
          # newline due to:
          # https://github.com/metanorma/iso-10303-2/issues/71
          if child_text =~ /\n\ +/
            child_text = child_text.gsub(/\n\ +/, "\n")
          end

          # # Only taking the first sentence
          # if child_text.contains?(".")
          #   child_text = child_text.split(".").first
          # end

          domain =  case linkend.first
                    when /_mim$/, /_arm$/
                      "module"
                    # when /_schema$/
                    else
                      "resource"
                    end

          schema = state[:exp_repo].schemas.first
          # entities = schema.entities.map do |entity|
          #   if entity.subtype_of.size.zero?

          # end
          entity = schema.entities.select { |e| e.id == linkend.last }.first
          entity_text = extract_entity_text(entity, linkend.last)

          <<~TEMPLATE
            === #{linkend.last}

            #{domain ? "domain:[#{domain}: #{schema.id}]" : ''}

            #{entity_text}

            NOTE: #{child_text}
          TEMPLATE
        end

        private

        def extract_entity_text(entity, entity_name)
          if entity.nil?
            "entity data type that represents a/an #{entity_name} entity"
          elsif entity.subtype_of.size.zero?
            "entity data type that represents a/an #{entity.id} entity"
          elsif entity.subtype_of.size == 1
            "entity data type that is a type of #{entity.subtype_of[0].id} that represents a/an #{entity.id} entity"
          else
            "entity data type that is a type of #{entity.subtype_of.map(&:id).join(' and ')} that represents a/an #{entity.id} entity"
          end
        end
      end

      ReverseAdoc::Converters.register :ext_description,
                                       StepmodExtDescription.new
    end
  end
end
