module EntityProjection
  module Fixtures
    class Projection
      include TestBench::Fixture
      include Initializer

      initializer :projection, :control_entity, :entity, :event, :action

      def self.build(projection, entity, event, &action)
        control_entity = entity.dup
        new(projection, control_entity, entity, event, action)
      end

      def call
        projection_type = projection.name.split('::').last
        entity_type = entity.class.name.split('::').last
        event_type = event.message_type

        detail "Projection Class: #{projection.name}"

        context "Apply #{event.message_type} to #{entity.class.type}" do

          detail "Entity Class: #{entity.class.name}"
          detail "Event Class: #{event.class.name}"

          projection.(entity, event)

          if not action.nil?
            action.call(self)
          end
        end
      end

      def assert_attributes_copied(attribute_names=nil, ignore_class: nil)
        ignore_class ||= true

        fixture(
          Schema::Fixtures::Equality,
          event,
          entity,
          attribute_names,
          ignore_class: ignore_class
        )
      end

      def assert_time_converted_and_copied(event_time_attribute, entity_time_attribute=nil)
        entity_time_attribute ||= event_time_attribute

        event_time = event.public_send(event_time_attribute)
        enity_time = entity.public_send(entity_time_attribute)

        context "Time converted and copied" do
          detail "Event Time: #{event_time}"
          detail "Entity Time: #{enity_time.strftime('%Y-%m-%d %I:%M:%S.%L %Z')}"

          printed_attribute_name = self.class.printed_attribute_name(event_time_attribute, entity_time_attribute)

          test printed_attribute_name do
            assert(enity_time == Time.parse(event_time))
          end
        end
      end

      def self.printed_attribute_name(control_name, compare_name)
        if control_name == compare_name
          return control_name.to_s
        else
          return "#{control_name} => #{compare_name}"
        end
      end
    end
  end
end
