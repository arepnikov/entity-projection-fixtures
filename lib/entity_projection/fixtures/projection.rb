module EntityProjection
  module Fixtures
    class Projection
      include TestBench::Fixture
      include Initializer

      initializer :projection, :control_entity, :entity, :event

      def self.build(projection, entity, event)
        control_entity = entity.dup
        new(projection, control_entity, entity, event)
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


        end
      end

      def assert_attributes_copied(attribute_names, ignore_class: nil)
        ignore_class ||= true

        fixture(
          Schema::Fixtures::Equality,
          event,
          entity,
          attribute_names,
          ignore_class: ignore_class
        )
      end


    end
  end
end
