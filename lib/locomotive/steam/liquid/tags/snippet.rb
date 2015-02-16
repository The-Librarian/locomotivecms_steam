module Locomotive
  module Steam
    module Liquid
      module Tags

        class Snippet < ::Liquid::Include

          def parse(tokens)
            if listener = options[:events_listener]
              listener.emit(:include, page: options[:page], name: @template_name)

              # look for editable elements
              name = evaluate_snippet_name
              if snippet = options[:snippet_finder].find(name)
                options[:parser]._parse(snippet, options.merge(snippet: name))
              end
            end
          end

          def render(context)
            @template_name = evaluate_snippet_name(context)
            super
          end

          private

          def read_template_from_file_system(context)
            service = context.registers[:services]
            snippet = service.snippet_finder.find(@template_name)

            raise SnippetNotFound.new("Snippet with slug '#{@template_name}' was not found") if snippet.nil?

            snippet.liquid_source
          end

          def evaluate_snippet_name(context = nil)
            context.try(:evaluate, @template_name) ||
            @template_name.send(:state).first
          end

        end

        ::Liquid::Template.register_tag('include'.freeze, Snippet)
      end
    end
  end
end
